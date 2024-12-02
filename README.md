# Building a 3 Tier Architecture on AWS Services
---
### Architecture
<img src="https://github.com/user-attachments/assets/8c9b3611-4b3c-40aa-b57f-66fb87370bdd"/>

<br>

**Use Skills**
```shell
AWS                        Application/Framework
 - VPC                       - Python/Flask
 - EC2
 - Load Balancer
 - Auto Scaling Group
 - RDS
 - ECR
 - CloudWatch
 - WAF
```

<br>

**Set Up**
```
git clone https://github.com/Daliy-Cloud/3-Tier-Architecture.git
mv 3-Tier-Architecture/src/* ./
terraform init
terraform apply --auto-approve
```