#!/usr/bin/env python3
import os
import desk_environment

WorkPath=os.path.dirname(os.path.realpath(__file__))
konsolecommand="gnome-terminal --"
#set konsole command according to system
if not desk_environment.detect_desktop_environment() == "gnome":
	konsolecommand="konsole -e"

result = os.system("python3 "+WorkPath+"/conf/guicheck.py")
if 0 == result:
    print("all good")
    print(konsolecommand+" '"+os.path.join(WorkPath, "run.sh'"))
    os.system(konsolecommand+" '"+os.path.join(WorkPath, "run.sh'")) 	
else:
    print("Error occured, try to install missing dependencies")
    os.system(konsolecommand+" 'python3 "+os.path.join(WorkPath, "dependencies.sh'"))

