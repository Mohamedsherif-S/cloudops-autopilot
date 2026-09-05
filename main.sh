#! /bin/bash

source ./lib/monitor.sh
source ./lib/services.sh
source ./lib/logs.sh

echo "=============================="
echo "     CLOUDOPS AUTOPILOT"
echo "=============================="

echo "System Check Starting..."
echo

cpu=$(get_cpu )
ram=$(get_ram )
disk=$(get_disk)
CPU_STATUS=$(check_status "$cpu" "CPU")
RAM_STATUS=$(check_status "$ram" "RAM")
DISK_STATUS=$(check_status "$disk" "DISK")
OVERALL_STATUS=$(check_overall_status "$CPU_STATUS" "$RAM_STATUS" "$DISK_STATUS")



echo "Your CPU Usage : $cpu%"
echo "$CPU_STATUS"
echo 
echo "Your RAM Usage : $ram%"
echo "$RAM_STATUS"
echo 
echo "Your DISK Usage : $disk%"
echo "$DISK_STATUS"
echo 
echo "=============================="
echo "   OVERALL SYSTEM STATUS      " 
echo "=============================="
echo -e "Overall status:" $OVERALL_STATUS
echo 
echo "=============================="
echo "  HIGH CPU PROCESSES          "
echo "=============================="
echo
check_high_processes "CPU" 7

echo
echo "=============================="
echo "  HIGH RAM PROCESSES          "
echo "=============================="
echo
check_high_processes "RAM" 10
echo
echo "=============================="
echo "  ZOMBIE PROCESSES            "
echo "=============================="
echo

check_zombie_processes

echo
echo "=============================="
echo "       SERVICES STATUS        "
echo "=============================="

services=("ssh" "nginx" "docker" "cron" )

for service in "${services[@]}"; do
    check_service "$service"
    echo
done
echo
echo "=============================="
echo "  SSH LOG INTELLIGENCE        "
echo "=============================="
echo

check_ssh_authentication

echo
echo "=============================="
echo "  SYSTEM ERROR INTELLIGENCE"
echo "=============================="
echo

check_system_errors