#!/bin/bash

# Define variables
snippet_storage="dir01"
snippet_storage_path="/mnt/pve/$snippet_storage/snippets"
csv_file="vmlist.csv"
cloudinit_template="ci_temp.yaml"

# Read the CSV file and skip the header
tail -n +2 "$csv_file" | while IFS=',' read -r vmname dstvmid srcvmid disksize memsize cpus vmip vmgw vmip1 netvlan1 vmip2 netvlan2 vmip3 netvlan3 vmip4 netvlan4; do

    # Clone the VM from the source VM ID
    echo "Cloning VM $vmname (ID: $dstvmid) from template $srcvmid..."
    qm clone "$srcvmid" "$dstvmid" --name "$vmname"

    # Set the memory, CPUs, and disk size
    echo "Configuring VM $vmname: CPUs=$cpus, Memory=$memsize, Disk=$disksize..."
    qm set "$dstvmid" --memory "$memsize" --cores "$cpus" --ide0 "$snippet_storage:vm-$dstvmid-disk-0,size=$disksize"

    # Copy and modify cloud-init template for this VM
    echo "Modifying and copying cloud-init template for VM $vmname..."
    cp "$cloudinit_template" "$snippet_storage_path/$dstvmid.yaml"

    # Modify the hostname and fqdn in the copied YAML file
    sed -i "s/hostname: \"seed\"/hostname: \"$vmname\"/" "$snippet_storage_path/$dstvmid.yaml"
    sed -i "s/#fqdn: \"seed.fritz.box\"/fqdn: \"$vmname.fritz.box\"/" "$snippet_storage_path/$dstvmid.yaml"

    # Apply cloud-init customization
    echo "Applying cloud-init for VM $vmname..."
    qm set "$dstvmid" --cicustom "user=$snippet_storage:snippets/$dstvmid.yaml"

    # Configure network settings (IP and gateway)
    echo "Setting IP config for VM $vmname: IP=$vmip, Gateway=$vmgw..."
    qm set "$dstvmid" --ipconfig0 ip="$vmip",gw="$vmgw"
    qm set "$dstvmid" --net1 virtio,bridge=vmbr0,tag=$netvlan1
    qm set "$dstvmid" --net2 virtio,bridge=vmbr0,tag=$netvlan2
    qm set "$dstvmid" --net3 virtio,bridge=vmbr0,tag=$netvlan3
    qm set "$dstvmid" --net4 virtio,bridge=vmbr0,tag=$netvlan4
    echo qm set "$dstvmid" --ipconfig1 ip="$vmip1"
    qm set "$dstvmid" --ipconfig1 ip="$vmip1"
    echo qm set "$dstvmid" --ipconfig2 ip="$vmip2"
    qm set "$dstvmid" --ipconfig2 ip="$vmip2"
    echo qm set "$dstvmid" --ipconfig3 ip="$vmip3"
    qm set "$dstvmid" --ipconfig3 ip="$vmip3"
    echo qm set "$dstvmid" --ipconfig4 ip="$vmip4"
    qm set "$dstvmid" --ipconfig4 ip="$vmip4"

    # Start the VM
    qm start $dstvmid

    echo "VM $vmname setup completed."
done

echo "All VMs processed."
