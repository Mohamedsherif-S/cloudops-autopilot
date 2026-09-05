#!/bin/bash

check_ssh_authentication(){

    local result

    result=$(journalctl | grep -E "Accepted password|Failed password")

    if [[ -z "$result" ]]; then
        echo "SSH Authentication Events: 0"
        echo -e "\033[32mNORMAL\033[0m: No SSH authentication events detected."
        return 0
    fi

    echo "SSH Authentication Events:"
    echo

    printf "%s\n" "$result" | awk '
    {
        event=""
        user=""
        ip=""
        port=""

        for(i=1; i<=NF; i++){

            if($i == "Accepted")
                event="SSH_LOGIN_SUCCESS"

            if($i == "Failed")
                event="SSH_LOGIN_FAILED"

            if($i == "for")
                user=$(i+1)

            if($i == "from")
                ip=$(i+1)

            if($i == "port")
                port=$(i+1)
        }

        if(event == "SSH_LOGIN_FAILED")
            failed_ips[ip]++

        printf "EVENT: %s | USER: %s | IP: %s | PORT: %s\n",
               event, user, ip, port
    }

    END {
        print ""
        print "Failed Attempts By IP:"

        for(ip in failed_ips){

            attempts=failed_ips[ip]

            if(attempts > 5){
                printf "IP: %s | ATTEMPTS: %d | SEVERITY: \033[31mCRITICAL\033[0m | STATUS: \033[31mSUSPICIOUS\033[0m\n",
                       ip, attempts

                printf "\033[31mSECURITY ALERT\033[0m: Suspicious SSH activity from %s\n",
                       ip
            }
            else{
                printf "IP: %s | ATTEMPTS: %d | SEVERITY: \033[33mWARNING\033[0m\n",
                       ip, attempts
            }
        }
    }'
}

check_system_errors(){

    local logs

    logs=$(journalctl -p err -n 50 --no-pager)

    if [[ -z "$logs" ]]; then
        echo "System Errors: 0"
        echo -e "\033[32mNORMAL\033[0m: No system errors detected."
        return 0
    fi

    echo "System Error Intelligence:"
    echo

    
    local soft_lockups
    soft_lockups=$(printf "%s\n" "$logs" | grep "soft lockup")

    if [[ -n "$soft_lockups" ]]; then
        printf "%s\n" "$soft_lockups" | awk '{
            for(i=1; i<=NF; i++){
                if($i ~ /^CPU#[0-9]+$/)
                    cpu=$i

                if($i == "for")
                    duration=$(i+1)

                if($i ~ /^\[/){
                    process=$i
                    gsub(/^\[/, "", process)
                    gsub(/\]$/, "", process)
                }
            }

            printf "EVENT: KERNEL_SOFT_LOCKUP | CPU: %s | DURATION: %s | PROCESS: %s | SEVERITY: \033[31mCRITICAL\033[0m\n",
                   cpu, duration, process
        }'
    fi


  
    local rcu_stalls
    rcu_stalls=$(printf "%s\n" "$logs" |
        grep "rcu_preempt self-detected stall on CPU")

    if [[ -n "$rcu_stalls" ]]; then
        echo "EVENT: KERNEL_RCU_STALL | COMPONENT: rcu_preempt | SEVERITY: \033[31mCRITICAL\033[0m"
    fi


   
    local service_failures
    service_failures=$(printf "%s\n" "$logs" | grep "Failed to start")

    if [[ -n "$service_failures" ]]; then
        printf "%s\n" "$service_failures" | awk '{
            service=$0
            sub(/.*Failed to start /, "", service)

            printf "EVENT: SERVICE_START_FAILURE | SERVICE: %s | SEVERITY: \033[31mCRITICAL\033[0m\n",
                   service
        }'
    fi


   
    local watchdog
    watchdog=$(printf "%s\n" "$logs" | grep "Watchdog timeout")

    if [[ -n "$watchdog" ]]; then
        printf "%s\n" "$watchdog" |
        awk '{
            printf "EVENT: SERVICE_WATCHDOG_TIMEOUT | SEVERITY: \033[31mCRITICAL\033[0m\n"
        }'
    fi


    
    local driver_errors
    driver_errors=$(printf "%s\n" "$logs" | grep "\*ERROR\*")

    if [[ -n "$driver_errors" ]]; then
        printf "%s\n" "$driver_errors" |
        awk '{
            printf "EVENT: KERNEL_DRIVER_ERROR | SEVERITY: \033[31mCRITICAL\033[0m | MESSAGE: %s\n", $0
        }'
    fi


   
    local network_errors
    network_errors=$(printf "%s\n" "$logs" | grep "Connection refused")

    if [[ -n "$network_errors" ]]; then
        printf "%s\n" "$network_errors" |
        awk '{
            printf "EVENT: NETWORK_CONNECTION_ERROR | SEVERITY: \033[33mWARNING\033[0m | MESSAGE: %s\n", $0
        }'
    fi


   
    local block_errors
    block_errors=$(printf "%s\n" "$logs" | grep "Can.t open blockdev")

    if [[ -n "$block_errors" ]]; then
        printf "%s\n" "$block_errors" |
        awk '{
            printf "EVENT: BLOCK_DEVICE_ERROR | SEVERITY: \033[33mWARNING\033[0m | MESSAGE: %s\n", $0
        }'
    fi


   
    local daemon_errors
    daemon_errors=$(printf "%s\n" "$logs" | grep "unable to locate daemon")

    if [[ -n "$daemon_errors" ]]; then
        printf "%s\n" "$daemon_errors" |
        awk '{
            printf "EVENT: DAEMON_ERROR | SEVERITY: \033[33mWARNING\033[0m | MESSAGE: %s\n", $0
        }'
    fi


    
    local tty_errors
    tty_errors=$(printf "%s\n" "$logs" | grep "get tty for session")

    if [[ -n "$tty_errors" ]]; then
        printf "%s\n" "$tty_errors" |
        awk '{
            printf "EVENT: TTY_ERROR | SEVERITY: \033[33mWARNING\033[0m | MESSAGE: %s\n", $0
        }'
    fi
}