# Pi-hole + Wireguard on Ubuntu 24.04 LTS with Google Cloud's free tier, via cloud-init

<img src="./images/data-privacy-risk.svg" width="125" align="right">

The goal of this project is to enable you to safely and privately use the Internet on your phones, tablets, and computers with a self-run VPN Server in the cloud, or on your own hardware in your home. This software shields you from intrusive advertisements. It blocks your ISP, cell phone company, public WiFi hotspot provider, and apps/websites from gaining insight into your usage activity.

Both Full Tunnel (all traffic) and Split Tunnel (DNS traffic only) VPN connections provide DNS based ad-blocking over an encrypted connection to the cloud. The differences are:

- A Split Tunnel VPN allows direct interaction with devices on your Local Network (such as a Chromecast or Roku), but blocks DNS based discovery of local devices.
- A Full Tunnel VPN can help bypass misconfigured proxies on corporate WiFi networks, protects you from Man-In-The-Middle SSL proxies, and obfuscates IP address based geolocation by making the device appear like it is located where the VPN server is running.

| Tunnel Type | Data Usage | Server CPU Load | Security | Ad Blocking |
| -- | -- | -- | -- | -- |
| full | +10% overhead for vpn | low | 100% encryption | yes
| split | just kilobytes per day | very low | dns encryption only | yes

---

## Install and configure the gcloud CLI

This guide assumes you are running the following commands in a Linux environment. Windows or macOS users can get an instant Linux virtual machine on their computer with [Multipass](https://multipass.run/install).

1.  Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install)

        sudo snap install google-cloud-cli --classic

2.  Connect gcloud CLI with your Google Cloud account

        gcloud init

    1. Enter **Y** when prompted with *Would you like to log in (Y/n)?*
    2. Visit the authentication link which starts with `https://accounts.google.com/`
    3. Sign in with a Google account
    4. Click **Allow** to grant access to the Google Cloud SDK
    5. Click **Copy** to copy the verification code
    6. Paste the verification code into the terminal window where the `gcloud init` process is running

    If you complete the `gcloud init` process successfully, you will receive the following output:

    > ```text
    > You are now logged in as [your@email.com].
    > Your current project is [None].  You can change this setting by running:
    > $ gcloud config set project PROJECT_ID
    > ```

## Provision resources and deploy

1. List the projects that are in your account:
    
       gcloud projects list
    
    You’ll receive output similar to:
    
    > ```text
    > PROJECT_ID        NAME              PROJECT_NUMBER
    > project-id        project-name      12345678910
    > ```
    
2. Set your project ID to the `PROJECT_ID` environment variable. Replace `project-id` with your personal project ID from the previous output:
    
       PROJECT_ID=project-id
    
    This step isn’t required, but it’s recommended because the `PROJECT_ID` variable is used often.
    
3. Associate gcloud CLI to this `PROJECT_ID`:
    
       gcloud config set project $PROJECT_ID
    
    This is where the adblocker virtual machine (VM) will be launched.
    
4. List the available cloud zones and cloud regions where VMs can be run:
    
       gcloud compute zones list
    
    You’ll receive output similar to:
    
    > ```text
    > NAME                       REGION                   STATUS  NEXT_MAINTENANCE  TURNDOWN_DATE
    > us-east1-b                 us-east1                 UP
    > ```
    
5. Only `us-west1`, `us-central1`, and `us-east` regions qualify for Google Cloud's free tier. Set the `ZONE` and `REGION` environment variables by replacing `us-east1-b` and `us-east1` in the example commands below, with your desired zone and region:
    
    ```bash
    ZONE=us-east1-b
    REGION=us-east1
    ```
    
6. Reserve a static IP address and label it `pihole-external-ip`:
    
       gcloud compute addresses create pihole-external-ip --region=$REGION
    
7. Use curl to download the cloud-init YAML.

       sudo apt install -y curl
       curl -s https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/cloud-init.yaml -o cloud-init.yaml

8. Open the file in an editor to change configurations specified between lines 4 and 36. The default values that have been provided will work, but changing the value for **WEBPASSWORD** from `pAs5word` to another alphanumeric string is recommended. Setting **TOKEN** with an [Ubuntu Pro token](https://ubuntu.com/pro/dashboard) is strongly recommended, so [Livepatch](https://ubuntu.com/security/livepatch) can be enabled.

    ```markdown
    # SET OUR VARIABLES
    # =================

    # TIME TO REBOOT FOR SECURITY AND BUGFIX PATCHES IN XX:XX FORMAT
    SECURITY_REBOOT_TIME = "03:00"

    # TIME TO UPDATE AND UPGRADE PIHOLE IN XX:XX:XX FORMAT
    PIHOLE_UPDATE_TIME = "05:00:00"

    # ALPHANUMERIC PIHOLE WEB ADMIN PASSWORD
    {% set WEBPASSWORD = 'pAs5word' %}

    # UBUNTU PRO TOKEN FROM https://ubuntu.com/pro/dashboard
    # leave blank when using Ubuntu Pro instances on Azure, AWS, or Google Cloud
    {% set TOKEN = '' %}

    # WIREGUARD CONFIGURATIONS
    {% set SERVER_WG_NIC = 'wg0' %}
    {% set SERVER_WG_IPV4 = '10.66.66.1' %}
    {% set SERVER_WG_IPV6 = 'fd42:42:42::1' %}
    {% set SERVER_PORT = '51515' %}

    # TIMEZONE: as represented in /usr/share/zoneinfo. An empty string ('') will result in UTC time being used.
    {% set TIMEZONE = 'America/New_York' %}

    # HOSTNAME: subdomain of FQDN (e.g. `server` for `server.yourdomain.com`)
    {% set HOSTNAME = 'pihole' %}

    # DOMAIN (e.g. `yourdomain.com`)
    {% set DOMAIN = '' %}

    # =========================
    # END OF SETTING VARIABLES
    ```

9. Run the following command to launch an e2-micro virtual machine named "adblocker":
    
    ```bash
    gcloud compute instances create adblocker \
        --zone=$ZONE \
        --machine-type=e2-micro \
        --address=pihole-external-ip \
        --tags=wireguard \
        --boot-disk-size=10 \
        --image-family=ubuntu-2404-lts-amd64 \
        --image-project=ubuntu-os-cloud \
        --metadata-from-file=user-data=cloud-init.yaml
    ```

10. Allow your "adblocker" virtual machine to receive incoming UDP Wireguard VPN connections on Port 51515, as defined by SERVER_PORT in Step 8 above.

    ```bash
    gcloud compute firewall-rules create allow-udp-51515 \
        --direction=INGRESS \
        --action=ALLOW \
        --target-tags=wireguard \
        --source-ranges=0.0.0.0/0 \
        --rules=udp:51515 \
        --description="Allow UDP traffic on port 51515 for adblocker"
    ```

11. Observe the progress of your installation by tailing the `/var/log/cloud-init-output.log` file on the virtual machine:
    
        gcloud compute ssh adblocker --zone $ZONE --command "tail -f /var/log/cloud-init-output.log"
    
12. If you are a first time gcloud CLI user, you’ll be prompted for a passphrase twice. This password can be left blank, press **Enter** twice to proceed:
    
    > ```text
    > WARNING: The private SSH key file for gcloud does not exist.
    > WARNING: The public SSH key file for gcloud does not exist.
    > WARNING: You do not have an SSH key for gcloud.
    > WARNING: SSH keygen will be executed to generate a key.
    > Generating public/private rsa key pair.
    > Enter passphrase (empty for no passphrase):
    > Enter same passphrase again:
    > ```
    
13. A reboot may be required during the cloud-init process. If a reboot is required, you’ll receive the following output:
    
    > ```text
    > 2023-08-20 17:30:04,721 - cc_package_update_upgrade_install.py[WARNING]: Rebooting after upgrade or install per /var/run/reboot-required
    > ```
    
    If the `IMAGE_FAMILY` specified earlier contained all the security patches, this reboot step may not occur.
    
14. Repeat the following code if a reboot was necessary to continue observing the progress of the installation:
    
        gcloud compute ssh adblocker --zone $ZONE --command "tail -f /var/log/cloud-init-output.log"
    
15. Wait until the cloud-init process is complete. When it's complete, you’ll receive two lines similar to this:
    
    > ```text
    > Cloud-init v. 24.1.3-0ubuntu3.3 finished at Thu, 20 Jun 2024 03:53:16 +0000. Datasource DataSourceGCELocal.  Up 666.00 seconds
    > ```
    
16. Press `CTRL + C` to terminate the tail process in your terminal window.

## Configure your Wireguard tunnels

1. SSH into the adblocker instance, and run the `wireguard` command. Press `1` to create a VPN tunnel for a new user, and accept the default values for the wizard's prompts.

       sudo wireguard

2. The generated **.conf** file will create a Split Tunnel VPN connection by default. This configuration will be reflected in the generated QR code, which can be scanned in the Wireguard mobile apps. The tunnel configuration can be edited from within the Wireguard mobile app, if you wish to have a full tunnel connection. Replace the contents of **Allowed IPs** with `0.0.0.0/0` to route all traffic through Google Cloud. If you edit the **.conf** file on the server, you will need to regenerate the QR code to reflect this configuration change. The command to regenerate the QR code is:

       qrencode -t ansiutf8 -l L <"~/wg0-client-name.conf"

## Configure Pi-hole

1. Connect to your adblocker virtual machine with a newly created Wireguard tunnel. To configure your Pi-hole, visit `http://10.66.66.1/admin` from the VPN connected device.

## How to delete everything, if you wish to start over

**THE FOLLOWING STEPS WILL DELETE WHAT YOU HAVE CREATED, ABOVE**

This is how to remove the "adblocker" VM, its static IP address, and its firewall rules.

1. List all the addresses you’ve created:
    
       gcloud compute addresses list

2. To delete the address named "pihole-external-ip" we created earlier:

       gcloud compute addresses delete pihole-external-ip --region=$REGION

3. List all VMs in this project:

       gcloud compute instances list

4. To delete the "adblocker" VM we created earlier:

       gcloud compute instances delete INSTANCE_NAME --zone $ZONE

5. List all firewall rules in this project:
    
       gcloud compute firewall-rules list

6. To delete the "allow-udp-51515" firewall rules we created earlier:

       gcloud compute firewall-rules delete allow-udp-51515

## Contributions Welcome

If there is something that can be done better, or if this documentation can be improved in any way, please submit a Pull Request with your fixes or edits.

Contributors should be aware of [REASONS.md](./REASONS.md), which explain the factors behind choices made throughout this guide.

Please review the [Issues](https://github.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/issues) if you are in a position to help others, or participate in improving this project.
