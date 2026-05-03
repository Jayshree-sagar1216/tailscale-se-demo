# Secure Private Access with Tailscale — SE Project

## What I Built

I set up a small but realistic private networking environment using Tailscale. The idea was simple: two internal services running on a cloud server, accessible only to authorized devices over a Tailscale network — no public ports open, no VPN appliance, no bastion host.

The two services are a mock Internal Employee Portal and a Private API, both running as Docker containers on an AWS EC2 instance. My Mac acts as the developer machine. Neither service is reachable from the public internet — only through the Tailnet.

## Why I Chose This Use Case

This came from a problem I've seen come up repeatedly in real conversations with engineering teams. Developers need to reach internal services in cloud environments, but the usual options — opening ports, setting up a bastion, or rolling out a corporate VPN — all come with real tradeoffs around security, complexity, and maintenance overhead.

Tailscale solves exactly that problem without adding infrastructure. The connectivity just works, access is identity-based, and nothing gets exposed that shouldn't be.

## Architecture

- **Node 1:** My MacBook (developer machine, Tailscale installed)
- **Node 2:** AWS EC2 t3.micro running Ubuntu 24.04 (cloud server)
- **Service 1:** Internal Employee Portal — nginx container on port 3000
- **Service 2:** Private API — nginx container on port 5000
- **Networking:** Tailscale Tailnet with MagicDNS enabled
- **SSH:** Tailscale SSH only — no public SSH port, no key distribution
- **Access control:** Tailscale ACL policy

## How Traffic Flows

1. Developer types http://tailscale-demo-server:3000 in the browser
2. MagicDNS resolves the hostname to the server's Tailscale IP (100.83.58.50)
3. Traffic travels over an encrypted WireGuard tunnel — never touches the public internet
4. The EC2 server receives the request locally and nginx responds
5. The EC2 security group has no open app ports — so the public internet simply cannot reach it

## Setup and Deployment

### Prerequisites
- AWS account
- Tailscale account (free tier works fine)
- Mac or Linux machine with Tailscale installed

### Steps

On AWS:
1. Launch an EC2 t3.micro instance with Ubuntu 24.04
2. Security group: allow SSH from your IP only — nothing else
3. SSH into the instance using your key pair

On the EC2 server:

sudo apt update && sudo apt install docker.io -y
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker ubuntu
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh
git clone https://github.com/jayshree-sagar1216/tailscale-se-demo.git
cd tailscale-se-demo
bash deploy.sh

In Tailscale admin:
1. Enable MagicDNS at https://login.tailscale.com/admin/dns
2. Apply the ACL policy from acl.json
3. Rename machine to tailscale-demo-server if needed

## How to Validate It Works

Services reachable over Tailscale:
curl http://tailscale-demo-server:3000
curl http://tailscale-demo-server:5000

Services NOT reachable over public internet:
curl --max-time 10 http://18.220.17.216:3000
Result: Connection timed out — nothing exposed publicly

Tailscale SSH — no key file needed:
tailscale ssh ubuntu@tailscale-demo-server

Tailscale status:
100.83.58.50   tailscale-demo-server  linux  Connected
100.64.151.32  jayshrees-macbook-air  macOS  Connected

## What Worked Well

Tailscale SSH was the biggest win for me. Removing key management from the equation entirely — and replacing it with identity-based access that can be revoked instantly — is something that's genuinely hard to explain until you see it working. MagicDNS was similarly smooth. Once enabled, hostname resolution just worked with no extra configuration on my end.

The deploy script made the whole thing reproducible, which mattered to me. I wanted someone else to be able to pick this up and run it without guessing.

## What Was Difficult

Getting the ACL policy right took a few iterations. The tag-based model is powerful but requires you to think carefully about ownership and how devices are classified. For this demo I simplified to an open policy between my two nodes, which is appropriate for a single-user environment — but I've documented what a proper tag-based policy would look like below.

Docker default port binding behavior also needs attention. By default Docker binds to all interfaces, which could expose ports publicly if your security group is not locked down. Worth being deliberate about this in production.

## What I Would Do Differently With More Time

- Provision EC2 with Terraform so the whole environment is reproducible with one command
- Use Tailscale Serve to front the apps with HTTPS and valid certificates
- Add a second user account to demonstrate ACL enforcement across multiple identities
- Set up a subnet router to expose a private VPC CIDR — more realistic for enterprise use cases
- Wire up a GitHub Actions workflow that accesses the private service over Tailscale during CI

## Tailscale vs Traditional Approaches

Approach | The Problem | How Tailscale Is Different
Open security group ports | Attack surface grows, hard to audit | Nothing exposed publicly ever
Bastion host | Extra infra, single point of failure, still needs key management | No bastion needed at all
Corporate VPN | Heavy to deploy, routes all traffic, slow | Lightweight, per-service access, WireGuard speed
SSH key management | Keys get shared, rotation is painful, hard to revoke | Identity-based auth, revoke access in seconds

## A Note on Tag-Based ACLs

For a production deployment with multiple users and roles I would use tags instead of open access:

tagOwners:
  tag:server — owned by admin
  tag:developer — owned by admin

acls:
  tag:developer can reach tag:server on ports 3000 and 5000 only

ssh:
  tag:developer can SSH into tag:server as ubuntu

This enforces least-privilege access — developers can only reach specific ports on tagged servers and nothing else.

## Tailnet Information

Tailnet name: tail4a417a.ts.net
Tailscale account: jayshreesagar1204@gmail.com

## AI Disclosure

I used ChatGPT during this project — primarily for help structuring the deploy script, scaffolding the HTML files, and drafting the README. I reviewed and tested every command myself, adapted the explanations based on what I actually observed, and made all the architecture and use case decisions independently. The AI helped speed up boilerplate and documentation work, while the implementation, troubleshooting, and validation were done by me.





