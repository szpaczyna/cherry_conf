#!/usr/bin/env python
#-*- coding: utf8 -*-

# Copyright 2009-2012 Kamil Winczek <kwinczek@gmail.com>
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

import sys
import cterm
import datetime


# --------------------------------------------------------------------- #
#                                                                       #
#  Class Formatter                                                      #
#                                                                       #
# --------------------------------------------------------------------- #

class Formatter(object):
    def __init__(self, show, options, dateFormat=None):
        """Creates simple formating map - based on show.details information."""
        self.show = show
        self.options = options
        self.dateFormat=dateFormat
        self.map = {}

        for (key, value) in self.show.details.items():
            if value == None:
                value = 'Unknown'
            self.map[self.show_detail_to_key(key)] = value

        if self.options.when:
            self.map['when_day'] = str(options.when).capitalize()

        if options.verbose:
            self.map['totalepisodes'] = len(show.episodes)
            self.map['akas'] = '\n'.join(['\t    %s: %s' % (item.items()[0]) for item in self.map['akas']])
            self.map['genres'] = ', '.join(self.map['genres'])


        # Color translations
        for (key, value) in self.color().items():
           self.map[key] = value

        # Debug
        if self.options.debug:
            self.debug_format_elements('Main elements', self.map)


    def color(self):
        """Return dict with colors translations, depends on options.nocolor
        Then will return translations to empty strings"""
        printer = cterm.Printer()

        # Reset them to empty strings if --no-color was given
        if self.options.nocolor:
            for key in printer.cmap.keys():
                printer.cmap[key] = ''

        return printer.cmap


    def format(self, template, season_no=None, episode=None):
        """Returns formated string."""
        map = {}
        map.update(self.map)

        if self.options.season or self.options.episode:
            for (key, value) in episode.items():
                map[self.episode_detail_to_key(key)] = value

        # Date formatting
        # Changing datetime.date objects according to users preferences
        for i in ('prev_ep_airdate', 'next_ep_airdate', 'ep_airdate'):
            # In try-except block due to various situations, that means
            # we not always have got all the details available.
            try:
                # If airdate == Unaired that means we do not know date yet and we did put 
                # Unaired string into airdate. We cannot format such a thing, skipping
                if map[i] == 'Unaired': continue

                # Formatting
                map[i] = map[i].strftime(self.dateFormat)
            except:
                pass
                #raise 

        # Debug
        if self.options.debug:
            self.debug_format_elements('Extended elements', map)

        try:
            return template % map
        except:
            if self.options.debug:
                raise
            sys.stderr.write('Error: Template Failure. Please fix your templates or use default.\nError in: %s\n' % template)
            sys.exit(4)


    def format_simple(self, template):
        try:
            return template % self.map
        except:
            if self.options.debug:
                raise
            sys.stderr.write('Error: Template Failure. Please fix your templates or use default.\nError in: %s\n' % template)
            sys.exit(4)


    def show_detail_to_key(self, detail):
        return detail.lower().replace(' ', '_')

    def episode_detail_to_key(self, detail):
        return 'ep_' + detail.lower().replace(' ', '_')

    def add_prev_next(self, prev, next):
        for (key, value) in prev.items():
            self.map['prev_' + self.episode_detail_to_key(key)] = value

        if next:
            for (key, value) in next.items():
                self.map['next_' + self.episode_detail_to_key(key)] = value

    # Debug
    def debug_format_elements(self, header, map):
        print("")
        print('+'+'-'*9, header, '-'*10)
        if header.startswith('Main'):
            for k, v in map.items():
                print('| %-22.22s: %s' % (k, v))
        elif header.startswith('Extended'):
            for k, v in map.items():
                if not k in self.map:
                    print('| %-22.22s: %s' % (k, v))
        print('+'+'-'*(21+len(header)))
        print("")
