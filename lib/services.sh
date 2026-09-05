#! /bin/bash

check_service(){
local service=$1
if systemctl list-unit-files --type=service | grep -q "^$service.service";then
	echo  "Service exists: $service"
    status=$(systemctl is-active "$service")
    if [[ $status == "active" ]];then 
        echo -e "Status is : \033[32mRUNNING\033[0m"
    elif [[ $status == "inactive" ]]; then 
        echo -e "Status is : \033[33mSTOPPED\033[0m"
    elif [[ $status == "failed" ]]; then
        echo -e "Status is : \033[31mFAILED\033[0m"
    else echo -e "Status is : \033[31mUNKNOWN\033[0m"
    fi

else
        echo -e "Status is : \033[31mNOT INSTALLED\033[0m"
    fi
}