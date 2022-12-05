# terraform-aws-eks-cluster

Creating Cluster-EKS using Terraform

# Prerequisites
1. AWS Account
2. IAM User( AmazonEKSCluster ploicy & Admission Control) Save Access Key & Secret keys. Later  Configure to your terminal(aws configure)
3. AWS CLI
4. Terraform
5. Kubectl

# kubeconfig update command
1. update the ~/.kube/config file for the cluster and automatically configure kubectl so that you can connect to the EKS Cluster using the kubectl command. 
2. aws eks update-kubeconfig --region us-east-1 --name EKSClusterName
3. aws eks –region $(terraform output -raw region) update-kubeconfig –name $(terraform output -raw cluster_name)




