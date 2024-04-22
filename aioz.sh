#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges to run."
    echo "Please try running this script again with 'sudo -i' to switch to root, then execute the script."
    exit 1
fi

# Node installation function
function install_node() {

apt update
apt install screen -y

# Download the compressed package for AIOZ dCDN CLI node
echo "Downloading AIOZ dCDN CLI node..."
curl -LO https://github.com/AIOZNetwork/aioz-dcdn-cli-node/files/13561211/aioznode-linux-amd64-1.1.0.tar.gz

# Extract the downloaded file
echo "Extracting files..."
tar xzf aioznode-linux-amd64-1.1.0.tar.gz

# Move the extracted directory to a new location
mv aioznode-linux-amd64-1.1.0 aioznode

# Verify if the node is runnable by checking its version
echo "Verifying AIOZ dCDN CLI node version..."
./aioznode version

# Generate a new mnemonic and private key, and save the private key to a file
echo "Generating a new mnemonic and private key..."
./aioznode keytool new --save-priv-key privkey.json

echo "=============================Backup wallet and mnemonic, needed below==================================="

# Confirm backup
read -p "Have you backed up your wallet and mnemonic? (y/n) " backup_confirmed
if [ "$backup_confirmed" != "y" ]; then
        echo "Please backup your mnemonic first before continuing with the script."
        exit 1
fi

# Run the node with the specified home directory and private key file
echo "Starting AIOZ dCDN CLI node..."
screen -dmS aioznode ./aioznode start --home nodedata --priv-key-file privkey.json

# Remind users about the notes on automatic updates and permission settings
echo "Use 'screen -r aioznode' to monitor the operation."

}

function check_status() {
./aioznode stats

}

function reward_balance() {
    ./aioznode reward balance
}

function withdraw_balance() {
read -p "Please enter wallet address: " wallet_address
read -p "Please enter withdrawal amount: " math
./aioznode reward withdraw --address $wallet_address --amount ${math}aioz --priv-key-file privkey.json

}
# Main menu
function main_menu() {
    while true; do
        clear
        echo "To exit the script, press ctrl c on the keyboard"
        echo "Please select an action to perform:"
        echo "1. Install Node"
        echo "2. Check Node Status"
        echo "3. Check Earnings"
        echo "4. Claim Earnings"
        read -p "Enter option (1-4): " OPTION

        case $OPTION in
        1) install_node ;;
        2) check_status ;;
        3) reward_balance ;;
        4) withdraw_balance ;;
        *) echo "Invalid option." ;;
        esac
        echo "Press any key to return to the main menu..."
        read -n 1
    done
    
}

# Display the main menu
main_menu
