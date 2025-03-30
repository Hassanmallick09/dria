#!/bin/bash

tput reset
tput civis

# Color functions
show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Script stopped"
    echo
    exit 0
}

incorrect_option() {
    echo
    show_red "Invalid option. Please choose from the available options."
    echo
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Success"
        echo
    else
        sleep 1
        echo
        show_red "Failed"
        echo
    fi
}

check_rust_version() {
    if command -v rustc &> /dev/null; then
        INSTALLED_RUST_VERSION=$(rustc --version | awk '{print $2}')
        show_orange "Installed Rust version: $INSTALLED_RUST_VERSION"
    else
        INSTALLED_RUST_VERSION=""
        show_blue "Rust not installed"
    fi
    echo
}

install_or_update_rust() {
    if [ -z "$INSTALLED_RUST_VERSION" ]; then
        process_notification "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        show_green "Rust installed successfully"
    elif [ "$INSTALLED_RUST_VERSION" != "$LATEST_RUST_VERSION" ]; then
        process_notification "Updating Rust"
        rustup update
        show_green "Rust updated successfully"
    else
        show_green "Rust already at latest version ($LATEST_RUST_VERSION)"
    fi
    echo
}

print_logo() {
    echo
    show_orange "  _______  .______       __       ___ " && sleep 0.2
    show_orange " |       \ |   _  \     |  |     /   \ " && sleep 0.2
    show_orange " |  .--.  ||  |_)  |    |  |    /  ^  \ " && sleep 0.2
    show_orange " |  |  |  ||      /     |  |   /  /_\  \ " && sleep 0.2
    show_orange " |  '--'  ||  |\  \----.|  |  /  _____  \ " && sleep 0.2
    show_orange " |_______/ | _|  ._____||__| /__/     \__\ " && sleep 0.2
    echo
    sleep 1
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Preparation"
    echo "2. Installation"
    echo "3. Configuration"
    echo "4. Node Management"
    echo "5. View Logs"
    echo "6. Uninstall"
    echo "7. Exit"
    echo
    read -p "Select option: " option

    case $option in
        1)
            # PREPARATION
            process_notification "Starting system preparation..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y && sudo apt install -y screen"

            process_notification "Checking Rust installation..."
            sleep 2
            install_or_update_rust

            process_notification "Installing Ollama..."
            run_commands "curl -fsSL https://ollama.com/install.sh | sh"
            echo
            show_green "$(ollama --version)"
            echo
            show_green "--- PREPARATION COMPLETED ---"
            echo
            ;;
        2)
            # INSTALLATION
            process_notification "Installing Dria node..."
            run_commands "curl -fsSL https://dria.co/launcher | bash"
            show_green "--- INSTALLATION COMPLETED ---"
            echo
            ;;
        3)
            # CONFIGURATION
            echo
            while true; do
                show_green "------ CONFIGURATION MENU ------ "
                echo "1. Wallet, Port, Models, API"
                echo "2. Referral code"
                echo "3. Back to main menu"
                echo
                read -p "Select option: " option
                echo
                case $option in
                    1)
                        # Wallet, Port, Models, API
                        dkn-compute-launcher settings
                        ;;
                    2)
                        # referrals
                        dkn-compute-launcher referrals
                        ;;
                    3)
                        # EXIT
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # NODE MANAGEMENT
            echo
            while true; do
                show_green "------ NODE MANAGEMENT MENU ------ "
                echo "1. Start node"
                echo "2. Stop node"
                echo "3. Update node"
                echo "4. Back to main menu"
                echo
                read -p "Select option: " option
                echo
                case $option in
                    1)
                        # START
                        process_notification "Starting Dria node..."
                        screen -dmS dria bash -c "cd $HOME/ && dkn-compute-launcher start"
                        show_green "Node started in screen session 'dria'"
                        ;;
                    2)
                        # STOP
                        process_notification "Stopping Dria node..."
                        run_commands "screen -r dria -X quit"
                        ;;
                    3)
                        # UPDATE
                        cd $HOME/
                        dkn-compute-launcher update
                        ;;
                    4)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        5)
            # LOGS
            process_notification "Connecting to node logs..." && sleep 2
            cd $HOME && screen -r dria
            ;;
        6)
            # UNINSTALL
            process_notification "Uninstalling Dria node..."
            echo
            while true; do
                read -p "Confirm node uninstall? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Stopping node..."
                        run_commands "screen -r dria -X quit"

                        run_commands "dkn-compute-launcher uninstall"

                        show_green "--- NODE UNINSTALLED SUCCESSFULLY ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Uninstall cancelled"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        7)
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
