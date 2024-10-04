#!/usr/bin/env python

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
from html import escape
from itertools import chain
from typing import Dict

DATE_FORMAT = "%d/%m/%Y"
DATETIME_FORMAT = f"{DATE_FORMAT} %H:%M"


def debug(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)


@dataclass
class Event:
    start: datetime
    end: datetime
    duration: timedelta
    until_start: float
    until_end: float
    togo: bool

    raw: Dict[str, str]


def main():

    parser = argparse.ArgumentParser(
        prog="Waybar meeting notification over khal",
        description="Reads khal output and update the status bar.",
    )
    parser.add_argument(
        "--config",
        default=None,
        help="Config file to read.",
    )

    parser.add_argument(
        "--open-url",
        action="store_true",
        help="Open the Meeting URL if found on the soonest meeting.",
    )
    args = parser.parse_args()

    included_calendars = []
    max_title_length = 20

    if args.config:
        with open(args.config) as f:
            config = json.load(f)

        if config["calendars"]:
            included_calendars: list[str] = list(
                chain(*[["--include-calendar", c] for c in config["calendars"]])
            )

        max_title_length = config.get("max_title_length", max_title_length)

    res = subprocess.check_output(
        [
            "khal",
            "list",
            "now",
            "24h",
            "--day-format",
            "",
            *included_calendars,
            "--json=start-date-full",
            "--json=end-date-full",
            "--json=start-time-full",
            "--json=end-time-full",
            "--json=title",
            "--json=url",
            "--json=all-day",
            "--json=calendar-color",
            "--json=repeat-pattern",
            "--json=description",
            "--json=location",
            "--json=status",
        ],
        encoding="utf-8",
        universal_newlines=True,
    )
    raw_events = []
    for line in res.splitlines():
        raw_events += json.loads(line)

    now = datetime.now()
    debug(f"Date now: {now}")

    raw_events = list(filter(lambda e: e["all-day"] in [False, "False"], raw_events))
    raw_events = list(
        filter(lambda e: e["status"].lower() not in "cancelled", raw_events)
    )

    events: list[Event] = []
    for e in raw_events:

        start = datetime.strptime(
            "{0} {1}".format(e["start-date-full"], e["start-time-full"]),
            DATETIME_FORMAT,
        )

        end = datetime.strptime(
            "{0} {1}".format(e["end-date-full"], e["end-time-full"]),
            DATETIME_FORMAT,
        )

        events.append(
            Event(
                start=start,
                end=end,
                until_start=(start - now).total_seconds() / 60,
                until_end=(end - now).total_seconds() / 60,
                duration=end - start,
                togo=now >= start and now <= end,
                raw=e,
            )
        )

    events = sorted(events, key=lambda e: (e.start, e.duration))
    debug(events)

    def format_event(e, short=False):
        title = e.raw["title"]
        if len(title) > max_title_length:
            title = title[0 : max(max_title_length - 3, 0)] + "..."

        delta = e.until_end if e.togo else e.until_start

        if delta > 60:
            delta_h = int(delta / 60.0)
            delta_m = delta % 60.0
            delta_fmt = "{0:>2.0f}h {1:>2.0f} min".format(delta_h, delta_m)
        else:
            delta_fmt = "{0:>2.0f} min".format(delta)

        estim = ("still {}" if e.togo else "in {}").format(delta_fmt)

        if short:
            return "󰃰  {0} ({1}) | {2}".format(
                e.raw["start-time-full"],
                estim,
                escape(title),
            )
        else:
            return "󰃰  {0} ↦ {1} ({2}) | {3}".format(
                e.raw["start-time-full"],
                e.raw["end-time-full"],
                estim,
                escape(title),
            )

    if len(events) == 0:
        debug("No meetings")
        print(json.dumps({"text": "󰃯 No upcoming meeting", "class": "none"}))
    else:
        meetings = "\n".join([format_event(e) for e in events])
        e_soon = events[0]

        if args.open_url:
            url = find_url(e_soon)
            if url is not None:
                open_url(url)
                return

        if e_soon.togo:
            cls = "togo"
        else:
            if e_soon.until_start > 10:
                cls = "soon"
            elif e_soon.until_start > 5:
                # 10-5min before.
                cls = "soon-urgent"
            else:
                cls = "soon-critical"

        debug(meetings)
        print(
            json.dumps(
                {
                    "text": f"{format_event(e_soon, short=True)}",
                    "class": cls,
                    "tooltip": meetings,
                }
            )
        )


# Find the meeting URL for the event.
def find_url(event: Event) -> str | None:
    zoom_re = re.compile(r"\(?https://.*\.zoom\..*\)?")
    google_re = re.compile(r"\(?https://meet\.google.*\)?")

    def match(line):
        for w in line.split(" "):
            if zoom_re.match(w) is not None or google_re.match(w) is not None:
                return w
        return None

    for key in ["description", "location"]:
        if key not in event.raw:
            continue

        desc = event.raw[key].splitlines()
        for l in desc:
            m = match(l)
            if m is not None:
                return m

    raise RuntimeError(f"Did not find any URL in event.")


# Open a URL in the browser.
def open_url(url: str):
    try:
        subprocess.check_call(["notify-send", "Opening URL in browser.", f"URL: {url}"])
    except:
        pass

    subprocess.check_call(["xdg-open", url])


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        subprocess.check_call(
            ["notify-send", "--category", "warning", "Exception happened.", f"{e}"]
        )
