🚀 VMware vCenter Automation Platform (Terraform + Ansible)

End-to-end Infrastructure as Code (IaC) solution for automated virtual machine provisioning and configuration on VMware vCenter.

This project demonstrates a real-world DevOps workflow where infrastructure is fully provisioned using Terraform and configured using Ansible, simulating enterprise-grade automation pipelines.

✨ Overview

This platform automates the entire VM lifecycle:

🏗️ Infrastructure provisioning in VMware vCenter
⚙️ Post-provision configuration using Ansible
🌐 Application deployment (NGINX example)
🧠 Fully repeatable Infrastructure as Code workflow

Instead of manual VM setup, everything is driven by code.

📌 Architecture
                ┌──────────────────────┐
                │   Terraform Code     │
                └─────────┬────────────┘
                          │
                          ▼
            ┌────────────────────────────┐
            │   VMware vCenter (API)     │
            └─────────┬──────────────────┘
                      │
          VM Provisioned (Linux Instance)
                      │
                      ▼
            ┌────────────────────────────┐
            │        Ansible            │
            └─────────┬──────────────────┘
                      │
                      ▼
        Configuration (NGINX / Services)
🧰 Tech Stack
Layer	Technology
Infrastructure	Terraform
Configuration	Ansible
Virtualization	VMware vCenter
Automation	Bash Scripts
OS	Linux
📁 Project Structure
.
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   │   └── install-nginx.yml
│   └── templates/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── templates/
│   └── scripts/
│
├── scripts/
│   └── vm-manager.sh
│
├── manage.sh
└── README.md
⚙️ How It Works
1️⃣ Provision Infrastructure

Terraform connects to VMware vCenter and creates a virtual machine based on predefined configuration.

2️⃣ Retrieve Outputs

VM details (IP, hostname, etc.) are generated after provisioning.

3️⃣ Configure System

Ansible connects via SSH and configures the VM automatically.

4️⃣ Deploy Application

Example: NGINX web server is installed and started.

🚀 Getting Started
🔹 Clone Repository
git clone https://github.com/YOUR_USERNAME/vmware-terraform-ansible.git
cd vmware-terraform-ansible
🔹 Configure Terraform Variables

Edit:

terraform/terraform.tfvars

Add your vCenter credentials and VM configuration.

🔹 Initialize Terraform
cd terraform
terraform init
🔹 Deploy Infrastructure
terraform apply
🔹 Run Ansible Configuration
cd ../ansible
ansible-playbook -i inventory install-nginx.yml
📸 Screenshots
🖥️ VM Provisioned in VMware vCenter

⚙️ Terraform Execution

🌐 NGINX Deployment

🔐 Security Practices
❌ No credentials stored in code
❌ terraform.tfvars excluded from Git
❌ Terraform state files ignored
🔐 SSH-based secure access
📈 What This Project Demonstrates
Infrastructure as Code (IaC)
VMware automation using APIs
Configuration management at scale
Separation of provisioning and configuration
Real-world DevOps workflow design
🧠 Key Learnings
Terraform provider integration with VMware
Ansible inventory and automation workflows
End-to-end system orchestration
Practical DevOps pipeline design
🚀 Future Improvements
Multi-VM scaling support
Dynamic inventory generation for Ansible
CI/CD integration (GitHub Actions)
Terraform module restructuring
Cloud-init automation support
👨‍💻 Author

Built as a hands-on DevOps automation project focusing on real-world infrastructure workflows.

⭐ If you like this project

Feel free to ⭐ the repository and connect.
