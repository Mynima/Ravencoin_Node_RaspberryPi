# Ravencoin_Node_RaspberryPi
Useful scripts for helping to set up and run a Ravencoin Node on your Rapsberry Pi.

## Disclaimer #
This code is an attempt to create and install a necessary items for a Ravencoin Node on Raspberry Pi. Although every attempt has been made to keep this code error free and robust please use at own risk. I will accept no responsibility for any issues resulting either directly, or indirectly from this. Code is provided for educational purposes only.     Happy Node Running Y'all                          

## Setup #
To get started you need to execute the following commands from the terminal on your Raspberry Pi.

This will fetch the files:

* wget https://github.com/Mynima/Ravencoin_Node_101/blob/2020-03-25_First_Attempt/01_Install_Raven_node.sh
* wget https://github.com/Mynima/Ravencoin_Node_101/blob/2020-03-25_First_Attempt/02_Check_Status.sh

Then enter to make the files executable:
* chmod +x ~/01_Install_Raven_node.sh
* chmod +x ~/02_Check_Status.sh 

Finally, type the following command to start the process:
* ~/01_Install_Raven_node.sh

If you have already installed and would like to check the status of your Node use the following command:
* ~/02_Check_Status.sh


## Thanks #
Special thanks to Jeroz_ and Ravenland, whom created the original wiki guide on which this script was created. It can be found at https://raven.wiki/wiki/RaspberryPi. You can also find a summary version of the steps in this guide and that have been used throughout this script to on my blog at Publis0x at: https://www.publish0x.com/hobbyist-mining/raspberry-pi-project-03-rvn-node-for-beginners-xndzzl       


