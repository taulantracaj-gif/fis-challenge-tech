# 02-Nginx: Reverse Proxy & Load Balancer

# Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Files](#files)  
4. [Certificate Generation (Reference)](#certificate-generation-reference)  
5. [Running Locally](#running-locally)  
   - [Build & Start Container](#build--start-container)  
   - [Access via Ports](#access-via-ports)  
6. [Logs](#logs)  

## Overview
This service configures **NGINX** as:
1. A **reverse proxy** accepting client requests.
2. A **load balancer** distributing traffic across Node.js containers (`app1`, `app2`, `app3`).
3. A **HTTPS gateway**, serving traffic securely with self-signed certificates.

---
## Features
- **Reverse proxying** with `proxy_pass`.
- **Least connections load balancing** (for optimized traffic distribution).
- **SSL termination** with OpenSSL-generated self-signed certs.
- **Logging** (access & error logs) for monitoring traffic.

---
## Files
- `nginx.conf` – Load balancing configurations.
- `docker-compose.yaml` – Deployment of the NGINX container.
- `nginx-certs/`
- `logs/`
  - `access.log`, `error.log`

---
## Certificate Generation (Reference)
 ```bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048
    -keyout {CERT}.key
    -out {CERT}.crt
 ```
- `-nodes` → no passphrase (usable by service containers).
- `-days 365` → valid for 1 year.
- `rsa:2048` → 2048-bit RSA key.

 ---
 ## Running Locally
### Build & Start Container
 ```bash
    cd 02-Nginx
    docker-compose up -d
 ```

 
### Access via Ports
- HTTP → [http://localhost:8080](http://localhost:8080)  
  (redirects to HTTPS)
- HTTPS → [https://localhost:443](https://localhost:443)  
  (may show **self-signed certificate warning**)
---

## Logs
- `logs/access.log` – Shows client traffic and which upstream served request.
- `logs/error.log` – Debugging for SSL or proxy issues.

---
