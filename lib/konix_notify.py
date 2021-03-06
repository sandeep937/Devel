#!/usr/bin/env python
# -*- coding:utf-8 -*-
import logging
logging.basicConfig(level=logging.DEBUG)
LOGGER = logging.getLogger(__name__)

def by_konubinix_notificator(message,unique=False, duration=3000):
    import dbus
    session = dbus.SessionBus()
    if unique:
        path = "/UniqueNotification"
    else:
        path = "/Notification"
    LOGGER.info("Opening communication with "+path)
    notification = session.get_object('konubinix.notificator',
                                      path)
    LOGGER.info("Displaying message "+message)
    notification.Notify(message, duration)
    LOGGER.info("Message displayed")

def by_pynotify(message):
    import pynotify
    if not pynotify.init("Message"):
        sys.exit(1)
    n = pynotify.Notification("Message", message)
    n.set_timeout(3000)
    n.show()

def by_sl4a(message):
    from konix_android import droid
    droid.makeToast(message)

def by_pyosd(message):
    import pyosd
    p = pyosd.osd("-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-1", colour="green", pos=pyosd.POS_BOT,offset=40, align=pyosd.ALIGN_CENTER)
    p.display(message)

def main(message,unique=False, duration=3000):
    message = message.replace("<", "-")

    try:
        LOGGER.info("Trying with the notificator")
        by_konubinix_notificator(message,unique, duration)
    except:
        try:
            LOGGER.error("Fallbacking to pynotify")
            by_pynotify(message)
        except:
            LOGGER.error("Fallbacking to pyosd")
            try:
                by_pyosd(message)
            except:
                by_sl4a(message)
