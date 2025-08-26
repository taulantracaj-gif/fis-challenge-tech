# Azure VM Management with Ansible - Complete Project Guide

## 📚 Table of Contents

1. [🏗️ Project Architecture](#️-project-architecture)
2. [📋 Prerequisites](#-prerequisites)
3. [🚀 Phase 1: Infrastructure Deployment with Terraform/Terragrunt](#-phase-1-infrastructure-deployment-with-terraformterragrunt)
   - [1.1 Project Structure](#11-project-structure)
   - [1.2 Virtual Machine Definitions](#12-virtual-machine-definitions)
   - [1.3 Deploy Infrastructure](#13-deploy-infrastructure)
   - [1.4 Key Features](#14-key-features)
4. [🔧 Phase 2: Ansible Configuration and Management](#-phase-2-ansible-configuration-and-management)
   - [2.1 Jump Box Setup](#21-jump-box-setup)
   - [2.2 SSH Key Configuration](#22-ssh-key-configuration)
   - [2.3 Ansible Project Structure](#23-ansible-project-structure)
   - [2.4 Key Configuration Files](#24-key-configuration-files)
   - [2.5 Create Encrypted Password Files](#25-create-encrypted-password-files)
   - [2.6 Update Group Variables](#26-update-group-variables)
   - [2.7 Vault Management Commands](#27-vault-management-commands)
5. [🎯 Phase 3: Role-Based Implementation](#-phase-3-role-based-implementation)
   - [3.1 Common Role](#31-common-role)
   - [3.2 Apache Role (Ubuntu)](#32-apache-role-ubuntu)
   - [3.3 MariaDB Role (RedHat)](#33-mariadb-role-redhat)
6. [🚀 Phase 4: Execution and Testing](#-phase-4-execution-and-testing)
   - [4.1 Test Ansible Connectivity](#41-test-ansible-connectivity)
   - [4.2 Run the Complete Playbook](#42-run-the-complete-playbook)
   - [4.3 Execution Options](#43-execution-options)
7. [✅ Phase 5: Verification and Testing](#-phase-5-verification-and-testing)
   - [5.1 Apache Web Server Verification](#51-apache-web-server-verification)
   - [5.2 MariaDB Database Verification](#52-mariadb-database-verification)
   - [5.3 System Monitoring Commands](#53-system-monitoring-commands)
8. [🔍 Troubleshooting](#-troubleshooting)
   - [Common Issues and Solutions](#common-issues-and-solutions)
   - [Log Analysis](#log-analysis)
9. [🌟 Key Benefits of This Architecture](#-key-benefits-of-this-architecture)
10. [📝 Next Steps and Extensions](#-next-steps-and-extensions)
11. [📚 Additional Resources](#-additional-resources)

---
This project demonstrates how to deploy Azure Virtual Machines using Terraform/Terragrunt and manage them with Ansible using a role-based architecture. The setup includes Ubuntu and RedHat servers managed through a jump box with Apache and MariaDB configurations.

## 🏗️ Project Architecture

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Jump Box (Ubuntu) │────│  Ubuntu Server      │    │  RedHat Server      │
│   - Ansible Control │    │  - Apache Web Server│    │  - MariaDB Database │
│   - SSH Key Management│    │  - Custom HTML Page │    │  - Demo Database    │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
        172.22.1.x                172.22.1.x               172.22.1.x
```

## 📋 Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Terragrunt
- SSH client
- Basic knowledge of Ansible, Terraform, and Linux administration

## 🚀 Phase 1: Infrastructure Deployment with Terraform/Terragrunt

### 1.1 Project Structure

```
terraform/
├── main.tf
├── locals_vms.tf
├── locals_globals.tf
├── data.tf
├── output.tf
├── modules/
│   └── vm-blueprint/
│       ├── vm-linux.tf
│       ├── variables.tf
│       ├── output.tf
│       └── data.tf
└── terragrunt/
    ├── tr-subscr/
    │   ├── env.hcl
    │   └── terragrunt.hcl
    └── root.hcl
```

### 1.2 Virtual Machine Definitions

The infrastructure creates three VMs:
- **Ubuntu Server** (`vm-tr-ubuntu-ne-001`) - Standard_B1ms
- **RedHat Server** (`vm-tr-redhat-ne-002`) - Standard_B2ms  
- **Jump Box** (`vm-tr-jumpbox-ne-003`) - Standard_B2ms (Ubuntu-based)

### 1.3 Deploy Infrastructure

```bash
# Navigate to terragrunt directory
cd terragrunt/tr-subscr/

# Initialize and deploy
terragrunt init
terragrunt plan
terragrunt apply
```

### 1.4 Key Features

- **Automated SSH Key Generation**: Uses Azure API to generate SSH key pairs
- **Key Vault Integration**: Stores private keys and VM passwords securely
- **Network Security**: VMs deployed in private subnet
- **Managed Identity**: System-assigned managed identities for each VM
- **Encryption**: Encryption at host enabled for security

## 🔧 Phase 2: Ansible Configuration and Management

### 2.1 Jump Box Setup

SSH into the jump box and set up the environment:

```bash
# SSH to jump box (use private key from Key Vault)
ssh -i ~/.ssh/jumpbox-key azureuser@<JUMPBOX_PUBLIC_IP>

# Update system and install required packages
sudo apt update
sudo apt install ansible curl wget tree vim -y
```

### 2.2 SSH Key Configuration

Generate and distribute SSH keys for passwordless authentication:

```bash
# Generate SSH key pair on jump box
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copy public key to target servers
echo "<KEY>" >> ~/.ssh/authorized_keys

# Test SSH connectivity
ssh azureuser@172.22.1.X  # Ubuntu server
ssh azureuser@172.22.1.X  # RedHat server
```

### 2.3 Ansible Project Structure

Create the role-based Ansible project structure:


```
ansible-project/
├── ansible.cfg
├── inventories/
│   └── hosts.yml
├── playbooks/
│   ├── playbooks.yml
│   ├── redhat.yml
│   └── ubuntu.yml
│   └── health-check.yml
├── group_vars/
│   ├── all.yml
│   ├── ubuntu_servers.yml
│   └── redhat_servers.yml
└── roles/
    ├── common/
    │   ├── tasks/
    │   │   ├── main.yml
    │   │   ├── update_ubuntu.yml
    │   │   └── update_redhat.yml
    │   │   └── gather_facts.yml
    │   └── handlers/main.yml
    ├── apache/
    │   │   ├── tasks/
    │   │   ├── install.yml
    │   │   ├── main.yml
    │   ├── handlers/main.yml
    │   └── templates/index.html.j2
    └── mariadb/
        ├── tasks/
        │   ├── main.yml
        │   ├── install.yml
        │   ├── database.yml
        │   └── status-check.yml
        │   └── configure.yml
        └── handlers/main.yml
```

### 2.4 Key Configuration Files

#### Inventory (inventories/hosts.yml)
```yaml
all:
  children:
    ubuntu_servers:
      hosts:
        ubuntu-vm:
          ansible_host: 172.22.1.x
          ansible_user: azureuser
    redhat_servers:
      hosts:
        redhat-vm:
          ansible_host: 172.22.1.x
          ansible_user: azureuser
```

#### Ansible Configuration (ansible.cfg)
```ini
[defaults]
inventory = inventories/hosts.yml
remote_user = azureuser
host_key_checking = False
timeout = 30
log_path = ~/ansible.log
gathering = smart
fact_caching = memory
roles_path = roles

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o UserKnownHostsFile=/dev/null
pipelining = True
```

#### Main Playbook (playbooks/site.yml)
```yaml
---
- name: Manage All Servers - Common Tasks
  hosts: all
  become: yes
  roles:
    - common

- name: Configure Ubuntu Servers
  hosts: ubuntu_servers
  become: yes
  roles:
    - apache

- name: Configure RedHat Servers
  hosts: redhat_servers
  become: yes
  roles:
    - mariadb
```
### 2.5 Create Encrypted Password Files
Create secure password storage using Ansible Vault:

```bash
# Create directory structure for vault files
mkdir -p group_vars/redhat_servers

# Create encrypted vault file for MariaDB passwords
ansible-vault create group_vars/redhat_servers/vault.yml
```

When prompted, enter a vault password and then add the following content:
```yaml
# Encrypted passwords for RedHat servers
vault_mariadb_root_password: "YourSuperSecurePassword123!"
```

### 2.6 Update Group Variables

#### group_vars/redhat_servers/vars.yml
```yaml
---
# RedHat-specific variables (non-sensitive)
mariadb_database_name: "ansible_demo_db"
mariadb_service_name: "mariadb"

# Reference to vaulted passwords
mariadb_root_password: "{{ vault_mariadb_root_password }}"

```

#### 2.7 Vault Management Commands
```bash
# View encrypted file
ansible-vault view group_vars/redhat_servers/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/redhat_servers/vault.yml

# Change vault password
ansible-vault rekey group_vars/redhat_servers/vault.yml

# Encrypt existing file
ansible-vault encrypt group_vars/redhat_servers/vars.yml

# Decrypt file (temporarily)
ansible-vault decrypt group_vars/redhat_servers/vault.yml
```

## 🎯 Phase 3: Role-Based Implementation

### 3.1 Common Role
Handles system updates and basic configuration for all servers:
- System information gathering
- OS-specific package updates (APT for Ubuntu, YUM for RedHat)
- Reboot management if required

### 3.2 Apache Role (Ubuntu)
Configures web server on Ubuntu systems:
- Apache2 installation and configuration
- Dynamic HTML page with server information
- Firewall configuration (UFW)
- Service management and health checks

### 3.3 MariaDB Role (RedHat)
Sets up database server on RedHat systems:
- MariaDB server installation
- Database security configuration
- Demo database and table creation
- Firewall configuration (firewalld)

## 🚀 Phase 4: Execution and Testing

### 4.1 Test Ansible Connectivity

```bash
# Test ping to all servers
ansible all -m ping

# Expected output:
ubuntu-vm | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
redhat-vm | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```
# Test ping to specific servers
```
ansible ubuntu_servers -i inventories/hosts.yml -m ping
ansible redhat_servers -i inventories/hosts.yml -m ping
```

### 4.2 Run the Complete Playbook

```bash
# Navigate to project directory
cd ~/ansible-project

# Check playbook syntax
ansible-playbook --syntax-check playbooks/site.yml

# Run the complete playbook
ansible-playbook playbooks/site.yml -v
ansible-playbook playbooks/site.yml -v --ask-vault-pass
```

Vault password: 
[WARNING]: Unable to parse /home/azureuser/ansible-new/hosts.yml as an inventory source
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

### 4.3 Execution Options

```bash
# Run only common tasks
ansible-playbook playbooks/site.yml --tags common

# Run only Ubuntu servers
ansible-playbook playbooks/site.yml --limit ubuntu_servers

# Run only RedHat servers  
ansible-playbook playbooks/site.yml --limit redhat_servers

# Dry run (check mode)
ansible-playbook playbooks/site.yml --check

# Maximum verbosity for debugging
ansible-playbook playbooks/site.yml -vvv
```

## ✅ Phase 5: Verification and Testing

### 5.1 Apache Web Server Verification

```bash
# Test Apache from jump box
curl http://172.22.1.x

# Pretty print HTML response
curl -s http://172.22.1.x | grep -E '<title>|<h1>|Hello World'

# Check Apache status via Ansible
ansible ubuntu_servers -a "systemctl status apache2" --become

# SSH into Ubuntu VM for local testing
ssh azureuser@172.22.1.x
sudo systemctl status apache2
curl http://localhost
exit
```

### 5.2 MariaDB Database Verification

```bash
# Check MariaDB status via Ansible
ansible redhat_servers -a "systemctl status mariadb" --become

# SSH into RedHat VM for database testing
ssh azureuser@172.22.1.8

# Test MariaDB connection (Password: SecurePassword123!)
mysql -u root -p -e "SHOW DATABASES;"
mysql -u root -p -e "USE ansible_demo_db; SELECT * FROM servers;"

# Check service status
sudo systemctl status mariadb
exit
```

### 5.3 System Monitoring Commands

```bash
# Check system uptime on all servers
ansible all -a "uptime"

# Check disk usage
ansible all -a "df -h" --become

# Check memory usage
ansible all -a "free -h"

# Check network connections
ansible all -a "netstat -tlnp" --become
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Playbook Execution Issues
```bash
# Check playbook syntax
ansible-playbook --syntax-check playbooks/site.yml

# Dry run to see what would change
ansible-playbook playbooks/site.yml --check

# Run with maximum verbosity
ansible-playbook playbooks/site.yml -vvv
```

#### Service Issues
```bash
# Apache troubleshooting (Ubuntu)
ansible ubuntu_servers -a "sudo systemctl status apache2" --become
ansible ubuntu_servers -a "sudo journalctl -u apache2 -n 20" --become

# MariaDB troubleshooting (RedHat)
ansible redhat_servers -a "sudo systemctl status mariadb" --become
ansible redhat_servers -a "sudo journalctl -u mariadb -n 20" --become
```

#### Package Installation Issues
```bash
# Check disk space
ansible all -a "df -h /" --become

# Check for package manager locks
ansible ubuntu_servers -a "sudo lsof /var/lib/dpkg/lock-frontend" --become
ansible redhat_servers -a "sudo lsof /var/run/yum.pid" --become
```

### Log Analysis

```bash
# View Ansible execution logs
tail -f ~/ansible.log

# View Apache access logs (Ubuntu)
ansible ubuntu_servers -a "tail -10 /var/log/apache2/access.log" --become

# View MariaDB logs (RedHat)
ansible redhat_servers -a "tail -10 /var/log/mariadb/mariadb.log" --become
```

## 🌟 Key Benefits of This Architecture

### 1. **Infrastructure as Code**
- Repeatable VM deployments using Terraform/Terragrunt
- Version-controlled infrastructure configuration
- Automated SSH key management and security

### 2. **Modular Ansible Design**
- **Role Separation**: Each service (Apache, MariaDB) in separate roles
- **Reusability**: Roles can be used across different projects
- **Maintainability**: Easy to update and extend individual components
- **Variables**: Proper separation using group_vars for different server types

### 3. **Security Best Practices**
- SSH key-based authentication (no passwords)
- Private network deployment
- Key Vault integration for sensitive data

### 4. **Operational Excellence**
- **Health Checks**: Automated service verification
- **Logging**: Comprehensive logging for troubleshooting  
- **Templates**: Dynamic content generation
- **Handlers**: Efficient service restart management

### 5. **Scalability**
- Easy to add new server types or services
- Template-based infrastructure deployment
- Role-based configuration management

## 📝 Next Steps and Extensions

1. **Add SSL/TLS Configuration**: Implement HTTPS for Apache
2. **Database Backup**: Automated MariaDB backup roles
3. **Monitoring Integration**: Add Prometheus/Grafana monitoring
4. **CI/CD Pipeline**: Integrate with Azure DevOps or GitHub Actions
5. **High Availability**: Load balancer and database clustering
6. **Configuration Management**: Extend with more services (Nginx, PostgreSQL, etc.)

---
