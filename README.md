# TERRAFORM TO PROVISION KUBERNETES 

- Check if script ran successfully: sudo cat /var/log/cloud-init-output.log 
- On master instance -  POD_CIDR=10.244.0.0/16 - SERVICE_CIDR=10.96.0.0/16 - sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --cri-socket unix:///var/run/containerd/containerd.sock
- On master apply pod networking = kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml
- Apply ingress controller for loadbalancer = kubectl --kubeconfig=/tmp/kubeconfig apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/aws/deploy.yaml --validate=false --v=8
- helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
- 