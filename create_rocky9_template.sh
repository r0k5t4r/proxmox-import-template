#!/bin/bash

# Variables
vmid="201"
storage="local-lvm"
upgrade="1"
ciuser="rocky"
cipassword="rocky"
name="rocky9-template"
agent="1"
qcowdir="/var/lib/vz/template/qcow2"
disksizeplus="20G"
templateurl="https://mirror.netzwerge.de/rocky-linux/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
templatefile="Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
md5sumurl="https://mirror.netzwerge.de/rocky-linux/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2.CHECKSUM"

# Create qcow2 directory if it doesn't exist
echo "Checking if qcow2 directory exists..."
test -d $qcowdir || mkdir -p $qcowdir
cd $qcowdir

# Check if the template image already exists, download if it doesn't
if [ -f "$templatefile" ]; then
    echo "Template image $templatefile already exists, skipping download."
else
    echo "Downloading Rocky 9 qcow2 image..."
    wget --show-progress $templateurl
fi

# Check if the checksum file already exists, download if it doesn't
if [ -f "$checksumfile" ]; then
    echo "Checksum file already exists, skipping download."
else
    echo "Downloading checksum file..."
    wget -O CHECKSUM --show-progress $md5sumurl
fi

# Verify the checksum
echo "Verifying the integrity of the downloaded qcow2 image..."
sha256sum -c CHECKSUM --ignore-missing
if [ $? -ne 0 ]; then
    echo "sha256 checksum verification failed! Exiting..."
    exit 1
else
    echo "sha256 checksum verified successfully."
fi

# Create a new VM
echo "Creating VM $name with ID $vmid..."
qm create $vmid --name $name --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --cpu cputype=host &&
echo "Importing the downloaded qcow2 disk to VM $vmid..."
qm importdisk $vmid Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 $storage &&

# Configure the VM
echo "Configuring VM $vmid with necessary settings..."
qm set $vmid --agent $agent &&
qm set $vmid --ide2 $storage:cloudinit &&
qm set $vmid --cipassword $ciuser &&
qm set $vmid --ciuser $cipassword &&
qm set $vmid --ciupgrade $upgrade &&
qm set $vmid --virtio0 $storage:vm-$vmid-disk-0,cache=writeback,discard=on &&
qm set $vmid --boot c --bootdisk virtio0 &&

# Resize the disk
echo "Increasing disk size by $disksizeplus..."
qm resize $vmid virtio0 +$disksizeplus

# Convert VM to a template
echo "Converting VM $vmid to a template..."
qm template $vmid

echo "Template $name with ID $vmid created successfully!"
