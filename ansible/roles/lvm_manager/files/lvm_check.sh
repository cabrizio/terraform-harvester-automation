#!/bin/bash
# roles/lvm_manager/files/lvm_check.sh
# LVM status checking script

set -e

echo "=== LVM Configuration Status ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

echo "=== Disk Layout ==="
lsblk
echo ""

echo "=== Physical Volumes ==="
if command -v pvs >/dev/null 2>&1; then
    pvs --all || echo "No physical volumes found"
else
    echo "LVM tools not installed"
fi
echo ""

echo "=== Volume Groups ==="
if command -v vgs >/dev/null 2>&1; then
    vgs --all || echo "No volume groups found"
else
    echo "LVM tools not installed"
fi
echo ""

echo "=== Logical Volumes ==="
if command -v lvs >/dev/null 2>&1; then
    lvs --all || echo "No logical volumes found"
else
    echo "LVM tools not installed"
fi
echo ""

echo "=== Mount Points ==="
mount | grep -E "(mapper|lvm)" || echo "No LVM mounts found"
echo ""

echo "=== Filesystem Usage ==="
df -h | grep -E "(mapper|lvm|Filesystem)" || df -h
echo ""

echo "=== fstab LVM Entries ==="
grep -E "(mapper|lvm)" /etc/fstab || echo "No LVM entries in /etc/fstab"
echo ""

echo "=== LVM Services Status ==="
for service in lvm2-lvmpolld lvm2-monitor; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "$service: active"
    else
        echo "$service: inactive/not found"
    fi
done
