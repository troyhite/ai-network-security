# AI Network Security Bicep Template

This repository contains a Bicep template for deploying a secure AI network infrastructure on Azure. The template provisions various Azure resources, including storage accounts, virtual networks, virtual machines, AI workspaces, and more, with a focus on security and best practices.

## Resources Deployed

The Bicep template deploys the following resources:

1. **Storage Account**
   - Secure storage with TLS 1.2 enforced and public network access enabled.

2. **Azure Cognitive Search Service**
   - A search service with system-assigned identity and public network access enabled.

3. **Key Vault**
   - A secure vault for managing keys, secrets, and certificates with access policies.

4. **Virtual Network**
   - A virtual network with subnets for default and Azure Bastion.

5. **Network Interface**
   - A network interface for the virtual machine.

6. **Virtual Machine**
   - A Windows 11 virtual machine with dynamic private IP allocation.

7. **AI Foundry Hub Workspace**
   - A hub workspace for AI projects with data isolation and identity-based authentication.

8. **AI Foundry Project Workspace**
   - A project workspace linked to the hub workspace with similar security settings.

9. **Public IP Address**
   - A static IPv4 public IP address for the Bastion host.

10. **Azure Bastion Host**
    - A bastion host for secure RDP/SSH access to the virtual machine.

## Parameters

The template includes the following parameters:

- `storageAccountName`: Name of the storage account.
- `searchServiceName`: Name of the search service.
- `keyVaultName`: Name of the key vault.
- `virtualNetworkName`: Name of the virtual network.
- `virtualMachineName`: Name of the virtual machine.
- `bastionHostName`: Name of the bastion host.
- `publicIPAddressName`: Name of the public IP address for the bastion host.
- `aiHubWorkspaceName`: Name of the AI Foundry hub workspace.
- `aiProjectWorkspaceName`: Name of the AI Foundry project workspace.
- `adminPassword`: Administrator password for the virtual machine (secure parameter).
- `adminUsername`: Administrator username for the virtual machine.
- `networkInterfaceName`: Name of the network interface.

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/ai-network-security.git
   cd ai-network-security
   ```

2. Modify the `template.bicep` file to customize the parameters as needed.

3. Deploy the template using Azure CLI:
   ```bash
   az deployment group create --resource-group <your-resource-group> --template-file template.bicep
   ```

4. Monitor the deployment process and verify the resources in the Azure portal.

## Security Considerations

- Ensure the `adminPassword` parameter is stored securely and not hardcoded.
- Review and update access policies for the Key Vault to restrict access.
- Use private endpoints where possible to enhance security.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
