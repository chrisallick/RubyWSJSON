from __future__ import print_function

events = {}

def fireEvent(event,msg):
    events[event](msg)

def addEvent(event,type,func):
	events[event] = func

def onCompass(msg):
	print(msg)

addEvent("compass","string",onCompass)

fireEvent( "compass", "wazzsup" )