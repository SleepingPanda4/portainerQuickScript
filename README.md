# portainerQuickScript
Bash script for quick launching Portainer

**This is to be used for Virtual Machines alongside a NAS such as UNRAID or TrueNas.** Set up NFS shares inside Unraid or Truenas and then create an Ubuntu Server Virtual Machine and then create this script and run it.
This is a quick and easy script that Creates your Plex Media mount folders. Downloads and installs Docker, Portainer, and common-nfs then mounts your NFS share from your NAS to the machine and adds it to the fstab to then auto-attach your NFS share on startup.

### Instructions:
**There are two sets of instructions one for local docker storage and one for mounting NAS NFS share for docker data storage**

#### Remote Docker Data Storage through NFS Share:
1. Run "mkdir /home/scripts"
2. "cd  /home/scripts"
3. Run "wget https://raw.githubusercontent.com/SleepingPanda4/portainerQuickScript/refs/heads/main/CreateServer.sh"
OR 
1. Run "mkdir /home/scripts"
2. Run "nano /home/scripts/CreateServer.sh"
3. Copy CreateServer.sh and paste it in.

4. Change **NAS_IPADDRESS** to your local NAS ip such as 192.168.1.22
5. Change **PLEXNFSBASELOC** to your PLEX NFS share base location. **EXAMPLE 192.168.1.22:/mnt/users/PlexMedia**
6. Change **SERVERFILESNFSBASELOC** to your SERVER NFS share base location. **Example 192.168.1.22:/mnt/users/ServerFiles** **THIS IS ONLY IF YOU ARE SAVING YOUR DOCKER DATA TO A NAS NFS**
7. Press "CTRL+x" "y" "Enter"
8. Run "chmod +x /home/scripts/CreateServer.sh"
9. Run "/home/scripts/CreateServer.sh"
10. Follow prompts on screen and then you're finished.

**Your Plex Files now will be accessible through cd /mnt/PlexMedia and your server files through cd /mnt/ServerFiles**

#### Local Docker Data Storage Through "/srv/dockerdata/
1. Run "mkdir /home/scripts"
2. "cd  /home/scripts"
3. Run "wget https://raw.githubusercontent.com/SleepingPanda4/portainerQuickScript/refs/heads/main/CreateServerLocalDocker.sh"
OR 
1. Run "mkdir /home/scripts"
2. Run "nano /home/scripts/CreateServerLocalDocker.sh"
3. Copy CreateServerLocalDocker.sh and paste it in.

4. Change **NAS_IPADDRESS** to your local NAS ip such as 192.168.1.22
5. Change **PLEXNFSBASELOC** to your PLEX NFS share base location. **EXAMPLE 192.168.1.22:/mnt/users/Plex_Media**
