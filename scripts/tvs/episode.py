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

import datetime
import lxml.etree as etree


class NotAnEtreeElement(Exception):
    def __init__(self, msg):
        Exception.__init__(self, msg)
        self.args = (msg,)

    def __repr__(self):
        return self.args[0]

    __str__ = __repr__



class Episode(object):
    def __init__(self, episode):
        if not isinstance(episode, etree._Element):
            raise NotAnEtreeElement('Given argument is not an etree element.')

        self.details = {}
        self.details['seasonno'] = int(episode.getparent().attrib['no'])
        for detail in episode.getchildren():
            # Very misleasing. Seasonnum actually means episode number within current season.
            if detail.tag in ('epnum', 'seasonnum'):
                self.details[detail.tag] = int(detail.text)
                continue
            elif detail.tag in ('airdate'):
                try:
                    self.details[detail.tag] = datetime.datetime.strptime(detail.text, '%Y-%m-%d').date()
                    continue
                except:
                    self.details[detail.tag] = None

            # The rest, basicaly all strings
            else:
                self.details[detail.tag] = detail.text

            # Adding ident: 01x10
            self.details['ident'] = '%02dx%02d' % (self.details['seasonno'], self.details['seasonnum'])

    def __getitem__(self, key):
        return self.details.get(key, None)

    def items(self):
        return self.details.items()


class SpecialEpisode(Episode):
    def __init__(self, episode):
        if not isinstance(episode, etree._Element):
            raise NotAnEtreeElement('Given argument is not an etree element.')

        self.details = {}
        for detail in episode.getchildren():
            if detail.tag in ('season'):
                self.details[detail.tag] = int(detail.text)
                continue
            elif detail.tag in ('airdate'):
                try:
                    self.details[detail.tag] = datetime.datetime.strptime(detail.text, '%Y-%m-%d').date()
                    continue
                except:
                    self.details[detail.tag] = None

            else:
                self.details[detail.tag] = detail.text

            # Adding ident: S01x11
            self.details['ident'] = '%02dxSE' % (self.details['season'])
            # Special episodes does not have epnum which --verbose needs. Set it to something.
            self.details['epnum'] = 'Spec'
