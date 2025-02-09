#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# VADPacker - A small tool to create Virtuoso VAD packages
# Copyright (C) 2012-2025 OpenLink Software <opensource@openlinksw.com>
#
# This project is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; only version 2 of the License, dated June 1991.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#

from __future__ import print_function
from __future__ import unicode_literals


import hashlib
import struct
import os
import sys
import platform
import optparse
import datetime
import re
import glob
import subprocess
import gzip


#
#  Use xml.etree.ElementTree
#
import xml.etree.ElementTree as ET


#
#  Use BytesIO
#
from io import BytesIO


#
#  Setup logging
#
# set up logging to file - see previous section for more details
import logging
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename='vadpacker.log',
                    filemode='w')


#
#  Define a handler which writes INFO messages and higher to the sys.stderr
#
console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter('%(levelname)s: %(message)s')
console.setFormatter(formatter)
logging.getLogger('').addHandler(console)



#
# settings
#
verbose = False
prefix = ""
targetprefix = ""


#
# Our hash
#
ctx = hashlib.md5()

def zshglob(pattern):
    """
    Some additional globbing inspired by the ZSH shell:
    - **/ matches any depth dir
    """
    if '`' in pattern:
    # We execute a shell command to generate the list of files
        try:
            return subprocess.check_output(pattern.replace('`', ''), shell=True).splitlines()
        except OSError as e:
            logging.error('Failed to execute file glob shell command: %s: "%s"' % (pattern.replace('`', ''), e))
            exit(1)
    elif '**/' in pattern:
        # here we need to glob in every possible subdir
        # if we for example have pattern "a/**/b/*.txt"
        # we need to find every subdir of a/ and run glob("a/subdir/b/*.txt")
        # this includes subsubdirs like glob("a/subdir/subsub/b/*.txt")
        baseDir = pattern[:pattern.find('**/')]
        restDir = pattern[pattern.find('**/')+3:]

        # We start with no subdirs
        r = sorted(glob.glob(baseDir + restDir))

        # And then run through all the subdirs we find
        for path in sorted([x[0] for x in os.walk(baseDir or '.')]):
            r += sorted(glob.glob(path.lstrip('./') + '/' + restDir))
        return [f for f in r if os.path.isfile(f)]
    else:
        return [f for f in sorted(glob.glob(pattern)) if os.path.isfile(f)]


def vadWriteChar(s, val):
    """
    Writes a single char to a VAD file and
    updates the hash while at it.

    s -- The stream to write to
    val -- The value to write.
    ctx -- The hash object to update.
    """
    s.write(val)
    ctx.update(val)


def vadWriteLong(s, val):
    """
    Writes a 32bit integer to a VAD file and
    updates the hash while at it.
    The long will be written with big endian
    byte order.

    s -- The stream to write to
    val -- The value to write.
    ctx -- The hash object to update.
    """
    be = struct.pack(str('>i'), val)
    s.write(be)
    ctx.update(be)


def vadWriteString(s, val):
    """
    Writes a string to a VAD file and
    updates the hash while at it. A string
    in a VAD is always prefixed with the
    length of the string.

    s -- The stream to write to
    val -- The value to write.
    ctx -- The hash object to update.
    """
    vadWriteLong(s, len(val))
    bytes2 = val.encode()
    s.write(bytes2)
    ctx.update(bytes2)


def vadWriteRow(s, name, data):
    # write the row name
    vadWriteChar(s, b'\xb6')
    vadWriteString(s, name)

    # write the row contents
    vadWriteChar(s, b'\xdf')
    vadWriteString(s, data)


def vadWriteFile(s, name, fname, use_gz):
    """
    Writes a file to a VAD file and
    updates the hash while at it. The file is
    supposed to be a file on the local filesystem
    rather than in the DAV.

    s -- The stream to write to
    name -- The name of the file in the VAD.
    fname -- The path of the local file.
    use_gz -- Should the file be stored compressed
    ctx -- The hash object to update.
    """
    with open(fname, 'rb') as f:
        # read contents of file
        val = f.read()

        # compress the file if requested
        if use_gz == "yes":
            if sys.version_info > (2, 7):       # Python 2.7 and newer
                buf = BytesIO()
                with gzip.GzipFile(fileobj=buf, mode='wb', compresslevel=9, mtime=0) as f:
                    f.write(val)
                val = buf.getvalue()
            else:
               raise Exception("use_gzip requires python 2.7 or newer")

            if verbose:
                f_len = os.path.getsize(fname)
                logging.info("compress: original size=%ld, compressed size=%ld compression=%.2f%%" %
                        (f_len, len(val), 100.0 * ((f_len - len(val))/f_len)))

        # write the file name
        vadWriteChar(s, b'\xb6')
        vadWriteString(s, name)

        # write the content marker
        vadWriteChar(s, b'\xdf')

        # write the file size
        vadWriteLong(s, len(val))

        # write the file contents
        s.write(val)
        ctx.update(val)


def getDefaultPerms(f):
    executable = 0
    if f.endswith('.sql'):
        return "110100000NN"
    if f.endswith('.vsp') or f.endswith('.vspx') or f.endswith('.php'):
        executable = 1
    return "11%d10%d10%dNN" % (executable, executable, executable)


def createSticker(stickerUrl, variables, files):
    """
    Create the final sticker from sticker template, variables, and additional files.
    Returns a string containing the final sticker
    """
    global targetprefix
    global prefix
    if len(prefix) > 0 and not prefix.endswith('/'):
        prefix = prefix + '/'

    # Remember already added resources to avoid duplicates
    allResources = []

    # Remember used variables for warnings
    usedVariables = []

    # Write the contents of the sticker
    sticker = ''
    with open(stickerUrl) as stickerFile:
        sticker = stickerFile.read()
        # replace all given variables
        for key in variables:
            tmpSticker = sticker.replace('$%s$' % key, variables[key])
            if tmpSticker != sticker:
                usedVariables.append(key)
            sticker = tmpSticker
        # replace well-known variables
        sticker = sticker.replace('$PACKDATE$', datetime.datetime.now().strftime('%Y-%m-%d %H:%M'))
        sticker = sticker.replace('$HOME$', os.environ['HOME'])

    # See if any of the given variables was not used and print a warning about it
    for key in variables:
        if key not in usedVariables:
            logging.warning('WARNING: Unused sticker variable: "%s"' % key)

    # Change the working dir to the root of the sticker file
    os.chdir(os.path.dirname(os.path.abspath(stickerUrl)))

    # Expand any wildcards in the sticker's resource list
    resources = ""
    stickerTree = ET.fromstring(sticker)
    for f in stickerTree.findall("resources/file"):
        overwrite = f.get("overwrite") or 'yes'
        resType = f.get("type") or 'dav'
        resSource = f.get("source") or 'data'
        targetUri = f.get("target_uri")
        sourceUri = f.get("source_uri") or targetUri
        owner = f.get("dav_owner") or "dav"
        grp = f.get("dav_grp") or "administrators"
        perms = f.get("dav_perm")
        use_gz = f.get ("gzip") or "no"

        # and add a new line for each globbed one
        for path in zshglob(prefix + sourceUri):
            # The stripped path takes the prefix into account which is never used in target URLs
            strippedPath = path[len(prefix):]
            targetUri = targetUri.replace('$f$', os.path.split(path)[1])
            targetUri = targetUri.replace('$p$', strippedPath)
            if targetUri.endswith('/'):
                targetUri += strippedPath
            if use_gz == "yes":
              targetUri += '.gz'
            if(targetUri in allResources):
                targetUri = f.get("target_uri")
                continue
            allResources.append(targetUri)
            resources += '  <file overwrite="%s" type="%s" source="data" source_uri="%s" target_uri="%s" dav_owner="%s" dav_grp="%s" dav_perm="%s" makepath="yes" %s/>\n' % (overwrite, resType, path, targetUri, owner, grp, perms or getDefaultPerms(path), 'gzip="yes"' if use_gz == 'yes' else '')
            targetUri = f.get("target_uri")

    # Create the XML blob of additional files to add
    if len(targetprefix) > 0 and not targetprefix.endswith('/'):
        targetprefix = targetprefix + '/'
    for f in files:
        f = re.sub('^./', '', f)
        executable = 0
        if f.endswith('.vsp') or f.endswith('.vspx') or f.endswith('.php'):
            executable = 1
        targetUri = targetprefix + f
        if(targetUri in allResources):
            continue
        allResources.append(targetUri)
        resources += '  <file overwrite="yes" type="dav" source="data" source_uri="%s" target_uri="%s" dav_owner="dav" dav_grp="administrators" dav_perm="%s" makepath="yes"/>\n' % (f, targetUri, getDefaultPerms(f))

    # Replace the resources in the sticker with our expanded ones the dumb way (we want to preserve the original sticker formatting if possible)
    resEx = re.compile('<resources>.*</resources>', re.DOTALL)
    sticker = resEx.sub('<resources>\n' + resources + '</resources>\n', sticker, 0)

    # Check if any variable values are missing
    missingVals = list(set(re.findall(r'\$([^\$]+)\$', sticker)))
    if len(missingVals) > 0:
        logging.error('Missing variable values: %s' % ', '.join(missingVals))
        exit(1)

    return sticker


def createVad(basePath, sticker, s):
    # write a clean text warning
    vadWriteRow(s, 'VAD', 'This file consists of binary data and should not be touched by hands!')

    # Write the final sticker contents
    vadWriteRow(s, 'STICKER', sticker)

    # Write all the files defined in the sticker
    stickerTree = ET.fromstring(sticker)
    for f in stickerTree.findall("resources/file"):
        resType = f.get("type")
        resSource = f.get("source")
        targetUri = f.get("target_uri")
        sourceUri = f.get("source_uri")
        use_gz  = f.get("gzip")
        if resSource == "dav":
            logging.error("Cannot handle DAV resources")
            exit(1)
        if verbose:
            logging.info("Packing file %s as %s" % (sourceUri, targetUri))
        vadWriteFile(s, targetUri, sourceUri, use_gz)

    # Write the md5 hash
    vadWriteRow(s, 'MD5', ctx.hexdigest())


def buildVariableMap(variables):
    "Converts a list of key=val pairs into a map"
    values = {}
    for v in variables:
        x = v.split('=')
        if len(x) != 2:
            logging.error("Invalid variable value: '%s'. Expecting 'key=val'." % v)
            exit(1)
        values[x[0]] = x[1]
    return values


def main():
    global verbose
    global prefix
    global targetprefix

    #
    #  Check mimimal python version
    #
    if sys.version_info < (2, 7, 5):
        logging.error("Vadpacker requires Python 2.7.5 or newer instead of Python %s" % platform.python_version())
        exit (1);

    #
    #  Parse command line args
    #
    usage="""\
vadpacker.py [-h] --output PATH [--verbose] [--prefix PREFIX]
[--targetprefix PREFIX] [--var [VAR [VAR ...]]] sticker_template
[files [files ...]]"""
    description="""\
Copyright (C) 2012-2025 OpenLink Software. Vadpacker can be used
to build Virtuoso VAD packages by providing the tool with a sticker
template file. Vadpacker supports variable replacement and wildcards
for file resources."""
    epilog="""\
The optional list of files at the end will be packed in addition to the
files in the sticker.
Vadpacker will create additional resource entries with default permissions
(dav, administrators, 111101101NN for vsp, vspx, and php pages; 110100100NN
for all other files) in the packed sticker using the relative paths of
the given files."""

    #  create parser
    parser = optparse.OptionParser(
        usage=usage,
        version='Virtuoso VAD Packer v1.10',
        description=description,
        epilog=epilog
    )

    #  add options
    parser.add_option('--output', '-o',
         type="string", metavar='PATH', dest='output',
         help='The destination VAD file.')

    parser.add_option('--verbose', '-v',
         action="store_true", dest="verbose", default=False,
         help="Be verbose about the packing.")

    parser.add_option('--prefix', '-p',
         type="string", default="", metavar='PREFIX', dest='prefix',
         help='An optional prefix to be used for locating local files. This prefix is prepended to all resource source_uris in the sticker template. The final target_uri will not contain the prefix.')

    parser.add_option('--targetprefix', '-t',
         type="string", default="", metavar='PREFIX', dest='targetprefix',
         help='An optional prefix to be used for target_uri values in additional resource entries created through the files list.')

    parser.add_option('--var',
         type="string", metavar='VAR', dest='var', default=[], action="append",
         help='Set variable values to be replaced in the sticker. Example: --var="VARNAME=xyz" will replace any occurence of $VARNAME$ with "xyz"')

    parser.add_option('--print-sticker',
         action="store_true", dest="printsticker", default=False,
         help="Do not pack the vad, only print the final sticker to stdout.")

    #  parse arguments
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.error("missing sticker_template argument")

    #  store arguments
    verbose = options.verbose
    prefix = options.prefix
    targetprefix = options.targetprefix
    stickerUrl = args[0]


    #
    #  Parse the sticker
    #
    try:
        if verbose:
            logging.info("Creating sticker from template '%s'" % stickerUrl)
        sticker = createSticker(stickerUrl, buildVariableMap(options.var), args[1:])
    except Exception as ex:
        if verbose:
            logging.exception("Error parsing sticker template '%s': %s" % (stickerUrl, ex))
        else:
            logging.error("Error parsing sticker template '%s': %s" % (stickerUrl, ex))
        exit (1)
    finally:
        if options.printsticker:
            print (sticker)
            exit (0)


    #
    #  Generate the VAD package
    #
    try:
        # Open the target file and write the VAD
        with open(options.output, "wb") as s:
            if verbose:
                logging.info("Packing VAD file '%s'" % (options.output))
            createVad(os.path.dirname(os.path.realpath(stickerUrl)), sticker, s)
    except Exception as ex:
        if verbose:
            logging.exception("Error packing VAD file '%s': %s" % (options.output, ex))
        else:
            logging.error("Error packing VAD file '%s': %s" % (options.output, ex))
        logging.warning ("Removing partial VAD file")
        os.remove (options.output)
        exit (1)
    finally:
        #  success
        logging.info ("Vadpacker completed without errors")


if __name__ == "__main__":
    main()
