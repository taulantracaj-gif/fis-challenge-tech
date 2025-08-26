# 01-Node: Simple "Hello World" Web App
1. [Overview](#overview)  
2. [How It Works](#how-it-works)  
3. [Running Locally](#running-locally)  
   - [Build & Start](#build--start)  
   - [Check](#check)  

## Overview
This service is a simple **Node.js application** that:
- Serves a static HTML file (`index.html`) on `/`.
- Hosts static images from `/images`.
- Logs which app instance served the request (`App1`, `App2`, `App3`).
- Supports load balancing by running **multiple Node.js containers**.
---
## How It Works
- Each container runs the app on **port 3000** internally.
- Docker Compose maps them externally as:
  - `App1 → localhost:3001`
  - `App2 → localhost:3002`
  - `App3 → localhost:3003`
- When accessed, each prints which container handled the request.

---
## Running Locally
### Build & Start
#### 1. Using Docker CLI 
This approach involves building the Docker image yourself and running containers individually.
**Build the Docker image:**
 ```bash
    cd 01-Node
    docker build -t myapp:1.0 .
 ```
 **Run a container from the image:**
  ```bash
    docker run -d -p 3000:3000 --name myapp-container myapp:1.0
 ```
 **Manage containers::**
   ```bash
    docker ps # List running containers
    docker stop myapp-container # Stop the container
    docker rm myapp-container # Remove the container
 ```
#### 2. Using Docker Compose (recommended for multi-container setup)
Docker Compose automates running multiple container instances with defined networking and environment.

**Start all containers:**

 ```bash
    cd 01-Node
    docker-compose up --build -d
 ```
This will start three replicas (`app1`, `app2`, `app3`), each mapped to different external ports. 

### Check Logs
 ```bash
    docker ps
    docker logs -f {CONTAINER_NAME}
 ```
   
