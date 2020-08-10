#!/usr/bin/env python3
import PySimpleGUI as sg
import os, subprocess, sys
import desk_environment
from PIL import Image
from resizeimage import resizeimage
from conf.config import *

sg.theme('Reddit')


#First things first: Are we root?
if os.popen('whoami').read().strip() != 'root':
	[[sg.popup_error('You need to be root to start the iBuntu Builder')]]
	sys.exit()


def isobutton(pathtoiso):
    print(pathtoiso)
    if (not os.path.exists(pathtoiso)):
        buttoncolorISO='#eeece9'
        print("negativ")

    else:
        buttoncolorISO='#66e0ff'
    print(buttoncolorISO)
    return buttoncolorISO

def writestuff():
		#write config to .conf file for bashscript
		filepath = os.path.join(WorkPath,'conf/config.py')
		f = open(filepath,"w")
		configcontent = "#!/usr/bin/env python3\n# -*- coding: utf-8 -*-\n\nBASEWORKDIR='%s'\nLIVEUSER='%s'\nDISTNAME='%s'\nCUSTOMISO='%s'\nLIVECDLABEL='%s'\nLIVECDURL='%s'\nEXCLUDES='%s'\nSQUASHFSOPTS='%s'\nREMOVERESTRICTED='%s'\n" %(str(BASEWORKDIR),str(LIVEUSER),str(DISTNAME),str(CUSTOMISO),str(LIVECDLABEL),str(LIVECDURL),str(EXCLUDES),str(SQUASHFSOPTS),str(REMOVERESTRICTED))
		print(configcontent)
		print(filepath)
		f.write(configcontent)


def resize_splash(splash, splashcropped):
	with Image.open(splash) as image:
		cover = resizeimage.resize_cover(image, [100, 75])
		cover.save(splashcropped, image.format)

konsolecommand="gnome-terminal"
print(desk_environment.detect_desktop_environment())
#set konsole command according to system
if not desk_environment.detect_desktop_environment() == "gnome":
	konsolecommand="konsole"

print(konsolecommand)
WorkPath=os.path.dirname(os.path.realpath(__file__))
winicon=WorkPath+'/conf/icon.png'
splash=WorkPath+'/etc/isolinux/splash.png'
splashcropped=WorkPath+'/etc/isolinux/splashcropped.png'
resize_splash(splash, splashcropped)

pathtoiso=BASEWORKDIR+"/build/"+CUSTOMISO
buttoncolorISO=isobutton(pathtoiso)
print(buttoncolorISO)

frame_Splash = [
				  [sg.Image(r''+splashcropped)]
			   ]

Tab1col1= [[sg.Text('')],
	[sg.Button('Create ISO', size=(28,2), button_color=('black','#86de96'), key="ISO")],
	[sg.Button('Burn bootable ISO', size=(28,2), button_color=('black',buttoncolorISO), key="USB", disabled=bool(not os.path.exists(pathtoiso)))],
    [sg.Text('')],
	[sg.InputText(LIVECDLABEL, size=(32,2), key="Label")],
	[sg.T('')],
	[sg.InputText(DISTNAME, size=(32,2),key="distribution")],
	[sg.T('')],
	[sg.Frame('', frame_Splash), sg.Text("Splash")]]

Tab1col2= [[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
    [sg.Text('')],
	[sg.Text('')],
	[sg.Text('Distribution Name')],
	[sg.T('')],
	[sg.Text('Distribution Fullname')]]

Tab1col3= [[sg.Text('	   ')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')]]

Tab1col4 = [[sg.Text('')],
	[sg.Image(r''+WorkPath+'/conf/icon.png')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')],
	[sg.Text('')]]

Tab2col1=[[sg.Text('')],
	[sg.Text('')],
	[sg.Text('Workdirectory')],
	[sg.Text('')],
	[sg.Text('ISO Filename')],
	[sg.Text('')],
	[sg.Text('LiveCD URL')],
	[sg.Text('')],
	[sg.Text('Liveuser')]]

Tab2col2=[[sg.Text('')],
	[sg.Text('')],
	[sg.Text(''),sg.InputText(BASEWORKDIR,size=(30,2),key="directory")],
	[sg.Text('')],
	[sg.Text(''),sg.InputText(CUSTOMISO,size=(30,2),key="isofile")],
	[sg.Text('')],
	[sg.Text(''),sg.InputText(LIVECDURL,size=(30,2),key="URL")],
	[sg.Text('')],
	[sg.Text(''),sg.InputText(LIVEUSER,size=(30,2),key="live-user")]]
Tab2col3=[[sg.Text('		   ')],
	[sg.Image(r''+WorkPath+'/conf/icon.png')]]

tab1_layout =  [[sg.Column(Tab1col1), sg.Column(Tab1col2), sg.Column(Tab1col3), sg.Column(Tab1col4)]]

tab2_layout = [[sg.Column(Tab2col1), sg.Column(Tab2col2), sg.Column(Tab2col3)]]

layout = [[sg.TabGroup([[sg.Tab('iBuntu OS', tab1_layout), sg.Tab('Advanced', tab2_layout)]])],
		  [sg.T('')],
		  [sg.Button('Close',button_color=('black','#faf9f8'),size=(28,2))]]



window = sg.Window('iBuntu Builder 1.0', layout, icon=winicon, default_element_size=(12,1))

while True:
    event, values = window.read()
    print(event,values)
    if event == 'ISO':
        os.remove(splashcropped)
        BASEWORKDIR=values['directory']
        LIVEUSER=values['live-user']
        DISTNAME=values['distribution']
        CUSTOMISO=values['isofile']
        LIVECDLABEL=values['Label']
        LIVECDURL=values['URL']
        writestuff()
        window.Element('ISO').Update(disabled=True, button_color=('black','#eeece9'))
        os.system(konsolecommand+" -e '/bin/bash "+WorkPath+"/ibuntubuilder'")
        window.Element('ISO').Update(disabled=False, button_color=('black','#86de96'))
        buttoncolorISO=isobutton(pathtoiso)
        window.Element('USB').Update(button_color=('black',buttoncolorISO), disabled=bool(not os.path.exists(pathtoiso)))

    if event == 'Close':		   # always,  always give a way out!
        os.remove(splashcropped)
        BASEWORKDIR=values['directory']
        LIVEUSER=values['live-user']
        DISTNAME=values['distribution']
        CUSTOMISO=values['isofile']
        LIVECDLABEL=values['Label']
        LIVECDURL=values['URL']
        writestuff()
        break

    if event == 'USB':
        os.system(WorkPath+"/conf/balenaEtcher-1.5.101-x64.AppImage ibuntu.iso")


    if event == sg.WIN_CLOSED:		   # always,  always give a way out!
        os.remove(splashcropped)
        break
