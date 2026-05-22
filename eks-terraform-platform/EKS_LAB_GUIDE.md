# EKS Lab - Week 1: Network Architecture & Security

## 🎯 Learning Objective
Understand why EKS clusters use Private Subnets for worker nodes and how the security design pattern protects your infrastructure.

---

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS VPC (10.0.0.0/16)                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐          ┌──────────────────┐         │
│  │ PUBLIC SUBNET 1a │          │ PUBLIC SUBNET 1b │         │
│  │  (10.0.1.0/24)   │          │  (10.0.3.0/24)   │         │
│  ├──────────────────┤          ├──────────────────┤         │
│  │ NAT Gateway ✓    │          │ NAT Gateway ✓    │         │
│  │ IGW ✓            │          │ (standby)        │         │
│  │ Load Balancer*   │          │ (standby)        │         │
│  └──────────────────┘          └──────────────────┘         │
│         │                              │                     │
│         └──────────────┬───────────────┘                     │
│                        │                                     │
│                        ↓ (0.0.0.0/0 → IGW)                  │
│                  ┌─────────────┐                             │
│                  │ INTERNET ☁️ │                            │
│                  └─────────────┘                             │
│                        ↑                                     │
│         ┌──────────────┴───────────────┐                     │
│         │ (0.0.0.0/0 → NAT Gateway)    │                    │
│  ┌──────────────────┐          ┌──────────────────┐         │
│  │ PRIVATE SUB 1a   │          │ PRIVATE SUB 1b   │         │
│  │  (10.0.2.0/24)   │          │  (10.0.4.0/24)   │         │
│  ├──────────────────┤          ├──────────────────┤         │
│  │ Worker Node 1 ✓  │          │ Worker Node 2 ✓  │         │
│  │ Pods ✓           │          │ Pods ✓           │         │
│  │                  │          │                  │         │
│  │ NO public IP ✗   │          │ NO public IP ✗   │         │
│  └──────────────────┘          └──────────────────┘         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Why Private Subnets?

### Security Principle: "Defense in Depth"

| Aspect | Public Subnet | Private Subnet |
|--------|---------------|----------------|
| **Inbound Access** | ✓ Accessible from internet | ✗ BLOCKED |
| **Outbound Access** | → IGW (Direct) | → NAT → IGW (Indirect) |
| **Public IP** | ✓ Yes | ✗ No |
| **Security Risk** | Direct attack surface | Protected |
| **Pod Exposure** | Vulnerable | Safe |

### Why Worker Nodes Go Private

1. **🎯 Attack Surface Reduction**
   - Pods cannot be accessed directly from the internet
   - No random port scanners can find your services
   - SSH access only possible through Bastion/Systems Manager

2. **📦 Container Image Pulling (Still Works!)**
   ```
   Pod needs Docker image:
   Pod → (internal VPC routing) → NAT Gateway → Internet → ECR/Docker Hub
   ✓ Images pull successfully
   ✓ No direct exposure needed
   ```

3. **🔗 API Calls (Still Works!)**
   ```
   Pod calls external API:
   Pod → (internal VPC routing) → NAT Gateway → Internet → External API
   ✓ APIs respond successfully
   ✓ Response comes back through NAT
   ```

4. **👥 User Access (Enabled via Load Balancer)**
   ```
   User Request:
   User → Internet → Load Balancer (Public) → Pod (Private)
   Response:
   Pod → NAT Gateway → Internet → User
   ✓ Users can reach your services
   ✓ Pods remain protected
   ```

---

## 🏗️ Infrastructure Components

### 1. **VPC (Virtual Private Cloud)**
- **CIDR Block**: `10.0.0.0/16`
- **DNS Support**: Enabled (required for EKS)
- **DNS Hostnames**: Enabled (required for pods)

### 2. **Public Subnets** (For NAT & Load Balancer)

| Component | Subnet 1a | Subnet 1b |
|-----------|-----------|-----------|
| **CIDR** | `10.0.1.0/24` | `10.0.3.0/24` |
| **AZ** | `us-east-1a` | `us-east-1b` |
| **Route** | 0.0.0.0/0 → IGW | 0.0.0.0/0 → IGW |
| **Auto Assign IP** | ✓ Yes (for NAT) | ✓ Yes (for NAT) |

### 3. **Private Subnets** (For Worker Nodes & Pods)

| Component | Subnet 1a | Subnet 1b |
|-----------|-----------|-----------|
| **CIDR** | `10.0.2.0/24` | `10.0.4.0/24` |
| **AZ** | `us-east-1b` | `us-east-1c` |
| **Route** | 0.0.0.0/0 → NAT 1a | 0.0.0.0/0 → NAT 1b |
| **Auto Assign IP** | ✗ No | ✗ No |

### 4. **NAT Gateways** (Outbound Internet Access for Pods)

#### NAT Gateway 1a (Primary)
- **Location**: Public Subnet 1a
- **Elastic IP**: Auto-assigned
- **Usage**: Outbound traffic from Private Subnet 1a

#### NAT Gateway 1b (High Availability)
- **Location**: Public Subnet 1b
- **Elastic IP**: Auto-assigned
- **Usage**: Outbound traffic from Private Subnet 1b

**Why 2 NAT Gateways?**
- **High Availability**: If one NAT fails, the other handles traffic
- **Cross-AZ Resilience**: Each private subnet has its own NAT in the same AZ
- **No Single Point of Failure**: True production-grade architecture

### 5. **Internet Gateway** (IGW)
- **Location**: Attached to VPC
- **Purpose**: Routes public subnet traffic to internet
- **NAT Dependency**: NAT Gateway depends on IGW being present

### 6. **Worker Nodes** (EC2 Instances)

| Property | Worker 1 | Worker 2 |
|----------|----------|----------|
| **Subnet** | Private 1a | Private 1b |
| **Private IP** | Dynamic | Dynamic |
| **Public IP** | ✗ No | ✗ No |
| **OS** | Ubuntu 22.04 | Ubuntu 22.04 |
| **Instance Type** | t3.micro | t3.micro |
| **Docker** | ✓ Pre-installed | ✓ Pre-installed |

### 7. **Security Group** (Network Firewall)

#### Inbound Rules
| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | 0.0.0.0/0 | SSH (LAB ONLY!) |
| 80 | TCP | 0.0.0.0/0 | HTTP from LB |
| 443 | TCP | 0.0.0.0/0 | HTTPS from LB |
| ALL | TCP | 10.0.0.0/16 | Pod-to-Pod networking |

#### Outbound Rules
| Port | Protocol | Target | Purpose |
|------|----------|--------|---------|
| ALL | ALL | 0.0.0.0/0 | All outbound (via NAT) |

---

## 📊 Traffic Flow Examples

### Example 1: Pod Pulling Docker Image

```
Step 1: Pod requests Ubuntu image
  Pod (Private) → DNS Query → Route 53

Step 2: Route lookup
  Route: 0.0.0.0/0 → NAT Gateway
  Found! Send to NAT

Step 3: NAT Gateway translates
  Source: Pod Private IP → NAT Public IP (Elastic IP)
  Destination: Docker Hub

Step 4: Docker Hub responds
  Response → Internet → NAT Gateway

Step 5: NAT translates back
  NAT Public IP → Pod Private IP
  Response delivered to Pod

✓ Image successfully pulled!
```

### Example 2: External API Call

```
Step 1: Pod calls https://api.example.com
  Pod (Private) → HTTP Request

Step 2: Routing decision
  Destination: api.example.com (external)
  Route: 0.0.0.0/0 → NAT Gateway
  Send to NAT

Step 3: NAT translates
  Pod Private IP → NAT Public IP
  Request leaves VPC through NAT

Step 4: API server responds
  Response → Internet → NAT Gateway

Step 5: NAT translates back
  NAT Public IP → Pod Private IP
  Response delivered to Pod

✓ API call completed successfully!
```

### Example 3: User Accessing Your Service

```
Step 1: User browser makes request
  User IP → Load Balancer (Public)

Step 2: Load Balancer routes to Pod
  LB (Public Subnet) → Pod (Private Subnet)

Step 3: Pod processes request
  Pod does work

Step 4: Pod sends response
  Response → Pod → NAT Gateway

Step 5: NAT Gateway handles response
  Response → Internet → User Browser

✓ User receives response!
✓ Pod remained protected in private subnet!
```

---

## 🚀 Deployment Instructions

### 1. **Deploy Infrastructure**
```bash
cd eks-terraform-platform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -o=tfplan

# Apply configuration
terraform apply tfplan
```

### 2. **Verify Deployment**
```bash
# Get outputs
terraform output

# Check NAT Gateway IPs (this will be your pod's source IP)
terraform output nat_gateway_eip
terraform output nat_gateway_eip_2

# Check worker node IPs
terraform output worker_1_private_ip
terraform output worker_2_private_ip
```

### 3. **Connect to Worker Node** (requires SSM or Bastion)
```bash
# Via AWS Systems Manager (recommended for production)
aws ssm start-session \
  --target $(terraform output -raw worker_1_instance_id)

# Or set up a Bastion host in public subnet
```

### 4. **Verify Private Subnet Behavior**
```bash
# SSH into worker node (via bastion)
# Then verify no public IP
curl http://checkip.amazonaws.com

# This should show the NAT Gateway's Elastic IP, not worker's IP
# Example Output: 54.123.45.67 (This is NAT Gateway IP)

# Now you know all traffic from this worker uses that IP!
```

---

## 🧪 Lab Exercises

### Exercise 1: Verify Outbound NAT
```bash
# SSH into worker node 1 (via bastion)
# Check all outbound traffic uses NAT IP
curl https://api.ipify.org

# Should show NAT Gateway Elastic IP from terraform output
# Not the worker node's IP!
```

### Exercise 2: Verify Pod-to-Pod Communication
```bash
# SSH into worker 1
# Connect to worker 2
ssh ubuntu@<worker-2-private-ip>

# Should work! (They're in same VPC/SG)
```

### Exercise 3: Verify No Inbound Internet Access
```bash
# SSH into worker 1 (via bastion)
# Try to receive external connections
nc -l -p 8080

# From your local machine, try:
nc -zv <worker-public-ip> 8080

# Should TIMEOUT (no public IP = unreachable!)
```

### Exercise 4: Verify Load Balancer Access**
```bash
# Deploy a simple web server
# ssh into worker 1 (via bastion)
# python3 -m http.server 8080

# Set up load balancer to forward traffic to pod
# Then access from your machine through Load Balancer
curl http://<load-balancer-dns>:8080

# Should work! Traffic: Your IP → LB → Pod → NAT → Response
```

---

## 📚 Key Concepts Summary

| Concept | What | Why |
|---------|------|-----|
| **Private Subnet** | Subnet without public IP routing | Security: protect workloads |
| **NAT Gateway** | Translates private IP → public IP | Enables outbound internet |
| **Elastic IP** | Static public IP for NAT | Consistent outbound address |
| **High Availability** | 2 NAT per AZ | No single point of failure |
| **Route Table** | Rules directing traffic | Private/Public routing logic |
| **Security Group** | Stateful firewall | Control inbound/outbound |
| **IGW** | Internet Gateway | VPC ↔ Internet connection |

---

## 🚨 Important Notes

1. **This is a LAB setup** - The security group allows SSH from anywhere (0.0.0.0/0)
   - ✓ OK for learning
   - ✗ NOT for production
   - **Production**: Restrict SSH to bastion hosts or Systems Manager

2. **NAT Gateway Costs**
   - Each NAT Gateway costs ~$32/month
   - Plus data transfer charges
   - Consider for production budgeting

3. **Kubernetes EKS Tags**
   - Subnets have `kubernetes.io/role/*` tags
   - These help EKS auto-discover subnets
   - **Important for EKS cluster setup**

4. **Cross-AZ Resilience**
   - Worker nodes spread across AZs (1a, 1b, 1c)
   - Each has its own NAT Gateway
   - If entire AZ fails, pods still have internet

---

## 🎓 What You Learned

✅ Why EKS uses private subnets  
✅ How NAT Gateway enables outbound access  
✅ Traffic flow through public/private subnets  
✅ High availability across availability zones  
✅ Security group rules for EKS workloads  
✅ How pods pull images and call APIs securely  

---

## 🔗 Next Steps

1. **Week 2**: EKS Cluster Setup
   - Create actual EKS cluster
   - Deploy kubelets on worker nodes
   - Test pod networking

2. **Week 3**: Container Registry & Image Pulling
   - Set up ECR (Elastic Container Registry)
   - Deploy sample containers
   - Verify image pulling through NAT

3. **Week 4**: Load Balancer & External Access
   - Configure AWS Load Balancer
   - Expose pods to internet
   - Public HTTP/HTTPS access

---

## 📖 References

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [NAT Gateway Concepts](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [EKS Networking](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)

---

**Happy Learning! 🚀**
