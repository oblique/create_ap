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
network = os.listdir('/sys/class/net/')
# run ifconfig and count network outputs example (enp2s0,lo,wlp1s0)
var1, var2, var3, var4 = network 
OPTIONS = [
"choose internet source", var1 , var2, var3, var4
] 
OPTIONS1 = [
"choose hotspot source", var1, var2, var3, var4
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
OPTIONS5 = [
"client", "client isloation"
]
master = Tk()
variable = StringVar(master)
variable1 = StringVar(master)
variable2 = StringVar(master)
variable3 = StringVar(master)
variable4 = StringVar(master)
variable5 = StringVar(master)
variable.set(OPTIONS[0]) # default value
variable1.set(OPTIONS1[0]) # default value
variable2.set(OPTIONS2[1]) # default value
variable3.set(OPTIONS3[0]) # default value
variable4.set(OPTIONS4[1]) # default value
variable5.set(OPTIONS5[1]) # default value
w = OptionMenu(master, variable, *OPTIONS)
w1 = OptionMenu(master, variable1, *OPTIONS1)
w2 = OptionMenu(master, variable2, *OPTIONS2)
w3 = OptionMenu(master, variable3, *OPTIONS3)
w4 = OptionMenu(master, variable4, *OPTIONS4)
w5 = OptionMenu(master, variable5, *OPTIONS5)
w.grid(row = 3, column = 9)
w.pack()
w1.pack()
w2.pack()
w3.pack()
w4.pack()
w5.pack()
master.title("HotSpot")

#hotspot name field
label1 = Label(master, text="hotspot name")
e1 = Entry(master, bd =5)
#hotspot password field 
label2 = Label(master, text="hotspot password")
e2 = Entry(master, bd =5)

def ok():
    #checks to see if bridge mode is needed
    bridge = variable2.get()             
    internet = variable3.get()
    sec = variable4.get()
    client = variable5.get()
#' ' + '--isolate-clients' +
    if bridge in ('bridge mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client'):  
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge'  +   ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'): 
                if client in ('client'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' +    variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('bridge mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')) 
                
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client'): 
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '-n' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client'): 
                    process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client'):
                    subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'): 
                if client in ('client'):
                    subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '-n' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
#---------------------------------------------------------------------------------------

    if bridge in ('bridge mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client-islation'):  
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge'  +  ' ' + '--isolate-clients' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))           
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'): 
                if client in ('client-islation'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '--isolate-clients' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' +    variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('bridge mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client-islation'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' +  ' ' + '--isolate-clients' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')) 
                
    else:
        pass 
    if bridge in ('bridge mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client-islation'): 
                    process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + ' ' + '--isolate-clients' + ' ' + '-n' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('internet hotspot'): 
            if sec in ('no-ieee-80211n-mode'):
                if client in ('client-islation'):
                    process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '--isolate-clients' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('internet hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client-islation'): 
                    process = subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '--isolate-clients' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass
    if bridge in ('no-bridge-mode'):       
         if internet in ('no-internet-hotspot'): 
            if sec in ('ieee 80211n mode'):
                if client in ('client-islation'):
                    subprocess.call(shlex.split('./create_ap.sh ' + ' ' + '--isolate-clients' + ' ' + '-n' + ' ' + '--ieee80211n --ht_capab [HT40+] ' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
    else:
        pass 
    if bridge in ('no-bridge-mode'): 
        if internet in ('no-internet-hotspot'): 
            if sec in ('no-ieee-80211n-mode'): 
                if client in ('client-islation'):
                    subprocess.call(shlex.split('./create_ap.sh ' +  ' ' + '--isolate-clients' + ' ' + '-n' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))
    else:
        pass


button = Button(master, text="OK", command=ok) 
button.pack(side = BOTTOM)

label1.pack()
e1.pack()

label2.pack()
e2.pack()

mainloop()
