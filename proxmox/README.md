# Proxmox VMs: template → clone → VM

This folder builds the Proxmox VMs in three steps, the IaC way.
- Terraform downloads an [Ubuntu cloud image](https://cloud-images.ubuntu.com/) and turns it into a base template.
- Packer then clones that base, installs what every VM needs (e.g. qemu-guest-agent, package updates), and saves the result as a second template.
- Terraform then clones that second template into real VMs.

```
Ubuntu 24.04 cloud image (downloaded to the node)
        │  terraform: vm_template_ubuntu_2404.tf
        ▼
Base template 9000  "ubuntu-24.04-template"
        │  packer: packer/ubuntu-cloud.pkr.hcl
        ▼
Golden template 9001  "ubuntu-24.04-packer"
        │  terraform: modules/vm_clone_module
        ▼
Running VMs (VMID 130 and up)
```

## Step 1: Create base template 9000 (Terraform)

`vm_template_ubuntu_2404.tf` does three things:

1. Downloads `noble-server-cloudimg-amd64.img` (Noble: Ubuntu Server 24.04 LTS) onto the node (`proxmox_download_file`).
2. Uploads a cloud-init snippet (`templates/cloud-init-base.yml.tftpl`) that runs on first boot: it creates the `ubuntu` user with our SSH public half (`data/ubuntu.pub`) and installs `qemu-guest-agent`.
3. Creates VM 9000 from that disk, marks it `template = true`, and wires the snippet in through `user_data_file_id`.

Nothing boots here yet. The template is like a frozen disk plus a first-boot recipe.

The snippet installs the guest agent because Ubuntu cloud images ship without it, and both Packer and Terraform ask the agent for the VM's IP address. Without the agent, they wait forever and time out.

## Step 2: Create golden template 9001 (Packer)

`packer/ubuntu-cloud.pkr.hcl` uses the `proxmox-clone` builder:

1. Clones template 9000 into a temporary VM and boots it.
2. The first-boot cloud-init from step 1 runs: user created, agent installed. The agent reports the IP, and Packer logs in over SSH as `ubuntu` with `~/.ssh/id_rsa`.
3. Provisioners run `apt update` / `apt upgrade` and re-install the agent as a safety net.
4. A last provisioner wipes the machine-id, SSH host files, and cloud-init state, so every future clone looks like a brand-new machine.
5. Packer shuts the VM down and converts it into template 9001.

The point of this step: the slow work (package updates, agent install) happens once, at build time. Clones of 9001 skip all of it and boot ready.

If we are just installing the qemu-guest-agent, Packer may be overkill. Packer is better when:

1. **VM boot time matters, especially with heavy provisioning**

   Cloud-init can run `apt update && apt install ...` on every new VM, just like Packer can at build time. If we are installing just qemu-guest-agent, either with cloud-init or Packer, it will just take a few seconds so it doesn't matter much. However, if it's Docker + JVM + a 2GB ML model + compiled dependencies + `awscli`, every VM will spend like 10 minutes at boot. So, if we bake these in _once_ with Packer, the subsequent clones are ready in seconds. This is the reason autoscaling groups in AWS use AMIs: when traffic spikes, we need the new instance serving in 40 seconds instead of compiling things at boot for ~10 minutes.

2. **Deterministic boot time**

   Cloud-init installing packages during boot means every VM does a live `apt install` against the internet. What if the package mirror is slow today? Boot is slow. Upstream published a new package version an hour ago? The Tuesday VM will be different from the Monday VM. A Packer image is frozen (a snapshot), so every clone is bit-for-bit identical until it is deliberately rebuilt. That's why regulated/production environments bake: the artifact that passed testing (like [CIS Benchmarks](https://www.cisecurity.org/cis-hardened-images/amazon)) is the artifact that runs.

3. **No internet during boot**

   Air-gapped networks, private subnets without NAT, DMZ hosts / higher production environments. Cloud-init can't `apt install` anything if there's no egress route. Everything must be pre-baked.

4. **The change is below cloud-init's reach**

   Cloud-init runs inside a booted OS on first boot. Some things need to happen before that or can't be done from a running system cleanly, such as kernel customization, filesystem layout/partitioning changes, pre-enrolled disk encryption, stripping the OS down (image minimization), or running a full config-management pass (Ansible provisioner in Packer) whose result we want frozen.

5. **Scan/test the artifact, not the instance**

   Run the build in a CI pipeline: Packer build → vulnerability scan the image → smoke-test boot it → tag it v2026.07.07 → only then let Terraform use it. We can't scan-and-approve "whatever cloud-init produces at boot"; there's no artifact until it's already running in production.

6. **Amortizing across many instances**

   If there are just 3 VMs, with one template, cloud-init doing the work 3 times is probably fine. If we are looking at 50 Kubernetes nodes or an autoscaling fleet, 50 identical `apt install docker containerd kubelet` runs are wasted time, wasted bandwidth, and 50 chances for a transient failure.


## Step 3: Create real VMs (Terraform, `vm_clone_module`)

Currently, each VM is one module block using `modules/vm_clone_module`. Using `vm_sample_docker.tf` as the reference:

```hcl
module "sample_docker" {
  source = "./modules/vm_clone_module"

  name             = "sample-docker"
  node_name        = "homelab3"
  vm_id            = 130
  template_vm_id   = 9001
  cpu_cores        = 2
  memory_dedicated = 2048
  disk_size        = 16

  cloud_init_user_data = templatefile("${path.module}/templates/cloud-init-sample-docker.yml.tftpl", {
    ssh_public_key = trimspace(file("${path.module}/data/ubuntu.pub"))
    # ... whatever the template needs
  })
}
```

The module makes a full clone of 9001, grows the disk to `disk_size`, and uploads the per-VM `cloud-init` snippet. That snippet handles everything unique to this one machine like its user, packages, and what it should run.

## Packer vs cloud-init: who does what

- **Packer bakes what every VM shares.** Package updates, the guest agent, and anything else that would otherwise repeat on every boot. The result is an image that is identical every time you clone it.
- **Cloud-init handles what makes each VM itself.** Hostname, user, SSH access, its own packages, its own services. It runs once, on first boot.

> Rule of thumb: if a new VM spends minutes installing the same things as the last one, move those things into the Packer build. If it only needs a name and something to run, cloud-init alone is enough.

## Rebuilding from scratch

```bash
# 1. Base template (download + snippet + VM 9000)
MODULE=proxmox_virtual_environment_vm.ubuntu_2404_template mise run plan-module
MODULE=proxmox_virtual_environment_vm.ubuntu_2404_template mise run apply-module

# 2. Golden template 9001 (needs pve_api_url / pve_username / pve_token,
#    passed as PKR_VAR_* environment variables or an untracked vars file)
cd packer
packer init .
packer build .
cd ..

# 3. VMs
mise run plan
mise run apply
```

Rebuilding 9001 overwrites the old template in place. VMs already cloned from it keep running; only new clones pick up the new image.

## Things that troubled me previously

- **Cloud images have no qemu-guest-agent.** Anything that waits on the agent for an IP (Packer, Terraform) hangs until the base template's cloud-init has installed it. That is why step 1 exists.
- **The Packer plugin ignores the template's hardware settings.** Its defaults (`lsi` controller, `os = other`) leave the cloud image unable to boot (`LABEL=cloudimg-rootfs does not exist`). The build pins `scsi_controller = "virtio-scsi-pci"`, `os = "l26"`, `cpu_type = "host"`.
- **Snippets must be switched on per datastore.** `pvesm set local --content backup,iso,vztmpl,snippets`. Careful: `--content` replaces the full list, so repeat the existing entries.
- **`user_data_file_id` replaces the whole user config.** A `user_account` block next to it is ignored. The user and SSH setup must live inside the snippet itself.
- **Templates stay on one node.** Disks on `local-lvm` are node-local, so a clone can only land on the node that holds the template. Today both templates live on `homelab3`. To clone onto another node, build the templates there too (loop the Packer build over nodes, or `for_each` the Terraform resources), or move to shared storage.
- **VMID rules.** 9000/9001 are reserved for templates. New VMs should start at ID 130. IDs below 130 belong to manually created VMs and LXC containers; some are imported into Terraform, others (LXCs 114-124) are unmanaged. Never reuse them.
