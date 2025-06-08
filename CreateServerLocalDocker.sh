##########################################
###### DIRECTIONS FOR CREATING BASH ######
##########################################
# mkdir /home/scripts
# nano /home/scripts/createserver.sh
# COPY AND PASTE SCRIPT INTO NANO
# chmod +x /home/scripts/createserver.sh
# /home/scripts/createserver.sh
##########################################
########## SCRIPT WILL INSTALL ###########
### DOCKER, PORTAINER, NFS-COMMON, FTP ###
################## AND ###################
########## WILL MOUNT NFS SHARE ##########
########### REPLACE ALL README ###########
##########################################

#!/bin/bash   

    RED='\e[31m'
    GREEN='\e[32m'
    BLUE='\e[34m'
    RESET='\e[0m'


    NAS_IPADDRESS=NAS_IP_ADDRESS #
    PLEXNFSBASELOC=PLEXMOUNTADDRESS:/mnt/user/Plex_Media #Insert serverfiles/PlexMedia file NFS share: Example 192.168.1.22:/mnt/users/Plex_Media


echo -e "${BLUE}Creating mount Files${RESET}"
sudo mkdir /mnt/PlexMedia
sudo mkdir /mnt/ServerFiles
sudo mkdir /srv/
sudo mkdir /srv/dockerdata
# sudo mkdir /srv/dockerdata

echo "Finding updates for apt!"
sudo apt update
echo "Updgrading apt!"
sudo apt upgrade -y
echo "Finding updates for apt-get!"
sudo apt-get update
echo "Updgrading apt-get!"
sudo apt-get upgrade -y

# Add Docker's official GPG key:
echo -e "${GREEN}Getting Docker!${RESET}";
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sleep 1.5;
echo -e "${GREEN}Installing Docker!${RESET}";

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo -e "${GREEN}Testing Docker!${RESET}"
sudo docker run hello-world
echo -e "${BLUE}Docker complete!${RESET}"
# while true; do
#         read -p "Do you want to install Docker? (y/n) " yn

#         case $yn in 
#                 [yY] ) echo ok, we will proceed;
#                 for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done;
#                 echo -e "${GREEN}Getting Docker!${RESET}";
#                 sleep 1.5;
#                 sudo apt-get update;
#                 sudo apt-get install ca-certificates curl;
#                 sudo install -m 0755 -d /etc/apt/keyrings;
#                 sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc;
#                 sudo chmod a+r /etc/apt/keyrings/docker.asc;
#                 echo \
#                 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#                 $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \ 
#                 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
#                 sleep 1.5;
#                 echo -e "${GREEN}Installing Docker!${RESET}";
#                 sudo apt-get update -y;

#                 sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y;
#                 echo -e "${GREEN}Testing Docker!${RESET}";
#                 sudo docker run hello-world;
#                 echo -e "${BLUE}Docker complete!${RESET}";
#                 break;;
#                 [nN] ) echo -e "${RED}continuing without docker...${RESET}";
#                         break;;
#                 * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${RESET}"
#                         ;;
#         esac
# done


while true; do
        read -p "Do you want to install Portainer? (y/n) " yn

        case $yn in 
                [yY] ) echo ok, we will proceed;
                        echo -e "${GREEN}Creating Portainer!${RESET}";
                        sleep 1.5;  
                        sudo docker volume create portainer_data;
                        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts;
                        echo -e "${BLUE}Portainer complete!${RESET}";
                        break;;
                [nN] ) echo -e "${RED}continuing without portainer...${RESET}";
                        break;;
                * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${RESET}"
                        ;;
        esac
done

while true; do
        read -p "Do you want to install nfs-common? (y/n) " yn

        case $yn in 
                [yY] ) echo ok, we will proceed;
                        echo -e "${GREEN}Installing nfs-common!${RESET}";
                        sleep 1.5;  
                        sudo apt install nfs-common -y;
                        echo -e "${BLUE}NFS complete!${RESET}";
                        break;;
                [nN] ) echo -e "${RED}continuing without nfs-common...${RESET}";
                        break;;
                * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${RESET}"
                        ;;
        esac
done

while true; do
        read -p "Do you want to install ftp server? (y/n) " yn

        case $yn in 
                [yY] ) echo ok, we will proceed;
                        echo -e "${GREEN}Installing ftp server!${RESET}";
                        sleep 1.5;  
                        sudo apt install vsftpd -y
                        sudo systemctl start vsftpd
                        sudo systemctl enable vsftpd
                        sudo ufw allow 20/tcp
                        sudo ufw allow 21/tcp
                        echo "write_enable=YES" >> /etc/vsftpd.conf
                        sudo systemctl restart vsftpd.service
                        echo -e "${BLUE}NFS complete!${RESET}";
                        break;;
                [nN] ) echo -e "${RED}continuing without nfs-common...${RESET}";
                        break;;
                * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${RESET}"
                        ;;
        esac
done

echo "${PLEXNFSBASELOC}"
echo -e "${GREEN}Mounting NFS Share files!${RESET}"

sudo mount -t nfs ${PLEXNFSBASELOC} /mnt/PlexMedia

echo -e "${BLUE}Mounting NFS Share files for boot!${RESET}"
echo "${PLEXNFSBASELOC} /mnt/PlexMedia nfs4 rw,relatime 0 0" >> /etc/fstab

echo -e "${GREEN}Installation Complete! Type Clear to remove logs!${RESET}";
