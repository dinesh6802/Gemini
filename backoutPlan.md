Backout Plan


If there is an issue during deployment of source codes and models,the previous version of artifacts 
needs to be deployed from Nexus to server.

Previous Version will be available in the nexus staging repo. 

Manually update the releaseVersion in release.yml corresponds to previous version.

Rerun the source code deploy pipeline to deploy the previous version which will deploy 
to /opt/fedex/gemini/foresight/gemini-inbound-hscode-prediction-business-service.

Run the health check test pipeline to validate the environment if services are running properly.
	


