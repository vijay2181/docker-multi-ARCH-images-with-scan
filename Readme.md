# Multi Arch Docker Images

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
# AMD-64 STEPS:-
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


# ARM-64 STEPS:-
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
```
cd web-server
docker build -t vijay2181/web-arm64:v1 --platform linux/arm64 .
docker run -d --name arm-webserver -p 80:80 vijay2181/web-arm64:v1
```
```
[root@ip-172-31-60-120 web-server]# docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                               NAMES
756441c4c3fa   vijay2181/web-arm64:v1   "/usr/sbin/httpd -D …"   3 seconds ago   Up 2 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   arm-webserver

[root@ip-172-31-25-164 web-server]# docker exec -it arm-webserver bash

bash-4.2# uname -a
Linux 756441c4c3fa 5.10.179-166.674.amzn2.aarch64 #1 SMP Mon May 8 16:54:34 UTC 2023 aarch64 aarch64 aarch64 GNU/Linux
```
```
goto broswer and access 
http://<public_ip>:80
make sure 80 is allowed in SG
```
```
docker tag local-image:tagname new-repo:tagname
docker push new-repo:tagname
docker login
```
```
docker push vijay2181/web-arm64:v1
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/db30a6cc-1dcf-46a3-9a98-07a2b9ea1fea)


# SCAN DOCKER IMAGES USING TRIVY:-
```
Trivy is a Simple and Comprehensive Vulnerability Scanner for Containers and other Artifacts, Suitable for CI
It is the most popular open source security scanner, reliable, fast, and easy to use.
```
the below script downloads Trivy binary based on your OS and architecture.
```
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3
sudo ln -s /usr/local/bin/trivy /usr/bin/trivy
```
```
[root@ip-172-31-25-164 web-server]# trivy image vijay2181/web-amd64:v1
2023-06-20T17:22:12.632Z        INFO    Need to update DB
2023-06-20T17:22:12.633Z        INFO    Downloading DB...
30.57 MiB / 30.57 MiB [-----------------------------------------------------------------------------------------------------] 100.00% 20.79 MiB p/s 1s
2023-06-20T17:22:47.790Z        INFO    Detected OS: amazon
2023-06-20T17:22:47.792Z        INFO    Detecting Amazon Linux vulnerabilities...
2023-06-20T17:22:47.837Z        INFO    Number of PL dependency files: 0

vijay2181/web-amd64:v1 (amazon 2 (Karoo))
=========================================
Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)
```

# MANIFESTS:-
```
https://github.com/opencontainers/image-spec/blob/main/manifest.md
we can use OSI repository, This supports multi-architecture images by creating manifests. Docker has introduced experimental command called 'docker manifest' to manage them 

https://docs.docker.com/engine/reference/commandline/manifest/
```
```
on ARM machine
root@ip-172-31-60-120 web-server]# docker pull vijay2181/web-amd64:v1

[root@ip-172-31-60-120 web-server]# docker images
REPOSITORY            TAG       IMAGE ID       CREATED             SIZE
vijay2181/web-arm64   v1        53bed4f61932   37 minutes ago      556MB
vijay2181/web-amd64   v1        0a9ddbcc5bf6   About an hour ago   585MB
amazonlinux           2         7db83c35e2d6   7 days ago          195MB

so now we have two images with different architecture 

you need to create a manifest, like without any architecture suffixes and list all images with different architectures that manifest list, in my case im going to create 'multi-arch:v1' manifest, this manifest will contain both images for amd and arm based architectures

docker manifest create vijay2181/multi-arch:v1 \
vijay2181/web-amd64:v1 \
vijay2181/web-arm64:v1

Created manifest list docker.io/vijay2181/multi-arch:v1
```
```
[root@ip-172-31-60-120 web-server]# docker manifest inspect vijay2181/multi-arch:v1
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 949,
         "digest": "sha256:61bf8ea32f6c69ac0d53655c0e7e0d536a5b61af779468825b4ff5c5b6d39f4e",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 949,
         "digest": "sha256:8c5b81f473fc288b93f03470708fea915b16a367387b92b3a32743f029080141",
         "platform": {
            "architecture": "arm64",
            "os": "linux",
            "variant": "v8"
         }
      }
   ]
}
```

docker manifest inspect will all the images in that manifest

```
docker manifest push vijay2181/multi-arch:v1
[root@ip-172-31-60-120 web-server]# docker manifest push vijay2181/multi-arch:v1
Pushed ref docker.io/vijay2181/multi-arch@sha256:61bf8ea32f6c69ac0d53655c0e7e0d536a5b61af779468825b4ff5c5b6d39f4e with digest: sha256:61bf8ea32f6c69ac0d53655c0e7e0d536a5b61af779468825b4ff5c5b6d39f4e
Pushed ref docker.io/vijay2181/multi-arch@sha256:8c5b81f473fc288b93f03470708fea915b16a367387b92b3a32743f029080141 with digest: sha256:8c5b81f473fc288b93f03470708fea915b16a367387b92b3a32743f029080141
sha256:16d11df32800d2a831839e524866ca56b54ce74c0331bb913914f927c3f198a1
```
```
under vijay2181/multi-arch manifest with version1(v1), you will have two images with amd and arm architectures, This is how you will create multi-architecture images in docker Hub
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/06981743-0b70-425e-93d7-f1540609620c)

```
However most of the time we will use cloud native image repositoriesn such as AWS ECR image registry.
ECR does not support combining multiple repositories into one, instead you can create image tags with specific architectures and combine them together.
Lets create a private ECR repository 'vijay-app'
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/0c49cd4e-396a-403c-9b06-8e8abb388cbd)


```
if we want to interact with the ECR registry from our terminal, we need to authenticate the docker client, so configure aws profile
```

```
[root@ip-172-31-60-120 ~]#  aws --region us-west-2 --profile awsvijay ecr get-login --no-include-email | bash
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
Login Succeeded
```

```
since we already have images ready,you can simply tag them or rebuild them by specifying ecr repository, we can now include the target architecture in the image tag 

re-building image for ecr with amd64 architecture by using Dockerfile
docker build -t 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:amd64-v1 --platform linux/amd64 .

pushing image to ECR
docker push 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:amd64-v1

we will do same for amd64 based architecture
docker build -t 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:arm64-v1 --platform linux/arm64 .
docker push 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:arm64-v1
```


![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/0c652bd6-0662-413d-8505-8c65fef9d4f6)


```
Now create a docker manifest list that includes both the images

docker manifest create 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:multi-arch-v1 \
328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:amd64-v1 \
328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:arm64-v1


push the above manifest to ECR as well
docker manifest push 328222922690.dkr.ecr.us-west-2.amazonaws.com/vijay-app:multi-arch-v1

so in vijay-app ecr repository, we have two images with with different architectures and we have another different type of artifact(multi-arch-v1) for the v1 version 
```

![image](https://github.com/vijay2181/docker-multi-ARCH-images-with-scan/assets/66196388/539e22a6-148c-4a11-928f-879e8a1898b0)


## Why Multi-Arch Images

Architecture Flexibility: 
-------------------------
Multi-arch images allow you to build and deploy containerized applications that can run on different CPU architectures. This is particularly useful when you have a heterogeneous infrastructure with multiple EC2 instances using different processor architectures, such as Intel x86 and ARM-based processors. With multi-arch images, you can seamlessly deploy your services across these instances without worrying about compatibility issues.

Cost Optimization:
------------------
Different processor architectures may have varying performance characteristics and costs. By leveraging multi-arch images, you can optimize your infrastructure costs by choosing the most cost-effective EC2 instances based on their architecture while ensuring your services can run on them.

Portability:
------------
Multi-arch images enhance the portability of your services. They can be deployed on different cloud providers or on-premises environments that support the respective CPU architectures. This flexibility allows you to avoid vendor lock-in and easily migrate your services across platforms as needed.

Future-proofing:
----------------
As the technology landscape evolves, new CPU architectures may emerge, and existing ones may become more prevalent. Multi-arch images future-proof your services by ensuring they can adapt to different architectures without requiring major changes to your deployment infrastructure.

Ecosystem Support:
------------------
Docker multi-arch images are supported by various container management tools and platforms, including AWS ECS. You can leverage the ecosystem of container-related tools, libraries, and platforms that work seamlessly with multi-arch images, enhancing the overall development and deployment experience.

Overall, using multi-arch images for services in AWS offers flexibility, cost optimization, portability, future-proofing, and support within the container ecosystem. It allows you to build and deploy containerized applications that can run on a variety of CPU architectures, enabling efficient resource utilization and compatibility across different infrastructure setups.

```
When you pull a multi-arch Docker image manifest for a service that supports both AMD64 and ARM64 architectures.
the behavior depends on the architecture of the EC2 instance from which you are pulling the image.
```

AMD64 EC2 Instance:
--------------------
If you are pulling the manifest from an AMD64-based EC2 instance, Docker will automatically detect the instance's architecture and fetch the appropriate image layer for AMD64. The Docker engine will then use this image layer to create and run the container.

ARM64 EC2 Instance:
-------------------
Conversely, if you are pulling the manifest from an ARM64-based EC2 instance, Docker will identify the architecture and retrieve the corresponding image layer for ARM64. The container will be created and executed using this specific image layer.

In both cases, Docker selects the image layer that matches the architecture of the host EC2 instance, ensuring compatibility and optimal execution. This seamless behavior is possible due to the underlying functionality of Docker and its support for multi-arch manifests.

The Docker manifest itself serves as a reference point for the Docker engine to determine the appropriate image layer based on the architecture of the host machine. By using the manifest, you can simplify the process of deploying services to different architectures without manually managing multiple image variants.

It's worth noting that the availability of multi-arch manifests and the behavior described above depend on the Docker version and the specific container runtime environment you are using. However, with the widespread adoption of multi-arch images and the popularity of Docker, this behavior is well-supported in most modern container environments.
