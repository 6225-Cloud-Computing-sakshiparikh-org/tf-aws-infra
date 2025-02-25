# tf-aws-infra
# Terraform AWS VPC Setup

     This Terraform configuration provisions an AWS Virtual Private Cloud (VPC) environment with both public and private subnets, an Internet Gateway, route tables, and subnet associations. A random suffix is appended to resource names to ensure uniqueness.

## Overview

The configuration sets up the following resources:

- **VPC:**  
  A VPC with DNS support enabled.
  
- **Random Suffix:**  
  Generates a unique 4-character numeric suffix for naming resources.

- **Internet Gateway:**  
  An Internet Gateway attached to the VPC to allow internet connectivity.

- **Subnets:**  
  - **Public Subnets:**  
    Configured to assign public IPs on launch.
  - **Private Subnets:**  
    No public IP assignment.

- **Route Tables:**  
  - A public route table with a default route to the Internet Gateway.
  - A private route table for private subnets.

- **Associations:**  
  Associates public subnets with the public route table and private subnets with the private route table.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version 1.x recommended)
- An AWS account with proper credentials.
- AWS CLI configured with a profile if using the `aws_profile` variable.

## Usage

1. **Clone the Repository:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
## Configure Variables

Create a `terraform.tfvars` file (or use another method) to provide the following variables:

- **aws_region:** AWS region (e.g., `us-east-1`).
- **aws_profile:** AWS CLI profile name.
- **vpc_cidr:** The CIDR block for the VPC (e.g., `10.0.0.0/16`).
- **vpc_name:** Base name for the VPC and related resources.
- **public_subnets:** List of CIDR blocks for public subnets (e.g., `["10.0.1.0/24", "10.0.2.0/24"]`).
- **private_subnets:** List of CIDR blocks for private subnets (e.g., `["10.0.3.0/24", "10.0.4.0/24"]`).
- **availability_zones:** List of availability zones corresponding to your subnets (e.g., `["us-east-1a", "us-east-1b"]`).

## Initialize Terraform

Initialize the configuration and download required providers:

```bash
terraform init 
```

## Apply the Configuration

Create the resources by applying the configuration:

```bash
terraform apply
```

## Destroy Resources 

If you need to remove all resources at any point, run the following command:

```bash
terraform destroy
```

## File Structure

-**main.tf:** Contains the Terraform configuration for the AWS resources.

-**variables.tf:** Define and document the input variables.

-**outputs.tf:** Specify outputs to display resource information after creation.


## Resource Naming

The resource names are generated using a base name and a random suffix. Adjust the naming pattern as needed to suit your environment.

## Network Design

Modify CIDR blocks, subnet counts, and availability zones in your variable definitions to match your network requirements.

## License

This project is licensed under the MIT License.
