# Architecture Diagram

## Environment Overview

+----------------------------------+         +----------------------------------+
|        MacBook (Node 1)          |         |      AWS EC2 Ubuntu (Node 2)     |
|                                  |         |                                  |
|  Developer Machine               |         |  tailscale-demo-server           |
|  Tailscale IP: 100.64.151.32     |         |  Tailscale IP: 100.83.58.50      |
|                                  |         |                                  |
|  - Tailscale installed           |         |  - Tailscale installed           |
|  - MagicDNS enabled              |         |  - Docker running                |
|  - Browser / curl / SSH client   |         |  - nginx (port 3000) — Portal    |
|                                  |         |  - nginx (port 5000) — API       |
+----------------------------------+         +----------------------------------+
|                                            |
|         Tailscale Tunnel (WireGuard)       |
+--------------------------------------------+
Encrypted — No public ports open
+----------------------------------+
|        Public Internet           |
|                                  |
|  curl http://18.220.17.216:3000  |
|  Result: CONNECTION TIMEOUT      |
|  Nothing is exposed publicly     |
+----------------------------------+




## Traffic Flow

1. Developer types http://tailscale-demo-server:3000 on Mac
2. MagicDNS resolves hostname to 100.83.58.50 (Tailscale IP)
3. Traffic flows over encrypted WireGuard tunnel
4. EC2 server receives request on port 3000 — nginx responds
5. Public internet hits 18.220.17.216:3000 — times out

## What Is NOT Open to the Internet

- Port 3000 — Internal Employee Portal
- Port 5000 — Private API
- Port 22 — SSH (replaced by Tailscale SSH)

## What Tailscale Replaces

| Removed | Replaced With |
|---|---|
| Open security group ports | Tailscale ACL policy |
| Bastion host | Tailscale SSH |
| VPN appliance | WireGuard tunnel via Tailscale |
| SSH key distribution | Identity-based auth |
