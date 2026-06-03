# ========================================
# Kubernetes Dashboard Setup with RBAC
# ========================================

# Update kubeconfig to include EKS cluster
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name} && kubectl config use-context arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${aws_eks_cluster.main.name}"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

data "aws_caller_identity" "current" {}

# Namespace for Kubernetes Dashboard
resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  depends_on = [
    aws_eks_node_group.main,
    null_resource.update_kubeconfig
  ]
}

# ========================================
# Deploy Kubernetes Dashboard using kubectl apply
# ========================================

# Apply official Kubernetes Dashboard manifest
resource "null_resource" "kubernetes_dashboard" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --context arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${aws_eks_cluster.main.name}"
  }

  depends_on = [
    kubernetes_namespace.dashboard,
    aws_eks_node_group.main,
    null_resource.update_kubeconfig
  ]
}

# ========================================
# RBAC: Admin User (Full Cluster Access)
# ========================================

# Service Account for Admin
resource "kubernetes_service_account" "dashboard_admin" {
  metadata {
    name      = "dashboard-admin-user"
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_namespace.dashboard,
    null_resource.update_kubeconfig
  ]
}

# ClusterRoleBinding for Admin
resource "kubernetes_cluster_role_binding" "dashboard_admin" {
  metadata {
    name = "dashboard-admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_admin.metadata[0].name
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.dashboard_admin
  ]
}

# ========================================
# RBAC: Practice User (Limited Access)
# ========================================

# Service Account for Practice User
resource "kubernetes_service_account" "dashboard_practice" {
  metadata {
    name      = "dashboard-practice-user"
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_namespace.dashboard,
    null_resource.update_kubeconfig
  ]
}

# ClusterRole for Practice (Read-only + pods exec)
resource "kubernetes_cluster_role" "practice_role" {
  metadata {
    name = "dashboard-practice-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/logs", "pods/portforward"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create", "get"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

# ClusterRoleBinding for Practice User
resource "kubernetes_cluster_role_binding" "dashboard_practice" {
  metadata {
    name = "dashboard-practice-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.practice_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_practice.metadata[0].name
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.dashboard_practice,
    kubernetes_cluster_role.practice_role
  ]
}

# ========================================
# Port-Forward Setup for Direct Dashboard Access
# ========================================

# Setup port-forward to dashboard service (will be started manually or via script)
# This ensures the dashboard is accessible at https://localhost:8443
resource "local_file" "start_dashboard_portforward" {
  filename = "${path.module}/start-dashboard-portforward.ps1"
  content  = <<-EOT
    # Start Kubernetes Dashboard Port Forward
    # Usage: .\start-dashboard-portforward.ps1
    
    Write-Host "Starting Kubernetes Dashboard port-forward..." -ForegroundColor Cyan
    Write-Host "Dashboard will be available at: https://localhost:8443" -ForegroundColor Green
    Write-Host ""
    
    # Kill any existing port-forward on 8443
    Get-NetTCPConnection -LocalPort 8443 -ErrorAction SilentlyContinue | ForEach-Object {
      Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Forwarding port 8443 to kubernetes-dashboard service..." -ForegroundColor Yellow
    
    # Start port-forward
    kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address=127.0.0.1
    
    Write-Host "✓ Port-forward established!" -ForegroundColor Green
    Write-Host "Dashboard URL: https://localhost:8443" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop port-forward" -ForegroundColor Yellow
  EOT

  depends_on = [
    kubernetes_namespace.dashboard,
    null_resource.kubernetes_dashboard
  ]
}

# Bash version for Git Bash/WSL users
resource "local_file" "start_dashboard_portforward_bash" {
  filename = "${path.module}/start-dashboard-portforward.sh"
  content  = <<-EOT
    #!/bin/bash
    
    # Start Kubernetes Dashboard Port Forward
    # Usage: bash start-dashboard-portforward.sh
    
    echo -e "\033[36mStarting Kubernetes Dashboard port-forward...\033[0m"
    echo -e "\033[32mDashboard will be available at: https://localhost:8443\033[0m"
    echo ""
    
    # Kill any existing port-forward on 8443
    pkill -f "kubectl port-forward.*8443" 2>/dev/null || true
    
    echo -e "\033[33mForwarding port 8443 to kubernetes-dashboard service...\033[0m"
    
    # Start port-forward
    kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address=127.0.0.1
    
    echo -e "\033[32m✓ Port-forward established!\033[0m"
    echo -e "\033[32mDashboard URL: https://localhost:8443\033[0m"
    echo -e "\033[33mPress Ctrl+C to stop port-forward\033[0m"
  EOT

  depends_on = [
    kubernetes_namespace.dashboard,
    null_resource.kubernetes_dashboard
  ]
}

# ========================================
# Outputs
# ========================================

output "dashboard_direct_url" {
  description = "Direct URL to access Kubernetes Dashboard (HTTPS)"
  value       = "https://localhost:8443"
}

output "dashboard_url" {
  description = "URL to access Kubernetes Dashboard via proxy"
  value       = "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
}

output "dashboard_admin_command" {
  description = "Command to get admin token"
  value       = "kubectl -n kubernetes-dashboard create token dashboard-admin-user"
}

output "dashboard_practice_command" {
  description = "Command to get practice token"
  value       = "kubectl -n kubernetes-dashboard create token dashboard-practice-user"
}

output "proxy_command" {
  description = "Command to start kubectl proxy"
  value       = "kubectl proxy"
}

output "dashboard_access_instructions" {
  description = "Instructions to access the dashboard"
  value       = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════╗
    ║          KUBERNETES DASHBOARD ACCESS INSTRUCTIONS              ║
    ╠════════════════════════════════════════════════════════════════╣
    ║                                                                ║
    ║  1. Access Dashboard (Direct HTTPS):                          ║
    ║     https://localhost:8443                                    ║
    ║     (Note: Accept the self-signed certificate warning)        ║
    ║                                                                ║
    ║  2. Generate Admin Token:                                     ║
    ║     kubectl -n kubernetes-dashboard create token \            ║
    ║       dashboard-admin-user                                    ║
    ║                                                                ║
    ║  3. Generate Practice User Token (Read-only):                 ║
    ║     kubectl -n kubernetes-dashboard create token \            ║
    ║       dashboard-practice-user                                 ║
    ║                                                                ║
    ║  4. Login:                                                     ║
    ║     - Select "Token" option                                   ║
    ║     - Paste the token from step 2 or 3                        ║
    ║     - Click "Sign in"                                         ║
    ║                                                                ║
    ║  ROLES:                                                        ║
    ║    • Admin:    Full cluster access and management             ║
    ║    • Practice: Read-only + pod exec (for learning)            ║
    ║                                                                ║
    ║  TOKEN EXPIRATION: 1 hour (generate new token as needed)      ║
    ║                                                                ║
    ╚════════════════════════════════════════════════════════════════╝
    
  EOT
}
