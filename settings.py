from Tkinter import *
import subprocess
import shlex
import time
import os
import signal
import time
import psutil
import re
 
# input your network interfaces here: use 'ifconfig -a' to list all network interfaces  
OPTIONS = [
"wlp1s0","enp2s0","lo","anbox0"
] 
OPTIONS1 = [
"wlp1s0","enp2s0","lo","anbox0"
]
OPTIONS2 = [
"-m bridge", "no bridge mode"
]
master = Tk()
variable = StringVar(master)
variable1 = StringVar(master)
variable2 = StringVar(master)
variable.set(OPTIONS[0]) # default value
variable1.set(OPTIONS1[0]) # default value
variable2.set(OPTIONS2[0]) # default value
w = OptionMenu(master, variable, *OPTIONS)
w1 = OptionMenu(master, variable1, *OPTIONS1)
w2 = OptionMenu(master, variable2, *OPTIONS2)
w.grid(row = 3, column = 9)
w.pack()
w1.pack()
w2.pack()
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
    if variable2.get() in ('-m bridge'):
        print('./create_ap.sh ' + '-m bridge' + ' ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')
        #process = subprocess.call(shlex.split('./create_ap.sh ' + '-m bridge' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
    else:
        print('./create_ap.sh ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + '')
        #process = subprocess.call(shlex.split('./create_ap.sh ' + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
    #starts hotspot
    #process = subprocess.call(shlex.split('./create_ap.sh ' +  + variable.get()  + ' ' + variable1.get() +  ' ' + e1.get() + ' ' + e2.get() + ''))  
button = Button(master, text="OK", command=ok) 
button.pack(side = BOTTOM)

label1.pack()
e1.pack()

label2.pack()
e2.pack()

#label3.pack()
#e3.pack()

mainloop()
