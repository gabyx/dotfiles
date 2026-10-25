package waybarcmd

import (
	"cmp"
	"encoding/json"
	"fmt"
	"html"
	"math"
	"net/url"
	"os"
	"regexp"
	"slices"
	"strings"
	"time"

	gexec "gabyx-cli/pkg/exec"

	"github.com/gabyx/quitsh/pkg/errors"
	"github.com/gabyx/quitsh/pkg/exec"
	"github.com/gabyx/quitsh/pkg/log"
	"github.com/spf13/cobra"
)

const (
	// Date and time format of `khal` (`start-date-full`, `start-time-full`).
	khalDateTimeFormat = "02/01/2006 15:04"

	defaultMaxTitleLength = 20

	minutesPerHour = 60.0

	iconNoMeeting = "\U000F00EF"
	iconMeeting   = "\U000F00F0"

	// Keys of a `khal` event which are searched for the meeting URL.
	keyLocation    = "location"
	keyDescription = "description"
)

type nextMeetingArgs struct {
	config  string
	openURL bool
}

type nextMeetingConfig struct {
	Calendars      []string `json:"calendars"`
	MaxTitleLength int      `json:"max_title_length"` //nolint:tagliatelle // Key in the existing config file.
}

type event struct {
	start      time.Time
	end        time.Time
	untilStart float64 // Minutes until the start.
	untilEnd   float64 // Minutes until the end.
	togo       bool    // The event is running.

	raw map[string]any
}

func addNextMeetingCmd(parent *cobra.Command) {
	var args nextMeetingArgs

	cmd := &cobra.Command{
		Use:   "next-meeting",
		Short: "Print the next meetings of the next 24h from 'khal' for Waybar.",
		Args:  cobra.NoArgs,
		RunE: func(_cmd *cobra.Command, _args []string) error {
			err := nextMeeting(&args)
			if err != nil {
				_ = exec.NewCommandCtx(".").
					Check(gexec.ExtCmdNotifySend, "--category", "warning", "Exception happened.", err.Error())
			}

			return err
		},
	}

	cmd.Flags().
		StringVar(&args.config, "config", "", "Config file to read (keys: 'calendars', 'max_title_length').")
	cmd.Flags().
		BoolVar(&args.openURL, "open-url", false, "Open the meeting URL of the next meeting.")

	parent.AddCommand(cmd)
}

func nextMeeting(args *nextMeetingArgs) error {
	conf := nextMeetingConfig{Calendars: nil, MaxTitleLength: defaultMaxTitleLength}

	if args.config != "" {
		content, err := os.ReadFile(args.config)
		if err != nil {
			return err
		}

		err = json.Unmarshal(content, &conf)
		if err != nil {
			return errors.AddContext(err, "could not read config '%s'", args.config)
		}
	}

	now := time.Now()
	log.Debug("Date now.", "now", now)

	events, err := khalEvents(conf.Calendars, now)
	if err != nil {
		return err
	}

	if len(events) == 0 {
		log.Debug("No meetings.")
		o := output{
			Text:       iconNoMeeting + " No upcoming meeting",
			Alt:        "",
			Tooltip:    "",
			Class:      valueNone,
			Percentage: 0}

		return o.print()
	}

	next := events[0]

	if args.openURL {
		u, e := findMeetingURL(next.raw)
		if e != nil {
			return e
		}

		return openURL(u)
	}

	lines := make([]string, 0, len(events))
	for i := range events {
		lines = append(lines, formatEvent(&events[i], conf.MaxTitleLength, false))
	}

	o := output{
		Text:       formatEvent(&next, conf.MaxTitleLength, true),
		Alt:        "",
		Tooltip:    strings.Join(lines, "\n"),
		Class:      eventClass(&next),
		Percentage: 0,
	}

	return o.print()
}

// khalEvents returns the events of the next 24h which are not all-day and
// not cancelled, sorted by start and duration.
func khalEvents(calendars []string, now time.Time) ([]event, error) {
	args := []string{gexec.ExtCmdKhal, "list", "now", "24h", "--day-format", ""}
	for _, c := range calendars {
		args = append(args, "--include-calendar", c)
	}

	for _, f := range []string{
		"start-date-full", "end-date-full", "start-time-full", "end-time-full",
		"title", "url", "all-day", "calendar-color", "repeat-pattern",
		keyDescription, keyLocation, "status",
	} {
		args = append(args, "--json="+f)
	}

	lines, err := exec.NewCommandCtx(".").GetSplit(args...)
	if err != nil {
		return nil, err
	}

	return parseKhalEvents(lines, now)
}

// parseKhalEvents parses the `khal list --json` output `lines` (one JSON array per line).
func parseKhalEvents(lines []string, now time.Time) ([]event, error) {
	var events []event

	for _, l := range lines {
		if strings.TrimSpace(l) == "" {
			continue
		}

		var raws []map[string]any

		err := json.Unmarshal([]byte(l), &raws)
		if err != nil {
			return nil, errors.AddContext(err, "could not parse 'khal' output line '%s'", l)
		}

		for _, raw := range raws {
			if isAllDay(raw) || strings.EqualFold(field(raw, "status"), "cancelled") {
				continue
			}

			ev, e := newEvent(raw, now)
			if e != nil {
				return nil, e
			}

			events = append(events, ev)
		}
	}

	slices.SortStableFunc(events, func(a, b event) int {
		return cmp.Or(a.start.Compare(b.start), cmp.Compare(a.end.Sub(a.start), b.end.Sub(b.start)))
	})

	return events, nil
}

func newEvent(raw map[string]any, now time.Time) (event, error) {
	start, err := time.ParseInLocation(khalDateTimeFormat,
		field(raw, "start-date-full")+" "+field(raw, "start-time-full"), time.Local)
	if err != nil {
		return event{}, errors.AddContext(
			err,
			"could not parse start of event '%s'",
			field(raw, "title"),
		)
	}

	end, err := time.ParseInLocation(khalDateTimeFormat,
		field(raw, "end-date-full")+" "+field(raw, "end-time-full"), time.Local)
	if err != nil {
		return event{}, errors.AddContext(
			err,
			"could not parse end of event '%s'",
			field(raw, "title"),
		)
	}

	return event{
		start:      start,
		end:        end,
		untilStart: start.Sub(now).Minutes(),
		untilEnd:   end.Sub(now).Minutes(),
		togo:       !now.Before(start) && !now.After(end),
		raw:        raw,
	}, nil
}

// field returns the value of `key` in the `khal` event `raw` as string.
func field(raw map[string]any, key string) string {
	switch v := raw[key].(type) {
	case nil:
		return ""
	case string:
		return v
	default:
		return fmt.Sprint(v)
	}
}

// isAllDay returns `true` if the event is an all-day event.
// `khal` reports `all-day` as boolean or as string.
func isAllDay(raw map[string]any) bool {
	v := field(raw, "all-day")

	return v != "false" && v != "False"
}

func formatEvent(e *event, maxTitleLength int, short bool) string {
	title := []rune(field(e.raw, "title"))
	if len(title) > maxTitleLength {
		ellipsis := []rune("...")
		title = append(title[:max(maxTitleLength-len(ellipsis), 0)], ellipsis...)
	}

	delta := e.untilStart
	if e.togo {
		delta = e.untilEnd
	}

	var deltaFmt string
	if delta > minutesPerHour {
		deltaFmt = fmt.Sprintf(
			"%2.0fh %2.0f min",
			math.Trunc(delta/minutesPerHour),
			math.Mod(delta, minutesPerHour),
		)
	} else {
		deltaFmt = fmt.Sprintf("%2.0f min", delta)
	}

	estimate := "in " + deltaFmt
	if e.togo {
		estimate = "still " + deltaFmt
	}

	if short {
		return fmt.Sprintf(
			"%s  %s (%s) | %s",
			iconMeeting,
			field(e.raw, "start-time-full"),
			estimate,
			html.EscapeString(string(title)),
		)
	}

	return fmt.Sprintf("%s  %s ↦ %s (%s) | %s",
		iconMeeting, field(e.raw, "start-time-full"), field(e.raw, "end-time-full"),
		estimate, html.EscapeString(string(title)))
}

// eventClass returns the CSS class for the next event `e`.
func eventClass(e *event) string {
	switch {
	case e.togo:
		return "togo"
	case e.untilStart > 10: //nolint:mnd // Minutes before the start.
		return "soon"
	case e.untilStart > 5: //nolint:mnd // Minutes before the start.
		return "soon-urgent"
	default:
		return "soon-critical"
	}
}

func meetingURLRegexes() []*regexp.Regexp {
	return []*regexp.Regexp{
		regexp.MustCompile(`^.*\(?(https://.*\.zoom\.[a-z]+/j/[^\s\)]+)\)?`),
		regexp.MustCompile(`^.*\(?(https://meet\.google\.[^\s\)]+)\)?`),
		regexp.MustCompile(`^.*<?(https://teams\.microsoft\.com.*-join[^\s>]+)>?`),
	}
}

// findMeetingURL returns the first Zoom, Google Meet or Teams URL
// in the location or the description of the event `raw`.
func findMeetingURL(raw map[string]any) (string, error) {
	regexes := meetingURLRegexes()

	for _, key := range []string{keyLocation, keyDescription} {
		log.Debug("Check for meeting URL.", "key", key)

		for line := range strings.Lines(field(raw, key)) {
			for w := range strings.SplitSeq(strings.TrimRight(line, "\r\n"), " ") {
				for _, re := range regexes {
					if m := re.FindStringSubmatch(w); m != nil {
						return m[1], nil
					}
				}
			}
		}
	}

	return "", errors.New("did not find any meeting URL in event '%s'", field(raw, "title"))
}

// openURL opens the URL `u` in the browser.
func openURL(u string) error {
	p, err := url.Parse(u)
	if err != nil || p.Scheme == "" || p.Host == "" {
		return errors.New("URL '%s' cannot be parsed", u)
	}

	_ = exec.NewCommandCtx(".").Check(gexec.ExtCmdNotifySend, "Opening URL in browser.", "URL: "+u)

	return exec.NewCommandCtx(".").Check(gexec.ExtCmdXdgOpen, u)
}
