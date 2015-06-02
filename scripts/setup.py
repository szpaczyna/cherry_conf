#!/usr/bin/env python

from distutils.core import setup

setup ( name='tvseries',
        version='0.6.7',
        description='TVRage.com parser',
        author='Kamil Winczek',
        author_email='kamil@winczek.com',
        url='http://winczek.com/tvseries/',
        packages=['tvs'],
        scripts = ["tvseries", 'tvs_spin.py'] )
