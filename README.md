# bash_script

Bash script to install go, mongo db, docker, docker-compose over a ubuntu machine. Tested with Linix 18.04 version.

Just clone the repo and use bash command to run bash files.

Install docker over ubuntu :

bash docker-installation-linux.sh

- Note; It will gonna remove docker and docker images first and then reinstall docker again to overcome docker daemon issues.

Install docker compose using python-pip

bash docker-compose-installation-linux.sh

Install go mongo installation over ubutnu

bash go-mongo-installation-linux.sh

- Note: it will remove previous installed go and mongo and then reinstall again. It will also goona set default users like:


`echo "Setting up default settings"
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
EOF`

In this it's creating default `root username as admin and password as admin`. Also it's creating `dbOwner user for lam database with username admin and password`.
