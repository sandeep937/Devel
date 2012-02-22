#!/usr/bin/env python
# -*- coding:utf-8 -*-
import os
import sys

from install_lib import *

def install_shell():
        environ = get_environ()
        # ####################################################################################################
        # install shrc_var
        # ####################################################################################################
        SHRC_VAR_FILE_NAME = os.path.join(environ["HOME"], ".shrc_var")
        SHRC_VAR_FILE_CONTENT = """#!/bin/bash
# put the python of this platform in front of the path
# the only hacky stuf I need is the platform
export WANTED_PLATFORM="$(source "${HOME}/init_bin/_konix_platform.sh")"
PATH_SEPARATOR="$(cd "${HOME}/init_bin" && "./_konix_get_default_env.py" PATH_SEPARATOR)"
export PYTHON_BIN="$(cd "${HOME}/init_bin" && "./_konix_get_default_env.py" PYTHON_BIN)"
export PYTHON_PATH="$(cd "${HOME}/init_bin" && ./konix_dirname.py "$PYTHON_BIN")"
# now, I am sure the python bin is set before running the init_lib
# Import env variables
source "${HOME}/init_bin/konix_init_lib.sh"
# importing custom environnement variables
import_env
"""
        replace_file_content(SHRC_VAR_FILE_NAME, SHRC_VAR_FILE_CONTENT)

        # ####################################################################################################
        # Install KONIX_SH_CUSTOM_FILE
        # ####################################################################################################
        if not os.path.exists(environ["KONIX_SH_CUSTOM_FILE"]):
                replace_file_content(environ["KONIX_SH_CUSTOM_FILE"], """#!/bin/bash
# custom sh commands
""")

        # ####################################################################################################
        # Install bashrc
        # ####################################################################################################
        replace_file_content(os.path.join(environ["HOME"], ".bashrc"), """#!/bin/bash
source "${HOME}/.shrc_var"
source "${KONIX_CONFIG_DIR}/bashrc"
source "${KONIX_SH_CUSTOM_FILE}"
""")

        # ####################################################################################################
        # SHRC
        # ####################################################################################################
        replace_file_content(os.path.join(environ["HOME"], ".shrc"), """#!/bin/sh
source "${HOME}/.shrc_var"
source "${KONIX_CONFIG_DIR}/shrc"
source "${KONIX_SH_CUSTOM_FILE}"
""")
        # ####################################################################################################
        # ZSHRC
        # ####################################################################################################
        replace_file_content(os.path.join(environ["HOME"], ".zshrc"), """#!/bin/zsh
source "${HOME}/.shrc_var"
source "${KONIX_CONFIG_DIR}/zshrc"
source "${KONIX_SH_CUSTOM_FILE}"
""")
        print "Successful installed shell config"
if __name__ == '__main__':
        install_shell()
