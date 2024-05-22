#!/usr/bin/env python

import argparse
import json
import math
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
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
    parser.add_argument("--max-title-length", default=20, type=int)
    args = parser.parse_args()

    res = subprocess.check_output(
        [
            "khal",
            "list",
            "now",
            "24h",
            "--day-format",
            "",
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
            "--json=status",
        ],
        encoding="utf-8",
        universal_newlines=True,
    )
    raw_events = []
    for line in res.splitlines():
        raw_events += json.loads(line)

    now = datetime.now()
    raw_events = list(filter(lambda e: e["all-day"] in [False, "False"], raw_events))
    raw_events = list(
        filter(lambda e: e["status"].lower() not in "cancelled", raw_events)
    )

    events = []
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
        if len(title) > args.max_title_length:
            title = title[0 : max(args.max_title_length - 3, 0)] + "..."

        delta = e.until_end if e.togo else e.until_start
        if delta > 60:
            delta_fmt = "{0:>2.0f}h {0:>2.0f} min".format(int(delta / 60), delta % 60)
        else:
            delta_fmt = "{0:>2.0f} min".format(delta)

        estim = ("still {}" if e.togo else "in {}").format(delta_fmt)

        if short:
            return "󰃰  {0} ({1}) | {2}".format(
                e.raw["start-time-full"],
                estim,
                title,
            )
        else:
            return "󰃰  {0} ↦ {1} ({2}) | {3}".format(
                e.raw["start-time-full"],
                e.raw["end-time-full"],
                estim,
                title,
            )

    if len(events) == 0:
        debug("No meetings")
        print(json.dumps({"text": "󰃯 No upcoming meeting", "class": "none"}))
    else:
        meetings = "\n".join([format_event(e) for e in events])
        e_soon = events[0]

        if e_soon.togo:
            cls = "togo"
        else:
            if e_soon.until_start > 20:
                cls = "soon"
            elif e_soon.until_start > 10:
                # 20-10min before.
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


if __name__ == "__main__":
    main()
