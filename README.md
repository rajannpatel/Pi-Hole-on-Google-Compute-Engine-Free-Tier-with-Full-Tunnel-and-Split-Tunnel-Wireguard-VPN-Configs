# Set up a Pi-Hole Ad Blocking VPN Server with a static Anycast IP on Google Cloud's Always Free Usage Tier
## Configure Full Tunnel or Split Tunnel IPv6 Wireguard connections from your Android, iOS, Linux, macOS, & Windows devices

<img src="./images/data-privacy-risk.svg" width="125" align="right">

The goal of this guide is to enable you to safely and privately use the Internet on your phones, tablets, and computers with a self-run VPN Server in the cloud. It can be run at no cost to you; shields you from intrusive advertisements; and blocks your ISP, cell phone company, public WiFi hotspot provider, and apps/websites from gaining insight into your usage activity.

<img src="./images/upfront-cost.svg" width="90" align="right">

Run your own privacy-first ad blocking service within the **[Free Usage Tier](https://cloud.google.com/free/)** on Google Cloud. **This guide gets you set up with a Google Cloud account, and walks you through setting up a full tunnel (all traffic) or split tunnel (DNS traffic only) VPN connection on your Android & iOS devices, and computers.**

Both Full Tunnel and Split Tunnel VPN connections provide DNS based ad-blocking over an encrypted connection to the cloud. The differences are:

- A Split Tunnel VPN allows you to interact with devices on your Local Network (such as a Chromecast or Roku).
- A Full Tunnel VPN can help bypass misconfigured proxies on corporate WiFi networks, and protects you from Man-In-The-Middle SSL proxies.

| Tunnel Type | Data Usage | Server CPU Load | Security | Ad Blocking |
| -- | -- | -- | -- | -- |
| full | +10% overhead for vpn | low | 100% encryption | yes
| split | just kilobytes per day | very low | dns encryption only | yes

The technical merits of major choices in this guide are outlined in [REASONS.md](./REASONS.md).

---

# Get Started

This simple 2 step process will get you up and running:

1. [Google Cloud Login, Account Creation, & Server Provisioning](./GOOGLE-CLOUD.md)
2. [Server & Client Configurations](./CONFIGURATION.md)

# Contributions Welcome

If there is something that can be done better, or if this documentation can be improved in any way, please submit a Pull Request with your fixes or edits.

Contributors should be aware of [REASONS.md](./REASONS.md), which explain the factors behind choices made throughout this guide.

Please review the [Issues](https://github.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/issues) if you are in a position to help others, or participate in improving this project.
