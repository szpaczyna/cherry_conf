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
import os
import re
import shelve
import sys

from optparse import OptionParser, OptionGroup


# --------------------------------------------------------------------- #
#                                                                       #
#  Configuration                                                        #
#                                                                       #
# --------------------------------------------------------------------- #

DEFAULT_CONFIG_DIR  = os.path.join(os.getenv('HOME'), '.tvseries')

DEFAULT_CONFIG_FILE = os.path.join(DEFAULT_CONFIG_DIR, 'config')
DEFAULT_CACHE_FILE  = os.path.join(DEFAULT_CONFIG_DIR, '.cache')
DEFAULT_CACHE_IDS  = os.path.join(DEFAULT_CONFIG_DIR, '.ids')

def opt_parse():
    """Define cmd line options"""
    usage = "TVRage.com parser by crs (http://winczek.com/tvseries/)\nusage: %prog [options] [title ...]"
    parser = OptionParser(usage, version="%prog 0.6.6" )

    group_a = OptionGroup(parser, "Actions")
    group_p = OptionGroup(parser, "Program control")
    group_f = OptionGroup(parser, "Files locations")


    group_a.add_option("-w", "--when", dest="when",
            help="Print series for given day only. Values: yesterday, today, tommorow or date in format: YYYY-DD-MM.")

    group_a.add_option("-s", "--season", dest="season", action="store", default=None,
            help="Print given season only. Values: <int>, '0' for current one; 'all' for all seasons.")

    group_a.add_option("-e", "--episode", dest="episode", action="store",
            help="Print given episode only. To be used with --season only. Values: <int>.")

    group_f.add_option("-f", "--config-file", dest="configfile",
                       default=DEFAULT_CONFIG_FILE,
                       help="Read config from CONFIGFILE.")

    group_f.add_option("-c", "--cache-file", dest="cachefile",
                       default=DEFAULT_CACHE_FILE,
                       help="Read cache from CACHEFILE.")

    group_f.add_option("-i", "--cache-ids", dest="cacheids",
                       default=DEFAULT_CACHE_IDS,
                       help="Read shows ids cache from CACHEIDS.")

    group_p.add_option("--with-specials", dest="with_specials", action="store_true", default=False,
                       help="Print special episodes as well as regular ones.")

    group_a.add_option("--calendar", dest="g_calendar", action="store_true", default=False,
                       help="Update google calendar with episodes broadcast information.")

    group_p.add_option("-m", "--no-color", dest="nocolor", action="store_true", default=False,
                       help="Use monochromatic display. Do not print colors.")

    group_p.add_option("-n", "--no-cache", action="store_false", default=True, dest="cache",
                       help="Do not use caching. ON by default.")

    group_p.add_option("-r", "--refresh", action="store_true", default=False, dest="refresh",
                       help="Force downloading and refreshing cache.")

    group_p.add_option("-v", "--verbose", default=False,
                       action="store_true", dest="verbose")

    group_p.add_option("-d", "--debug", default=False,
                       action="store_true", dest="debug")

    group_p.add_option("--no-spinner", action="store_false", default=True, dest="spinner",
                       help="Do not show spinner while performing network operations.")

    group_p.add_option("--print-settings", dest="print_settings_and_exit", action="store_true", default=False,
                       help="Print settings and exit.")

    parser.add_option_group(group_a)
    parser.add_option_group(group_p)
    parser.add_option_group(group_f)

    (options, args) = parser.parse_args()

    # Validate parameters:
    # --season
    if options.season:
        if options.season == 'all':
            options.season = -1
        elif options.season == '0':
                options.season = -2
        else:
            try:
                options.season = int(options.season)
            except:
                parser.error('Invalid season value')

        if options.season < -2 or options.season > 1000:
            parser.error("Season value not in range 0-1000")

    # No cache and refresh?
    if not options.cache and options.refresh:
        parser.error("--no-cache and --refresh cannot be used together.")


    # --episode
    if options.episode:
        if not options.season:
            parser.error("Please use -s <n> to specify season.")
        try:
            options.episode = int(options.episode)
        except:
            parser.error('Invalid episode value')

        if options.episode < 1 or options.episode > 1000:
            parser.error("Episode value not in range 1-1000")


    # --when
    if options.when:
        if options.when.lower() in ['yesterday', 'today', 'tomorrow']:
            when_map = {'yesterday': datetime.date.today() - datetime.timedelta(1),
                            'today': datetime.date.today(),
                         'tomorrow': datetime.date.today() + datetime.timedelta(1)}

            options.when = when_map[options.when.lower()]

        elif re.match('[0-9]{4}[-][0-9]{2}[-][0-9]{2}', options.when):
            options.when = datetime.datetime.strptime(options.when, '%Y-%m-%d').date()
        else:
            parser.error('--when - Invalid argument.\nTry: today, yesterday, tomorrow or date in format YYYY-MM-DD')


    # Checking for required files
    if not os.path.exists(DEFAULT_CONFIG_DIR):
        os.makedirs(DEFAULT_CONFIG_DIR)

    if not os.path.exists(options.configfile):
        open(options.configfile, 'w').close()

    if not os.path.exists(options.cachefile):
        shelve.open(options.cachefile).close()

    if not os.path.exists(options.cacheids):
        shelve.open(options.cacheids).close()

    return (options, args)


# ---------------------------------------------------------------------

def read_config_file(configfile):
    # Default configuration is stored here.
    series = []
    g_creds = {'login':'', 'passwd':''}
    templates = {'list_header_format': '[ %(c_blue)s%(name)s:%(c_red)s Season %(season_no)s%(c_none)s ]',
                 'list_format': '[%(ep_ident)s] %(ep_title)-25.24s @ %(ep_airdate)s',
                 'list_format_verbose': 'No: %(ep_epnum)04s  [%(ep_ident)s] %(ep_title)-25.24s @ %(ep_airdate)s\n\t\t%(ep_link)s',
                 'when_day_format': '.. %(when_day)s ..',
                 'when_name_format': '[ %(c_blue)s%(name)s%(c_none)s ]',
                 'when_format': '%(ep_airdate)s [%(ep_ident)s] %(ep_title)s',
                 'single_header_format': '',
                 'single_format': '%(name)s [%(ep_ident)s] %(ep_title)s.avi',
                 'info_header_format': '[ %(c_blue)s%(name)s%(c_none)s ]',
                 'info_verbose_format':
"""   Country: %(origin_country)s
   Network: %(network)s
   Airtime: %(airday)s at %(airtime)s [%(timezone)s]
   Runtime: %(runtime)s mins
     Class: %(classification)s
   Started: %(started)s
    Status: %(status)s
    Genres: %(genres)s
   Seasons: %(totalseasons)s
  Episodes: %(totalepisodes)s
   Weblink: %(showlink)s
      Akas: \n%(akas)s\n""",
                 'info_prev_format': 'Previous episode: [ %(prev_ep_ident)s ] %(prev_ep_title)-21.20s @ %(prev_ep_airdate)s',
                 'info_next_format': '    Next episode: [ %(next_ep_ident)s ] %(next_ep_title)-21.20s @ %(next_ep_airdate)s',
                 'date_format': '%d %h %Y'}

    # Read config file and overwrite default values if directives found.
    lineno = 0
    for line in open(configfile).readlines():
        lineno += 1
        line = line.strip()
        if not line or line.startswith('#'):
            continue

        try:
            key, value = line.split('=', 1)
        except IndexError:
            sys.stderr.write("Config file corrupted or incorrect. Error at line: %d\n" % (lineno,))
            sys.stderr.write("Line: %s\n" % line)
            sys.stderr.write("Please refer to README for correct configuration directives\n")
            sys.exit(3)

        if key == 'series':
            if value.endswith(','):
                vialue = value[:-1]
            if not value:
                series = None
            else:
                series = [el.replace('\n', '') for el in value.split(',')]
            continue

        if key in ('list_header_format', 'list_format', 'list_format_verbose', 'single_header_format',
                   'info_verbose_format',
                   'single_format', 'info_header_format', 'info_prev_format',
                   'info_next_format', 'date_format',
                   'when_name_format', 'when_day_format', 'when_format'):
            templates[key] = value
            continue

        if key == 'g_login':
            g_creds['login'] = value
            continue
        if key == 'g_passwd':
            g_creds['passwd'] = value
            continue

        else:
            sys.stderr.write("Invalid configuration directive at line %d.\n" % (lineno,))
            sys.stderr.write("Line: %s\n" % line)
            sys.stderr.write("Please refer to README for correct configuration directives.\n")
            sys.exit(3)

    return (series, templates, g_creds)
