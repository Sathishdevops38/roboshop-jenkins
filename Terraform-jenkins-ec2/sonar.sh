#!/bin/bash
sudo timedatectl set-ntp true
sudo timedatectl set-timezone UTC
sudo systemctl restart chronyd || systemctl restart systemd-timesyncd
sudo timedatectl

# 1. Install Java 17 if not already present
echo "Installing OpenJDK 17..."
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-17-amazon-corretto-devel --nogpgcheck

# 2. Use 'alternatives' to set Java 17 as the default
# The --set flag forces the system to use this specific path
echo "Configuring system alternatives..."
alternatives --set java /usr/lib/jvm/java-17-openjdk/bin/java
alternatives --set javac /usr/lib/jvm/java-17-openjdk/bin/javac

# 3. Export JAVA_HOME for the current session and future shells
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
if ! grep -q "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk" ~/.bashrc; then
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk" >> ~/.bashrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
fi

# 4. Verify the change
echo "--------------------------------------"
echo "Success! Current Java version:"
java -version
echo "JAVA_HOME is set to: $JAVA_HOME"
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo yum install wget unzip -y
cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip
sudo unzip sonarqube-9.9.8.100196.zip
sudo mv sonarqube-9.9.8.100196 sonarqube
sudo useradd sonar
echo 'sonar ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo chmod -R 775 /opt/sonarqube
sudo cd /opt/sonarqube/bin/linux-x86-64/

sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh status"