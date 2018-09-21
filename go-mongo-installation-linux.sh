#!/bin/bash
#!/Created By Amit Kumar
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
set -e

VERSION="1.10.1"

if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
    # assume Zsh
    shell_profile="zshrc"
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
    # assume Bash
    shell_profile="bashrc"
fi

echo "System Info :\n";

Kernel=$(uname -s)
case "$Kernel" in
    Linux)  Kernel="linux"              ;;
    Darwin) Kernel="mac"                ;;
    FreeBSD)    Kernel="freebsd"            ;;
* ) echo "Your Operating System -> ITS NOT SUPPORTED"   ;;
esac

echo "Operating System Kernel : $Kernel"

# Get the machine Architecture
Architecture=$(uname -m)

echo "Operating System Architecture : $Architecture"

if [ -d "$HOME/.go" ] || [ -d "$HOME/go" ]; then
    echo "The 'go' or '.go' directories already exist. Removing previous installed GO."
    rm -rf "$HOME/.go/"
    rm -rf "$HOME/go/"
    sed -i '/# GoLang/d' "$HOME/.${shell_profile}"
    sed -i '/export GOROOT/d' "$HOME/.${shell_profile}"
    sed -i '/:$GOROOT/d' "$HOME/.${shell_profile}"
    sed -i '/export GOPATH/d' "$HOME/.${shell_profile}"
    sed -i '/:$GOPATH/d' "$HOME/.${shell_profile}"
    echo "Go removed."
fi

arch=$(uname -i)

if [[ $arch == i*86 ]]; then
    DFILE="go$VERSION.linux-386.tar.gz"
    echo "32"
elif [[ $arch == x86_64* ]]; then
    DFILE="go$VERSION.linux-amd64.tar.gz"
    echo "64"
elif  [[ $arch == arm* ]]; then
    DFILE="go$VERSION.linux-armv6l.tar.gz"
    echo "arm"
else
    DFILE="go$VERSION.darwin-amd64.tar.gz"
    echo "darwin"
fi

if [ -d "$HOME/.go" ] || [ -d "$HOME/go" ]; then
    echo "The 'go' or '.go' directories already exist. Exiting."
    exit 1
fi

echo "Downloading $DFILE ..."
wget https://storage.googleapis.com/golang/$DFILE -O /tmp/go.tar.gz

if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting File..."
tar -C "$HOME" -xzf /tmp/go.tar.gz
mv "$HOME/go" "$HOME/.go"
touch "$HOME/.${shell_profile}"
{
    echo '# GoLang'
    echo 'export GOROOT=$HOME/.go'
    echo 'export PATH=$PATH:$GOROOT/bin'
    echo 'export GOPATH=$HOME/go'
    echo 'export PATH=$PATH:$GOPATH/bin'
} >> "$HOME/.${shell_profile}"

mkdir -p $HOME/go/{src,pkg,bin}
#echo -e "\nGo $VERSION was installed.\nMake sure to relogin into your shell or run:"
#echo -e "\n\tsource $HOME/.${shell_profile}\n\nto update your environment variables."
#echo "Tip: Opening a new terminal window usually just works. :)"

#exec bash
source $HOME/.${shell_profile}

chmod -R 777 $HOME/go

echo ""
echo -e "Go Installed"
echo ""
echo "Installing Mongo"
rm -f /tmp/go.tar.gz

echo -----------------------------------------------------------------
echo -                    Mongo - Ubuntu                       -
echo -----------------------------------------------------------------

echo "Unistalling Previous Repo"
apt-get purge mongodb-org*
rm -r /var/log/mongodb
rm -r /var/lib/mongodb

echo "Installing repo"
 
echo "Installing binaries"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

apt-get update
apt-get install -y mongodb-org
apt-get update

cat > /etc/systemd/system/mongodb.service <<'EOF'
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target

EOF

echo "File Edited"

#sudo systemctl start mongodb
#sudo systemctl status mongodb
systemctl enable mongod.service

service mongod stop
 
 
echo "Setting up default settings"
rm -rf /var/lib/mongodb/*
cat > /etc/mongod.conf <<'EOF'
storage:
  dbPath: /var/lib/mongodb
  directoryPerDB: true
  journal:
    enabled: true
  engine: "wiredTiger"
 
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
 
net:
  port: 27017
  bindIp: 0.0.0.0
  maxIncomingConnections: 100
 
replication:
  oplogSizeMB: 128
  replSetName: "rs1"
 
security:
  authorization: disabled
 
EOF
 
service mongod start
sleep 5
 
mongo admin <<'EOF'
use admin
rs.initiate()
exit
EOF
 
sleep 5
 
echo "Adding admin user"
mongo admin <<'EOF'
use admin
rs.initiate()
var user = {
  "user" : "admin",
  "pwd" : "admin",
  roles : [
      {
          "role" : "userAdminAnyDatabase",
          "db" : "admin"
      }
  ]
}
db.createUser(user);
exit
EOF

echo "Adding lam user"
mongo admin <<'EOF'
use lam
rs.initiate()
var user = {
  "user" : "admin",
  "pwd" : "admin123",
  roles : [
      {
          "role" : "dbOwner",
          "db" : "lam"
      }
  ]
}
db.createUser(user);
exit
EOF
 
echo "Complete"

