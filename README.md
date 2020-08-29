# Full Tunnel or Split Tunnel IPv6 + IPv4 Wireguard VPN connections to an ad blocking Pi-Hole server, from your Android, iOS, Chrome OS, Linux, macOS, & Windows devices

<img src="./images/data-privacy-risk.svg" width="125" align="right">

The goal of this project is to enable you to safely and privately use the Internet on your phones, tablets, and computers with a self-run VPN Server in the cloud, or on your own hardware in your home. This software shields you from intrusive advertisements. It blocks your ISP, cell phone company, public WiFi hotspot provider, and apps/websites from gaining insight into your usage activity.

Both Full Tunnel (all traffic) and Split Tunnel (DNS traffic only) VPN connections provide DNS based ad-blocking over an encrypted connection to the cloud. The differences are:

- A Split Tunnel VPN allows you to interact with devices on your Local Network (such as a Chromecast or Roku).
- A Full Tunnel VPN can help bypass misconfigured proxies on corporate WiFi networks, and protects you from Man-In-The-Middle SSL proxies.

| Tunnel Type | Data Usage | Server CPU Load | Security | Ad Blocking |
| -- | -- | -- | -- | -- |
| full | +10% overhead for vpn | low | 100% encryption | yes
| split | just kilobytes per day | very low | dns encryption only | yes

While Pi-hole was originally authored to run on a Raspberry Pi, people have followed this guide to deploy securely hosted instances of Pi-hole with VPN only access on Google Cloud, AWS, Heroku, Azure, Linode, Digital Ocean, Oracle Cloud, and on spare hardware at home.

---

## Quickstart

1.  Install [Ubuntu 20.04](https://ubuntu.com/download/server) if you want to benefit from the Wireguard Module natively shipped in the Linux Kernel. Ubuntu 18.04, Debian, and other Linux distributions do not yet have Wireguard implemented in the kernel-space, as of August 29, 2020.

2.  Download and execute **setup.sh** from this repository to:

    1.  install the latest Wireguard packages

    2.  install the latest Pi-Hole, and configure it to accept DNS requests from the Wireguard interface

    3.  display a QR Code for 1 Split Tunnel VPN Profile, so you can import the VPN Profile to your device without having to type anything

```bash
sudo su -
curl -O https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/setup.sh
chmod +x setup.sh
bash ./setup.sh 
```

3.  Make sure your router or firewall is forwarding incoming UDP packets on Port 51515 to the Ubuntu 20.04 Server, that you ran the **setup.sh** script on.

4.  Create another VPN Client Profile by running `./setup.sh` again, you can create 253 profiles without modifying the script.

5.  [Enable Wireguard VPN Connections on your devices](./CONNECTING-TO-WG-VPN.md)

---

## Server Setup Guide

<table>
    <tbody>
        <tr>
            <td><b><a href="#option-a--set-up-a-pi-hole-ad-blocking-vpn-server-with-a-static-anycast-ip-on-google-clouds-always-free-usage-tier">Option&nbsp;A</a></b></td>
            <td>
                Set up a Pi-Hole Ad Blocking VPN Server with a static Anycast IP on Google Cloud's Always Free Usage Tier.<br><br>
                <b>Fastest</b>: beefier server specs, premium network connectivity with an anycast static IP<br>
                <b>Cheapest</b>: $0 to run with Split Tunnel configuration
            </td>
        </tr>
        <tr>
            <td><b><a href="#option-b--set-up-a-pi-hole-ad-blocking-vpn-server-behind-your-router-at-home">Option&nbsp;B</a></b></td>
            <td>Set up a Pi-Hole Ad Blocking VPN Server behind your router at home.</td>
        </tr>
    </tbody>
</table>

---

### OPTION A <br> Set up a Pi-Hole Ad Blocking VPN Server with a static Anycast IP on Google Cloud's Always Free Usage Tier

<img src="./images/upfront-cost.svg" width="90" align="right">

You can run your own privacy-first ad blocking service within the **[Free Usage Tier](https://cloud.google.com/free/)** on Google Cloud. **Step 1 of this guide gets you set up with a Google Cloud account, and Step 2 walks you through setting up a full tunnel or split tunnel VPN connection on your Android & iOS devices, and computers.**

This simple 2 step process will get you up and running:

- **STEP 1** [Google Cloud Login, Account Creation, & Server Provisioning](./GOOGLE-CLOUD.md)

- **STEP 2** [Software Installation & Configuration](./CONFIGURATION.md)

There is no value in setting up DNS over HTTPS or DNS over TLS on a cloud hosted instance, because your DNS requests to the cloud are encrypted by Wireguard.

The performance related technical merits of Option A are outlined in [REASONS.md](./REASONS.md).

---

### OPTION B <br> Set up a Pi-Hole Ad Blocking VPN Server behind your router at home.

- **STEP 1** A new install of Ubuntu 20.04 (preferably not Raspbian or Debian, for lack of a Wireguard Linux Kernel Module), and have your Router forward all incoming UDP connections on Port 51515 to this device.

- **STEP 2** [Software Installation & Configuration](./CONFIGURATION.md)

- **STEP 3** [Enable DNS over HTTPS](https://docs.pi-hole.net/guides/dns-over-https/)

- **STEP 4** Bridge your Local LAN with your Wireguard network:

  - Open the Wireguard Application on your Client Device, and edit the VPN Profile.

  - Change the **Allowed IPs** to include your LAN subnet. For example, if your router's IP address is `192.168.86.1`, and your Ubuntu 20.04 Wireguard server has an IP somewhere in the range of `192.168.86.2` to `192.168.86.255`, your subnet is `192.168.86.0/24`. If you add `192.168.86.0/24` to the comma separated list of **Allowed IPs** in the Client Configuration file, you will be able to ping any device with an IP address between `192.168.86.1` to `192.168.86.254` over your Wireguard connection.

---

## Client Setup Guide

To connect and use the VPN, you will need to install the Wireguard VPN software on your device or computer: Review some [common Wireguard VPN Client configuration steps](./CONNECTING-TO-WG-VPN.md)

## Delete Clients from Server

Print list of all clients on the server:

```bash
sudo wg show
```

Sample output may look like this:

> ```
> peer: txUZ0iqCyu69qQFq08U420hOp3/A4lYtrHVrJrAYBys=
>   preshared key: (hidden)
>   endpoint: 99.99.99.99:99999
>   allowed ips: 10.66.66.2/32, fd42:42:42::2/128
>   latest handshake: 4 days, 20 hours, 4 minutes, 20 seconds ago
>   transfer: 4.20 MiB received, 4.20 MiB sent
> ```

Make note of the unique string after the word **peer:** for the client you wish to delete. In the example above, it is `txUZ0iqCyu69qQFq08U420hOp3/A4lYtrHVrJrAYBys=`.

Remove the client:

```bash
sudo wg set wg0 peer txUZ0iqCyu69qQFq08U420hOp3/A4lYtrHVrJrAYBys= remove
```

Replace `txUZ0iqCyu69qQFq08U420hOp3/A4lYtrHVrJrAYBys=` in the command above with the appropriate **peer:** you wish to delete on your server.

## Contributions Welcome

If there is something that can be done better, or if this documentation can be improved in any way, please submit a Pull Request with your fixes or edits.

Contributors should be aware of [REASONS.md](./REASONS.md), which explain the factors behind choices made throughout this guide.

Please review the [Issues](https://github.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/issues) if you are in a position to help others, or participate in improving this project.
