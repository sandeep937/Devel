#!/usr/bin/env python
# -*- coding:utf-8 -*-

from SimpleXMLRPCServer import SimpleXMLRPCServer
from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler
import os
import subprocess

# Restrict to a particular path.
class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)

# Create server
server = SimpleXMLRPCServer(("0.0.0.0", 9000),
                            requestHandler=RequestHandler)
server.register_introspection_functions()

def pyril():
    """Launch pyril"""
    os.system("pyril.py")
    return False
server.register_function(pyril)

def pyril_prior():
    """Launch pyril_prior"""
    os.system("pyril_prior.py")
    return False
server.register_function(pyril_prior)

def supervisord():
    """Launch supervisord"""
    return not bool(os.system("konix_supervisord.sh"))
server.register_function(supervisord)

def pyril_slow():
    """Launch pyril_slow"""
    os.system("pyril_slow.py")
    return False
server.register_function(pyril_slow)

def pyril_fast():
    """Launch pyril_fast"""
    os.system("pyril_fast.py")
    return False
server.register_function(pyril_fast)

def mail_me():
    """Email me"""
    os.system("andgtd2.sh &")
    return False
server.register_function(mail_me)

def sl4a():
    """Launch sl4a"""
    os.system("sl4a.sh")
    return False
server.register_function(sl4a)

def mount_user():
    """Mount the user directory in the sdcard"""
    os.system("konix_mount_user.sh")
    return False
server.register_function(mount_user)

def cpufreqset():
    """Set cpu governor"""
    os.system("andcpufreq.py")
    return False
server.register_function(cpufreqset)

def volumeclient():
    """Use the phone as a remote volume controler"""
    os.system("konix_volume_client.py")
    return False
server.register_function(volumeclient)

def mpdtunnel():
    """Create a tunnel to the MPD host"""
    os.system("konix_mpd_ssh_tunnel.sh")
    return False
server.register_function(mpdtunnel)

def mpdstream():
    """Listen to the mpd host stream"""
    os.system("konix_mpd_listener.sh")
    return False
server.register_function(mpdstream)

def mpdstreamlocal():
    """Listen to the mpd host stream via the tunnel"""
    os.system("konix_mpd_listener_local.sh")
    return False
server.register_function(mpdstreamlocal)

server.serve_forever()
