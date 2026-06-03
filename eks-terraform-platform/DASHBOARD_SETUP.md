# Kubernetes Dashboard Setup Guide

This guide explains how to use the Kubernetes Dashboard setup integrated into your Terraform configuration.

## Overview

The dashboard module provides:
- **Kubernetes Dashboard** deployment via Helm
- **Admin User**: Full cluster access for management
- **Practice User**: Limited read-only access for learning/practice
- Automatic token generation stored in local files

## Prerequisites

1. EKS cluster deployed with `terraform apply`
2. `kubectl` configured to access your EKS cluster
3. `helm` installed locally

## Setup

### 1. Initialize Terraform

```bash
cd eks-terraform-platform
terraform init
```

### 2. Deploy the Dashboard

```bash
terraform plan
terraform apply
```

The apply process will:
- Deploy Kubernetes Dashboard to the cluster
- Create service accounts for admin and practice users
- Apply RBAC rules for each user
- Generate authentication tokens in local files

## Accessing the Dashboard

### Step 1: Start kubectl proxy

```bash
kubectl proxy
```

You should see: `Starting to serve on 127.0.0.1:8001`

### Step 2: Open Dashboard URL

Visit in your browser:
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### Step 3: Authenticate

When prompted, select **Token** and paste one of the tokens below.

## User Roles

### Admin User
**Full cluster access** - Use for:
- Cluster management and troubleshooting
- Creating/deleting resources
- Modifying cluster configuration

**Get token:**
```bash
kubectl -n kubernetes-dashboard create token dashboard-admin-user
```

Or read from file:
```bash
cat dashboard_admin_token.txt
```

### Practice User
**Limited read-only access** - Use for:
- Learning Kubernetes
- Observing cluster resources
- Viewing pod logs and details
- Executing commands in pods (debugging)

**Get token:**
```bash
kubectl -n kubernetes-dashboard create token dashboard-practice-user
```

Or read from file:
```bash
cat dashboard_practice_token.txt
```

## Practice User Permissions

The practice user has read-only access to:
- Pods (including logs and portforward)
- Pod exec (for debugging)
- Deployments, DaemonSets, StatefulSets
- Services and ConfigMaps
- Namespaces

## Terraform Outputs

After deployment, view the dashboard information:

```bash
terraform output
```

Key outputs:
- `dashboard_url` - Direct URL to the dashboard
- `dashboard_admin_command` - Generate new admin token
- `dashboard_practice_command` - Generate new practice token
- `proxy_command` - Kubectl proxy command to run

## Regenerating Tokens

Tokens are valid for a limited time. To generate new tokens:

**Admin token:**
```bash
kubectl -n kubernetes-dashboard create token dashboard-admin-user
```

**Practice token:**
```bash
kubectl -n kubernetes-dashboard create token dashboard-practice-user
```

## Cleanup

To remove the dashboard and related RBAC resources:

```bash
terraform destroy
```

This will remove:
- Kubernetes Dashboard deployment
- All service accounts and roles
- ClusterRoleBindings
- Local token files

## Troubleshooting

### Dashboard not accessible
1. Ensure `kubectl proxy` is running
2. Check pod status: `kubectl get pods -n kubernetes-dashboard`
3. Check service status: `kubectl get svc -n kubernetes-dashboard`

### Token not working
1. Tokens are valid for 1 hour by default
2. Generate a new token using the commands above
3. Verify the service account exists: `kubectl get sa -n kubernetes-dashboard`

### kubectl proxy connection refused
```bash
# Kill existing proxy processes
pkill -f "kubectl proxy"

# Start fresh
kubectl proxy
```

## Additional Resources

- [Kubernetes Dashboard GitHub](https://github.com/kubernetes/dashboard)
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
