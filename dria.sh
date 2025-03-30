#!/bin/bash

NODENAME="dria"

# Color definitions
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export NC='\033[0m'  # No Color

# Welcome message
echo -e "${YELLOW}Starting Dria node installation...${NC}"
read -p "Please make sure to run this in a screen session (press Enter to continue): "

# Update packages and install dependencies
echo -e "${YELLOW}Updating packages and installing dependencies...${NC}"
sudo apt update && sudo apt install -y ca-certificates curl gnupg ufw expect

# Docker installation function
dockerSetup(){
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."

        # Remove conflicting packages
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done

        # Install Docker prerequisites
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker

        echo "Installing Docker Compose..."

        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        echo -e "${GREEN}Docker installed successfully.${NC}"

    else
        echo -e "${GREEN}Docker is already installed.${NC}"
    fi
}

# Initial setup function
setup() {
    cd /root
    if [ -d "$NODENAME" ]; then
        echo -e "${GREEN}/root/$NODENAME directory already exists. Removing...${NC}"
        rm -rf $NODENAME
        echo -e "${YELLOW}Removed /root/$NODENAME directory.${NC}"
    fi

    mkdir $NODENAME
    echo -e "${YELLOW}Created /root/$NODENAME directory.${NC}"
    cd $NODENAME
}

# Node installation function
installRequirements(){
    echo -e "${YELLOW}Installing required packages for $NODENAME...${NC}"
    sleep 2

    # Install unzip if not present
    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}Installing unzip...${NC}"
        sudo apt install unzip -y
        echo -e "${GREEN}Unzip installed.${NC}"
    else
        echo -e "${GREEN}Unzip is already installed.${NC}"
    fi

    # Install Ollama if not present
    if ! command -v ollama &> /dev/null; then
        echo -e "${YELLOW}Installing Ollama...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}Ollama installed.${NC}"
    else
        echo -e "${GREEN}Ollama is already installed.${NC}"
    fi

    echo -e "${YELLOW}Installing $NODENAME compute node...${NC}"

    # Check if dkn-compute-node directory exists
    if [ -d "/root/$NODENAME/dkn-compute-node" ]; then
        echo -e "${GREEN}Existing dkn-compute-node directory found. Continuing installation...${NC}"
    fi

    # Remove old zip file if exists
    if [ -f "/root/$NODENAME/dkn-compute-node.zip" ]; then
        echo -e "${YELLOW}Removing old dkn-compute-node.zip file...${NC}"
        rm -f /root/$NODENAME/dkn-compute-node.zip
    fi

    # Download and extract the node
    echo -e "${YELLOW}Downloading dkn-compute-node.zip...${NC}"
    curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip
    echo -e "${YELLOW}Extracting dkn-compute-node.zip...${NC}"
    unzip dkn-compute-node.zip -d /root/$NODENAME/
    rm /root/$NODENAME/dkn-compute-node.zip 
    cd /root/$NODENAME/dkn-compute-node
    echo -e "${GREEN}$NODENAME compute node installed successfully.${NC}"
}

# Node execution function
run() {
    echo -e "${YELLOW}Join our Discord: https://discord.com/invite/dria${NC}"
    echo -e "${YELLOW}Dashboard: https://dria.co/edge-ai/${NC}"
    echo -e "${YELLOW}When prompted to select models, we recommend: Ollama${NC}"
    echo -e "${GREEN}The first run will perform tests. If tests pass, detach from screen and create a new session to run the node permanently.${NC}"
    read -p "Do you want to start the node now? (y/n): " response
    if [[ $response == "y" ]]; then
        ./dkn-compute-launcher
    else
        echo -e "${GREEN}LFG (Let's F***ing Go)${NC}"
    fi
}

# Main execution flow
dockerSetup
setup
installRequirements
run
