# AWS Infrastructure with Terraform

This Terraform project sets up a complete AWS infrastructure including VPC, EC2 instances with Auto Scaling, RDS, Route53, and more.

## Infrastructure Components

### Networking
- **VPC** with configurable CIDR blocks
- **Public and Private Subnets** across multiple availability zones
- **Internet Gateway** for public internet access
- **Route Tables** for public and private subnets
- **Security Groups** for application and database instances

### Compute
- **Auto Scaling Group** with configurable capacity
- **Launch Template** with user data configuration
- **Application Load Balancer** with HTTP/HTTPS support
- **EC2 Instances** with CloudWatch agent configuration

### Database
- **RDS Instance** (MySQL 8.0)
- **DB Parameter Group** with UTF-8 configuration
- **DB Subnet Group** in private subnets
- **Encrypted Storage** using KMS

### Storage
- **S3 Bucket** with versioning and encryption
- **KMS Keys** for encryption
- **Server-side encryption** configuration

### DNS & SSL
- **Route53 Records** for domain management
- **ACM Certificate** for HTTPS (in dev environment)
- **DNS Validation** for SSL certificates

### Security
- **IAM Roles and Policies** for EC2 instances
- **Security Groups** with restricted access
- **Secrets Manager** for database credentials
- **KMS Keys** for encryption

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** (version ~> 1.0)
3. AWS account with appropriate permissions
4. Domain name (for Route53 configuration)


## Usage

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Format and Validate**
   ```bash
   terraform fmt
   terraform validate
   ```

3. **Plan the Infrastructure**
   ```bash
   terraform plan
   ```

4. **Apply the Configuration**
   ```bash
   terraform apply
   ```

5. **Destroy Infrastructure**
   ```bash
   terraform destroy
   ```

## Security Features

- Database passwords are automatically generated and stored in AWS Secrets Manager
- All sensitive data is encrypted using KMS
- S3 bucket has versioning and encryption enabled
- Security groups restrict access to necessary ports only
- Private subnets for database instances
- SSL/TLS encryption for HTTPS traffic

## Monitoring and Logging

- CloudWatch agent configuration for metrics and logs
- Custom metrics namespace for application monitoring
- Log retention policies
- Auto Scaling metrics and alarms

## Important Notes

1. The infrastructure is designed for both development and production environments
2. SSL certificates are automatically provisioned for dev environment
3. Database backups and maintenance windows are configurable
4. Auto Scaling group ensures high availability
5. All resources include proper tagging for cost allocation

## Resource Naming

Resources are named using the following pattern:
- Base name from `network_name` variable
- Resource type identifier
- Random suffix for uniqueness (where applicable)

## Outputs

The following outputs are available after successful deployment:
- VPC IDs
- Public and Private Subnet IDs
- RDS Endpoint
- Load Balancer DNS Name
- Auto Scaling Group Name

## File Structure

```
.
├── acm.tf                    # SSL/TLS certificate configuration
├── auto-scaling-group.tf     # Auto Scaling Group configuration
├── auto-load-balancer.tf     # Load Balancer configuration
├── internetgateway.tf        # Internet Gateway configuration
├── provider.tf               # AWS provider configuration
├── rds.tf                    # RDS instance configuration
├── rds-parameter-group.tf    # RDS parameter group settings
├── roles-and-policies.tf     # IAM roles and policies
├── route53.tf               # DNS configuration
├── s3.tf                    # S3 bucket configuration
├── secrets.tf               # Secrets Manager configuration
├── security_groups.tf       # Security group rules
├── variables.tf             # Input variables
├── vpc.tf                   # VPC configuration
└── outputs.tf               # Output values
```

## License

This project is licensed under the MIT License.