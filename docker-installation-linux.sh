#!/bin/bash

echo "Removing Docker. Press Y if CMD ask for permission."

sudo apt-get remove docker docker-engine docker.io

echo "Installing dependency packages..."

sudo apt-get install  software-properties-common ca-certificates apt-transport-http

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \ "deb [arch=amd64] https://download.docker.com/linux/ubuntu \ $(lsb_release -cs) \ stable"

sudo apt-get update
sudo apt-get install docker-ce

sudo systemctl start docker
sudo systemctl enable docker

sudo systemctl is-enabled docker

sudo groupadd docker
sudo gpasswd -a $USER docker
docker system prune -a

docker pull amku91/lam-heroku

docker run -p 8080:8080 amku91/lam-heroku