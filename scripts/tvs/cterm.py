#!/usr/bin/env python
#-*- coding: utf8 -*-

# Copyright 2009-2010 Daniel 'Beorn' Mróz <beorn@cyberdeck.pl>
# and crs <crs@wafel.com>
#
# This file is part of series.py.
#
# series.py is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# series.py is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with series.py. If not, see http://www.gnu.org/licenses/.

import curses
import os
import sys


class MonoPrinter(object):
    """ Base class wich also serves as Monochromatic Printer class """
    def __init__(self):
        self.disable()

    def disable(self):
        self.cmap = {}
        self.cmap['c_grey']   = ''
        self.cmap['c_red']    = ''
        self.cmap['c_green']  = ''
        self.cmap['c_yellow'] = ''
        self.cmap['c_blue']   = ''
        self.cmap['c_purple'] = ''
        self.cmap['c_cyan']   = ''
        self.cmap['c_none']   = ''

    def enable(self):
        pass


class ColorPrinter(MonoPrinter):
    """ Color Printer class """
    def __init__(self):
        MonoPrinter.__init__(self)
        self.enable()


    def enable(self):
        self.cmap['c_grey']   = curses.tparm(curses.tigetstr('setaf'), 0)
        self.cmap['c_red']    = curses.tparm(curses.tigetstr('setaf'), 1)
        self.cmap['c_green']  = curses.tparm(curses.tigetstr('setaf'), 2)
        self.cmap['c_yellow'] = curses.tparm(curses.tigetstr('setaf'), 3)
        self.cmap['c_blue']   = curses.tparm(curses.tigetstr('setaf'), 4)
        self.cmap['c_purple'] = curses.tparm(curses.tigetstr('setaf'), 5)
        self.cmap['c_cyan']   = curses.tparm(curses.tigetstr('setaf'), 6)
        self.cmap['c_none']   = curses.tigetstr('sgr0')


if not os.isatty(sys.stdout.fileno()) or not os.isatty(sys.stderr.fileno()):
    # We are not connected to a terminal (i.e. stdout or stderr is
    # redirected to a file), so it is better to not use colored
    # output at all.
    Printer = MonoPrinter
else:
    try:
        curses.setupterm()
    except:
        # Some weird terminal. Colors are disabled, since they can
        # really mess up entire console.
        Printer = MonoPrinter
    else:
        Printer = ColorPrinter
