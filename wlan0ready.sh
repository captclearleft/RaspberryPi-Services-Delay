#!/bin/bash

# Maximum number of attempts
echo 'cc: Starting Wlan0 wait script' | systemd-cat -p warning
max_attempts=5
attempt=1
#led on
gpioset gpiochip0 5=1

#wait
echo 'cc: Sleep 30' | systemd-cat -p warning
sleep 30

gpioset gpiochip0 5=0
# Function to check if wlan0 exists
function check_wlan0_exists() {
    ip link show wlan0 >/dev/null 2>&1
    return $?
}

# Loop for a maximum of max_attempts times
while [ $attempt -le $max_attempts ]; do
    if check_wlan0_exists; then
        # Check if wlan0 is Down
        if ip link show wlan0 | grep -q "state DOWN"; then
            echo 'cc: wlan0 is DOWN' | systemd-cat -p warning
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2
            gpioset gpiochip0 5=1
            sleep .2
            gpioset gpiochip0 5=0
            sleep .2

            exit 0  # Exit successfully if wlan0 is DOWN
        else
            echo 'cc: Attempt $attempt: wlan0 is not DOWN. Waiting...' | systemd-cat -p warning
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
        echo 'cc: Attempt $attempt: wlan0 is not available. Waiting...' | systemd-cat -p warning
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
exit 1  # Exit with error if wlan0 didn't come up after max_attempts

