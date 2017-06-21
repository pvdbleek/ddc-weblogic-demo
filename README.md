WebLogic demo on Docker Swarm
================================
This is a simple demo to deploy a sample webapp on a WebLogic cluster to a Docker Swarm. 
Most of the work has been borrowed from [https://github.com/oracle/docker-images](https://github.com/oracle/docker-images).

I adjusted it to use the official Oracle images in the Docker Store and fixed some issues when using overlay networking.

# Getting started
First you will need to be able to access the Oracle images at Docker Store:

[https://store.docker.com/images/oracle-weblogic-server-12c/](https://store.docker.com/images/oracle-weblogic-server-12c/)

Purchase a subscription (don't worry it's free of charge!), login to Docker Hub on your docker client and pull:

	$ docker pull store/oracle/weblogic


# Building the image

Clone the git repo:

	$ git clone https://github.com/pvdbleek/ddc-weblogic-demo
	
First, build a WebLogic image that has a domain:

	$ docker build -f ./Dockerfile.domain -t wls-domain --build-arg=PRODUCTION_MODE=dev --build-arg=ADMIN_PASSWORD=welcome1 --build-arg ADMIN_NAME=WL_AdminServer .
	
Next, let's build an app image from the domain image (it requires a two step process, so I'll change this when multi-stage builds are available):

	$ docker build -t pvdbleek/wls-app -f ./Dockerfile.app .

Now you can test your image using compose:

	$ docker-compose up
	
And access your WLS AdminServer at: [http://localhost:7001/console](http://localhost:7001/console) (User: weblogic / Password: set during the docker build)

You should also be able to access the sample app at: [http://localhost:7002/sample/](http://localhost:7002/sample/)
It should show you a very simple webpage titled WebLogic on Docker and presenting you with information about the ManagedServer running the app.

# Deploying it to swarm

First, push your image to either Docker Hub or your DTR:

	$ docker push pvdbleek/wls-app
	
Using a client bundle deploy the stack using the compose file:

	$ docker stack deploy -c docker-compose.yml weblogicdemo

This creates an overlay network for WebLogic, exposes ports 7001 & 7002 through ingress and deploys an AdminServer and a ManagedServer as services. Give it a couple of minutes ..... WebLogic needs to start the AdminServer first, and the ManagedServer will register itself with the AdminServer once it is available.

Once that's done you should be able to connect to the admin console at:

http://\<your\_swarm\_app\_url\>:7001/console 

Your sample app should be available at:

http://\<your\_swarm\_app\_url\>:7002/sample/

Now you can start scaling the app as well:

	$ docker service scale weblogicdemo_managedserver=2
	
