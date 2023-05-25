curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb

curl -o synapse_creds.sh https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/synapse_creds.sh
chmod +x synapse_creds.sh

mkdir -p /.aws
curl -sSL https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/config | sed "s|<PERSONAL_ACCESS_TOKEN>|${AWS_TOKEN}|g" > /.aws/config
