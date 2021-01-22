## Ci/Cd pipeline by Jenkins Dynamic nodes on docker
### Prerequisites
*Docker image for jenkins dynamic cluster with packages and credentials for managing kubernetes cluster will be required.
*Configure dynamic cluter on jenkins  

* Example of Dockerfile for slave Jenkins image: 
~~~
FROM centos

RUN yum install java-11-openjdk-devel -y
RUN yum install openssh-server -y

COPY kubernetes.repo /etc/yum.repos.d/
RUN yum install kubectl -y

COPY config /root/.kube/
COPY ca.crt /root/
COPY client.crt /root/
COPY client.key /root/

RUN mkdir /root/jenkins

RUN ssh-keygen -A
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"] && /bin/bash
~~~
* Configuring dynamic Cluster on jenkins:
Manage Jenkins -> Manage Nodes and Clouds -> Configuring Clouds -> Add a new cloud:
![image](https://user-images.githubusercontent.com/53195216/105555230-01766000-5d1a-11eb-8b21-7226f85356dc.png)
---
![image](https://user-images.githubusercontent.com/53195216/105555313-2e2a7780-5d1a-11eb-998f-da63ac035992.png)
---
![image](https://user-images.githubusercontent.com/53195216/105555360-469a9200-5d1a-11eb-9a95-a54009c0ea4e.png)
Edit docket configuration file so it can be managed throw 4243 port:  
cat /usr/lib/systemd/system/docker.service
~~~
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock  -H tcp://0.0.0.0:4243
~~~

## Job1
* pull code from git, build docker image, push to registry
~~~
sudo rm -rf /root/DevOpsAL/*
sudo cp -rvf * /root/DevOpsAL/
sudo docker build -t quay.io/rasulkarimov/web:v1 /root/DevOpsAL/
sudo docker push quay.io/rasulkarimov/web:v1
~~~

## Job2
* Start webserver by slave Jenkins using code downloaded from git
~~~
if kubectl get deployments|grep webdeploy
then
echo "Old version webdeploy found, deleting"
kubectl delete all -l app=webdeploy
else
echo "Old version webdeploy not found"
fi
echo "Creating webdeploy app"
kubectl create deploy webdeploy --image=quay.io/rasulkarimov/web:v1
kubectl expose deploy webdeploy  --port=80  --type=NodePort
kubectl scale deployment webdeploy  --replicas=3
kubectl get all
~~~
