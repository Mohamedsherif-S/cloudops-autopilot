#! /bin/bash

ss -tunpl | awk 'NR > 1 {

    address = $

    if (address !~ /^\[/) {

        split(address, parts, ":")

        ip = parts[1]
        port = parts[2]

    }

    else {

        sub(/^\[/, "", address)

        split(address, parts, "]:")

        ip = parts[1]
        port = parts[2]

    }

    print "IP:", ip, "PORT:", port
}'