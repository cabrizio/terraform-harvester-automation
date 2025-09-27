resource "harvester_cloudinit_secret" "cloud-config-basic" {
  name      = "cloud-config-basic-${var.vm_name}"
  namespace = var.vm_namespace

  user_data    = <<-EOF
    #cloud-config

    # Harvester-optimized cloud-init configuration
    # Create a new user named 'ubuntu' with password 'ubuntu'

    users:
      - name: ansible
        # Use plain text password for better Harvester compatibility
        plain_text_passwd: ansible

        # Disable password expiration
        passwd_expire: false

        # Create home directory
        home: /home/ansible
        create_home: true

        # Set shell
        shell: /bin/bash

        # Add to groups
        groups: [sudo, users]

        # Enable sudo without password
        sudo: ['ALL=(ALL) NOPASSWD:ALL']

        # Don't lock the password
        lock_passwd: false
        ssh_authorized_keys:
          - >-
            ${trimspace(data.harvester_ssh_key.this.public_key)}
      - name: ubuntu
        # Use plain text password for better Harvester compatibility
        plain_text_passwd: ubuntu

        # Disable password expiration
        passwd_expire: false

        # Create home directory
        home: /home/ubuntu
        create_home: true

        # Set shell
        shell: /bin/bash

        # Add to groups
        groups: [sudo, users]

        # Enable sudo without password
        sudo: ['ALL=(ALL) NOPASSWD:ALL']

        # Don't lock the password
        lock_passwd: false
        ssh_authorized_keys:
          - >-
            ${trimspace(data.harvester_ssh_key.this.public_key)}

    # Enable password authentication for SSH
    ssh_pwauth: true

    # Disable root login but allow password auth
    disable_root: false
    ssh_config:
      PasswordAuthentication: yes
      PermitRootLogin: 'no'

    # Update system on first boot
    package_update: true
    package_upgrade: false

    # Basic packages
    packages:
      - openssh-server
      - curl
      - wget
      - qemu-guest-agent

    # Commands to run after setup
    runcmd:
      - systemctl enable ssh
      - systemctl start ssh
      - systemctl enable --now qemu-guest-agent
      - chage -d 0 ubuntu
      - echo "Cloud-init completed" | tee /var/log/cloud-init-custom.log
      - echo "User ubuntu created with password ubuntu" | tee -a /var/log/cloud-init-custom.log

    ssh_authorized_keys:
      - >-
        ${trimspace(data.harvester_ssh_key.this.public_key)}

    # Power state - don't reboot unless necessary
    power_state:
      mode: poweroff
      delay: 0
      condition: false
    EOF
  network_data = ""
}
