#!/usr/bin/env python
# Sourced from: http://blog.tplus1.com/index.php/2009/07/08/python-contextmanagers-subprocesses-and-an-ascii-spinner/
import sys, time

def draw_ascii_spinner(delay=0.1):
    for char in "/-\|\-": # there should be a backslash in here.
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(delay)
        sys.stdout.write('\b') # this should be backslash r.

while "forever":
    draw_ascii_spinner()
