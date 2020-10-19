#!/usr/bin/env python3
import os
import desk_environment

WorkPath=os.path.dirname(os.path.realpath(__file__))
konsolecommand="gnome-terminal"
#set konsole command according to system
if not desk_environment.detect_desktop_environment() == "gnome":
	konsolecommand="konsole"

result = os.system("python3 "+WorkPath+"/conf/guicheck.py")
if 0 == result:
    print("all good")
    os.system(konsolecommand+" -e "+os.path.join(WorkPath, "run.sh")) 		
else:
    print("Error occured, try to install missing dependencies")
    os.system(konsolecommand+" -e 'python3 "+os.path.join(WorkPath, "dependencies.sh'"))

