# Welcome to MyProject!
![](https://media.giphy.com/media/XD9o33QG9BoMis7iM4/giphy.gif)

*(DANGER! This gif may harm your eyes)*
<br/>
<br/>
### *TheElephant is the finel Opsschool project*
TheElephant will setup a full application architecture (infrastructure, service discovery, logging, monitoring, database and a full CICD process) which can help you control and monitor your AWS' instances.       
<br/>

## Prerequisites

 - Clone this repo
 - [Terraform](https://www.terraform.io/) version v0.14.3  
 Linux/Windows can be downloaded [here](https://releases.hashicorp.com/terraform/0.14.3/) 
 macOS using brew `brew install terraform@0.14` 

<br/>

## How To use  

Under _[variables.tf](https://github.com/rotemad/TheElephant/blob/main/variables.tf),_ set-up your [AWS profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) (the default profile is `default`)

To start the infrastructure provisioning, run the following commands:

`terraform init`

`terraform apply --auto-approve`

Once the provisioning ends, you will get the following output:

 - The *public* IP addresses of the bastion server
 - The *private* IP addresses of the Jenkins Master and Workers
 - The *private* IP addresses of the Consul servers
 - The *private* IP addresses of the Prometheus & Grafana Server
 - The *private* IP addresses of the Kibana service
 - ARN output for k8s 


A general certificate `gen_key.pem` will be generated during the provisioning which can be used to login to all the hosts.

<br/>

### EKS Cluster
In oreder to use and control the EKS cluster:

 - Make sure you have    [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)   , [kubctl](https://kubernetes.io/docs/tasks/tools/#kubectl)  and [helm](https://helm.sh/docs/intro/install/#through-package-managers)   installed  

- Run:
`aws eks --region=us-east-1 update-kubeconfig --name eks-TheElephant`  


- Get the aws-auth ARN role using:  
`kubectl get configmap aws-auth -n kube-system -o yaml`  
and edit `aws-auth-cm.yaml` #FileLocationHere as in the exemple:

      mapRoles: |
        - rolearn: <set your role ARN here>
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    Copy `ARN-For-K8S` output and paste the ARN as in the example:

      - rolearn: <set your role ARN here>
        username: consul-join
        groups:
          - system:masters

- Get Consul's service cluster IP using:  
`kubectl get svc`  and copy consul-consul-dns IP address.  
edit `coredns.yaml` #FileLocationHere as in the example:

      consul {
        errors
        cache 30
        forward . <consul-consul-dns cluster IP here>
 
- Run install.sh script 

<br/>

### Jenkins
- Under Manage Credentials set up:   
ssh key (gen_key.pem) for the workers connection  
[Github app](https://docs.github.com/en/developers/apps/creating-a-github-app)  token  
Kubernetes config (can be found under localhost's .kube/config)

- Set up a MultiBranch pipeline and point it to Kandula's  [staging](https://github.com/rotemad/kandula_assignment/tree/staging) branch
- Jenkinsfile is located in the [Kandula's repo](https://github.com/rotemad/kandula_assignment) as well


<br/>

### Connect to the environment using the bastion host

To keep the environment safe, the private network is not available directly from the <span>WWW</span>.
In order to access this private network in a secured manner, you’ll need to set up an SSH tunnel using one of the bastion hosts.

To set up the SSH tunnel, run the following command:

    ssh -i gen_key.pem -N -L 127.0.0.1:(the required port):(the host IP address):(the host's required port) -p 22 ubuntu@(the public bastion's server IP address)

Open your preferred web-browser and go to `http://localhost:(required port)`
 - Use port 8080 for: **Jenkins Master** web-management console
 - Use port 8500 for: **Consul Servers** web-management console
 - Use port 9090 for: **Prometheus** web-management console
 - Use port 3000 for: **Grafana** web-management console
 - Use port 5601 for: **Kibana** web-management console

<br/>

### Uninstall

- Run unistall.sh file under `/kubernetes-control` #FileLocationHere
- `terraform refresh`
- `terraform destroy --auto-approve`
