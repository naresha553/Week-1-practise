# EKS Lab Week 1 - Quick Reference

## 📋 Network CIDR Allocation

```
VPC CIDR Block: 10.0.0.0/16 (65,536 IPs)
├─ Public Subnet 1a:     10.0.1.0/24 (256 IPs)
├─ Private Subnet 1a:    10.0.2.0/24 (256 IPs)
├─ Public Subnet 1b:     10.0.3.0/24 (256 IPs)
└─ Private Subnet 1b:    10.0.4.0/24 (256 IPs)
```

## 🏗️ Infrastructure Components Checklist

```
VPC & Subnets:
  ☑️ VPC (10.0.0.0/16)
  ☑️ Public Subnet 1a (10.0.1.0/24, us-east-1a)
  ☑️ Private Subnet 1a (10.0.2.0/24, us-east-1b)
  ☑️ Public Subnet 1b (10.0.3.0/24, us-east-1b)
  ☑️ Private Subnet 1b (10.0.4.0/24, us-east-1c)

Internet Connectivity:
  ☑️ Internet Gateway (IGW)
  ☑️ NAT Gateway 1a (Public Subnet 1a → EIP)
  ☑️ NAT Gateway 1b (Public Subnet 1b → EIP)

Routing:
  ☑️ Public Route Table (0.0.0.0/0 → IGW)
  ☑️ Private Route Table 1a (0.0.0.0/0 → NAT 1a)
  ☑️ Private Route Table 1b (0.0.0.0/0 → NAT 1b)

Worker Nodes:
  ☑️ EC2 Worker 1 (Private Subnet 1a, t3.micro, Ubuntu 22.04)
  ☑️ EC2 Worker 2 (Private Subnet 1b, t3.micro, Ubuntu 22.04)

Security:
  ☑️ Security Group (SSH, HTTP, HTTPS, Pod-to-Pod)
  ☑️ EC2 Key Pair (eks-key)
```

## 🔐 Security Configuration

### Security Group Rules

**Ingress (Inbound):**
- SSH (22/TCP) from 0.0.0.0/0 [LAB ONLY]
- HTTP (80/TCP) from 0.0.0.0/0
- HTTPS (443/TCP) from 0.0.0.0/0
- All TCP ports from 10.0.0.0/16 (VPC)

**Egress (Outbound):**
- All protocols to 0.0.0.0/0 (via NAT)

### Worker Node Security

- ✓ NO public IP assigned
- ✓ Private IP only
- ✓ Access via Bastion or Systems Manager
- ✓ All outbound through NAT Gateway

## 🚀 Deployment Commands

```bash
# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan -o=tfplan

# Deploy
terraform apply tfplan

# View outputs
terraform output

# View specific output
terraform output nat_gateway_eip

# Destroy (cleanup)
terraform destroy
```

## 📊 Important Terraform Outputs

```bash
# VPC
vpc_id              → VPC identifier
vpc_cidr            → 10.0.0.0/16

# Public Subnets
public_subnet_id    → Subnet 1a ID
public_subnet_id_2  → Subnet 1b ID

# Private Subnets (Worker Nodes)
private_subnet_id   → Subnet 1a ID
private_subnet_id_2 → Subnet 1b ID

# NAT Gateways
nat_gateway_id      → NAT 1a ID
nat_gateway_eip     → NAT 1a Public IP (pod source IP)
nat_gateway_id_2    → NAT 1b ID
nat_gateway_eip_2   → NAT 1b Public IP

# Worker Nodes
worker_1_instance_id  → EC2 instance ID
worker_1_private_ip   → Private IP
worker_2_instance_id  → EC2 instance ID
worker_2_private_ip   → Private IP

# Security
security_group_id   → SG ID
key_pair_name       → Key pair name (eks-key)
key_file_path       → SSH key file location

# Connection
ssh_command_worker_1  → SSH command for worker 1
ssh_command_worker_2  → SSH command for worker 2

# Architecture
architecture_summary  → Full architecture diagram
```

## 🧪 Quick Test Commands

```bash
# Get NAT Gateway IP (this is what pod traffic looks like externally)
terraform output nat_gateway_eip

# Get worker node IPs
terraform output worker_1_private_ip
terraform output worker_2_private_ip

# SSH to worker (requires bastion setup)
aws ssm start-session --target $(terraform output -raw worker_1_instance_id)

# Once SSM'd into worker, check NAT:
curl http://checkip.amazonaws.com
# Output: <NAT Gateway Elastic IP>  ✓ Correct!
# This proves outbound traffic uses NAT

# Verify DNS works
nslookup google.com

# Verify you can download files
curl -I https://www.google.com

# Test pod-to-pod reach (same SG, same VPC)
ping <worker-2-private-ip>
```

## 🎯 Traffic Flow Cheat Sheet

```
INTERNET ACCESS (Pod → Internet):
Pod (Private) 
  → Route: 0.0.0.0/0 → NAT Gateway
  → NAT translates: Pod IP → NAT EIP
  → NAT → IGW → Internet
  ✓ Pod can pull images, call APIs

USER ACCESS (User → Pod):
User → Internet
  → Load Balancer (Public) 
  → Pod (Private)
  → NAT Gateway (for response)
  → IGW → Internet → User
✓ Users can reach your services

CROSS-POD (Pod → Pod):
Pod 1 (Private 1a)
  → Route: 10.0.0.0/16 → Local (VPC internal)
  → Pod 2 (Private 1b)
✓ Pods communicate without leaving VPC
```

## 🔧 File Structure

```
eks-terraform-platform/
├── provider.tf              # AWS provider config
├── vpc.tf                   # VPC + subnets (4 total)
├── igw.tf                   # Internet Gateway
├── nat_gateway.tf           # 2 NAT Gateways + EIPs
├── route_table.tf           # Public & Private routing
├── ec2.tf                   # 2 Worker nodes
├── security_group.tf        # Network firewall rules
├── key_pair.tf              # SSH key setup
├── local_file.tf            # Save SSH key locally
├── outputs.tf               # All output values
├── terraform.tfstate        # Current state
├── terraform.tfstate.backup # State backup
└── EKS_LAB_GUIDE.md        # Full documentation
```

## ⚠️ Production Checklist

- [ ] Restrict SSH to specific IPs (not 0.0.0.0/0)
- [ ] Use AWS Systems Manager instead of direct SSH
- [ ] Enable VPC Flow Logs for monitoring
- [ ] Add CloudWatch alarms for NAT Gateway
- [ ] Implement Network ACLs for additional security
- [ ] Use VPN or Private Link for cross-VPC communication
- [ ] Enable GuardDuty for threat detection
- [ ] Implement tagging strategy for cost allocation
- [ ] Set up backup/disaster recovery
- [ ] Document compliance requirements

## 📱 Useful AWS CLI Commands

```bash
# List subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# List NAT Gateways  
aws ec2 describe-nat-gateways

# List EC2 instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Get route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Check NAT Gateway IP
aws ec2 describe-addresses --filters "Name=domain,Values=vpc"
```

## 🎓 Key Terms

| Term | Definition | Example |
|------|-----------|---------|
| **Private Subnet** | Subnet routing to NAT, not IGW | 10.0.2.0/24 |
| **Public Subnet** | Subnet routing to IGW | 10.0.1.0/24 |
| **NAT Gateway** | Translates private IPs for internet | 54.123.45.67 |
| **Elastic IP** | Static public IP for resources | Assigned to NAT |
| **Route Table** | Rules routing traffic | Private RT: 0.0.0.0/0 → NAT |
| **Security Group** | Stateful firewall | Port 22, 80, 443 allowed |
| **IGW** | VPC to Internet connection | Attached to VPC |
| **CIDR** | IP address range notation | 10.0.0.0/16 |
| **AZ** | Availability Zone (data center) | us-east-1a, us-east-1b |

---

**Status: ✅ Lab Ready to Deploy**
