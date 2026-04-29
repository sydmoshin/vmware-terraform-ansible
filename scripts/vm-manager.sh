#!/bin/bash

# ============================================================================
# VM Manager - Terraform + Ansible VM Management
# ============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR/terraform"
ANSIBLE_DIR="$PROJECT_DIR/ansible"

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_header() { echo -e "${PURPLE}═══${NC} $1 ${PURPLE}═══${NC}"; }

export GOVC_URL='https://vcenter80-hp800g2.corp.mohtel.com/sdk'
export GOVC_USERNAME='administrator@vsphere.local'
export GOVC_PASSWORD='Wajed2moh#'
export GOVC_INSECURE=true
export GOVC_DATACENTER='Datacenter'

cd "$TERRAFORM_DIR"

# ============================================================================
# Clean SSH keys from known_hosts
# ============================================================================
clean_ssh_keys() {
    local VM_NAME=$1
    local VM_IP=$2
    
    if [ -n "$VM_NAME" ]; then
        ssh-keygen -R "$VM_NAME" 2>/dev/null
        ssh-keygen -R "$VM_NAME.corp.mohtel.com" 2>/dev/null
    fi
    if [ -n "$VM_IP" ]; then
        ssh-keygen -R "$VM_IP" 2>/dev/null
    fi
}

# ============================================================================
# Get VM IP address with retry
# ============================================================================
get_vm_ip() {
    local VM_NAME=$1
    local MAX_RETRIES=15
    local RETRY=0
    
    while [ $RETRY -lt $MAX_RETRIES ]; do
        VM_IP=$(terraform output -raw vm_ip 2>/dev/null)
        if [ -n "$VM_IP" ] && [ "$VM_IP" != "null" ]; then
            echo "$VM_IP"
            return 0
        fi
        sleep 5
        RETRY=$((RETRY + 1))
    done
    echo ""
    return 1
}

# ============================================================================
# Create VM
# ============================================================================
create_vm() {
    local VM_NAME=$1
    
    if [ -z "$VM_NAME" ]; then
        print_error "VM name required"
        echo "Usage: $0 create <vm_name>"
        return 1
    fi
    
    print_header "Creating VM: $VM_NAME"
    
    # Create workspace
    terraform workspace new "$VM_NAME" 2>/dev/null || terraform workspace select "$VM_NAME"
    
    # Create tfvars
    cat > terraform.tfvars << EOF
vm_name = "$VM_NAME"
vm_cpus = 2
vm_memory = 4096
domain = "corp.mohtel.com"
root_password = "wajed2moh"
EOF
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        print_info "Initializing Terraform..."
        terraform init > /dev/null 2>&1
    fi
    
    # Apply Terraform
    print_info "Deploying VM with Terraform..."
    terraform apply -auto-approve
    
    if [ $? -ne 0 ]; then
        print_error "Terraform apply failed"
        return 1
    fi
    
    print_success "VM created successfully!"
    
    # Get IP
    print_info "Waiting for IP address..."
    VM_IP=$(get_vm_ip "$VM_NAME")
    
    if [ -z "$VM_IP" ]; then
        print_error "Could not get VM IP"
        return 1
    fi
    
    print_success "VM IP: $VM_IP"
    
    # Clean old SSH keys
    clean_ssh_keys "$VM_NAME" "$VM_IP"
    
    # Wait for SSH
    print_info "Waiting for SSH to be ready..."
    sleep 30
    
    # Run Ansible
    print_info "Installing Nginx via Ansible..."
    
    cat > /tmp/inventory_${VM_NAME} << EOF
[${VM_NAME}]
${VM_IP} ansible_user=root ansible_password=wajed2moh ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
    
    ansible-playbook -i /tmp/inventory_${VM_NAME} \
        "$ANSIBLE_DIR/playbooks/install-nginx.yml" \
        --limit ${VM_NAME}
    
    rm -f /tmp/inventory_${VM_NAME}
    
    if [ $? -eq 0 ]; then
        print_success "Nginx installed successfully!"
        echo ""
        print_header "VM READY"
        echo "  Name: $VM_NAME"
        echo "  IP: $VM_IP"
        echo "  SSH: ssh root@$VM_IP"
        echo "  Password: wajed2moh"
        echo "  Website: http://$VM_IP"
        echo ""
        echo "Note: First SSH may show host key warning"
        echo "  Just run: ssh root@$VM_IP"
        echo ""
    else
        print_warning "VM created but Ansible failed"
        echo "  You can manually SSH: ssh root@$VM_IP"
    fi
}

# ============================================================================
# Destroy VM
# ============================================================================
destroy_vm() {
    local VM_NAME=$1
    
    if [ -z "$VM_NAME" ]; then
        print_error "VM name required"
        return 1
    fi
    
    print_header "Destroying VM: $VM_NAME"
    
    if ! terraform workspace select "$VM_NAME" 2>/dev/null; then
        print_error "VM '$VM_NAME' not found"
        return 1
    fi
    
    echo -n "Destroy VM '$VM_NAME'? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_info "Cancelled"
        return 0
    fi
    
    # Get IP before destroy for cleanup
    VM_IP=$(terraform output -raw vm_ip 2>/dev/null)
    
    terraform destroy -auto-approve
    
    # Clean SSH keys
    clean_ssh_keys "$VM_NAME" "$VM_IP"
    
    terraform workspace select default
    terraform workspace delete "$VM_NAME"
    
    print_success "VM destroyed: $VM_NAME"
}

# ============================================================================
# List VMs
# ============================================================================
list_vms() {
    print_header "VMs Managed by Terraform"
    
    echo ""
    printf "%-25s %-20s %-20s\n" "VM NAME" "STATE" "IP"
    printf "%-25s %-20s %-20s\n" "-------" "-----" "--"
    
    for workspace in $(terraform workspace list | tr -d '* ' | grep -v default); do
        terraform workspace select "$workspace" 2>/dev/null
        VM_NAME=$(terraform output -raw vm_name 2>/dev/null)
        VM_IP=$(terraform output -raw vm_ip 2>/dev/null)
        
        if [ -n "$VM_NAME" ]; then
            POWER_STATE=$(govc vm.info "/Datacenter/vm/${VM_NAME}" 2>/dev/null | grep "Power state" | awk '{print $NF}')
            if [ "$POWER_STATE" = "poweredOn" ]; then
                STATE="${GREEN}running${NC}"
            else
                STATE="${RED}stopped${NC}"
            fi
            printf "%-25s %-20b %-20s\n" "$VM_NAME" "$STATE" "$VM_IP"
        fi
    done
    
    terraform workspace select default 2>/dev/null
    echo ""
}

# ============================================================================
# Install Nginx on existing VM
# ============================================================================
install_nginx() {
    local VM_NAME=$1
    
    if [ -z "$VM_NAME" ]; then
        print_error "VM name required"
        return 1
    fi
    
    print_header "Installing Nginx on: $VM_NAME"
    
    if ! terraform workspace select "$VM_NAME" 2>/dev/null; then
        print_error "VM '$VM_NAME' not found"
        return 1
    fi
    
    VM_IP=$(terraform output -raw vm_ip 2>/dev/null)
    
    if [ -z "$VM_IP" ]; then
        print_error "Could not get VM IP"
        return 1
    fi
    
    cat > /tmp/inventory_${VM_NAME} << EOF
[${VM_NAME}]
${VM_IP} ansible_user=root ansible_password=wajed2moh ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
    
    ansible-playbook -i /tmp/inventory_${VM_NAME} \
        "$ANSIBLE_DIR/playbooks/install-nginx.yml" \
        --limit ${VM_NAME}
    
    rm -f /tmp/inventory_${VM_NAME}
    
    if [ $? -eq 0 ]; then
        print_success "Nginx installed on $VM_NAME"
        echo "  Access website: http://$VM_IP"
    else
        print_error "Failed to install Nginx"
    fi
    
    terraform workspace select default 2>/dev/null
}

# ============================================================================
# Power Operations
# ============================================================================
poweron_vm() {
    local VM_NAME=$1
    print_header "Powering on VM: $VM_NAME"
    govc vm.power -on "/Datacenter/vm/${VM_NAME}"
    print_success "VM powered on"
}

poweroff_vm() {
    local VM_NAME=$1
    print_header "Powering off VM: $VM_NAME"
    govc vm.power -off "/Datacenter/vm/${VM_NAME}"
    print_success "VM powered off"
}

# ============================================================================
# Status
# ============================================================================
status_vm() {
    local VM_NAME=$1
    
    if [ -z "$VM_NAME" ]; then
        print_error "VM name required"
        return 1
    fi
    
    print_header "Status: $VM_NAME"
    
    if ! terraform workspace select "$VM_NAME" 2>/dev/null; then
        print_error "VM '$VM_NAME' not found"
        return 1
    fi
    
    VM_IP=$(terraform output -raw vm_ip 2>/dev/null)
    POWER_STATE=$(govc vm.info "/Datacenter/vm/${VM_NAME}" 2>/dev/null | grep "Power state" | awk '{print $NF}')
    
    echo ""
    echo "  Name: $VM_NAME"
    echo "  IP: $VM_IP"
    echo "  State: $POWER_STATE"
    
    if [ "$POWER_STATE" = "poweredOn" ] && [ -n "$VM_IP" ]; then
        # Test web server
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$VM_IP" 2>/dev/null)
        if [ "$HTTP_STATUS" = "200" ]; then
            echo "  Web: http://$VM_IP (HTTP $HTTP_STATUS)"
        else
            echo "  Web: Not responding"
        fi
    fi
    echo ""
    
    terraform workspace select default 2>/dev/null
}

# ============================================================================
# Help
# ============================================================================
show_help() {
    echo ""
    echo "VM MANAGEMENT WITH TERRAFORM + ANSIBLE"
    echo "======================================="
    echo ""
    echo "Commands:"
    echo "  ./vm-manager.sh create <name>   - Create VM and install Nginx"
    echo "  ./vm-manager.sh destroy <name>  - Delete VM"
    echo "  ./vm-manager.sh list            - List all VMs"
    echo "  ./vm-manager.sh nginx <name>    - Install Nginx on existing VM"
    echo "  ./vm-manager.sh status <name>   - Show VM status"
    echo "  ./vm-manager.sh poweron <name>  - Power on VM"
    echo "  ./vm-manager.sh poweroff <name> - Power off VM"
    echo ""
    echo "Examples:"
    echo "  ./vm-manager.sh create web01"
    echo "  ./vm-manager.sh list"
    echo "  ./vm-manager.sh status web01"
    echo "  ./vm-manager.sh nginx web01"
    echo "  ./vm-manager.sh destroy web01"
    echo ""
    echo "Default password: wajed2moh"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
case "$1" in
    create)
        create_vm "$2"
        ;;
    destroy)
        destroy_vm "$2"
        ;;
    list|ls)
        list_vms
        ;;
    nginx)
        install_nginx "$2"
        ;;
    status)
        status_vm "$2"
        ;;
    poweron)
        poweron_vm "$2"
        ;;
    poweroff)
        poweroff_vm "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

exit 0
