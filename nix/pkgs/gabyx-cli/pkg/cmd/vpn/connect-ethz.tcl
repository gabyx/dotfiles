#!/usr/bin/expect -f
#
# Connect the ETH Zurich VPN over `$gabyx vpn connect <network>`.
# Run over `gabyx vpn connect-auto` which sets `GABYX_EXE`,
# `GABYX_VPN_NETWORK`, `GABYX_VPN_GROUP`, `GABYX_VPN_USERNAME`,
# `GABYX_VPN_PASSWORD` and `GABYX_VPN_OTP`.

set timeout 90

# Read the env. variables.
# They are removed from the environment to not pass them to the spawned process.
set vars {
    gabyx GABYX_EXE
    network GABYX_VPN_NETWORK
    group GABYX_VPN_GROUP
    username GABYX_VPN_USERNAME
    password GABYX_VPN_PASSWORD
    otp GABYX_VPN_OTP
}
foreach {name var} $vars {
    if {![info exists env($var)] || $env($var) eq ""} {
        send_user "ERROR: Env. variable '$var' is not set.\n"
        exit 1
    }
    set $name $env($var)
    unset env($var)
}

# Start the VPN connection.
spawn $gabyx vpn connect $network

# Answer the group prompt.
expect {
    -re "GROUP:.*" {
        send "$group\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for group prompt.\n"
        exit 1
    }
}

# Answer the username prompt.
expect {
    -re "Username:.*" {
        send "$username\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for username prompt.\n"
        exit 1
    }
}

# Answer the first password prompt.
expect {
    -re "Password:" {
        send "$password\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for password prompt.\n"
        exit 1
    }
}

# Answer the second password prompt (one time password).
expect {
    -re "Password:" {
        send "$otp\r"
    }
    timeout {
        send_user "ERROR: Timeout waiting for one time password prompt.\n"
        exit 1
    }
}

# Hand over to the user until the connection command exits.
interact
