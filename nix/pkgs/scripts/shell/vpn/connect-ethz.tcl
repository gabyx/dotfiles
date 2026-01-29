#!/usr/bin/expect -f

# Set timeout in seconds
set timeout 90

set fh [open "~/.config/vpn/eth-zurich-credentials" r]
set lines [split [read $fh] "\n"]
close $fh

set network [lindex $lines 0]
set group [lindex $lines 1]
set username [lindex $lines 2]

# Prompt for username
stty -echo
send_user "Password: "
expect_user -re "(.*)\n"
set password $expect_out(1,string)
send_user "\n"
stty echo

# Prompt OTP
send_user "One Time Password: "
expect_user -re "(.*)\n"
set otp $expect_out(1,string)
send_user "\n"

# Start the VPN CLI (replace with your actual command)
spawn bash -c "eval \"\$(gabyx::shell-source)\"; gabyx::vpn_connect '$network';"

# Handle GROUP selection automatically
expect {
    -re "GROUP:.*" {
        send "$group\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for GROUP prompt\n"
        exit 1
    }
}

# Look for the username prompt
expect {
    -re "Username:.*" {
        send "$username@$group.ethz.ch\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for username prompt\n"
        exit 1
    }
}

# Look for the password prompt (first)
expect {
    -re "Password:" {
        send "$password\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for first password prompt\n"
        exit 1
    }
}

# Look for the password prompt (OTP, if needed)
expect {
    -re "Password:" {
        send "$otp\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for first password prompt\n"
        exit 1
    }
}

# Wait for the final confirmation or prompt
expect {
    -re ".*" {
        # Done, you can capture output here if needed
    }
}

# Interact if you want to keep the session open
interact
