
# Kubernetes Provisioning with Terraform and KOPS  

This repository provides detailed instructions and scripts to set up Kubernetes clusters using two approaches: **Terraform** and **KOPS**. It outlines the steps to provision Kubernetes on AWS, apply networking configurations, and deploy essential services like ingress controllers.

---

## 🚀 Features  

1. **Provision Kubernetes with Terraform**  
   - Automate Kubernetes setup with `kubeadm`.
   - Define Pod and Service CIDRs.
   - Configure networking and ingress controllers.

2. **Provision Kubernetes with KOPS**  
   - Simplified Kubernetes cluster management on AWS.  
   - Automate cluster creation, updates, and validation.  
   - Use Route53 for DNS management.

3. **Networking and Ingress**  
   - Apply networking configurations.  
   - Set up and manage an ingress controller for load balancing.  

---

## 🛠️ Prerequisites  

1. **AWS**  
   - Access to an AWS account with administrative permissions.  
   - S3 bucket for cluster state storage (KOPS).  
   - Route53 hosted zone for DNS management.  

2. **Tools**  
   - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).  
   - [KOPS](https://kops.sigs.k8s.io/getting_started/install/).  
   - [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).  
   - [Helm](https://helm.sh/docs/intro/install/).  

---

## 🔧 Provision Kubernetes with Terraform  

### Steps  

1. **Set Up Instances**  
   - Ensure the script ran successfully:  
     ```bash  
     sudo cat /var/log/cloud-init-output.log  
     ```

2. **Initialize Master Node**  
   - Define Pod and Service CIDRs:  
     ```bash  
     POD_CIDR=10.244.0.0/16  
     SERVICE_CIDR=10.96.0.0/16  
     ```  
   - Initialize Kubernetes:  
     ```bash  
     sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --cri-socket unix:///var/run/containerd/containerd.sock  
     ```

3. **Apply Pod Networking**  
   ```bash  
   kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml  
   ```

4. **Deploy Ingress Controller**  
   ```bash  
   kubectl --kubeconfig=/tmp/kubeconfig apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/aws/deploy.yaml --validate=false --v=8  
   ```  
   ```bash  
   helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace  
   ```

---

## 🌐 Provision Kubernetes with KOPS  

### Steps  

1. **Set Up AWS Resources**  
   - Create an S3 bucket for cluster state storage.  
   - Set up a Route53 hosted zone:  
     - Add NS records from Route53 to GoDaddy.  

2. **Install Tools**  
   - [Install KOPS](https://kops.sigs.k8s.io/getting_started/install/).  
   - [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).  

3. **Create the Cluster**  
   ```bash  
   kops create cluster --name=adityaitc.theaditya.co.uk \  
       --state=s3://111-aditya-bucket \  
       --zones=eu-west-2a,eu-west-2b \  
       --node-count=2 --node-size=t3.small \  
       --control-plane-size=t3.medium \  
       --dns-zone=adityaitc.theaditya.co.uk \  
       --node-volume-size=12 --control-plane-volume-size=12 \  
       --ssh-public-key ~/.ssh/id_ed25519.pub  
   ```  

4. **Update and Validate Cluster**  
   ```bash  
   kops update cluster --name adityaitc.theaditya.co.uk --yes --admin --state=s3://111-aditya-bucket  
   kops validate cluster --name adityaitc.theaditya.co.uk --state=s3://111-aditya-bucket  
   ```

5. **Delete Cluster**  
   ```bash  
   kops delete cluster --name adityaitc.theaditya.co.uk --state=s3://111-aditya-bucket --yes  
   ```  

---

## 📚 Resources  

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs).  
- [Kubernetes Official Docs](https://kubernetes.io/docs/home/).  
- [KOPS Documentation](https://kops.sigs.k8s.io/).  

---

## 🤝 Contributing  

Feel free to contribute by opening issues or submitting pull requests. Let's make Kubernetes provisioning seamless!

---
