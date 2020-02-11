#!/usr/bin/env python3
import os
import sys
import subprocess

if 'DESTDIR' not in os.environ:
    datadir = sys.argv[1]
    schemadir = os.path.join(datadir, 'glib-2.0', 'schemas')
    icondir = os.path.join(datadir, 'icons', 'hicolor')

    print('Compiling gsettings schemas...')
    subprocess.call(['glib-compile-schemas', schemadir])

    print('Rebuilding desktop icons cache...')
    subprocess.call(['gtk-update-icon-cache', '-t', '-f', icondir])
