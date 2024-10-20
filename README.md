
# Proxmox Import Template and VM Cloning Scripts

This repository contains a collection of Bash scripts designed for Proxmox VE to:
1. Import a Rocky Linux 9 cloud-init image and create a Proxmox template.
2. Clone a single or multiple VMs from a template with cloud-init customization.

## Scripts Overview

### 1. `create_rocky9_template.sh`

This script automates the process of downloading the Rocky Linux 9 qcow2 image, verifying it, and creating a Proxmox template VM configured with cloud-init.

#### Key Features:
- Downloads and verifies the latest Rocky Linux 9 qcow2 cloud-init image.
- Creates a VM, imports the disk, and applies cloud-init settings.
- Configures a network interface and resizes the disk.
- Converts the VM into a Proxmox template.

#### Usage:
\`\`\`bash
sudo ./create_rocky9_template.sh
\`\`\`

### 2. `clone_vm.sh`

This script clones a single VM from a pre-existing Proxmox template and applies a customized cloud-init configuration (hostname, FQDN, and network settings).

#### Key Features:
- Clones a VM from a source VM/template.
- Copies and modifies the cloud-init template to set the VM's hostname and FQDN.
- Applies cloud-init configuration and network settings (IP and gateway).
- Starts the cloned VM.

#### Variables:
- `snippet_storage`: Storage path for cloud-init templates.
- `snippet_storage_path`: Full path to the cloud-init snippet directory.
- `srcvmid`: ID of the source VM/template to clone from.
- `dstvmid`: ID for the new cloned VM.
- `vmname`: Name of the cloned VM.
- `vmip`: IP address to assign to the cloned VM.
- `vmgw`: Gateway for the cloned VM.
- `cloudinit_template`: Path to the base cloud-init YAML file used for cloning.

#### Usage:
\`\`\`bash
sudo ./clone_vm.sh
\`\`\`

### 3. `clone_mult_vm.sh`

This script automates the process of cloning multiple VMs based on a CSV file. Each VM gets its own cloud-init configuration, including customized hostname, FQDN, and network settings.

#### Key Features:
- Reads VM configurations (name, VM ID, disk size, memory, CPU, IP, gateway, additional IPs and VLAN tags) from a CSV file.
- Clones multiple VMs from a specified template.
- Modifies cloud-init files to set unique hostnames, FQDNs, and network settings including multiple NICs, IPs and VLAN tags for each VM.
- Starts the VMs after configuration.

#### CSV File Format:
The `vmlist.csv` file should have the following format:

\`\`\`csv
name,vmid,clonefrom,disksize,memorysize,cpus,ip,gw,ip1,netvlan1,ip2,netvlan2,ip3,netvlan3,ip4,netvlan4,ip5,netvlan5
vm1,101,1001,30G,4096,2,192.168.2.101/24,192.168.2.1,192.168.20.140/24,20,192.168.43.140/24,43,192.168.50.140/24,50,192.168.9.140/24,9
vm2,102,1001,30G,4096,2,192.168.2.102/24,192.168.2.1,192.168.20.141/24,20,192.168.43.141/24,43,192.168.50.141/24,50,192.168.9.141/24,9
\`\`\`

Each row defines a VM's configuration.

#### Variables:
- `snippet_storage`: Storage path for cloud-init templates.
- `snippet_storage_path`: Full path to the cloud-init snippet directory.
- `csv_file`: Path to the CSV file containing VM details.
- `cloudinit_template`: Path to the base cloud-init YAML file used for cloning.

#### Usage:
\`\`\`bash
sudo ./clone_mult_vm.sh
\`\`\`

### Notes:
- Make sure the `local-lvm` or specified storage pool has enough space for the VM disks.
- Ensure the network bridge `vmbr0` exists, or modify the scripts to use your network configuration.
- Verify that the `vmlist.csv` is correctly formatted before running the `clone_mult_vm.sh` script.

### License
This project is licensed under the MIT License. See the `LICENSE` file for more details.
