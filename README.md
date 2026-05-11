🚀 VMware vCenter Automation Platform
Terraform + Ansible Infrastructure Automation
End-to-end Infrastructure as Code (IaC) solution for automated virtual machine provisioning and configuration using VMware vCenter, Terraform, and Ansible.
This project demonstrates a real-world DevOps workflow where infrastructure is provisioned with Terraform and configured automatically using Ansible — simulating enterprise-grade automation pipelines.

✨ Features


🏗️ Automated VM provisioning in VMware vCenter


⚙️ Post-provision server configuration with Ansible


🌐 Application deployment (NGINX example)


🔁 Fully repeatable Infrastructure as Code workflow


🔐 Secure credential handling practices


📦 Modular and scalable project structure


🧠 Real-world DevOps automation design



📌 Overview
Instead of manually creating and configuring virtual machines, this platform automates the entire lifecycle through code.
Workflow


Terraform provisions infrastructure in VMware vCenter


VM details and outputs are generated


Ansible connects to the VM via SSH


Required services and applications are installed automatically



🏗️ Architecture
                ┌──────────────────────┐                │   Terraform Code     │                └─────────┬────────────┘                          │                          ▼            ┌────────────────────────────┐            │   VMware vCenter (API)     │            └─────────┬──────────────────┘                      │          VM Provisioned (Linux Instance)                      │                      ▼            ┌────────────────────────────┐            │         Ansible            │            └─────────┬──────────────────┘                      │                      ▼        Configuration (NGINX / Services)

🧰 Tech Stack
LayerTechnologyInfrastructureTerraformConfiguration ManagementAnsibleVirtualization PlatformVMware vCenterAutomationBash ScriptsOperating SystemLinux

📁 Project Structure
.├── ansible/│   ├── inventory/│   ├── playbooks/│   │   └── install-nginx.yml│   └── templates/│├── terraform/│   ├── main.tf│   ├── variables.tf│   ├── terraform.tfvars│   ├── templates/│   └── scripts/│├── scripts/│   └── vm-manager.sh│├── manage.sh└── README.md

⚙️ How It Works
1️⃣ Provision Infrastructure
Terraform connects to VMware vCenter and provisions a virtual machine using predefined configurations.

2️⃣ Retrieve Outputs
Terraform generates outputs such as:


VM IP address


Hostname


Network details


Resource information



3️⃣ Configure the System
Ansible connects to the newly created VM over SSH and performs automated configuration tasks.

4️⃣ Deploy Applications
Example deployment included:


🌐 NGINX Web Server



🚀 Getting Started
🔹 Clone the Repository
git clone https://github.com/YOUR_USERNAME/vmware-terraform-ansible.gitcd vmware-terraform-ansible

🔹 Configure Terraform Variables
Edit the following file:
terraform/terraform.tfvars
Add your:


VMware vCenter credentials


Datacenter configuration


VM specifications


Network settings



🔹 Initialize Terraform
cd terraformterraform init

🔹 Deploy Infrastructure
terraform apply

🔹 Run Ansible Configuration
cd ../ansibleansible-playbook -i inventory install-nginx.yml

📸 Screenshots
Add screenshots here:


🖥️ VMware vCenter VM Provisioning


⚙️ Terraform Apply Execution


🌐 NGINX Deployment


📡 SSH / Automation Workflow


Example:
![Terraform Apply](screenshots/terraform-apply.png)

🔐 Security Best Practices


❌ No credentials stored directly in source code


❌ terraform.tfvars excluded from Git tracking


❌ Terraform state files ignored


🔐 Secure SSH-based authentication


🔐 Infrastructure managed through code and version control



📈 What This Project Demonstrates


Infrastructure as Code (IaC)


VMware automation using APIs


Configuration management with Ansible


Automated Linux server provisioning


Separation of provisioning and configuration workflows


Practical enterprise-style DevOps pipelines



🧠 Key Learnings


Terraform provider integration with VMware vCenter


Ansible inventory and automation workflows


End-to-end infrastructure orchestration


Automation pipeline design


Infrastructure scalability concepts



🚀 Future Improvements


 Multi-VM provisioning support


 Dynamic inventory generation for Ansible


 CI/CD integration using GitHub Actions


 Terraform module restructuring


 Cloud-init support


 Automated rollback and destroy workflows


 Monitoring and logging integration



👨‍💻 Author
Built as a hands-on DevOps automation project focused on real-world infrastructure provisioning and configuration workflows.

⭐ Support
If you found this project useful:


⭐ Star the repository


🍴 Fork the project


🔗 Connect and contribute



📜 License
This project is open-source and available under the MIT License.
