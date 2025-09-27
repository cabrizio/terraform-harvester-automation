output "hostname" {
  value = harvester_virtualmachine.this.hostname
}

output "ip_address" {
  value = harvester_virtualmachine.this.network_interface[0].ip_address
}

output "network_name" {
  value = harvester_virtualmachine.this.network_interface[0].network_name
}

output "vm_id" {
  value = harvester_virtualmachine.this.id
}
