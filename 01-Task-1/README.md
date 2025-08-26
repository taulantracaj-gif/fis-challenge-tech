# Dockerized "Hello World" Web App with Node.js & NGINX

# Table of Contents

1. [Overview](#overview)  
2. [Prerequisites](#prerequisites)  
   - [Docker & Docker Compose](#1-docker--docker-compose-setup)  
   - [Node.js & npm](#2-nodejs--npm)  
   - [OpenSSL](#3-openssl)  
3. [Flow](#flow)  
4. [Running the Solution Prerequisites](#running-the-solution-prerequisites)  
5. [Project Structure and Module READMEs](#project-structure-and-module-readmes)  

## NOTE
The NGINX reverse proxy and load balancer setup (**02-Nginx**) was **not part of the original task requirements**.  
I included it as a **bonus enhancement** to demonstrate HTTPS, reverse proxying, and load balancing in a containerized environment.

## Overview

This project demonstrates how to containerize a simple web application and expose it over HTTP/HTTPS using NGINX as a reverse proxy and load balancer. It is split into two parts:

1. **01-Node**  
   - A Node.js application serving a static HTML page (`index.html`) and images.  
   - Multiple replicas (`app1`, `app2`, `app3`) are created via Docker Compose.  
   - Each app instance exposes its service on a different port.

2. **02-Nginx**  
   - NGINX is configured as a reverse proxy and load balancer to distribute incoming client requests across the Node.js containers.  
   - Implements **least connections load balancing** to optimize distribution.  
   - Configured with **self-signed SSL certificates** to support HTTPS.  
   - Includes logging for requests and errors.

---

## Prerequisites

Before setting up and running this Dockerized web application and NGINX load balancer, make sure your local system has the following tools installed.

### 1. Docker & Docker Compose Setup
**Purpose:**  
Containerization and orchestration for running multiple services.

- **Download for Windows/Mac:** [Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Download for Linux:** [Docker Engine Install Guide](https://docs.docker.com/engine/install/)

 **Verify Installation:** 
 ```bash
    docker --version
    docker-compose --version
 ```   

### 2. Node.js & npm

**Purpose:**  
Local development, building, or running the Node.js web server outside Docker (optional).

- **Download:** [Node.js Download Page](https://nodejs.org/en/download/)
- **Note:** npm (Node Package Manager) comes bundled with Node.js.

**Verify Installation:**
 ```bash
    node --version
    npm --version
 ```

### 3. OpenSSL

**Purpose:**  
Generate self-signed SSL certificates for enabling HTTPS in NGINX.

- **Linux/macOS:**  
  - OpenSSL is usually pre-installed.  
  - If missing, install via package manager:  
    ```
    sudo apt update && sudo apt install openssl   # Debian/Ubuntu
    brew install openssl                          # macOS (Homebrew)
    ```
- **Windows:**  
  - Download installer from [Shining Light Productions](https://slproweb.com/products/Win32OpenSSL.html)

**Verify Installation:**

##  Flow

- Clients connect to `http://localhost:8080` or `https://localhost:443`
- Requests are distributed among the Node.js app containers.
- Static files (HTML + images) are served directly by the Node containers.

## Running the Solution Prerequisites

### Step 1 – Create Shared Docker Network
 ```bash
    docker network create tr-network
 ```

 ## Project Structure and Module READMEs

- [01-Node: Node.js Application README](./01-Task-1/01-Node/README.md)  
- [02-Nginx: NGINX Reverse Proxy and Load Balancer README](./01-Task-1/02-Nginx/README.md) 


