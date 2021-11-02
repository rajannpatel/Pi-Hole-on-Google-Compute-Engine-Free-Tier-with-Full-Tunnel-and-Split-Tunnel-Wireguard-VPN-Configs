# Docker Compose Example of Wireguard + Pihole. 

Heavily inspired from [Rajannpatel's github project](https://github.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs) but instead of running the setup.sh in that project this uses docker-compose to build up the same setup. 

The benefit of Rajannpatel's project is that you literally don't need to know anything about wireguard, pihole, etc to setup it. The project includes step-by-step instructions to get everything going including some defaults to take the thinking out of it.

This project, in contrast, requires understanding the wireguard INI files in the conf directory. They aren't complete. They will need to have the wireguard keys populated and some of the IP configuration completed as well. A basic understanding of the docker-compose file will help significantly too.

A compose.sh script that just runs the docker-compose image is included (because some of the VM images on Google Compute don't allow or include docker-compose). Speaking of the VM images, this will probably be best run on Ubuntu LTS or at the very least a Debian-based image with writtable modules directory (so not the Container Optimized OS that Google Compute champions for Docker usage).

# Rambling Dev Notes

What follows are my notes from doing this. I started with very little knowledge of what I was doing and the notes helped me context switch in and out of the little project. I've included them here in case they help others as a companion to the example configurations included here. Cheers!

## Docker Networking

What does the left side of the port mapping mean in relation to the network type? For example, if a container is "host" network does port mapping matter at all? Or if I have bridge network on two containers, I map both of the containers port to the same left side port, what does that do? 

From the [documentation](https://docs.docker.com/engine/reference/run/#network-settings) it says:

> Publishing ports and linking to other containers only works with the default (bridge).The linking feature is a legacy feature. You should always prefer using Docker network drivers over linking.

This means to me that the port mapping ONLY works if the network mode is 'bridge' and does not work in any other mode ('host', 'none', and named networks, either by container or otherwise). The semantics of 'none' are obvious. 'host' not working is kind of what I'm getting at though.

The port expose/mapping dynamic conceptually made sense to me as a sort of NAT on a container. What I mean is that internally the container will reference the ports that are defined with EXPOSE in the image. Externally to the container, those ports can be mapped to other ports to be referenced externally. 

I think this is probably mostly true, but the "external" that I'm referencing isn't per container necessarily. The containers (in a single compose [idk what the name is here cluster? swarm?]) by default run in 'bridge' which is like an unnamed network that contains all images on separate IPs.

In this way, I think the mapping is basically a NAT on the bridge network into the host's network. If that's true, then running a container in 'host' network mode would defeat the purpose of using port mapping other than overriding the EXPOSE in the image, which wouldn't make sense.

I am curious how that's supposed to work with named networks. I would expect that I could still define some sort of interface between a network and the host somehow. Maybe in the network definition?

The other unexplained network thing is if an image exposes a port and I don't map it, what happens? I'd kind of expect it to not be translated to the host, but I guess it could just default to the port that's exposed?

Easy enough to try using nginx. This works:

```bash
docker run --name some-nginx -p 80:80 -v html:/usr/share/nginx/html:ro -d nginx
```
This doesn't:
```bash
docker run --name some-nginx -v html:/usr/share/nginx/html:ro -d nginx
```

So I guess that means it works like I expect it too in bridge mode at least. Also found out that there's a bunch of docker commands for fucking with the network and port mapping. So that's dope, but really doesn't give you any info.

Also, I read the [docs](https://docs.docker.com/network/bridge/) some more. Imagine. 

> Containers on the default bridge network can only access each other by IP addresses, unless you use the --link option, which is considered legacy. On a user-defined bridge network, containers can resolve each other by name or alias.

That's cool and explains wtf the link reference was earlier.

> All containers without a --network specified, are attached to the default bridge network. This can be a risk, as unrelated stacks/services/containers are then able to communicate.

I used ```docker network ls``` to see the list of networks. You can see all the default ones ('none', 'bridge', and 'host').

I'm still left with my problem that the wg-ui container is host to control the wireguard interface on the host AND to serve HTTP. The easiest solution is just to run that in host network and then map the web port to something else. Wait, does that work? Do port mappings apply on host?

> Note: Given that the container does not have its own IP-address when using host mode networking, port-mapping does not take effect, and the -p, --publish, -P, and --publish-all option are ignored, producing a warning instead:

K well that answers that.

The real issue is that I'm trying to run all of this in a container, but it's dependent on the host's kernel module. Obviously those two things are going to conflict. It's unfortunate because the wireguard-go implementation is significantly slower than the kernel module. 

The options from here are:
- use wireguard-go with wireguard-ui
- make it all work with wireguard-ui on the host
- don't use wireguard-ui

Even ignoring the wireguard-ui issues, there's still the issue of what wireguard implementation to use. The options there are:
- use the kernel module w/ it's container-breaking complications
- use wireguard-go w/ it's shit performance
- use boringtun w/ little support because it's new

BoringTun idea is exciting, but it's new, so there isn't much support for it out there in documentation and examples, plus wireguard-ui doesn't support it. And I don't even know if it's actually faster than the go implementation. I'll assume it is since that's the reasoning behind it's creation. At any rate, I'd have to fork the wireguard-ui repo or write my own ui? 

The strange thing is the [wireguard landing page](https://www.wireguard.com/) says this is built for containers:

> WireGuard sends and receives encrypted packets using the network namespace in which the WireGuard interface was originally created. This means that you can create the WireGuard interface in your main network namespace, which has access to the Internet, and then move it into a network namespace belonging to a Docker container as that container's only interface. This ensures that the only possible way that container is able to access the network is through a secure encrypted WireGuard tunnel.

I don't really get what this is saying: *"you can create the WireGuard interface in your main network namespace"*. Does that mean 'host' to use the Docker terminology? I can't imagine it means anything else. *"then move it into a network namespace belonging to a Docker container as that container's only interface"* What does that mean? It explicitly mentions Docker and says move an interface to a container. I really don't understand what that means.

[More documentation](https://www.wireguard.com/netns)
> Like all Linux network interfaces, WireGuard integrates into the network namespace infrastructure.

So it's a Linux network stack thing, okay. It goes on to explain just how to setup the link in the default namespace, create a new namespace and then configure the link there:

```bash
# add the link and namespace
ip link add wg0 type wireguard
ip netns add container
ip link set wg0 netns container
# configure the link
ip -n container addr add 192.168.4.33/32 dev wg0
ip netns exec container wg setconf wg0 /etc/wireguard/wg0.conf
ip -n container link set wg0 up
ip -n container route add default dev wg0
```

On it's own this is straightforward, but it's annoying with containers because now I have to figure out how to do this network setup before I run the containers, either thru cloud-init or something else. This specific recommendation for Docker seems even more frustrating to automate AND brittle:

> Note that Docker users can specify the PID of a Docker process instead of the network namespace name, to use the network namespace that Docker already created for its container

This is all linked under the title "Ready for Containers," which I'm not buying at this point. I agree in principle that it's nice to use wireguard to tunnel into the container network namespace, but manually setting up networking on the host outside of a container config feels flimsy and at-odds with containers in principle. 

At any rate, it seems possible that wireguard-ui could run in a container network rather than host and still configure the wireguard link with the appropriate capabilities. The interface would just need to be created separately and then given to the container network. I'm not entirely sure how to do that cleanly. 

My next thought was that maybe the compose file's top-level "networks" config would allow me to do some sort of configuration like this. I'm probably missing some detail here, but there really isn't much beyond the [reference documentation](https://docs.docker.com/compose/compose-file/compose-file-v3/#network-configuration-reference). 

It's unfortunate that Docker doesn't make it easy to work with the netns that it uses. From messing around with nginx image before, I was unable to get the netns for Docker to appear using ip netns list, which led me to this [SO question](https://stackoverflow.com/questions/31265993/docker-networking-namespace-not-visible-in-ip-netns-list), to which the answer is to mount docker directories in system directories per-process to connect them. 

I guess that's fair isolation on Docker's side, but it really makes setting up this tunnel frustrating. I was hoping I could reference an existing netns in the compose file or reference an existing link in the compose file. Neither seems possible at the moment.

## One week later

It's been a week since I've actually worked on this. I spent the morning just cruising stuff vaguely related to this project. I had this thought that I would prefer Cloudfront's network to Google's even if Google's is free. I was hoping for a trade off of like $5/mo to be in Cloudfront, but they still don't really provide hosting beyond workers and the static resources. Reasoning there was that I get really annoyed when random websites block cloud provider IP addresses. I realize that you can bring custom CIDR into cloud providers but it's an enterprise offering.

That said, they do offer this 1.1.1.1 (their DNS ip address) service, which is actually a wireguard VPN for free. I switched my mobile to it. They call it WARP. They have a paid offering WARP+ that will route my shit thru their network which is really tempting. There really isn't a need for it, but it would be tight if that didn't hurt my throughput at all. WARP already didn't work once on me though. 

I also found out that pfSense doesn't support wireguard and the history there with Netgate left a sour taste in my mouth. Almost enough to migrate to OPNsense but I'm not sure I want to do that just yet.

Separately I'm still a bit confused on how Docker shares the host's kernel and how that's supposed to work across environments. If I provision a VM with FreeBSD and then try to run containers there how will that work? Especially if it's a Linux image. I should try that and just see what happens. 

## Post-weekend

Alright, coming back to this and I finally feel like I can close it out. I had been running the Docker images on my machine locally to setup the "server" side of the WG tunnel. I would publish the wireguard's port on my host machine's interface and then try to setup my wg0 on my host to be the peer to that connection. I could never get the two to communicate fully. I was able to ping some machines in the container network, but never any ips in the wireguard tunnel's CIDR, which made me feel like the routing was messed up.

It was! There were two things that I didn't realize. One was that the Docker container network created a bridge in my host's default netns. That's really strange to me. I thought that when I created a network in Docker it wouldn't be accessible on the host because Docker would create a separate netns for it, but I was getting a bridge interface on my main netns that allowed me to ping the containers without going through the Wireguard tunnel.

The other issue is that I was trying to be too crafty with the routing and network topology. I had the container network configured to be a superset of the CIDR for the wireguard tunnel. The idea being that it would be simpler to understand on the peer's routing table. It would just say 10.33.0.0/16 is through wg0 which would include both the tunnel's CIDR and the network on the other side of the tunnel. 

That DID work, but the return path from the relay server's network was broken. The routing table would have 10.33.0.0/16 mapped to eth0 (as configured by Docker via the compose file) and so packets destined for 10.33.33.0/24 (the tunnel's CIDR) would get lost in the container's network. 

This was all plainly obvious once I ran the containers in a VM and not on my machine. So yay, I'm done! ```ip route get ${DESTINATION_IP}``` ended up being a tremendously useful tool for getting me the last mile. Being able to run that in the containers, VM and locally helped debug the connections quickly.