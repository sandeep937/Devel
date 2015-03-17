#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
import os
import pathlib
import sys
import subprocess
import glob

def find_recoll_in_hierarchy(directory):
    path = pathlib.Path(directory).absolute()
    for parent in [path,] + list(path.parents):
        candidate = os.path.join(directory, "recoll")
        if os.path.exists(candidate):
            logger.debug("Found {}".format(candidate))
            return candidate
    return None

def call_recoll(program="recoll", args=None):
    args = args or []
    recoll_dir = find_recoll_in_hierarchy(".")
    environ = os.environ
    environ["RECOLL_EXTRA_DBS"] = os.pathsep.join(glob.glob(os.path.expanduser("~/.recoll/*")))
    environ["RECOLL_ACTIVE_EXTRA_DBS"] = ""
    if recoll_dir:
        logger.info("Using {}".format(recoll_dir))
        subprocess.call([program, "-c", recoll_dir] + sys.argv[1:], env=environ)
    else:
        environ["RECOLL_ACTIVE_EXTRA_DBS"] = environ["RECOLL_EXTRA_DBS"]
        logger.info("Don't use any recoll dir")
        subprocess.call([program,] + sys.argv[1:], env=environ)
