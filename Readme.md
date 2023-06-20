# Multi Arch Docker Images
## Trivy Scanner

```
Aws states that the processors based on graviton design offer upto 40% more value for your money compared to simialr modern processors that used x86(AMD) architecture
- if you accidently use the wrong docker image on arm based architecture, your application will crash.This is why you need to use two sets of images or at very least image tags 
- during testing and migrating to a new architecture like ARM, you can use single image tag for deployment on both ARM and AMD 
based instances
```
![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/c7ed5685-4657-4809-8bd6-5299280ef265)

the above both images comes into single manifest which is multi-arch:v1.
I will demonstrate with simple webserver on both architectures.

### In docker-hub:-
```
create a docker repository in docker-hub
vijay2181/web-amd64
```
![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/15c4acc0-9b97-4700-8fe7-b643e6ff5178)

```
next another repository
vijay2181/web-arm64
```
![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/7895b1b6-522f-410b-ad02-c506af17d2ad)

```
now we have two different repositories
- the first step is to build docker image for amd64 platform, to specify target architecture, you can use 'platform' tag 
```
## AMD-64
```
create one amd aws instance
goto community ami's
amzn2-ami-kernel-5.10-hvm-2.0.20230612.0-x86_64-gp2
ami-0cef94f067b35ada0
- free tier eligible(t3.micro)
```
```
[ec2-user@ip-172-31-25-164 ~]$ uname -a
Linux ip-172-31-25-164.us-west-2.compute.internal 5.10.179-171.711.amzn2.x86_64 #1 SMP Tue Jun 6 01:59:18 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```
```
sudo -i
bash -x amd-install.sh
```
```
cd web-server
docker build -t vijay2181/web-amd64:v1 --platform linux/amd64 .
docker run -d --name amd-webserver -p 80:80 vijay2181/web-amd64:v1

[root@ip-172-31-25-164 web-server]# docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                               NAMES
830b84d7292c   vijay2181/web-amd64:v1   "/usr/sbin/httpd -D …"   5 minutes ago   Up 5 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp   amd-webserver

[root@ip-172-31-25-164 web-server]# docker exec -it amd-webserver bash

bash-4.2# uname -a
Linux 830b84d7292c 5.10.179-171.711.amzn2.x86_64 #1 SMP Tue Jun 6 01:59:18 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```
```
goto broswer and access 
http://<public_ip>:80
make sure 80 is allowed in SG
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/d42d1b0c-2c3e-409b-99d1-7f021ac1384f)


```
docker tag local-image:tagname new-repo:tagname
docker push new-repo:tagname
docker login
```
```
docker push vijay2181/web-amd64:v1
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/d706295e-d63e-477f-8d07-b245831019c7)


## ARM-64
```
- the second step is to build docker image for arm64 platform, to specify target architecture, you can use 'platform' tag
Arm64
amzn2-ami-kernel-5.10-hvm-2.0.20230515.0-arm64-gp2
ami-014cdfc4d85e21f7f
Amazon Web Services (AWS) does not offer free tiers specifically for ARM instances.
- (t4g.micro)
```
```
[ec2-user@ip-172-31-60-120 ~]$ uname -a
Linux ip-172-31-60-120.us-west-2.compute.internal 5.10.179-166.674.amzn2.aarch64 #1 SMP Mon May 8 16:54:34 UTC 2023 aarch64 aarch64 aarch64 GNU/Linux
```
```
bash -x arm-install.sh
```

