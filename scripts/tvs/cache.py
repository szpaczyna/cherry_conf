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

import contextlib
import sys
import lxml.etree as etree
import shelve
import subprocess
try:
    import urllib2
except ImportError:
    import urllib as urllib2

import time

import tvs.show


# Spinner implementation.
@contextlib.contextmanager
def spinning_distraction(spin):
    if spin:
        global p
        p = subprocess.Popen(['tvs_spin.py'])
        yield
        p.terminate()
        sys.stdout.write("\r")
        sys.stdout.flush()

    else:
        yield


# --------------------------------------------------------------------- #
#                                                                       #
#  Class Cache                                                          #
#                                                                       #
# --------------------------------------------------------------------- #

class Cache(object):
    """
    Cache implementation.
    Cache is a wraper class for Show class.
    It is capable of retrieving and storing data from tvrage.com.
    ttl contains date upto when object is valid.
    """
    def __init__(self, keyword, options):
        self.keyword = keyword
        self.show = None
        self.options = options
        self.now = time.time()

        if self.options.cache:
            self.c = shelve.open(self.options.cachefile)
            self.i = shelve.open(self.options.cacheids)

        self.url_search = "http://services.tvrage.com/feeds/search.php?show=%s" % self.keyword
        self.showid = self.__get_show_id()

        self.url_full_show = "http://services.tvrage.com/feeds/full_show_info.php?sid=%s" % self.showid
        self.show = self.__get_show()

        if self.options.debug:
            print("Search URL: %s" % self.url_search)
            print("Shows full URL: %s" % self.url_full_show)


    def __del__(self):
        """If cache was used all files need to be closed."""
        if self.options.cache:
            self.c.close()
            self.i.close()


    def __save_id_to_cache(self, showid):
        """Saves retrieved show's id to cache"""
        self.i[self.keyword] = showid


    def __save_show_to_cache(self, show):
        if not show:
            return False
        # Set TTL, add 12h (43200secs) to current time (12h TTL)
        self.c[str(self.showid)] = (self.now+43200, show)
        return True


    def __get_id_from_cache(self):
        try:
            return self.i[self.keyword]
        except:
            return None


    def __get_id_from_tvrage(self):
        try:
            with spinning_distraction(spin=self.options.spinner):
                return etree.fromstring(urllib2.urlopen(self.url_search).read()).xpath('//Results/show/showid')[0].text
        except KeyboardInterrupt:
            raise
        except:
            return None


    def __get_show_from_cache(self):
        try:
            return self.c[str(self.showid)]
        except:
            return (None, None)


    def __get_show_from_tvrage(self):
        try:
            with spinning_distraction(spin=self.options.spinner):
                return tvs.show.Show(etree.fromstring(urllib2.urlopen(self.url_full_show).read()), self.options)
        except KeyboardInterrupt:
            raise
        except:
            return None


    def __get_show_id(self):
        """Returns first found id from search list. """
        # Try to get id from ids cache file
        if self.options.cache and not self.options.refresh:
            showid = self.__get_id_from_cache()
            if not showid:
                showid = self.__get_id_from_tvrage()
                if showid:
                    self.__save_id_to_cache(showid)
                    return showid
                return showid
            else:
                return showid

        elif self.options.refresh:
            showid = self.__get_id_from_tvrage()
            if showid:
                self.__save_id_to_cache(showid)
                return showid

        elif not self.options.cache:
            return self.__get_id_from_tvrage()

        else:
            showid = self.__get_id_from_tvrage()
            if showid:
                self.__save_id_to_cache(showid)
                return showid

        return None


    def __get_show(self):
        """Returns show instance with data from tvrage."""
        if self.showid == None: # Previously not found show id
            return None

        if self.options.cache and not self.options.refresh:
            ttl, show = self.__get_show_from_cache()

            if not ttl and not self.show or ttl < self.now:
                show = self.__get_show_from_tvrage()
                self.__save_show_to_cache(show)

        elif self.options.refresh:
            show = self.__get_show_from_tvrage()
            self.__save_show_to_cache(show)

        # If no cache to be used.
        else:
            show = self.__get_show_from_tvrage()

        return show


    def get_show(self):
        return self.show
