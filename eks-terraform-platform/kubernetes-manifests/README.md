# Kubernetes Practice Manifests

This folder contains YAML manifests for all Kubernetes resource types. You can apply them manually to learn and practice.

## File Structure

Each file is numbered for easy execution order:

| # | File | Resource Type | Description |
|---|------|---------------|-------------|
| 00 | namespace.yaml | Namespace | Creates the 'practice' namespace |
| 01 | deployment-nginx.yaml | Deployment | Nginx web server (2 replicas) |
| 02 | deployment-echo.yaml | Deployment | Echo server (2 replicas) |
| 03 | daemonset-monitor.yaml | DaemonSet | Node monitor (runs on every node) |
| 04 | daemonset-collector.yaml | DaemonSet | Log collector (runs on every node) |
| 05 | pod-debug.yaml | Pod | Standalone debug pod |
| 06 | pod-test.yaml | Pod | Standalone test pod |
| 07 | replicaset.yaml | ReplicaSet | 3 replicas managed by ReplicaSet |
| 08 | replication-controller.yaml | ReplicationController | 2 replicas (legacy RC) |
| 09 | job.yaml | Job | One-time batch job (processes 5 batches) |
| 10 | cronjob.yaml | CronJob | Scheduled job (runs every 5 minutes) |
| 11 | statefulset-mysql.yaml | StatefulSet | MySQL with 2 replicas & persistent storage |
| 12 | service-nginx.yaml | Service | ClusterIP service for nginx |
| 13 | service-echo.yaml | Service | ClusterIP service for echo server |
| 14 | service-mysql-headless.yaml | Service | Headless service for StatefulSet |

## Quick Start

### Apply All Manifests at Once
```bash
kubectl apply -f . -n practice
```

### Apply Namespace First (Required)
```bash
kubectl apply -f 00-namespace.yaml
```

### Apply Individual Manifests
```bash
# Create deployments
kubectl apply -f 01-deployment-nginx.yaml
kubectl apply -f 02-deployment-echo.yaml

# Create daemonsets
kubectl apply -f 03-daemonset-monitor.yaml
kubectl apply -f 04-daemonset-collector.yaml

# Create standalone pods
kubectl apply -f 05-pod-debug.yaml
kubectl apply -f 06-pod-test.yaml

# Create replicaset
kubectl apply -f 07-replicaset.yaml

# Create replication controller
kubectl apply -f 08-replication-controller.yaml

# Create job
kubectl apply -f 09-job.yaml

# Create cronjob
kubectl apply -f 10-cronjob.yaml

# Create statefulset
kubectl apply -f 11-statefulset-mysql.yaml

# Create services
kubectl apply -f 12-service-nginx.yaml
kubectl apply -f 13-service-echo.yaml
kubectl apply -f 14-service-mysql-headless.yaml
```

## Useful Commands for Practice

### View Resources
```bash
# All resources in practice namespace
kubectl get all -n practice

# Specific resource types
kubectl get pods -n practice
kubectl get deployments -n practice
kubectl get daemonsets -n practice
kubectl get replicasets -n practice
kubectl get jobs -n practice
kubectl get cronjobs -n practice
kubectl get statefulsets -n practice
kubectl get services -n practice

# Watch resources in real-time
kubectl get pods -n practice -w

# Detailed view
kubectl describe pod <pod-name> -n practice
kubectl describe deployment <deployment-name> -n practice
```

### Pod Operations
```bash
# View logs
kubectl logs <pod-name> -n practice
kubectl logs -f <pod-name> -n practice  # Follow logs

# Execute commands in pod
kubectl exec -it <pod-name> -n practice -- /bin/sh
kubectl exec <pod-name> -n practice -- ls -la

# Port forward to pod
kubectl port-forward <pod-name> 8080:80 -n practice
```

### Job Monitoring
```bash
# Watch job progress
kubectl get jobs -n practice -w

# View job logs
kubectl logs -n practice job/<job-name>

# Check cronjob history
kubectl get cronjobs -n practice
kubectl get jobs -n practice | grep backup
```

### StatefulSet Operations
```bash
# Check statefulset status
kubectl get statefulsets -n practice
kubectl describe statefulset mysql-statefulset -n practice

# Check persistent volumes
kubectl get pvc -n practice
kubectl get pv

# Connect to MySQL pod
kubectl exec -it mysql-statefulset-0 -n practice -- mysql -p
# Password: password123
```

## Editing and Reapplying

### Edit a resource
```bash
kubectl edit deployment nginx-app -n practice
```

### Delete Resources
```bash
# Delete a single resource
kubectl delete pod debug-pod -n practice

# Delete all resources in namespace
kubectl delete all -n practice

# Delete namespace (deletes all resources in it)
kubectl delete namespace practice
```

## Learning Tips

1. **Start with Deployments** - Most common workload type
2. **Compare DaemonSets** - Understand how they differ from Deployments
3. **Watch Jobs** - See how batch processing works
4. **Monitor CronJobs** - Observe scheduled execution
5. **Explore StatefulSets** - Learn persistent storage and ordering
6. **Test Services** - Understand networking and service discovery

## Resource Efficiency

All containers use minimal images to avoid consuming Pluralsight lab resources:
- **busybox** - Ultra-minimal shell (1-5 MB)
- **alpine** - Lightweight base image (5-7 MB)
- **nginx** - Popular web server
- **mysql:5.7** - Database for learning

CPU/Memory limits are set low to minimize resource usage.

## Cleanup

When done practicing:
```bash
# Delete entire namespace and all resources
kubectl delete namespace practice
```

This will remove all created resources at once.
