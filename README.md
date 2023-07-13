This project focuses on automating the setup of your local stack. Exrecise from Udemy course [Decoding DevOps](https://www.udemy.com/course/decodingdevops/)

## Servers
- Nginx - load balancer
- Tomcat - builds and runs the Java project
- RabbitMQ - message broker/message queue (dummy in this project)
- Memcache - Data cache
- MySQL - DB (MariaDB)


## Automating
- Vagrant
- VirtualBox
- Bash

## Workflow
1. VM Configuration
2. Validation of the VM's 
3. Server configuration
	- Mysql
	- Memcached
	- RabbitMQ
	- Tomcat
	- Ngnix
4. App deployment
5. Validation of the actual stack


## Mysql
Install pachages and start the DB service
```
sudo apt update -y && sudo apt install git mariadb-server -y
sudo systemctl start mariadb && sudo systemctl enable mariadb
```
Go through a mysql secure database setup
```
mysql_secure_installation
[Y,Y,n,Y,Y]
```
Configure database user
```
mysql -u root -ptest

create database accounts;
grant all privileges on accoutns.* to 'admin'@'%' identified by 'test';
flush privileges;
exit;
```
Clone the repository with a database backup that we will import into our db
```
git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git
cd vprofile-project
mysql -u root -ptest accounts < src/main/resources/db_backup.sql
mysql -u root -ptest accounts

sudo systemctl restart mariadb
```
Set up firewall (port 3306)
```
sudo systemctl start ufw && sudo systemctl enable ufw

sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 3306/tcp
sudo ufw reload

sudo systemctl restart mariadb
```

## Memcached
Install packages
```
sudo apt update -y && sudo apt install memcached -y
```

Start `memcached` service
```
sudo systemctl start memcached -y && sudo systemctl enable memcached

sudo memcached -p 11211 -U 11111 -u memcached -d 
```

Set up firewall (port 11211)
```
sudo systemctl start ufw && sudo systemctl enable ufw

sudo ufw enable
sudo ufw allow 11211/tcp
sudo ufw reload

sudo memcached -p 11211 -U 11111 -u memcached -d
```

## RabbitMQ
Install needed pachages
```
sudo apt update -y && sudo apt install wget rabbitmq-server -y
```

Start `rabbitmq-server` service
```
sudo systemctl start rabbitmq-server && sudo systemctl enable rabbitmq-server
```

Configure the server
```
sudo sh -c 'echo"[{rabbit,[{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator

sudo systemctl restart rabbitmq-server
```

Set up firewall (port 25672)
```
sudo systemctl start ufw && sudo systemctl enable ufw

sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 25672/tcp
sudo ufw reload
```
## Tomcat
Install needed packages
```
sudo apt update -y && sudo apt install git maven wget -y
```

Extract the repository from a shared dir
```
tar -xzvf /vagrant/apache-tomcat-8.5.37.tar.gz 
```

Configure `tomcat` user
```
mkdir /usr/local/tomcat8
useradd --home-dir /usr/local/tomcat8 --shell /sbin/nologin/tomcat

cp -r /vagrant/apache-tomcat-8.5.37/* /usr/local/tomcat8

chown -R tomcat.tomcat /usr/local/tomcat8
```

Configure `tomcat` service
```
sudo nano /etc/systemd/system/tomcat.service

CHANGE JRE_HOME and JAVA_HOME

[Unit] 
Description=Tomcat 
After=network.target 

[Service] 
User=tomcat 
WorkingDirectory=/usr/local/tomcat8 Environment=JRE_HOME=/usr/lib/jvm/jre Environment=JAVA_HOME=/usr/lib/jvm/jre Environment=CATALINA_HOME=/usr/local/tomcat8 Environment=CATALINE_BASE=/usr/local/tomcat8 ExecStart=/usr/local/tomcat8/bin/catalina.sh run ExecStop=/usr/local/tomcat8/bin/shutdown.sh SyslogIdentifier=tomcat-%i 

[Install] 
WantedBy=multi-user.target
```

Start the service
```
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
```

Set up firewall (port 8080)
```
sudo systemctl start ufw && sudo systemctl enable ufw

sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 8080/tcp
sudo ufw reload
```

### Building the app

Paste server details
```
git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git

cd vprofile-project

sudo nano src/main/resources/application.properties
```

Build app using `maven`
```
sudo mvn install
```

Place the build in a specified directory
```
sudo systemctl stop tomcat

rm -rf /usr/local/tomcat8/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat8/webapps/ROOT.war

sudo systemctl start tomcat
chown tomcat.tomcat usr/local/tomcat8/webapps -R
systemctl restart tomcat
```
## Nginx
Install needed packages
```
sudo apt update -y && sudo apt install nginx -y
```

Configure `nginx` to fetch the app from the `tomcat` server
```
sudo nano /etc/nginx/sites-available/vproapp

upstream vproapp { 
  server 192.168.1.3:8080; 
  } 
server { 
  listen 80; 
  location / { 
    proxy_pass http://vproapp;
  } 
}
```

Replace default site with our project
```
sudo rm -rf /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

sudo systemctl restart nginx
```
