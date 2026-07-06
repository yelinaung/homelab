#!/bin/bash

# Script to create Ubuntu 24.04 cloud template in Proxmox
# Usage: ./create-ubuntu-template.sh [vm_id] [template_name] [image_file]

set -e

# Default values
VM_ID=${1:-9000}
TEMPLATE_NAME=${2:-"ubuntu-24.04-template"}
IMAGE_FILE=${3:-"/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img"}

echo "Creating Ubuntu 24.04 cloud template..."
echo "VM ID: $VM_ID"
echo "Template Name: $TEMPLATE_NAME"
echo "Image File: $IMAGE_FILE"
echo

# Step 1: Create VM with basic configuration
echo "1. Creating VM with ID $VM_ID..."
qm create "$VM_ID" \
	--name "$TEMPLATE_NAME" \
	--memory 2048 \
	--cores 2 \
	--net0 virtio,bridge=vmbr0

echo "   - Created VM with 2GB RAM, 2 cores, virtio network on vmbr0 bridge"

# Step 2: Import the cloud image disk
echo "2. Importing cloud image disk..."
qm importdisk "$VM_ID" "$IMAGE_FILE" local-lvm

echo "   - Imported $IMAGE_FILE to local-lvm storage"
echo "   - This converts the cloud image to a VM disk format"

# Step 3: Configure SCSI controller and attach disk
echo "3. Configuring storage controller..."
qm set "$VM_ID" --scsihw virtio-scsi-pci --scsi0 "local-lvm:vm-$VM_ID-disk-0"

echo "   - Set SCSI hardware to virtio-scsi-pci (high performance)"
echo "   - Attached imported disk as SCSI0 (primary disk)"

# Step 4: Configure boot settings
echo "4. Configuring boot settings..."
qm set "$VM_ID" --boot c --bootdisk scsi0

echo "   - Set boot order to 'c' (boot from disk)"
echo "   - Set boot disk to scsi0 (the imported cloud image)"

# Step 5: Add cloud-init drive
echo "5. Adding cloud-init drive..."
qm set "$VM_ID" --ide2 local-lvm:cloudinit

echo "   - Added cloud-init drive on IDE2"
echo "   - Enables cloud-init configuration (user data, network, SSH keys)"

# Step 6: Configure serial console
echo "6. Configuring serial console..."
qm set "$VM_ID" --serial0 socket --vga serial0

echo "   - Enabled serial console on socket"
echo "   - Set VGA to serial0 for headless operation"
echo "   - Allows console access without VNC/SPICE"

# Step 7: Enable QEMU guest agent
echo "7. Enabling QEMU guest agent..."
qm set "$VM_ID" --agent enabled=1

echo "   - Enabled QEMU guest agent"
echo "   - Provides better VM integration (IP reporting, graceful shutdown)"

# Step 8: Configure cloud-init user data
echo "8. Configuring cloud-init user data..."
qm set "$VM_ID" --ciuser ubuntu
qm set "$VM_ID" --sshkeys ~/.ssh/id_rsa.pub
qm set "$VM_ID" --ipconfig0 ip=dhcp

echo "   - Set cloud-init user to 'ubuntu'"
echo "   - Added SSH public key for authentication (no password set)"
echo "   - Configured network to use DHCP"

# Step 9: Convert VM to template
echo "9. Converting VM to template..."
qm template "$VM_ID"

echo "   - Converted VM to template (read-only, used for cloning)"
echo "   - Template can now be cloned to create new VMs"

echo
echo "Ubuntu 24.04 cloud template created successfully!"
echo "Template Name: $TEMPLATE_NAME"
echo "Template ID: $VM_ID"
echo
echo "The template includes:"
echo "  - Ubuntu 24.04 Noble cloud image"
echo "  - Cloud-init support for automated configuration"
echo "  - QEMU guest agent for better VM management"
echo "  - Serial console for headless operation"
echo "  - Virtio drivers for optimal performance"
echo
echo "You can now clone this template to create new VMs or use it with Packer."
