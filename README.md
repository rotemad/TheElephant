# Welcome to MyProject!
![](https://media.giphy.com/media/XD9o33QG9BoMis7iM4/giphy.gif)

*(DANGER! This gif may harm your eyes)*
<br/>
<br/>
### *TheElephant explanation goes here.*
<br/>

## Prerequisites

 - Clone this repo
 - [Terraform](https://www.terraform.io/) version v0.14.3  
 Linux/Windows can be downloaded [here](https://releases.hashicorp.com/terraform/0.14.3/) 
 macOS using brew `brew install terraform@0.14`

## How To use  

Under _[variables.tf](https://github.com/rotemad/TheElephant/blob/main/variables.tf),_ set-up your [AWS profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) (the default profile is `default`)

To start the infrastructure provisioning, run the following commands:

`terraform init`

`terraform apply --auto-approve`

Once the provisioning ends, you will get the following output:

 - The *public* IP addresses of the bastion servers
 - The *private* IP addresses of the Jenkins Master and Workers
 - The *private* IP addresses of the Consul servers

A general certificate `gen_key.pem` will be generated during the provisioning which can be used to login to all the hosts.

## Connect to the environment using the bastion hosts 

To keep the environment safe, the private network is not available directly from the <span>WWW</span>.
In order to access this private network in a secured manner, you’ll need to set up an SSH tunnel using one of the bastion hosts.

To set up the SSH tunnel, run the following command:

    ssh -i gen_key.pem -N -L 127.0.0.1:(the required port):(the host IP address):(the host's required port) -p 22 ubuntu@(the public bastion's server IP address)

Open your preferred web-browser and go to `http://localhost:(required port)`
 - Use port 8080 for: **Jenkins Master** web-management console
 - Use port 8500 for: **Consul Servers** web-management console
 - Use port 9090 for: **Prometheus** web-management console
 - Use port 3000 for: **Grafana** web-management console

