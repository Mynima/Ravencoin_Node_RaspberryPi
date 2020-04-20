#!/bin/bash

#############################
######Created by Mynima######
#############################

#This code is an attempt to create and install a necessary items for a Ravencoin Node on Raspberry Pi
#Although every attempt has been made to keep this code error free and robust please use at own risk.
#I will accept no responsibility for any issues resulting either directly, or indirectly from this.
#The code is provided for educational purposes only.     Happy Node Running Y'all
#####################################################################################################

#Setup items

#Make sure Pi is up-to-date
read -p "First thing we will do is update/upgrade your Raspberry Pi, do you wish to continue? (y/n) " update_yn

if [ $update_yn == "y" ]; then
    sudo apt-get update
    sudo apt-get upgrade
fi

#Check the folder location to see if Daemon exists
if [ -f /usr/local/bin/ravend ];
then
    echo "Ravencoin Daemon already installed."
    sleep 3
    new_install=0
    read -p "Do you want to upgrade? (y/n) " upgrade_node
else
    echo "Ravencoin Daemon not Detected installation beginning."
    sleep 3
    new_install=1
fi

#If already installed Check if the process is running or not
############################################################

if (($new_install == 0 and "$upgrade_node" != "y" )); then
    echo "Checking if process is already running."
    sleep 3
    #Check if process is running and confirm current uptime
    if [[ $(ps -ef | grep -c ravend)  -ne 1 ]]; then
        echo "The Ravencoin Daemon is already running. No additional setup is required."
        sleep 3
        if [ -a /02_Check_Status.sh ]; then
            echo "Here is the current status of your node:"
            sleep 1
            echo " "
            ~/02_Check_Status.sh
            echo " "
            sleep 5
        else
            pid_num=$(pidof ravend)
            pid_time=$(expr $(date +"%s") - $(stat -c%X /proc/$pid_num))
            /bin/echo $pid_time | /usr/bin/awk '{printf "Node has been active for: %d days, %d:%d:%d\n",$1/(60*60*24),$1/(60*60)%24,$1%(60*60)/60,$1%60}';
            sleep 3
        fi   
        echo "If you wish to close out then type 'raven-cli stop' into the terminal and hit ENTER."
        sleep 2
    #If not running then offer to run
    else
        read -p "Node is not running. Would you like to start the node? (y/n) " resp_yn
        if [ "$resp_yn" == "y" ]; then
            echo "Great, starting now."
            sleep 2
            ravend &
            echo "If you wish to close out then type 'raven-cli stop' into the terminal and hit ENTER."
        else
            echo "OK, have a nice day!"
        fi

    fi

#If not already installed then begin process
############################################
else
    echo "First thing we need to do is download the latest version of Ravencoin Daemon."
    sleep 2
    #Check the version exists and download
    ver_check=404
    while (($ver_check == 404)); do
        read -p "Which version do you want to download? (example 3.3.2) " version_num
        ver_check=$(curl -s --head -w %{http_code} https://github.com/RavenProject/Ravencoin/releases/download/v$version_num/raven-$version_num.0-arm-linux-gnueabihf.tar.gz -o /dev/null)
        if (($ver_check == 404)); then 
            echo "Version $version_num does not exist, please try again."
        fi
    done

    #Download and unzip file
    if [ $ver_check -ne 404 ]; then
        echo "Downloading files and extracting version $version_num."
        sleep 2
        cd ~/ 
        wget https://github.com/RavenProject/Ravencoin/releases/download/v$version_num/raven-$version_num.0-arm-linux-gnueabihf.tar.gz 
        tar -xvzf raven-$version_num-arm-linux-gnueabihf.tar.gz 

        echo "Assigning to local binary for access across users"
        sleep 2
        sudo cp ./raven-$version_num/bin/* /usr/local/bin
    fi

    if [ $upgrade_node != "y" ]; then 
        #Download bootstrap, checking if they want to use default
        #########################################################
        bootstrap_check=404
        
        read -p "Do you want to use the default bootstrap from 2019? (y/n) " boot_yn

        if [ $boot_yn == "y" ]; then
            echo "Great, let's download the Ravenland file. This may take some time."
            wget http://bootstrap.ravenland.org/blockchain.tar.gz
            tar -xvzf bootstrap.tar.gz 
            rm bootstrap.tar.gz #deleting to save space 
        else
            while (( $bootstrap_check == 404 )); do
                read -p "Please file please enter the download location, (only .tar.gz files with full http:// address will be accepted). " bootstrap_file
                if [[ "$bootstrap_file" == *".tar.gz"* && "$bootstrap_file" == *"http://"* ]]; then
                    #Check file exists.
                    regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
                    if [[ $bootstrap_file =~ $regex ]]; then
                        echo "Excellent, downloading the file now. This may take some time."
                        wget  $bootstrap_file
                        bootstrap_file_zip=${bootstrap_file##*/}
                        tar -xvzf $bootstrap_file_zip 
                        rm $bootstrap_file_zip #deleting to save space
                        bootstrap_check=200
                    else
                        echo "File doesn't seem to exist. Please try again."
                        sleep 2
                        bootstrap_check=404
                    fi
                else
                    echo "Make sure to provide the full http:// address with relevant file extension '.tar.gz' and check that the file exists."
                    bootstrap_check=404
                    sleep 2
                fi
            done
        fi

        #Set up the config file
        #######################
        echo "We will now create the config file for Ravencoin Daemon. Please make these selections carefully."
        sleep 3
        echo "If you need to go back and modify them later then you can do this by typing 'nano ~/.raven/raven.conf' into the terminal and manually editing."
        sleep 5
        echo "If you do manually edit later make sure to press CTRL-O then ENTER, to save your updates and CTRL-X to return to the terminal."
        sleep 3

        #Check if config exists already and if so move to back up
        if [ -a ".raven/raven.conf" ]; then 
            date_time=$(date --utc +%FT%TZ)
            #Check for back up folder and create if none
            if [ -d ".raven/backup_config/" ]; then
                sudo mv ~/.raven/raven.conf ~/.raven/backup_config/raven_$date_time.conf
                echo "Old config file found, this was moved to '.raven/backup_config/' back up file named: 'raven_$date_time.conf'."
                sleep 3
            else
                sudo mkdir ~/.raven/backup_config
                sudo mv ~/.raven/raven.conf ~/.raven/backup_config/raven_$date_time.conf
                echo "Old config file found, this was moved to '.raven/backup_config/' back up file named: 'raven_$date_time.conf'."
                sleep 3
            fi
        fi


        #Populate Config file
        #####################
        read -p "Do you want to include RPC information in the config file, this is optional? (y/n) " rpc_yn

        if [ $rpc_yn == "y" ]; then
            rpc_ok=0
            while (( $rpc_ok == 0 )); do
                read -p "Supply chosen RPC username: " rpc_user
                read -p "Supply chosen RPC password (note that this will be broadcast unecripted on your network): " rpc_pass
                read -p "Supply chosen RPC allowed IP: " rpc_ip

                echo "RPC Username is $rpc_user"
                echo "RPC Password is $rpc_pass"
                echo "RPC allowed IP is $rpc_ip"
                sleep 4
                read -p "Is this information correct? (y/n)" rpc_correct
                if [ $rpc_correct == "y" ]; then
                    rpc_ok=1
                fi
            done
            
            #Creating Config File with RPC
            echo "Creating config file (inc. RPC)."
            sleep 2
            is_num=0
            while (( $is_num == 0 )); do
                read -p "What is the maximum size of your SD card? (GB, numeric only)" sd_size
                re='^[0-9]+$'
                if ! [[ $sd_size =~ $re ]] ; then
                    echo "Please only enter number, in GB."
                    sleep 2
                    is_num=0
                else
                    size_sd_mb=$(expr $sd_size \* 1000)
                    if [ $size_sd_mb -ge 42000 ];then
                        prune_size=42000
                    elif [ $size_sd_mb -le 2000 ]; then
                        prune_size=2000
                    else
                        prune_size=$(expr $size_sd_mb - 2000)
                    fi
                    echo "Great setting prune to be $prune_size."
                    sleep 2
                    is_num=1 
                fi
            done

            #Create the Config file
            touch ~/.raven/raven.conf
            /bin/cat <<EOM >~/raven.conf
rpcuser=$rpc_user
rpcpassword=$rpc_pass
rpcallowip=$rpc_ip #IP_ADDRESS_OF_HOST_YOU_ACCESS_RAVEN-CLI_FROM 
server=1 
upnp=1 
dbcache=800 
maxmempool=50 
disablewallet=1 
logips=1 
maxconnections=40 
prune=$prune_size 
maxuploadtarget=5000  
EOM
        else
            #Creating Config File
            echo "Creating config file (excl. RPC)."
            sleep 2
            is_num=0
            while (( $is_num == 0 )); do
                read -p "What is the maximum size of your SD card? (GB, numeric only)" sd_size
                re='^[0-9]+$'
                if ! [[ $sd_size =~ $re ]] ; then
                    echo "Please only enter number, in GB."
                    sleep 2
                    is_num=0
                else
                    size_sd_mb=$(expr $sd_size \* 1000)
                    if [ $size_sd_mb -ge 42000 ];then
                        prune_size=42000
                    elif [ $size_sd_mb -le 2000 ]; then
                        prune_size=2000
                    else
                        prune_size=$(expr $size_sd_mb - 2000)
                    fi
                    echo "Great setting prune to be $prune_size."
                    sleep 2
                    is_num=1 
                fi
            done

            #Create the Config file
            touch ~/.raven/raven.conf
            /bin/cat <<EOM >~/raven.conf
server=1 
upnp=1 
dbcache=800 
maxmempool=50 
disablewallet=1 
logips=1 
maxconnections=40 
prune=$prune_size 
maxuploadtarget=5000  
EOM
        fi

        #Start running Daemon
        #####################
        echo "There are a few other steps to complete, however, we are now ready to start the Daemon."
        sleep 2
        ravend &
        echo "Ravencoin Daemon was started."

        #Security
        #########
        echo "We will now set up some security measures by using the Uncomplicated Firewall (ufw)."
        sleep 3

        #Set up port for Ravencoin
        echo "Making sure listening ports are open for communication with the Ravencoin network."
        sleep 2
        sudo iptables -A INPUT -p tcp --dport 8767 -j ACCEPT 
        sudo iptables -A INPUT -p udp --dport 8767 -j ACCEPT 

        #Security: Firewall
        echo "Installing ufw, this shouldn't take too long."
        sleep 2
        sudo apt-get install ufw
        echo "Setting up rules for connections. Specifically: Limiting SSH, and allowing access to port 8767. Please make sure you've forward this port for your Pi on your Router."
        sleep 4
        sudo ufw limit ssh
        sudo ufw allow 8767 comment 'Ravencoin'

        read -p "Do you want to allow access for another specific IP address (note that you can add this later if you need to, but it will be necessary if you wish to connect with TightVNC)? (y/n) " access_yn
        if [ $access_yn == "y" ]; then
            read "Please add the IP address you wish to give access to: " other_ip
            sudo ufw allow from $other_ip
        fi
        
        #Start ufw
        echo "Starting ufw now."
        sleep 2
        sudo ufw enable
        
        read -p "Do you also want to add fail2ban, for additional protection against brute force attacks? (y/n) " fail2_yn
        if [ $fail2_yn == "y" ]; then
            echo "Installing Fail2Ban."
            sleep 2
            sudo apt install fail2ban
        fi


        echo "Checking connections/IP rules."
        sleep 2
        sudo ufw status verbose
        netstat | grep :8767
        if [ $fail2_yn == "y" ]; then
            sudo fail2ban-client status
        fi
        #Congratulations
        ################
        echo "  "
        echo "  "
        echo "  "
        echo "CONGRATULATIONS!!! You are now up and running with your very own Ravencoin Node."
        sleep 3
        echo "Thank you for supporting the network!"
        sleep 2
        echo "  "
        echo "  "
        echo "  "
        echo "If you installed the 02_Check_Status.sh file as well then you can now use this (by typing '~/02_Check_Status.sh') to check on the status of your blockchain."
        sleep 5
    else
        #Congratulations
        ################
        echo "  "
        echo "  "
        echo "  "
        echo "CONGRATULATIONS!!! You've upgraded the Ravencoin Node."
        sleep 3
        echo "Thank you for supporting the network!"
        sleep 2
        echo "Type 'ravend &' to start up the Node."
        sleep 2
        echo "  "
        echo "  "
        echo "  "
        echo "If you installed the 02_Check_Status.sh file as well then you can now use this (by typing '~/02_Check_Status.sh') to check on the status of your blockchain."
        sleep 5
    fi
    
fi


