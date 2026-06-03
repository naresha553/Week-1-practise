#!/bin/bash

# Start Kubernetes Dashboard Port Forward
# Usage: bash start-dashboard-portforward.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Kubernetes Dashboard Port Forward Setup                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "Dashboard will be available at: https://localhost:8443"
echo ""

# Kill any existing port-forward on 8443
echo "Checking for existing port-forward processes..."
pkill -f "kubectl port-forward.*8443" 2>/dev/null || true

echo "Starting port-forward to kubernetes-dashboard service..."
echo ""

# Start port-forward
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address=127.0.0.1

echo ""
echo "✓ Port-forward established!"
echo "Dashboard URL: https://localhost:8443"
echo "Press Ctrl+C to stop port-forward"
