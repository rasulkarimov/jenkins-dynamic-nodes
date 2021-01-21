## Ci/Cd pipeline by Jenkins Dynamic nodes on docker
* Docker image for dynamic jenkins with packages and credentials for managing kubernetes cluster will be required.   
Dockerfile example for this image: 
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

## Job1
* pull code from git, build docker image, push to registry
~~~
sudo rm -rf /root/DevOpsAL/*
sudo cp -rvf * /root/DevOpsAL/
sudo docker build -t quay.io/rasulkarimov/web:v1 /root/DevOpsAL/
sudo docker push quay.io/rasulkarimov/web:v1
~~~

## Job2
* Start dynamic Jenkins using prepared image. Set dynamic cluster: Manage Jenkins -> Manage Nodes and Clouds -> Configuring Clouds -> Add a new cloud -> fill required data for setting up dynamic jenkins 
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
