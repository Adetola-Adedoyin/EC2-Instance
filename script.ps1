#install AWS 
Install-Module -Name AWS.Tools.Installer -Force

#Confirm installation
Get-AWSPowerShellVersion

#Install EC2
Install-AWSToolsModule AWS.Tools.EC2 -Force

#confirm installation
Get-Module -ListAvailable

#set up your credentials
Set-AWSCredential -AccessKey YOUR_ACCESS_KEY -SecretKey YOUR_SECRET_KEY -StoreAs default


Uninstall-Module -Name AWS.Tools.SimpleSystemsManagement -AllVersions -Force
Install-Module -Name AWS.Tools.SimpleSystemsManagement -Force
Import-Module AWS.Tools.SimpleSystemsManagement

Get-SSMLatestEC2Image -Path ami-windows-latest | Format-List

#Create security groups for EC2
aws ec2 create-security-group --group-name "RDP-SG" --description "Security group for RDP access" --region "us-east-1"

#Authorise the RDP security port
aws ec2 authorize-security-group-ingress --group-id sg-034063e79811d8efd --protocol tcp --port 3389 --cidr 0.0.0.0/0 --region "us-east-1"

#Create keypairs 
aws ec2 create-key-pair --key-name adetola --region us-east-1 --query 'KeyMaterial' --output text > adetola.pem ;

#Create instance
aws ec2 run-instances --image-id ami-0a72780db6b062c23 --count 1 --instance-type t2.micro --key-name adetola --security-group-ids sg-034063e79811d8efd --region us-east-1 --placement AvailabilityZone=us-east-1a --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=adetola}]' --user-data "<powershell>
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
</powershell>"

aws ec2 describe-instances --region us-east-1 --query "Reservations[].Instances[].[InstanceId,PublicIpAddress]" --output table
Get-Content -Path .\adetola.pem
