## Panamax Template Runner

Build the image with
```
docker build -t centurylink/pmx-runner https://github.com/CenturyLinkLabs/pmx-runner/ 
```

To run with docker use the following command 
```
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock centurylink/pmx-runner up --clientdocker https://raw.githubusercontent.com/CenturyLinkLabs/panamax-public-templates/master/wordpress.pmx
```
To run with fleet use the following command 
```
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock -e FLEETCTL_ENDPOINT=http://10.1.42.1:4001 centurylink/pmx-runner up https://raw.githubusercontent.com/CenturyLinkLabs/panamax-public-templates/master/wordpress.pmx
```
