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
import re
import sys
import lxml.etree as etree

import tvs.episode as episode


class Show(object):
    def __init__(self, feed, options):
        self.options = options
        if self.options.debug:
            print('@@ Class Show()')
        self.feed = feed
        self.details = {}
        self.episodes = []
        self.specials = []

        self.__parse()
        del self.feed


    def __getitem__(self, key):
        return self.details.get(key, None)


    def __parse(self):
        if self.options.debug:
            print('@ __parse()')

        # Some shows might have no all required fields, let's create an empty one so tvseries won't crash.
        # It will be overwritten later on if found.
        self.details['akas'] = []
        self.details['airday'] = "(Week Day Unknown)"

        for element in self.feed.getchildren():
            # Elements which are integers objects
            if element.tag in ('totalseasons', 'runtime'):
                self.details[element.tag] = int(element.text)
                continue

            # Elements which are datetime objects.
            elif element.tag in ('started', 'ended'):
                try:
                    if element.text:
                        d = datetime.datetime.strptime(detail.test, '%b/%d/%Y')
                        data[detail.tag] = datetime.date(d.year, d.month, d.day)
                except:
                    self.details[element.tag] = None
                continue

            elif element.tag in ('airtime', 'timezone'):
                # I believe datetime should be used here!
                self.details[element.tag] = element.text
                continue

            # Genres.
            elif element.tag in ('genres'):
                self.details[element.tag] = []
                for genre in element:
                    self.details[element.tag].append(genre.text)
                continue

            # Parse akas, books...
            elif element.tag == 'akas':
                self.details['books'] = []
                for aka in element:
                    # AKAS
                    if aka.attrib.get('country'):
                        # If there is: <aka attr="(Catalan Title)" country="XX">
                        if aka.attrib.get('attr') == '(Catalan Title)':
                            self.details[element.tag].append({aka.attrib.get('country'): '%s (Catalan Title)' % aka.text})
                            continue
                        # And then for the rest.
                        self.details[element.tag].append({aka.attrib.get('country'): aka.text})
                        continue
                    # Books
                    elif aka.attrib.get('attr') == 'Book':
                        self.details['books'].append(aka.text)
                continue

            # Parse episodes.
            elif element.tag == 'Episodelist':
                # Regular episodes.
                for episode_el in element.xpath('//Season/episode'):
                    # Add episode to the list
                    # Put together date, time and timezone of broadcast for each episode. 
                    self.episodes.append(self.evaluate_real_starttime(episode.Episode(episode_el)))

                # Special episodes.
                for episode_el in element.xpath('//Special/episode'):
                    # Add episode to the list.
                    self.specials.append(episode.SpecialEpisode(episode_el))

            # All remaining strings.
            else:
                self.details[element.tag] = element.text


        if self.options.debug: print('... Parsing finished.')


    def __get_specials(self, season=-1):
        if season == -1:
            return self.specials

        for special in self.specials:
            return [sp for sp in self.specials if sp['season'] == season]



    def get_episodes(self, season_no, specials):
        if season_no == -1:
            episodes = self.episodes

        # Lets change season number (if not given) to last/current season
        elif season_no == -2:
             season_no = max([ep['seasonno'] for ep in self.episodes])
             episodes = [ep for ep in self.episodes if ep['seasonno'] == season_no]

        elif season_no >= 1:
             episodes = [ep for ep in self.episodes if ep['seasonno'] == season_no]

        if specials:
            # Season might not have any specials.
            try:
                episodes = episodes + self.__get_specials(season_no)
            except:
                pass

        # Let's try to sort episodes by date (will not work if one episode has no date).
        try:
            episodes = sorted(episodes, key=lambda ep: ep['airdate'])
        except:
            pass

        return episodes


    def get_prev_next_episode(self):
        prev = None
        next = None
        sorted_valid_eps = sorted([ep for ep in self.episodes if ep['airdate'] is not None], key=lambda ep: ep['airdate'])

        # Previous episode.
        for episode in sorted_valid_eps:
            if episode['airdate'] <= datetime.datetime.now():
                prev = episode

        # Next episode.
        # Try to get one with closest date in the future.
        # Attempt #1.
        for episode in sorted_valid_eps:
            if episode['airdate'] >= datetime.datetime.now():
                next = episode
                break

        # If not found, try to get next by ident (last chance call).
        # Attempt #2.
        if not next:
            for episode in self.episodes:
                if episode['seasonno'] >= prev['seasonno'] and episode['seasonnum'] > prev['seasonnum']:
                    next = episode
                    break
                elif episode['seasonno'] > prev['seasonno']:
                    next = episode
                    break

        return (prev, next)


    def get_episodes_by_date(self, date):
        if self.options.with_specials:
            episodes = self.episodes + self.__get.specials()
        else:
            episodes = self.episodes

        return [ep for ep in episodes if ep['airdate'] == date]


    def evaluate_real_starttime(self, episode):
        try:
            year, month, day = episode['airdate'].year, episode['airdate'].month, episode['airdate'].day
            hour, minute = self.details['airtime'].split(':')
            time_deflection = int(re.match('GMT([+-][0-9]*)[ ]?', self.details['timezone']).groups()[0])

            episode.details['airdate'] = datetime.datetime(year, month, day, int(hour), int(minute)) - datetime.timedelta(hours=time_deflection)

            return episode
        except:
            episode.details['airdate'] = None
            return episode
