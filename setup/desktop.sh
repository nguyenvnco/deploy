#!/bin/bash

#### SET ENVIRONMENT VARIABLE
# script name
SCRIPT_NAME="desktop.sh"

# color
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
END_COLOR="\e[0m"

# user & group
USER="linux"
GROUP="linux"
PASSWORD='echo $INPUT_PASS'

# file & directory
DIRECTORY=nnn1489 # option
DIRECTORY_LOG=/var/opt/log
FILE_NULL=/dev/null
FILE_RELEASE_INFO=/etc/os-release
FILE_ERROR=error.log
FILE_OK=ok.log
FILE_SUDO=/etc/sudoers

# networking
PING="8.8.8.8"

###############################################################################

#### DEFINED FUNCTION
# check exit code
check_exit_code_status() {
    if [ $? -ne 0 ]; then
        echo "$RED PLEASE RUN COMMAND: cat $DIRECTORY_LOG/$FILE_ERROR TO CHECK ERROR LOG!$END_COLOR"
    else
        echo "$GREEN COMMAND RUN SUCCESSFULLY!$END_COLOR"
    fi
}

check_upgrade() {
    echo "---> CHECKING ADDITIONAL UPGRADE PACKAGES...."

    sudo apt list --upgradable | awk '{ print $1 }' | grep '/' | cut -d'/' -f1 | while read -r PACKAGE_NAME; do
        echo "---> UPGRADING $GREEN $PACKAGE_NAME $END_COLOR PACKAGE...."
        echo "---> RUNNING COMMAND: $GREEN sudo apt upgrade -y $PACKAGE_NAME $END_COLOR"
        
        vnn1489: KIEM TRA XEM TAI SAO CAU LENH NAY LAI KHONG DUOC CHAY
        sudo apt upgrade -y $PACKAGE_NAME 1>> $FILE_OK 2>> $FILE_ERROR
    done
    check_exit_code_status
    
    echo "$GREEN COMPLETE DEPLOY UPGRADE PACKAGE PROCESS!$END_COLOR"
}


# check_upgrade() {
#     echo "---> CHECKING ADDITIONAL UPGRADE PACKAGES...."

#     eval "$PASSWORD | 
#         sudo -S apt list --upgradable | awk '{ print $1 }' | grep '/' | cut -d'/' -f1 |
    
#         while read -r PACKAGE_NAME; do
#             echo '---> UPGRADING $PACKAGE_NAME PACKAGE....'
#             eval '$PASSWORD | sudo -S apt upgrade -y $PACKAGE_NAME 1>> $FILE_OK 2>> $FILE_ERROR'
#         done
#         check_exit_code_status
#     "

#     echo "$GREEN COMPLETE DEPLOY UPGRADE PACKAGE PROCESS!$END_COLOR"
# }



# TESTING WITH EXIT CODE
test_with_exit_code_is_0 () {
    echo "$YELLOW YOU ARE TESTING YOUR CODE WITH EXIT CODE IS 0$END_COLOR"
    exit 0
}

test_with_exit_code_is_1 () {
    echo "$YELLOW YOU ARE TESTING YOUR CODE WITH EXIT CODE IS 1$END_COLOR"
    exit 1
}

# deploy for os is debian or based-on debian
deploy_software_use_apt () {
    echo "---> DEPLOYING WITH APT PACKAGE MANAGEMENT"

    options='
        update
        upgrade
        dist-upgrade
        autoremove
    '

    for option in $options; do
        echo "---> RUNNING COMMAND: $GREEN sudo apt $option -y $END_COLOR"
        eval "$PASSWORD | sudo -S apt $option -y 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
        check_upgrade
        check_exit_code_status
    done

    # vim net-tools openssh-server xz-utils at sshpass python3-pip ncdu 
    # NOTE: gnome-tweaks (use to when close screen, computer still run)
    apps='
        git
        snap
        tmux
        solaar
        ibus-unikey
        gnome-tweaks
        flatpak
        gnome-software-plugin-flatpak
    '

    for app in $apps; do
        echo "---> CHECKING $app EXISTS ON THE SYSTEM OR NOT?"

        if apt list --installed | grep -q "^$app/"; then
            echo "$GREEN THE $app IS INSTALLED.$END_COLOR"
        else
            echo "$YELLOW THE $app IS NOT INSTALLED.$END_COLOR"
            echo "---> RUNNING COMMAND: $GREEN sudo apt install -y $app $END_COLOR"
            eval "$PASSWORD | sudo -S apt install -y $app 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
            check_exit_code_status
            check_upgrade
        fi
    done
}

# install snap app use 1 flag
deploy_software_use_1_flag () {
    echo "---> RUNNING COMMAND: $GREEN sudo snap install $app --classic $END_COLOR"
    eval "$PASSWORD | sudo -S snap install $app --classic 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
    check_exit_code_status
}

# install snap app use 2 flag
deploy_software_use_2_flag () {
    echo "---> RUNNING COMMAND: $GREEN sudo snap install $app --edge --classic $END_COLOR"
    eval "$PASSWORD | sudo -S snap install $app --edge --classic 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
    check_exit_code_status
}

# install apps from snap
deploy_software_use_snap () {
    # NOTE: app use flag --classic: nvim, code
    # TIPS: applications that use flag --classic, should be put at the top inside the array to increase performance
    apps='
        nvim
        code
        node
        curl
        spotify
    '

    for app in $apps; do
        echo "---> CHECKING $app EXISTS ON THE SYSTEM OR NOT?"

        if snap list --all | grep -q "$app"; then
            echo "$GREEN THE $app IS INSTALLED.$END_COLOR"
        else
            echo "$YELLOW THE $app IS NOT INSTALLED.$END_COLOR"
            
            if [ "$app" = "nvim" ]; then
                deploy_software_use_1_flag
            elif [ "$app" = "code" ]; then
                deploy_software_use_1_flag
            elif [ "$app" = "node" ];then
                deploy_software_use_2_flag
            else
                echo "---> RUNNING COMMAND: $GREEN sudo snap install $app $END_COLOR"
                eval "$PASSWORD | sudo -S snap install $app 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
                check_exit_code_status
            fi    
        fi
    done
}

# install apps from flathub
deploy_software_use_flathub () {
    apps='
        com.brave.Browser
        com.spotify.Client
        org.flameshot.Flameshot
        org.libreoffice.LibreOffice
        com.google.Chrome
        org.videolan.VLC
        org.ferdium.Ferdium
        io.dbeaver.DBeaverCommunity
        com.github.unrud.VideoDownloader
    '

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    for app in $apps; do
        echo "---> CHECKING $app EXISTS ON THE SYSTEM OR NOT?"

        if flatpak list | grep -q "$app"; then
            echo "$GREEN THE $app IS INSTALLED.$END_COLOR"
        else
            echo "---> RUNNING COMMAND: $GREEN sudo -S flatpak install flathub -y $app $END_COLOR"
            eval "$PASSWORD | sudo -S flatpak install flathub -y $app 1>> $DIRECTORY_LOG/$FILE_OK 2>> $DIRECTORY_LOG/$FILE_ERROR"
            check_exit_code_status
        fi
    done
}

# deploy_apps_from_official () {
    
# }

###############################################################################

#### DEPLOYMENT
# enter password to automatically install
echo -n "ENTER YOUR PASSWORD: "
stty -echo
read INPUT_PASS
stty echo
echo    # newline

# checking user can execute commands with sudo permission
echo "---> CHECKING $(whoami) USER CAN EXECUTE COMMANDS WITH SUDO PERMISSION...."

sudo -l 1>> $FILE_OK 2>> $FILE_ERROR

if [ $? -eq 0 ]; then
    echo "$GREEN $(whoami) USER CAN RUN COMMANDS ON LINUX WITH SUDO PERMISSION.$END_COLOR"
else    
    echo "$RED $(whoami) USER CANNOT RUN COMMANDS ON LINUX WITH SUDO PERMISSION$END_COLOR"
    echo "---> REFER TO THE FOLLOWING INSTRUCTIONS TO ADD $GREEN $USER $END_COLOR USER INTO $FILE_SUDO FILE."
    echo "---> RUN COMMAND $GREEN su root $END_COLOR AND ENTER PASSWORD"
    echo "---> NEXT, RUN COMMAND $GREEN echo '$USER     ALL=(ALL:ALL) ALL' >> $FILE_SUDO $END_COLOR"
    echo "---> END, RUN COMMAND $GREEN exit $END_COLOR TO EXIT ROOT SESSION"
    echo "---> AFTER ALL THAT, PLEASE RE-RUN $GREEN $SCRIPT_NAME $END_COLOR FILE"
fi

# create file to write log ok, log error message during installation
eval "$PASSWORD | sudo -S mkdir -p $DIRECTORY_LOG"
eval "$PASSWORD | sudo -S touch $DIRECTORY_LOG/$FILE_OK $DIRECTORY_LOG/$FILE_ERROR"
eval "$PASSWORD | sudo -S chown -R $USER:$GROUP $DIRECTORY_LOG"

# create new directory inside user directory (option)
echo "---> CREATING $DIRECTORY DIRECTORY INSIDE /home/$USER...."
eval "$PASSWORD | sudo -S mkdir -p /home/$USER/$DIRECTORY"
echo "$GREEN CREATED $DIRECTORY DIRECTORY INSIDE /home/$USER $END_COLOR."

# checking network
echo "---> CHECKING NETWORK: PING TO $PING...."

if ping -c 1 "$PING" 1>> $DIRECTORY_LOG/$FILE_OK; then
    sleep 1
    echo "$GREEN NETWORK CONNECTION STATUS: OK!$END_COLOR"
else
    echo "$RED NETWORK CONNECTION STATUS: NG!$END_COLOR"
    echo "$RED PLEASE CHECK NETWORK ON THIS SYSTEM!$END_COLOR"
    exit 1
fi

# check distrobution info to select package management to deploy
echo "---> CHECKING PACKAGE MANAGEMENT TO DEPLOY FROM $FILE_RELEASE_INFO...."

distros='
    "Pop"
    "Lubuntu"
    "Ubuntu"
'

for distro in $distros; do
    if grep -q -e "$distro" "$FILE_RELEASE_INFO"; then
        deploy_software_use_apt
        deploy_software_use_snap
        deploy_software_use_flathub
        break
    else
        echo "$RED NOT FOUND $distro INSIDE $FILE_RELEASE_INFO $END_COLOR"
        # exit 1
    fi
done

# # MAKE UBUNTU FASTER
# # remove language-related ign from apt update
# echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/00aptitude