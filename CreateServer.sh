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

# Colors and symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
CHECKMARK="✅"
CROSS="❌"

# Variables to hold user input
NAS_IP=""
PLEX_SHARE=""
SERVER_SHARE=""
SERVER_OPTION=""

# Track step position
current_step=0

# Helper function for yes/no prompts with backtracking
ask_yes_no() {
  while true; do
    printf "%b" "$1"
    read -r answer
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]) return 1 ;;
      ",") return 2 ;;
      *) printf "%b\n" "${RED}${CROSS} Please answer yes/y or no/n, or , to go back.${RESET}" ;;
    esac
  done
}

prompt_ip() {
  while true; do
    printf "%b" "${BLUE}Enter NAS IP Address:${RESET} "
    read -r ip

    if [[ "$ip" == "," ]]; then
      return 2
    fi

    if [[ -z "$ip" ]]; then
      printf "%b\n" "${RED}${CROSS} Input cannot be empty.${RESET}"
      continue
    fi

    if ! [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      printf "%b\n" "${RED}${CROSS} Invalid IP address format.${RESET}"
      continue
    fi

    IFS='.' read -r -a octets <<< "$ip"
    valid_ip=true
    for octet in "${octets[@]}"; do
      if (( octet < 0 || octet > 255 )); then
        valid_ip=false
        break
      fi
    done
    if ! $valid_ip; then
      printf "%b\n" "${RED}${CROSS} Invalid IP address range.${RESET}"
      continue
    fi

    if ping -c 1 -W 1 "$ip" &>/dev/null; then
      NAS_IP="$ip"
      printf "%b\n" "${GREEN}${CHECKMARK} Connection passed${RESET}"
      return 0
    else
      printf "%b\n" "${RED}${CROSS} Connection failed. Please enter reachable IP.${RESET}"
    fi
  done
}

prompt_plex_share() {
  while true; do
    printf "%b" "${BLUE}Enter PlexMedia share path (e.g. /mnt/users/PlexMedia):${RESET} "
    read -r path

    if [[ "$path" == "," ]]; then
      return 2
    fi

    if [[ -z "$path" ]]; then
      printf "%b\n" "${RED}${CROSS} Share path cannot be empty.${RESET}"
      continue
    fi

    if [[ "$path" != /* ]]; then
      printf "%b\n" "${RED}${CROSS} Path must start with /${RESET}"
      continue
    fi

    PLEX_SHARE="$path"
    printf "%b\n" "${GREEN}${CHECKMARK} PlexMedia share set to: $NAS_IP:$PLEX_SHARE${RESET}"
    return 0
  done
}

prompt_server_share() {
  while true; do
    printf "%b" "${BLUE}Enter ServerFiles share path (or type 'local' for local docker data):${RESET} "
    read -r input

    if [[ "$input" == "," ]]; then
      return 2
    fi

    if [[ -z "$input" ]]; then
      printf "%b\n" "${RED}${CROSS} Input cannot be empty.${RESET}"
      continue
    fi

    if [[ "$input" == "local" ]]; then
      SERVER_OPTION="local"
      printf "%b\n" "${GREEN}${CHECKMARK} Local Docker Server Files selected.${RESET}"
      return 0
    fi

    if [[ "$input" != /* ]]; then
      printf "%b\n" "${RED}${CROSS} Path must start with /${RESET}"
      continue
    fi

    SERVER_SHARE="$input"
    SERVER_OPTION="remote"
    printf "%b\n" "${GREEN}${CHECKMARK} ServerFiles share set to: $NAS_IP:$SERVER_SHARE${RESET}"
    return 0
  done
}

# Prompt sequence definitions
steps=(
  "prompt_ip"
  "prompt_plex_share"
  "prompt_server_share"
  "install_updates"
  "install_docker"
  "install_portainer"
  "install_nfs"
  "install_vsftpd"
  "setup_mounts"
)

install_updates() {
  printf "%b\n\n" "${YELLOW}Starting system update...${RESET}"
  sudo apt-get update && sudo apt-get -y upgrade
  return 0
}

install_docker() {
  while true; do
    if ask_yes_no "${BLUE}Would you like to install Docker? (yes/no)${RESET} "; then
      printf "%b\n" "${YELLOW}Installing Docker...${RESET}"
      sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo systemctl enable docker --now
      printf "%b\n" "${GREEN}${CHECKMARK} Docker installed successfully.${RESET}"
      return 0
    elif [[ $? -eq 2 ]]; then
      return 2
    else
      printf "%b\n" "${RED}${CROSS} Skipping Docker installation.${RESET}"
      return 0
    fi
  done
}

install_portainer() {
  while true; do
    if ask_yes_no "${BLUE}Would you like to install Portainer? (yes/no)${RESET} "; then
      printf "%b\n" "${YELLOW}Installing Portainer...${RESET}"
      sudo docker volume create portainer_data
      sudo docker run -d -p 9000:9000 --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
      printf "%b\n" "${GREEN}${CHECKMARK} Portainer installed and running.${RESET}"
      return 0
    elif [[ $? -eq 2 ]]; then
      return 2
    else
      printf "%b\n" "${RED}${CROSS} Skipping Portainer installation.${RESET}"
      return 0
    fi
  done
}

install_nfs() {
  while true; do
    if ask_yes_no "${BLUE}Would you like to install nfs-common? (yes/no)${RESET} "; then
      printf "%b\n" "${YELLOW}Installing nfs-common...${RESET}"
      sudo apt-get install -y nfs-common
      printf "%b\n" "${GREEN}${CHECKMARK} nfs-common installed.${RESET}"
      return 0
    elif [[ $? -eq 2 ]]; then
      return 2
    else
      printf "%b\n" "${RED}${CROSS} Skipping nfs-common installation.${RESET}"
      return 0
    fi
  done
}

install_vsftpd() {
  while true; do
    if ask_yes_no "${BLUE}Would you like to install FTP server (vsftpd)? (yes/no)${RESET} "; then
      printf "%b\n" "${YELLOW}Installing vsftpd...${RESET}"
      sudo apt-get install -y vsftpd
      sudo sed -i 's/^#*write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
      sudo ufw allow 20/tcp
      sudo ufw allow 21/tcp
      sudo ufw allow 30000:31000/tcp
      sudo systemctl restart vsftpd
      printf "%b\n" "${GREEN}${CHECKMARK} vsftpd installed and configured.${RESET}"
      return 0
    elif [[ $? -eq 2 ]]; then
      return 2
    else
      printf "%b\n" "${RED}${CROSS} Skipping vsftpd installation.${RESET}"
      return 0
    fi
  done
}

setup_mounts() {
  printf "%b\n" "${YELLOW}Setting up mount points...${RESET}"
  sudo mkdir -p /mnt/PlexMedia
  if [[ "$SERVER_OPTION" == "local" ]]; then
    sudo mkdir -p /srv/dockerdata /mnt/ServerFiles
  else
    sudo mkdir -p /mnt/ServerFiles
  fi

  fstab_backup="/etc/fstab.bak.$(date +%s)"
  sudo cp /etc/fstab "$fstab_backup"
  printf "%b\n" "${GREEN}${CHECKMARK} fstab backup saved as $fstab_backup${RESET}"

  sudo sed -i "\|$NAS_IP:$PLEX_SHARE|d" /etc/fstab
  [[ "$SERVER_OPTION" == "remote" ]] && sudo sed -i "\|$NAS_IP:$SERVER_SHARE|d" /etc/fstab

  echo "$NAS_IP:$PLEX_SHARE /mnt/PlexMedia nfs defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
  [[ "$SERVER_OPTION" == "remote" ]] && echo "$NAS_IP:$SERVER_SHARE /mnt/ServerFiles nfs defaults 0 0" | sudo tee -a /etc/fstab >/dev/null

  printf "%b\n" "${YELLOW}Mounting shares...${RESET}"
  sudo mount -a
  printf "%b\n" "${GREEN}${CHECKMARK} Shares mounted.${RESET}"

  printf "%b\n" "${YELLOW}Configuring docker.service mount requirements...${RESET}"
  override_dir="/etc/systemd/system/docker.service.d"
  sudo mkdir -p "$override_dir"
  {
    echo "[Unit]"
    echo "RequiresMountsFor=/mnt/PlexMedia/Movies"
    [[ "$SERVER_OPTION" == "remote" ]] && echo "RequiresMountsFor=/mnt/ServerFiles/srv"
  } | sudo tee "$override_dir/override.conf" >/dev/null

  sudo systemctl daemon-reload
  sudo systemctl restart docker

  printf "%b\n" "${GREEN}${CHECKMARK} Setup complete.${RESET}"
  return 0
}

# Master loop to support full backtracking
while (( current_step < ${#steps[@]} )); do
  ${steps[$current_step]}
  rc=$?
  if [[ $rc -eq 0 ]]; then
    ((current_step++))
  elif [[ $rc -eq 2 ]]; then
    if (( current_step == 0 )); then
      printf "%b\n" "${YELLOW}Already at the first prompt, can't go back further.${RESET}"
    else
      ((current_step--))
    fi
  fi
done
