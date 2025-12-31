#!/bin/bash

# growing the /home volume for terraform purpose
growpart /dev/nvme0n1 4

lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -L +10G /dev/mapper/RootVG-rootVol
lvextend -l +100%FREE /dev/mapper/RootVG-homeVol

xfs_growfs /
xfs_growfs /var
xfs_growfs /home

#install terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

# install docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# install java
sudo yum install fontconfig java-21-openjdk -y
echo "Configuring system alternatives..."
alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac

# 3. Export JAVA_HOME for the current session and future shells
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk


#install nodejs
sudo dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y

#install Trivy
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo yum -y update
sudo yum -y install trivy

#install maven

MAVEN_VERSION="3.9.6"
INSTALL_DIR="/opt/maven"
DOWNLOAD_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

echo "Updating system and installing Java (required for Maven)..."
sudo yum update -y

echo "Downloading Maven ${MAVEN_VERSION}..."
wget ${DOWNLOAD_URL} -P /tmp

echo "Extracting Maven to ${INSTALL_DIR}..."
sudo mkdir -p ${INSTALL_DIR}
sudo tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C ${INSTALL_DIR} --strip-components=1

echo "Configuring Environment Variables..."
# Create a profile script so it persists after reboot
cat <<EOF | sudo tee /etc/profile.d/maven.sh
export M2_HOME=${INSTALL_DIR}
export PATH=\${M2_HOME}/bin:\${PATH}
EOF

# Make the script executable and load variables for the current session
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

echo "Verification:"
mvn -version

 #install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

#install kubectx and kubens 
git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

#install k9s
cd /tmp
wget https://github.com/derailed/k9s/releases/download/v0.50.16/k9s_Linux_amd64.tar.gz
sudo tar -xvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
sudo rm -rf k9s_Linux_amd64.tar.gz

#install kubectl
#install kubectl
 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
