[harvester_vms]
${vm_hostname} ansible_host=${vm_ip} ansible_user=${ssh_user} ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[harvester_vms:vars]
ansible_python_interpreter=/usr/bin/python3
