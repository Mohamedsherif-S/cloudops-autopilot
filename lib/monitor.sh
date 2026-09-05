#! /bin/bash

get_cpu(){
top -bn1 | grep  "Cpu(s):" | awk '{printf "%.1f" , 100 - $8}'
}

get_ram(){
free -m |grep "Mem:" | awk '{printf "%.1f" , $3/$2*100}' 
}

get_disk(){
df -h / | awk 'NR==2 {gsub("%","",$5);print $5}'
}

check_status()
{
local usage=$1
local name=$2
awk -v usage="$usage"  -v name="$name" 'BEGIN{
if( usage > 90 )
	 print "\033[31mCRITICAL\033[0m: " name " usage is too high!"

else if  ( usage > 70 ) 
	   print "\033[33mWARNING\033[0m: " name " usage is high."

else print "\033[32mNORMAL\033[0m: " name " usage is healthy."
}' 
}
check_overall_status(){
local overall_status="\033[32mNORMAL\033[0m"

if [[ $1 == *"CRITICAL"* || $2 == *"CRITICAL"* || $3 == *"CRITICAL"* ]];then 
	overall_status="\033[31mCRITICAL\033[0m"
elif [[ $1 == *"WARNING"* || $2 == *"WARNING"* || $3 == *"WARNING"* ]];then
	overall_status="\033[33mWARNING\033[0m"
fi
	echo -e $overall_status
}

check_high_processes(){
    local type=${1,,}
    local threshold=$2

    if [[ $type == "cpu" ]]; then
        ps aux --sort=-%cpu | awk -v threshold="$threshold" '
        NR > 1 && $3 > threshold {
            printf "HIGH CPU: PID=%s CPU=%s%% COMMAND=", $2, $3
            for(i=11; i<=NF; i++)
                printf "%s ", $i
            print ""
        }'

    elif [[ $type == "ram" ]]; then
        ps aux --sort=-%mem | awk -v threshold="$threshold" '
        NR > 1 && $4 > threshold {
            printf "HIGH RAM: PID=%s RAM=%s%% COMMAND=", $2, $4
            for(i=11; i<=NF; i++)
                printf "%s ", $i
            print ""
        }'
    fi
}
check_zombie_processes(){
    local result
    local count

    result=$(ps -eo pid=,ppid=,stat=,comm= | awk '$3 ~ /^Z/ {
        printf "ZOMBIE: PID=%s PPID=%s COMMAND=%s\n", $1, $2, $4
    }')

    if [[ -n "$result" ]]; then
        count=$(printf "%s\n" "$result" | wc -l)

        echo "Zombie Processes: $count"

        if [[ $count -gt 5 ]]; then
            echo -e "\033[31mCRITICAL\033[0m: Too many zombie processes detected!"
        else
            echo -e "\033[33mWARNING\033[0m: Zombie processes detected."
        fi

        echo "$result"
    else
        count=0
        echo "Zombie Processes: $count"
        echo -e "\033[32mNORMAL\033[0m: No zombie processes detected."
    fi
}
