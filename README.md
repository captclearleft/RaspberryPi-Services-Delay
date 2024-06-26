# RaspberryPi-Services-Delay
Delay Start of Raspberry Pi Services. Increase reliability for hardware dependencies.


The shell scripts written here are written with basic hacky coding skills and are not meant for production or commercial use. These sripts are for educational use as an example. Create a folder in the usr directory for your scripts. 

sudo mkdir /usr/scripts #scripts dir created.


These ".service" files are modified to wait for the "check_wlan0.service" and "check_wlan0mon.service" before starting other services.  This allows for the wifi adapters to come online prior to other services needing them.  The delays are set pretty high (ie 30 seconds on the wlan0ready.sh)(this can be reduced based on your system).  


REMOVE ALL REFRENCES TO: "gpioset gpiochip0 5" if you are NOT using an LED on pin 5 (gpiod refrence).  I use LEDs as simple indicators of what the program is doing.


If you are not familiar with how to use these - Simply - put the .sh files in a directory /usr/scripts... make them executable- "sudo chmod +x wlan0ready.sh" .  Add the ".service" files to the /etc/systemd/system directory.  Refresh the systemctl with "sudo systemctl daemon-reload", then enable them with "sudo systemctl enable whateverservice.service"... 


The bettercap service waits for check_wlan0mon.service, then the pwngrid-peer waits for check_wlan0mon.service...
