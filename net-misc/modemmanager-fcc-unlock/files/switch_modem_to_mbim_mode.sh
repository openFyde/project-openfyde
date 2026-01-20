#!/bin/bash
# Switch Quectel modem to MBIM mode
# Usage: switch_modem_to_mbim_mode.sh /dev/ttyUSB0

set -e

TTY_DEVICE="$1"

if [ -z "$TTY_DEVICE" ]; then
    echo "Usage: $0 <tty-device>"
    echo "Example: $0 /dev/ttyUSB0"
    exit 1
fi

if [ ! -e "$TTY_DEVICE" ]; then
    echo "Error: Device $TTY_DEVICE does not exist"
    exit 1
fi

echo "Using AT serial port: $TTY_DEVICE"

# Function to send AT command
send_at_command() {
    local cmd="$1"
    local tty="$TTY_DEVICE"

    # Open file descriptor
    exec 3<>"$tty"

    # Configure serial port
    stty -F "$tty" 115200 -echo -icrnl 2>/dev/null || true

    # Send command
    echo -e "${cmd}\r" >&3
    sleep 0.5

    # Read response
    timeout 2 cat <&3 &
    local cat_pid=$!
    sleep 1
    kill $cat_pid 2>/dev/null || true

    # Close file descriptor
    exec 3>&-
}

# Check current USB mode
echo "Checking current USB mode..."
send_at_command 'AT+QCFG="usbnet"'

# Switch to MBIM mode
echo ""
echo "Switching to MBIM mode (usbnet=2)..."
send_at_command 'AT+QCFG="usbnet",2'

# Reboot modem
echo ""
echo "Rebooting modem..."
send_at_command 'AT+CFUN=1,1'

echo ""
echo "Modem is rebooting and will re-enumerate in MBIM mode"
echo "Please wait 5-10 seconds for the modem to come back"
echo ""
echo "After reboot, verify with:"
echo "  mmcli -L"
echo "  ls -la /dev/cdc-wdm*"
echo ""
echo "The modem should now have /dev/cdc-wdm0 device with cdc_mbim driver"
