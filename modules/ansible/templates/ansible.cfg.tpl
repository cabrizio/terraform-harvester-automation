[defaults]
inventory = ${inventory_path}
host_key_checking = False
remote_user = ${remote_user}
ask_pass = false
ask_become_pass = false
gather_facts = True
retry_files_enabled = False
timeout = 30
gather_timeout = 30

# Increase verbosity for better debugging
# verbosity = 1

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = false

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30
pipelining = True
retries = 3
