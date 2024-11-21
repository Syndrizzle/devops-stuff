#!/bin/bash
spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
emojis=("🔍" "📦" "⚙️" "🚀" "🌐" "❓")

# Function for spinner animation
spin() {
    local message=$1
    local emoji=$2
    while :; do
        for i in "${spinner[@]}"; do
            echo -ne "\r\033[K$emoji $i $message"
            sleep 0.1
        done
    done
}

# Function to stop spinner
stop_spin() {
    kill "$1" >/dev/null 2>&1
    echo -e "\r\033[K✅ $2"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function for sub-status spinner
sub_status() {
    local message=$1
    local pid=$2
    spin "$message" "  ↳ " &
    local spinner_pid=$!
    wait "$pid"
    local result=$?
    kill $spinner_pid >/dev/null 2>&1
    if [ $result -eq 0 ]; then
        echo -e "\r\033[K✅ $message"
    else
        echo -e "\r\033[K❌ $message"
        return 1
    fi
}

# Function to get sudo credentials
get_sudo_access() {
    # Check if we already have sudo privileges without a password
    if sudo -n true 2>/dev/null; then
        echo -e "\n✅ Root privileges already available"
        return 0
    fi

    # Check if sudo is needed and available
    if ! command -v sudo >/dev/null; then
        if [ "$(id -u)" -eq 0 ]; then
            # Running as root, no sudo needed
            return 0
        else
            echo "❌ Root privileges are unavailable"
            exit 1
        fi
    fi

    # Need to ask for password
    echo -e "\n🔐 Root privileges are required for installation"
    echo -ne "┌──────────────────────────────────┐\n│ Please enter your sudo password: │\n└──────────────────────────────────┘\n"

    # Try to get sudo credentials
    if ! sudo -v; then
        echo "❌ Failed to obtain sudo privileges"
        exit 1
    fi
}

# Function to detect WSL
is_wsl() {
    if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
        return 0
    else
        return 1
    fi
}

# Install Jenkins function
install_jenkins() {
    local os_type=$1
    local jenkins_version=$2
    local install_log="/tmp/jenkins_install.log"

    case $os_type in
        debian)
            # System update
            (sudo apt-get update) &> "$install_log" &
            sub_status "Updating system" $! || return 1

            # Install dependencies with WSL check
            if is_wsl; then
                (sudo apt-get install -y openjdk-17-jdk fontconfig wslu wget gnupg) &>> "$install_log" &
                sub_status "Installing dependencies (OpenJDK 17, fontconfig, wslu)" $! || return 1
            else
                (sudo apt-get install -y openjdk-17-jdk fontconfig xdg-utils wget gnupg) &>> "$install_log" &
                sub_status "Installing dependencies (OpenJDK 17, fontconfig, xdg-utils)" $! || return 1
            fi

            # Add Jenkins keys and repository
            if [ "$jenkins_version" == "lts" ]; then
                jenkins_url="https://pkg.jenkins.io/debian-stable"
            else
                jenkins_url="https://pkg.jenkins.io/debian"
            fi
            (curl -fsSL $jenkins_url/jenkins.io-2023.key | sudo tee \
            /usr/share/keyrings/jenkins-keyring.asc > /dev/null && \
            echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] $jenkins_url binary/" | \
            sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null) &>> "$install_log" &
            sub_status "Adding Jenkins keys and repository" $! || return 1

            # Final update and install
            (sudo apt-get update && sudo apt-get install -y jenkins) &>> "$install_log" &
            sub_status "Installing Jenkins" $! || return 1
            ;;
        redhat|fedora)
            local pkg_manager
            pkg_manager=$([ "$os_type" == "redhat" ] && echo "yum" || echo "dnf")

            # System update
            (sudo "$pkg_manager" upgrade -y) &>> "$install_log" &
            sub_status "Updating system" $! || return 1

            # Install dependencies
            (sudo "$pkg_manager" install -y fontconfig java-17-openjdk xdg-utils wget) &>> "$install_log" &
            sub_status "Installing dependencies (OpenJDK 17, fontconfig)" $! || return 1

            # Add Jenkins keys and repository
            if [ "$jenkins_version" == "lts" ]; then
                jenkins_url="https://pkg.jenkins.io/redhat-stable"
            else
                jenkins_url="https://pkg.jenkins.io/redhat"
            fi
            (sudo wget -O /etc/yum.repos.d/jenkins.repo $jenkins_url/jenkins.repo && \
             sudo rpm --import $jenkins_url/jenkins.io-2023.key) &>> "$install_log" &
            sub_status "Adding Jenkins keys and repository" $! || return 1

            # Install Jenkins
            (sudo "$pkg_manager" install -y jenkins) &>> "$install_log" &
            sub_status "Installing Jenkins" $! || return 1

            # Reload daemon
            (sudo systemctl daemon-reload) &>> "$install_log" &
            sub_status "Reloading systemd daemon" $! || return 1
            ;;
        arch)
            (sudo pacman -Syu --noconfirm jdk17-openjdk jenkins) &>> "$install_log" &
            sub_status "Installing Jenkins and dependencies" $! || return 1
            ;;
        macos)
            if [ "$jenkins_version" == "lts" ]; then
                (brew install jenkins-lts java17) &>> "$install_log" &
            else
                (brew install jenkins java17) &>> "$install_log" &
            fi
            sub_status "Installing Jenkins and dependencies" $! || return 1
            ;;
    esac
    return 0
}

# Function to check for display server
has_display_server() {
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        return 0
    elif command -v xhost >/dev/null 2>&1 && xhost >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Uninstall Jenkins function
uninstall_jenkins() {
    local os_type=$1
    local uninstall_log="/tmp/jenkins_uninstall.log"

    # Stop Jenkins service if running
    if command -v systemctl >/dev/null && systemctl is-active jenkins >/dev/null 2>&1; then
        (sudo systemctl stop jenkins) &>> "$uninstall_log" &
        sub_status "Stopping Jenkins service" $! || return 1
    fi

    case $os_type in
        debian)
            # Remove Jenkins package
            (sudo apt-get remove --purge -y jenkins) &>> "$uninstall_log" &
            sub_status "Removing Jenkins package" $! || return 1

            # Remove Jenkins repository
            (sudo rm -f /etc/apt/sources.list.d/jenkins.list /usr/share/keyrings/jenkins-keyring.asc) &>> "$uninstall_log" &
            sub_status "Removing Jenkins repository" $! || return 1

            # Remove Java only if not needed by other packages
            (if ! dpkg -l | grep -q "^ii.*openjdk" || [ "$(dpkg -l | grep -c "^ii.*openjdk")" -eq 1 ]; then
                sudo apt-get remove -y openjdk-17-jdk
            fi) &>> "$uninstall_log" &
            sub_status "Cleaning up Java" $! || true

            # Clean package cache
            (sudo apt-get clean && sudo apt-get autoclean) &>> "$uninstall_log" &
            sub_status "Cleaning package cache" $! || true
            ;;
        redhat|fedora)
            local pkg_manager
            pkg_manager=$([ "$os_type" == "redhat" ] && echo "yum" || echo "dnf")

            # Remove Jenkins package
            (sudo "$pkg_manager" remove -y jenkins) &>> "$uninstall_log" &
            sub_status "Removing Jenkins package" $! || return 1

            # Remove Jenkins repository
            (sudo rm -f /etc/yum.repos.d/jenkins.repo) &>> "$uninstall_log" &
            sub_status "Removing Jenkins repository" $! || return 1

            # Remove Java only if not needed
            (if [ "$(rpm -qa | grep -c java-17-openjdk)" -eq 1 ]; then
                sudo "$pkg_manager" remove -y java-17-openjdk
            fi) &>> "$uninstall_log" &
            sub_status "Cleaning up Java" $! || true
            ;;
        arch)
            (sudo pacman -Rns --noconfirm jenkins) &>> "$uninstall_log" &
            sub_status "Removing Jenkins" $! || return 1
            ;;
        macos)
            if brew list jenkins-lts >/dev/null 2>&1; then
                (brew uninstall jenkins-lts) &>> "$uninstall_log" &
            else
                (brew uninstall jenkins) &>> "$uninstall_log" &
            fi
            sub_status "Removing Jenkins" $! || return 1
            ;;
    esac

    # Remove Jenkins data directory
    local jenkins_home
    if [[ "$OSTYPE" == "darwin"* ]]; then
        jenkins_home="/Users/Shared/Jenkins"
    else
        jenkins_home="/var/lib/jenkins"
    fi

    if [ -d "$jenkins_home" ]; then
        (sudo rm -rf "$jenkins_home") &>> "$uninstall_log" &
        sub_status "Removing Jenkins data directory" $! || return 1
    fi

    return 0
}

# Function to get initial admin password
get_jenkins_password() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo cat /Users/Shared/Jenkins/Home/secrets/initialAdminPassword
    else
        sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    fi
}

# Function to check if Jenkins is installed
check_jenkins_status() {
    local os_type=$1
    case $os_type in
        debian|redhat|fedora)
            if command -v jenkins >/dev/null 2>&1 || [ -d "/var/lib/jenkins" ]; then
                echo "installed"
            else
                echo "not_installed"
            fi
            ;;
        arch)
            if pacman -Qi jenkins >/dev/null 2>&1; then
                echo "installed"
            else
                echo "not_installed"
            fi
            ;;
        macos)
            if brew list jenkins-lts >/dev/null 2>&1 || brew list jenkins >/dev/null 2>&1; then
                echo "installed"
            else
                echo "not_installed"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Main script
echo "✨ Jenkins Utility Script"
echo "📦 1. Install Jenkins"
echo "🗑️  2. Uninstall Jenkins"
echo -n "Select an option (1/2): "
read -r option

case $option in
    1)
        # Get sudo access first
        get_sudo_access

        # Detect OS first
        os_type=$(detect_os)
        if [ "$os_type" == "unknown" ]; then
            echo "❌ Unsupported operating system"
            exit 1
        fi

        # Ask for Jenkins version
        echo -ne "${emojis[5]} Do you want to install the LTS or Weekly version of Jenkins?"
        echo -ne "\n   🛟 1. LTS (Long-Term Support)"
        echo -ne "\n   🎢 2. Weekly"
        echo -ne "\nSelect an option (1/2): "
        read -r version_option
        case $version_option in
            1)
                jenkins_version="lts"
                ;;
            2)
                jenkins_version="weekly"
                ;;
            *)
                echo "Invalid option. Defaulting to LTS."
                jenkins_version="lts"
                ;;
        esac

        # Check if Jenkins is already installed
        jenkins_status=$(check_jenkins_status "$os_type")
        if [ "$jenkins_status" == "installed" ]; then
            echo -e "❌ Jenkins is already installed!"
            echo -ne "Would you like to reinstall it? (y/n): "
            read -r reinstall
            if [[ $reinstall != "y" ]]; then
                echo "Installation cancelled."
                exit 0
            fi
            # If reinstalling, uninstall first
            spin "Removing existing Jenkins installation" "${emojis[2]}" &
            spinner_pid=$!
            if ! uninstall_jenkins "$os_type"; then
                kill $spinner_pid 2>/dev/null
                echo -e "\n❌ Failed to remove existing Jenkins installation"
                exit 1
            fi
            stop_spin $spinner_pid "Existing installation removal"
        fi

        # Continue with normal installation
        echo -e "🚀 Starting Jenkins installation... Press Ctrl+C to cancel"
        for i in {5..1}; do
            for s in "${spinner[@]}"; do
                echo -ne "\r\033[K$s Starting in $i seconds..."
                sleep 0.1
            done
        done
        echo -e ""

        # Get sudo access first
        get_sudo_access

        # Step 1: Detect OS
        spin "Detecting operating system" "${emojis[0]}" &
        spinner_pid=$!
        os_type=$(detect_os)
        sleep 2
        stop_spin $spinner_pid "OS Detection"
        echo "Detected OS: $os_type"

        # Step 2: Download Jenkins
        spin "Downloading Jenkins packages" "${emojis[1]}" &
        spinner_pid=$!
        sleep 2
        stop_spin $spinner_pid "Packages downloaded!"

        # Step 3: Install Jenkins
        echo -e "Installing Jenkins..."
        if install_jenkins "$os_type" $jenkins_version; then
            echo -e "✅ Jenkins installation completed!"
        else
            echo -e "\n❌ Jenkins installation failed. Installation process aborted."
            echo "Check install log at: /tmp/jenkins_install.log"
            exit 1
        fi

        # Step 4: Start Jenkins
        echo -ne "Would you like to start Jenkins server? (y/n): "
        read -r start_server
        if [[ $start_server == "y" ]]; then
            spin "Starting Jenkins server" "${emojis[3]}" &
            spinner_pid=$!
            sudo systemctl start jenkins
            sleep 5
            stop_spin $spinner_pid "Server startup"

            echo -ne "Would you like to open Jenkins in browser? (y/n): "
            read -r open_browser
            if [[ $open_browser == "y" ]]; then
                password=$(get_jenkins_password)
                echo -e "\n┌────────────────────────────────────────┐"
                echo -e "│    Initial Admin Password:             │"
                echo -e "│    $password    │"
                echo -e "└────────────────────────────────────────┘"

                if is_wsl; then
                    wslview "http://localhost:8080"
                elif has_display_server; then
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        open "http://localhost:8080"
                    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                        xdg-open "http://localhost:8080"
                    fi
                else
                    echo -e "\n⚠️  No display server detected."
                    echo "Please open http://localhost:8080 in your browser when a display server is available."
                fi
            fi
        fi
        ;;
    2)
        # Get sudo access first
        get_sudo_access

        # Detect OS first
        os_type=$(detect_os)
        if [ "$os_type" == "unknown" ]; then
            echo "❌ Unsupported operating system"
            exit 1
        fi

        # Check if Jenkins is already uninstalled
        jenkins_status=$(check_jenkins_status "$os_type")
        if [ "$jenkins_status" == "not_installed" ]; then
            echo -e "❌ Jenkins is not installed!"
            exit 0
        fi

        # Continue with normal uninstallation
        echo -e "🗑️  Starting Jenkins uninstallation... Press Ctrl+C to cancel"
        for i in {5..1}; do
            for s in "${spinner[@]}"; do
                echo -ne "\r\033[K$s Starting in $i seconds..."
                sleep 0.1
            done
        done
        echo -e ""

        # Get sudo access first
        get_sudo_access

        # Detect OS
        spin "Detecting operating system" "${emojis[0]}" &
        spinner_pid=$!
        os_type=$(detect_os)
        sleep 2
        stop_spin $spinner_pid "OS Detection"
        echo "Detected OS: $os_type"

        # Uninstall Jenkins
        echo -e "Uninstalling Jenkins..."
        if uninstall_jenkins "$os_type"; then
            echo -e "✅ Jenkins has been successfully uninstalled!"
        else
            echo -e "\n❌ Jenkins uninstallation failed. Check uninstall log at: /tmp/jenkins_uninstall.log"
            exit 1
        fi
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo -e "\n👋 BYE!"