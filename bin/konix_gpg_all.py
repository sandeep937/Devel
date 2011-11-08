#!/usr/bin/env python
# -*- coding:utf-8 -*-

import gnupg
import os
import sys
import subprocess

# ####################################################################################################
# Parsing arguments
# ####################################################################################################
import argparse
parser = argparse.ArgumentParser(description="""Encrypt of decrypt recursively
current directory but this script.""")
parser.add_argument('-d','--decrypt', nargs='?', const="a", help="""Use decrypt (by default,
encryption is done)""")

args = parser.parse_args()

# ####################################################################################################
# Real script
# ####################################################################################################
gpg_env_file = os.path.expanduser("~/.gpg-agent-info")
def load_gpg_env_file():
        with open(gpg_env_file,"r") as f:
                gpg_agent_info = f.readline().partition("=")
                os.environ[gpg_agent_info[0]] = gpg_agent_info[2]

def test_gpg_available():
        retcode = subprocess.call(["gpg-agent"])
        if retcode == 0:
                return True
        else:
                return False

def new_gpg_agent(gpg_env_file):
        retcode = subprocess.call(["gpg-agent","--daemon","--write-env-file",gpg_env_file])
        if retcode != 0:
                print >>sys.stderr, "Error when trying to run gpg-agen in daemon mode"
                return False
        else:
                return True

if os.path.exists(gpg_env_file):
        load_gpg_env_file()
if not test_gpg_available():
        if not new_gpg_agent(gpg_env_file):
                print "quitting because no gpg-agent initialization"
                exit(2)

dir_walker = os.walk(".")
def remove_hidden_files(walk_res):
        hidden_file_indices = []
        index = 0
        to_remove = []
        for _file in walk_res:
                if _file.startswith("."):
                        to_remove.append(_file)
        for to_remove_file in to_remove:
                walk_res.remove(to_remove_file)

def process_file(abs_file, decrypt):
        if abs_file.endswith(".gpg"):
                print abs_file,"looks like an encrypted file"
                if decrypt:
                        if "_nd" in abs_file:
                                print "File does not want decryption"
                                return
                        decrypted_file_name = abs_file.replace(".gpg","")
                        if os.path.exists(decrypted_file_name):
                                print "already a decrypted file for",abs_file,", don't touch it"
                        else:
                                print "decrypt",abs_file,"to",decrypted_file_name
                                retcode = subprocess.call(["gpg","-o",decrypted_file_name,"-d",abs_file])
                                if retcode == 0:
                                        print "removing old file ",abs_file
                                        os.remove(abs_file)
                else:
                        print "Nothing to do for",abs_file
        else:
                print abs_file,"looks like a decrypted file"
                if not decrypt:
                        encrypted_file_name = abs_file+".gpg"
                        if os.path.exists(encrypted_file_name):
                                print "already a gpg file for",abs_file,", replace it"
                                os.remove(encrypted_file_name)
                        print "encrypt",abs_file,"to",encrypted_file_name
                        retcode = subprocess.call(["gpg","-o",encrypted_file_name,"-r","Loury","-e",abs_file])
                        if retcode == 0:
                                print "removing old file ",abs_file
                                os.remove(abs_file)
                else:
                        print "Nothing to do for",abs_file

for root, dirs, files in dir_walker:
        remove_hidden_files(dirs)
        remove_hidden_files(files)
        for _file in files:
                if os.path.split(sys.argv[0])[1] == _file:
                        print "Not touching to me..."
                        continue
                abs_file = os.path.join(root,_file)
                process_file(abs_file, args.decrypt)
