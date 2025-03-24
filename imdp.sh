#!/bin/bash 

# |================================|
# |                                |
# | IMDP: INSTALL MY DAMN PACKAGES |
# |                                |
# |================================|

# =============================
# Configuration Options
# (0 = false, 1 = true)
USE_UNTESTED_PACKAGE_MANAGERS=1 # apt, pacman, zypper, emerge, apk, snap. If you find any bugs with this setting, please report it.
VERBOSE=1                       # Prints out warnings for package managers that are not installed.
declare -a extra_managers=()    # Try listing some extra package managers here. No garantees that they will work, will be attempted to install like DNF.
BYPASS_ROOT_CHECK=0             # Set to 1 to bypass the root check. For debugging only, it is unlikely that you will be able to install packages as root.
SAVE_INSTALL_LOG=0              # Set to 1 to save the output of the package managers to a log file.
# =============================
# arrays of package managers
declare -a package_managers=("dnf" "yum" "brew" "flatpak")
declare -a package_managers_untested=("apt-get" "pacman" "zypper" "emerge" "apk" "snap")
# =============================
# install commands for each package manager (configure this to make things work and please submit a PR)
declare -a package_managers_commands=(
  "dnf install -y"
  "yum install -y"
  "brew install"
  "flatpak install -y"
)

# I hope these work. If you can confirm, open an issue and I'll add them to the main list.
declare -a package_managers_untested_commands=(
  "apt-get install -y"
  "pacman -S --noconfirm"
  "zypper install -y"
  "emerge" # gentoo you're weird
  "apk add"
  "snap install"
)

# If you want to set up separate code for a package manager different from just "<MANAGER> install -y" uncomment this and write it.
# declare -a extra_managers_commands=(
# )


# =============================
#         BEGIN CODE
# =============================

# Check for root
if [ `whoami` == "root" ]; then
  if [ $BYPASS_ROOT_CHECK == 0 ]; then
    echo -e "\033[31mIMDP: ERROR | Do not run this script as root/with sudo.\033[0m"
    exit 1 # Exit if running as root
  fi
fi

# make sure the first parameter exists
if [ -z "$1" ]; then
  echo -e "\033[31mIMDP ERROR: Please specify a package to install.\033[0m"
  echo "Usage: $0 <package>"
  exit 1
fi


# Figure out what package managers are installed
echo -e "\033[32mIMDP: Checking for package managers...\033[0m"



# Function for checking if a package manager is installed
function manager_is_installed() {
  local -n managers=$1 # first parameter is the array of managers

  if [ $2 -eq 1 ]; then # second parameter is the condition to be met. (For no condition, just pass the number 1)
    for i in "${managers[@]}"; do  # iterate through the array
      if [ -x "$(command -v $i)" ]; then # check if the item in the array is a command
        echo -e "\033[32mIMDP: Found $i.\033[0m"
      else
        if [ $VERBOSE == 1 ]; then
          echo -e "\033[33mIMDP: WARNING | $i not found.\033[0m" # if verbose is true, print a warning if not found
        fi
      fi
    done
  fi
}

manager_is_installed package_managers 1 # normal tested package managers

manager_is_installed package_managers_untested $USE_UNTESTED_PACKAGE_MANAGERS # untested package managers that I'll support eventually

manager_is_installed extra_managers 1 # extra package managers set by the user
