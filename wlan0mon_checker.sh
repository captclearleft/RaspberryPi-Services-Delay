#!/bin/bash

# Maximum number of attempts
echo 'cc: Starting Wlan0mon check script' | systemd-cat -p warning
max_attempts=5
attempt=1
#led on
gpioset gpiochip0 5=1

#wait
echo 'cc: wlan0mon checker Sleep 5' | systemd-cat -p warning
sleep 5

gpioset gpiochip0 5=0
#Check if in monitor mode.
check_monitor_mode() {
    mode=$(sudo iw dev wlan0mon info | grep -i type)
    if [[ "$mode" == *"type monitor"* ]]; then
        ((consecutive_success++))  # Increment the consecutive success counter
        echo 'cc:wlan0mon is in monitor mode.' | systemd-cat -p warning
    else
        consecutive_success=0  # Reset the consecutive success counter
        echo 'cc: wlan0mon is not in monitor mode.' | systemd-cat -p warning
    fi
}

# Initialize consecutive success counter
consecutive_success=0

# Function to check if wlan0mon exists
function check_wlan0mon_exists() {
    ip link show wlan0mon >/dev/null 2>&1
    return $?
}

# Loop for a maximum of max_attempts times
while [ $attempt -le $max_attempts ]; do
    if check_wlan0mon_exists; then
        # Check if wlan0mon is UNKNOWN
        if ip link show wlan0mon | grep -q "state UNKNOWN"; then
            echo 'cc: wlan0mon is UNKNOWN, Checking if in monitor mode...' | systemd-cat -p warning
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2

                # Loop 5 times with a 3-second delay between attempts
                for (( i=1; i<=5 && consecutive_success < 2; i++ )); do
                    echo "cc: wlan0mon Checker - Attempt $i:" | systemd-cat -p warning
                    check_monitor_mode
                    if [ $i -lt 5 ]; then
                        echo 'cc: Waiting 3 seconds before next attempt...' | systemd-cat -p warning
                        gpioset gpiochip0 5=1
                        sleep .2
                        gpioset gpiochip0 5=0
                        sleep .2
                        gpioset gpiochip0 5=1
                        sleep .2
                        gpioset gpiochip0 5=0
                        sleep .2
                        sleep 3
                    fi
                done
                # Additional check to exit if 2 consecutive successes were achieved
                if [ $consecutive_success -ge 2 ]; then
                    echo 'cc: Exiting loop: wlan0mon is in monitor mode for 2 consecutive attempts.' | systemd-cat -p warning
                else
                    echo 'cc: Maximum attempts reached or less than 2 consecutive successes.' | systemd-cat -p warning
                fi
            exit 0  # Exit successfully if wlan0mon is UNKNOWN
        else
            echo 'cc: Attempt $attempt: wlan0mon is not UNKNOWN. Waiting...' | systemd-cat -p warning
            attempt=$((attempt + 1))
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
            sleep 5  # Adjust the sleep interval as needed
        fi
    else
        echo 'cc: Attempt $attempt: wlan0mon is not available. Waiting...' | systemd-cat -p warning
        attempt=$((attempt + 1))
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
        sleep 5  # Adjust the sleep interval as needed
    fi
done

echo 'cc: Maximum attempts reached. Exiting.' | systemd-cat -p warning
gpioset gpiochip0 5=1
sleep .2
gpioset gpiochip0 5=0
sleep .2
gpioset gpiochip0 5=1
sleep .2
gpioset gpiochip0 5=0
sleep .2
gpioset gpiochip0 5=1
sleep .2
gpioset gpiochip0 5=0
sleep .2
exit 1  # Exit with error if wlan0mon didn't come up after max_attempts

