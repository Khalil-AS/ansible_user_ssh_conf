🚀 **Ansible Role: User SSH Configuration**

📌 **Overview**

This Ansible role automates the creation and configuration of an SSH user with key-based authentication. It ensures secure access by generating an SSH key, setting up a user, and configuring sudo privileges to allow running hands-off Playbook.

✅ **Features**

✔️ Generates an SSH key pair for secure authentication

✔️ Creates an SSH user with a hashed password

✔️ Adds the SSH key to the authorized_keys file

✔️ Grants the user sudo privileges without a password

✔️ Ensures correct permissions on SSH-related files

📋 Prerequisites

🛠 Supported Operating Systems (Tested)

    Debian 12+

⚙️ Required Dependencies

    Ensure the control machine has:

      Ansible-core 2.15.13

      Python 3.9.21
      
      Paramiko 3.5.1

      Ansible collection community.crypto

    Ensure the target machine has:

      Internet access (for package downloads)
      
      Python 3.11.2

🔑 Privileges

Run playbooks as a user with sudo privileges and SSH passwor auth.

In this role, the default user is control.

🚀 Quick Start Guide

1️⃣ Install the Role

    Clone this repository or download it:

      git clone https://github.com/Kharune/ansible_user_ssh_conf.git
      cd ansible-role-user-ssh

2️⃣ Configure Inventory, Playbook, and Ansible Configuration

Before running the playbook, ensure the following files are properly configured based on your environment.

Inventory Configuration (hosts.yml)

    lab:
      vars:
        ansible_python_interpreter: auto_silent
      hosts:
        192.168.253.130:22450  # Change this based on your environment
    preprod:
      children:
        lab:

Playbook Configuration (PB_deploy_ssh.yml)

    ---
    - name: Configure SSH User with Key-Based Authentication
      hosts: preprod  # Change this based on your target group
      remote_user: admk  # Change this based on your user
      become: true
    
      vars_files:
        - vars/secrets.yml  # Load encrypted variables (e.g., ssh_password)
    
      roles:
        - user_ssh_conf

Ansible Configuration (ansible.cfg)

Ensure your Ansible configuration is set correctly:

    [defaults]
    inventory=/home/control/hosts.yml  # Change to your inventory file
    transport=paramiko  # Change if you don't use paramiko

3️⃣ Run the Playbook

Run the playbook:

    ansible-playbook basic_config_srv_linux.yml --ask-vault-password

⚙️ Role Variables

Customize the user created and key parameters by modifying (defaults/main.yml):
    
    # SSH user created
    ssh_user: control
        
    # SSH key settings
    ssh_key_type: ed25519
    ssh_key_path: "/home/{{ ssh_user }}/.ssh/id_{{ ssh_key_type }}"

    # ssh_password: "sha521!!" # ansible-vault in use, path (vars/secrets.yml) password in vault_pass.txt
