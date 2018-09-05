from Tkinter import *
import subprocess
import shlex
import time
import os
import signal
import time
import psutil
import re

# cant use ieee 80211n while no brige mode is on 
# input your network interfaces here: use 'ifconfig -a' to list all network interfaces  
OPTIONS = [
"choose internet source","wlp1s0","enp2s0","lo","anbox0"
] 
OPTIONS1 = [
"choose hotspot source","wlp1s0","enp2s0","lo","anbox0"
]
OPTIONS2 = [
"bridge mode", "no-bridge-mode"
]
OPTIONS3 = [
"internet hotspot", "no-internet-hotspot"
]
OPTIONS4 = [
"ieee 80211n mode", "no-ieee-80211n-mode"
]
master = Tk()
variable = StringVar(master)
variable1 = StringVar(master)
variable2 = StringVar(master)
variable3 = StringVar(master)
variable4 = StringVar(master)
variable.set(OPTIONS[0]) # default value
variable1.set(OPTIONS1[0]) # default value
variable2.set(OPTIONS2[1]) # default value
variable3.set(OPTIONS3[0]) # default value
variable4.set(OPTIONS4[1]) # default value
w = OptionMenu(master, variable, *OPTIONS)
w1 = OptionMenu(master, variable1, *OPTIONS1)
w2 = OptionMenu(master, variable2, *OPTIONS2)
w3 = OptionMenu(master, variable3, *OPTIONS3)
w4 = OptionMenu(master, variable4, *OPTIONS4)
w.grid(row = 3, column = 9)
w.pack()
w1.pack()
w2.pack()
w3.pack()
w4.pack()
master.title("HotSpot")

#hotspot name field
label1 = Label(master, text="hotspot name")
e1 = Entry(master, bd =5)
#hotspot password field 
label2 = Label(master, text="hotspot password")
e2 = Entry(master, bd =5)
#hotspot on time need help with kiling subprocces any help would be nice 
#label3 = Label(master, text="hotspot on time in minutes")
#e3 = Entry(master, bd =5)

def ok():
    #checks to see if bridge mode is needed
    #print(variable3.get())
    bridge = variable2.get()             
    internet = variable3.get()
    sec = variable4.get()
    print('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')  
    if bridge in ('bridge mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'): 
                process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge'  + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'): 
                process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' +    variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('bridge mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')) 
                
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'): 
                process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '-n' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'): 
                process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'): 
                subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass


#no-bridge-internet-80211n 
#process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
#no-bridge-internet-no-80211n 
#process = subprocess.call(shlex.split('./create_ap.sh ' +  ' ' + '-n' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
#no-bridge-no-internet-80211n 
#process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
#no-bridge-no-internet-no-80211n 
#process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
button = Button(master, text="OK", command=ok) 
button.pack(side = BOTTOM)

label1.pack()
e1.pack()

label2.pack()
e2.pack()

#label3.pack()
#e3.pack()

mainloop()
