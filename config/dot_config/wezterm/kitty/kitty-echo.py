#!/usr/bin/env python3

"""
Program to Show what codes are sent by key presses using the kitty protocol
The flags for progressive-enhancement can be passed as an integer argument (hex is allowed).
Defaults to 1
"""

import sys
import termios
import tty

if len(sys.argv) >= 2:
    # get the mode to use from the first argument
    if sys.argv[1] == "n":
        flags = None
    else:
        flags = int(sys.argv[1], 0)
else:
    flags = 1

buffer = bytearray(1)


def encoded(b):
    "Encode a byte as printable text"
    if 32 <= b < 127 or b == 0x0A:
        return chr(b)
    elif b == 0x1B:
        return "\\e"
    else:
        return "\\{:02x}".format(b)


def echo_next():
    "Read the next byte from input, and print a representation of it to stdout"
    if sys.stdin.buffer.readinto(buffer) != 1:
        raise EOFError()
    fwrite(encoded(buffer[0]))
    if buffer == b"Q":
        raise EOFError()


def fwrite(s):
    "Write some output to stdout and flush"
    print(s, end="", flush=True)


old_attrs = tty.setcbreak(sys.stdin)
try:
    # Tell the terminal to use kitty protocol
    # TODO: support using other modes?
    if flags is not None:
        fwrite(f"\x1B[>{flags}u")
    while True:
        # TODO: terminate somehow
        echo_next()
except EOFError:
    pass
finally:
    termios.tcsetattr(sys.stdin, termios.TCSAFLUSH, old_attrs)
    if flags is not None:
        print("\x1B[<u", flush=True)
