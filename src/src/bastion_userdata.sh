#!/bin/bash
yum update -y
yum install -y jq curl wget unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
ln -s /usr/local/bin/aws /usr/bin/
ln -s /usr/local/bin/aws_completer /usr/bin/
echo "Port 2220" >> /etc/ssh/sshd_config
sed -i "s|#PasswordAuthentication no|PasswordAuthentication yes|g" /etc/ssh/sshd_config
systemctl restart sshd
echo 'Skill53##' | passwd --stdin ec2-user
echo 'Skill53##' | passwd --stdin root
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
usermod -aG docker root
chmod 666 /var/run/docker.sock
dnf install -y mariadb105

HOME=/home/ec2-user
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
S3_BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[?contains(Name, 'app')].Name" --output text)
ECR_REPOSITORY_URL="$ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/wsc-ecr:latest"
mkdir ~/image/
sudo chown ec2-user:ec2-user ~/image/
su - ec2-user -c "aws s3 cp s3://$S3_BUCKET_NAME/app.pyc ~/image/"
su - ec2-user -c "aws s3 cp s3://$S3_BUCKET_NAME/Dockerfile ~/image/"
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
docker build -t $ECR_REPOSITORY_URL ~/image/
docker push $ECR_REPOSITORY_URL
aws s3 rm s3://$S3_BUCKET_NAME --recursive
aws s3 rb s3://$S3_BUCKET_NAME --force

cat <<\EOF> /tmp/app.py
import boto3
import time
import datetime
import requests
import os

AWS_DEFAULT_REGION = "ap-northeast-2"

logs = boto3.client('logs',
    region_name=AWS_DEFAULT_REGION)

stream = os.popen('whoami')
user = stream.read().rstrip()

now = datetime.datetime.now()

def describe_instance_id():
    token_url = 'http://169.254.169.254/latest/api/token'
    token_ttl = '21600'
    token_headers = {'X-aws-ec2-metadata-token-ttl-seconds': token_ttl}
    response = requests.put(token_url, headers=token_headers)
    token = response.text.strip()
    metadata_url = 'http://169.254.169.254/latest/meta-data/instance-id'
    instance_headers = {'X-aws-ec2-metadata-token': token}
    response = requests.get(metadata_url, headers=instance_headers)
    instance_id = response.text.strip()
    return instance_id

def logging():
    instance_id = describe_instance_id()
    LOG_GROUP = '/wsc/Logging/access/'
    LOG_STREAM = instance_id

    try:
        logs.create_log_group(logGroupName=LOG_GROUP)
    except logs.exceptions.ResourceAlreadyExistsException:
        pass

    try:
        logs.create_log_stream(logGroupName=LOG_GROUP, logStreamName=LOG_STREAM)
    except logs.exceptions.ResourceAlreadyExistsException:
        pass

    timestamp = int(round(time.time() * 1000))
    response = logs.put_log_events(
        logGroupName=LOG_GROUP,
        logStreamName=LOG_STREAM,
        logEvents=[
            {
                'timestamp': timestamp,
                'message': now.strftime("%Y-%m-%d %H:%M:%S") + " Server Join " + user + "!"
            }
        ]
    )

logging()

EOF

yum install -y python3-pip
pip3 install boto3
pip3 install requests

cat <<\EOF>> /etc/bashrc
export TZ=Asia/Seoul
EOF

source /etc/bashrc

cat <<\EOF> /etc/profile.d/login.sh
#!/bin/bash
python3 /tmp/app.py
EOF

chmod +x /etc/profile.d/login.sh