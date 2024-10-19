snippet_storage="dir01"
snippet_storage_path="/mnt/pve/$snippet_storage/snippets"
srcvmid="1001"
dstvmid="100"
vmname="seed2"
vmip="192.168.2.145/24"
vmgw="192.168.2.1"
snippet_storage="dir01"
cloudinit_template="100.yaml"

# Copy and modify cloud-init template for this VM
echo "Modifying and copying cloud-init template for VM $vmname..."
cp "$cloudinit_template" "$snippet_storage_path/$dstvmid.yaml"

# Modify the hostname and fqdn in the copied YAML file
sed -i "s/hostname: \"seed\"/hostname: \"$vmname\"/" "$snippet_storage_path/$dstvmid.yaml"
sed -i "s/#fqdn: \"seed.fritz.box\"/fqdn: \"$vmname.fritz.box\"/" "$snippet_storage_path/$dstvmid.yaml"

# Apply cloud-init customization
echo "Applying cloud-init for VM $vmname..."

qm clone $srcvmid $dstvmid --name $vmname &&
qm set "$dstvmid" --cicustom "user=$snippet_storage:snippets/$dstvmid.yaml" &&
qm set "$dstvmid" --ipconfig0 ip=$vmip,gw=$vmgw

qm start $dstvmid
