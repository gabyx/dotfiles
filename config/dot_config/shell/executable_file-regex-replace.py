#!/usr/bin/env python

import argparse
import functools
import os
import re
import subprocess
from multiprocessing import Pool
from typing import Optional
import os.path as path

def replace(file, regexes: list[str], force: bool = False) -> list[str]:
    cmd = ["perl", "-i", "-0777pe", ";".join(regexes), file]

    if force:
        subprocess.check_call(cmd)
        # 0777: reads the file into ram (changes file spereator http://stackoverflow.com/questions/16742526/how-to-search-and-replace-across-multiple-lines-with-perl)
        # with this we can match/replace also multiple lines wit /s modifier as "s@.*@Gaga@s"
        # p: reads line by line
        # e: command execution

    return cmd


def replace_files(
    dir: str,
    regex: list[str],
    incs: Optional[list[str]],
    excs: list[str] = [],
    force: bool = False,
    verbose: bool = True,
):
    includes = None
    if incs:
        includes = [re.compile(r) for r in incs]

    excludes: list[re.Pattern] = [re.compile(r) for r in excs]

    def is_included(f: str):
        return (any(r.match(f) for r in includes) if includes else True) and not any(
            r.match(f) for r in excludes
        )

    files: list[str] = []
    for d, _, fs in os.walk(dir):
        files += list(filter(is_included, [path.join(d, f) for f in fs]))

    if not force:
        print(f"Dry-run: replacing in '{len(files)}' files.")
        if verbose:
            msg = "\n".join([f" - '{f}'" for f in files])
            print(f"Files:\n{msg}")
    else:
        print(f"Replacing in '{len(files)}' files.")

    def exec(force: bool) -> list[str]:
        func = functools.partial(replace, regexes=regex, force=force)
        return Pool().map(func, files)  # type: ignore

    if verbose:
        cmds = exec(False)
        msg = "\n".join([f" - {c}" for c in [f"'{c}'" for c in cmds]])
        if not force:
            print(f"Dry-run: would executed:\n{msg}")
        else:
            print(f"Executing:\n{msg}")

    if force:
        exec(True)


def main():
    parser = argparse.ArgumentParser(
        prog="file-regex-replace", description="Replaces regexes in files."
    )

    parser.add_argument(
        "-r",
        "--regex",
        action="append",
        required=True,
        help="Perl regex to replace.",
    )
    parser.add_argument(
        "-e",
        "--exclude",
        default=[],
        action="append",
        help="Exclude path regex for files.",
    )
    parser.add_argument(
        "-i",
        "--include",
        default=None,
        action="append",
        help="Include path regex for files.",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Force the replacements, no dry-run.",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Verbose printing.",
    )
    parser.add_argument(
        "dir",
        help="Directory to search for files.",
    )

    args = parser.parse_args()
    replace_files(
        dir=args.dir,
        incs=args.include,
        excs=args.exclude,
        force=args.force,
        regex=args.regex,
    )


if __name__ == "__main__":
    main()
