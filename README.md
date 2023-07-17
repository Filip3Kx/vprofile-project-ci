This project focuses on automating the setup of your local stack. Exrecise from Udemy course [Decoding DevOps](https://www.udemy.com/course/decodingdevops/)

## Pipeline

![image](https://github.com/Filip3Kx/vprofile-project-ci/assets/114138650/a94eabd9-bb11-4aac-9623-424199a586e9)

- After jenkins finds a code change in GitHub repository a pipeline starts
- It builds the app with maven
- Runs JUnit tests
- The results and additional code analysis runs on SonarQube
- .war artifact is stored into Nexus repository
- Post step is to notify users whether the build was succesful or not

## Deployment
Deployment of the entire stack is done via Docker Compose.

After the CI pipeline the docker image with an app artifact is uploaded to Nexus. [docker-compose.yml]() uses this file so setting up the stack is as simple as running
```
docker compose up
```
![image](https://github.com/Filip3Kx/vprofile-project-ci/assets/114138650/6907c030-2fc7-4c98-816a-92e8c588217e)

## App Services
- Nginx - load balancer
- Tomcat - builds and runs the Java project
- RabbitMQ - message broker/message queue (dummy in this project)
- Memcache - Data cache
- MySQL - DB (MariaDB)


