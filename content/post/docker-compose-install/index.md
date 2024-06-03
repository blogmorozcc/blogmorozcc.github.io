+++
title = "What is Docker and Docker Compose and how to install and use it on Debian"
date = "2024-06-03"
tags = [
    "Debian",
    "Docker",
    "Docker Compose",
    "Containerization",
]
categories = [
    "Linux",
]
image = "header.png"
+++

## What is Docker and Docker Compose

Docker and Docker Compose are tools designed to simplify the process of managing and deploying applications in containers. Here’s an overview of each, along with their differences and key benefits.

### Docker

**Definition:**

Docker is a platform that uses containerization to deploy, manage, and run applications. Containers are lightweight, portable, and consistent environments that include everything needed to run a piece of software, such as the code, runtime, system tools, libraries, and settings.

**Key Benefits:**

- Consistency: Docker ensures that software will run the same regardless of where it's deployed because containers encapsulate all dependencies.
- Isolation: Containers run in isolated environments, which makes it easier to manage dependencies and avoid conflicts.
- Portability: Containers can run on any system that supports Docker, including on-premises servers, public clouds, and personal machines.
- Efficiency: Docker containers are lightweight and have lower overhead compared to traditional virtual machines.
- Scalability: Docker makes it easy to scale applications horizontally by running multiple containers across different hosts.

### Docker Compose

**Definition:**

Docker Compose is a tool for defining and running multi-container Docker applications. It uses a YAML file to configure the application's services, networks, and volumes, allowing you to manage multiple containers as a single application.

**Key Benefits:**

- Simplified Configuration: Docker Compose uses a single YAML file (docker-compose.yml) to configure all your application's services, making it easier to manage and understand.
- Multi-Container Management: It allows you to define, run, and manage multiple interconnected containers with a single command (docker-compose up).
- Environment Consistency: Ensures consistent environments across different stages of development, testing, and production by using the same configuration file.
- Networking: Automatically sets up a network so that the containers can communicate with each other without additional configuration.
- Volume Management: Simplifies the setup and management of data volumes that can be shared between containers.

### Differences

- Scope: Docker is used for single-container applications, whereas Docker Compose is designed for applications consisting of multiple containers.
- Usage: Docker commands (docker run, docker build, etc.) are used to manage individual containers, while Docker Compose commands (docker-compose up, docker-compose down, etc.) manage entire multi-container applications defined in a YAML file.
- Configuration: Docker uses Dockerfiles to define container images, while Docker Compose uses a docker-compose.yml file to define multi-container applications, including their networks and volumes.

**Combined Key Benefits**

- Streamlined Development: Together, Docker and Docker Compose allow for rapid and consistent development, testing, and deployment of applications.
- Reproducibility: Both tools ensure that the environment in which the application runs is consistent across different stages, reducing the "it works on my machine" problem.
- Simplified CI/CD: Integration with CI/CD pipelines becomes easier, as containers can be used to run tests and deploy applications in a consistent environment.
- Resource Efficiency: Containers share the same OS kernel and can be more resource-efficient than virtual machines.

### Practical example

Suppose you have a web application with the following components:

- A web server (e.g., Nginx)
- An application server (e.g., Node.js)
- A database (e.g., PostgreSQL)

**With Docker:**

- You create individual Dockerfiles for each component to containerize them.

**With Docker Compose:**

- You create a docker-compose.yml file to define all three services and their interactions.
- You can bring up the entire stack with a single command (docker-compose up).

## Docker installation 

First of all update system packages to the latest vesions:

{{< highlight shell "linenos=false" >}}
sudo apt update && sudo apt upgrade
{{< / highlight >}}

Then install necessary packages:

{{< highlight shell "linenos=false" >}}
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg2
{{< / highlight >}}

Add GPG public key for official Docker repository:

{{< highlight shell "linenos=false" >}}
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
{{< / highlight >}}

Add the Docker debian repository to apt package manager sources list:

{{< highlight shell "linenos=false" >}}
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
{{< / highlight >}}

Update package indexes and install Docker Community Edition:

{{< highlight shell "linenos=false" >}}
sudo apt update && sudo apt install docker-ce
{{< / highlight >}}

Enable and start the docker systemd daemon:

{{< highlight shell "linenos=false" >}}
sudo systemctl enable --now docker
{{< / highlight >}}

Finally, verify the installation by running demo `hello-world` container:

{{< highlight shell "linenos=false" >}}
sudo docker run hello-world
{{< / highlight >}}

## Docker Compose installation 

Download the latest release from official repository:

{{< highlight shell "linenos=false" >}}
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
{{< / highlight >}}

Add execution permissions to the downloaded binary:

{{< highlight shell "linenos=false" >}}
sudo chmod +x /usr/local/bin/docker-compose
{{< / highlight >}}

Verify the installition by printing out Docker Compose version:

{{< highlight shell "linenos=false" >}}
docker compose --version
{{< / highlight >}}

In addition, you can create a test `docker-compose.yml` file with a couple of demo services (for example web server and database):

```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "80:80"
  database:
    image: postgres
    environment:
      POSTGRES_PASSWORD: example
```

And then to start it use the command:

{{< highlight shell "linenos=false" >}}
docker compose up
{{< / highlight >}}

## Conclusion

This example illustrates how to install Docker and Docker Compose on Debian system to complement each other in developing, deploying, and managing applications efficiently.
