# ========================================
# Kubernetes Dashboard Setup with RBAC
# ========================================

# Namespace for Kubernetes Dashboard
resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  depends_on = [
    aws_eks_node_group.main
  ]
}

# ========================================
# Deploy Kubernetes Dashboard using Helm
# ========================================

resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = kubernetes_namespace.dashboard.metadata[0].name
  create_namespace = false
  version          = "6.0.8"

  values = [yamlencode({
    service = {
      type         = "ClusterIP"
      externalPort = 80
    }
    protocolHttp = true
  })]

  depends_on = [
    kubernetes_namespace.dashboard
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
    kubernetes_namespace.dashboard
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
    kubernetes_namespace.dashboard
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
# Generate Authentication Tokens
# ========================================

# Admin Token (stored locally)
resource "local_file" "dashboard_admin_token" {
  filename = "${path.module}/dashboard_admin_token.txt"
  content  = ""

  provisioner "local-exec" {
    command = "kubectl -n kubernetes-dashboard create token dashboard-admin-user > ${path.module}/dashboard_admin_token.txt"
  }

  depends_on = [
    kubernetes_cluster_role_binding.dashboard_admin
  ]
}

# Practice Token (stored locally)
resource "local_file" "dashboard_practice_token" {
  filename = "${path.module}/dashboard_practice_token.txt"
  content  = ""

  provisioner "local-exec" {
    command = "kubectl -n kubernetes-dashboard create token dashboard-practice-user > ${path.module}/dashboard_practice_token.txt"
  }

  depends_on = [
    kubernetes_cluster_role_binding.dashboard_practice
  ]
}

# ========================================
# Outputs
# ========================================

output "dashboard_url" {
  description = "URL to access Kubernetes Dashboard"
  value       = "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
}

output "dashboard_admin_token_file" {
  description = "File containing admin user token"
  value       = local_file.dashboard_admin_token.filename
}

output "dashboard_practice_token_file" {
  description = "File containing practice user token"
  value       = local_file.dashboard_practice_token.filename
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
