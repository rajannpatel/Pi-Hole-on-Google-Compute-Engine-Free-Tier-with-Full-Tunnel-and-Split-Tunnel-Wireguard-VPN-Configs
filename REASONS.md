# The Top 3 Concerns

<img src="./images/faq.svg" height="150" align="right">

These factors determined the choices I made in writing this guide:

1. Security
2. Privacy
3. Cost
4. Performance

## Security

Ubuntu has been built on a foundation of enterprise-grade, industry leading security practices. With a free Ubuntu Pro token, you can use all of Canonical's security products: expanded security maintenance, systems management, automatic kernel hotfixes, and more.

## Privacy

Google Cloud is not targeted towards consumers, it is a service targeted towards businesses and engineers, but can be very valuable for consumers. As a consumer, there should be no hesitations about using the service due to privacy concerns. Google Cloud is enterprise and government grade: customers of Google Cloud are typically in Education, Financial Services, Government, Healthcare & Life Sciences, Media and Entertainment, and Retail. In order to secure customers in these industries, Google Cloud abides by stringent compliance policies, internationally.

You can read more about how Google Cloud handles security, transparency, privacy, and compliance on their website: https://cloud.google.com/security/

Running your own self-hosted VPN service on Google's Cloud is a vastly superior option to using any VPN-as-a-service provider that targets consumers.

## Cost

You get a lot for nothing. A free server running on 2 shared vCPU on 1 shared CPU core, with 1GB of RAM, and a cloud based firewall. Monitoring your Google Cloud footprint is simple with their Android and iOS apps, and the Google Cloud web portal at https://console.cloud.google.com.

## Performance

<img src="./images/logos/faq-network.svg" height="36" align="left">

### Network

This significantly outperforms other public cloud offerings.

With the Premium Tier Network, inbound traffic from your tablet/phone/computer to your Pi-Hole in Google Cloud goes over Google’s private, high performance network at the POP closest to you. Google delivers outbound traffic returning from Pi-Hole in Google Cloud to your tablet/phone/computer on Google’s network, and exits at the POP closest to you. *You can be anywhere in the world.*

Routers will select the desired path on the basis of number of hops, distance, lowest cost, latency measurements or based on the least congested route.

<img src="./images/premium-network-diagram.svg">

This means that most of this traffic will reach your device with a single hop to your ISP: so you enjoy minimum congestion (latency), and maximum performance.

<img src="./images/logos/faq-dns.svg" height="36" align="left">

### DNS

<img src="./images/global-dns-network.png" height="150" align="right">

DNS latency is caused by the following 2 concerns:

1. latency between the client and the DNS resolving server
2. latency between the resolving servers and other name servers

Choosing a DNS server with the lowest latency is the simplest way to address concern #1.

#### Use Google Public DNS

Of all DNS providers, Google's Public DNS servers have the lowest latency to your adblocker virtual machine, because the network requests are resolved completely within Google's internal private Premium Tier network. A round trip ping to Google's Public DNS from within Google's Cloud is 0.16ms, whereas a provider such as Cloudflare with direct peering to Google's network has a ping of 16ms.

<img src="./images/logos/faq-cpu.svg" height="36" align="left">

### Kernel

#### Wireguard Module

This guide has favored Ubuntu for years, since Canonical's blog post announcing [Ubuntu 20.04's arrival](https://ubuntu.com/blog/ubuntu-20-04-lts-arrives):

>  WireGuard is included in Ubuntu 20.04 LTS

At the time, this was met with confusion because Ubuntu 20.04 shipped with Linux Kernel 5.4, and Wireguard was officially in Linux Kernel 5.6. Canonical backported the Wireguard kernel module into 5.4 for Ubuntu 20.04 LTS.

Four years later, Ubuntu is still the recommended platform to run this critical network resource.