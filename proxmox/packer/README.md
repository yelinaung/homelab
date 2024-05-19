### Building Proxmox VM Template with Packer

- [Christian Lempa's Video](https://www.youtube.com/watch?v=1nf3WOEFq1Y)
- [Christian Lempa's boilerplates](https://github.com/ChristianLempa/boilerplates/tree/main/packer/proxmox)
- [Packer](https://www.packer.io/)
- [Proxmox](https://www.proxmox.com/)
- [Packer Proxmox](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)

#### Steps

- Install packer
- Set up Proxmox credentials for Packer
- Create the credential file (e.g `credentials.pkr.hcl`)
```hcl
proxmox_api_url = "https://proxmox_server:8006/api2/json"
proxmox_api_token_id = "user_namn"
proxmox_api_token_secret = "token_secret"
```
- Verify
```bash
$ packer validate -var-file="../credentials.pkr.hcl" ubuntu-server-jammy.pkr.hcl
```
- Build
```bash
$ packer build -var-file="../credentials.pkr.hcl" ubuntu-server-jammy.pkr.hcl
```
- Packer will create a VM template
