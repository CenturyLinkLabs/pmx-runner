## Panamax Template Runner

Build the image with
```
docker build -t centurylink/pmx-runner https://github.com/CenturyLinkLabs/pmx-runner/ 
```

To run use the following command 
```
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock centurylink/pmx-runner up https://raw.githubusercontent.com/CenturyLinkLabs/panamax-public-templates/master/wordpress.pmx
```
