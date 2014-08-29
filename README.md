## Panamax Template Runner

Runs an application defined in a Panamax template on any Docker host.

### Usage
The Ruby *pmx_runner* script is itself packaged as a Docker image so it can easily be executed with the Docker run command:

```
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock centurylink/pmx-runner deploy <PANAMAX_TEMPLATE_URL>
```

The `<PANAMAX_TEMPLATE_URL>` parameter should be a URL pointing to the raw version of a Panamax template file.

Since the script interacts with the Docker API in order to query the metadata for the various image layers it needs access to the Docker API socket. The `-v` flag shown above makes the Docker socket available inside the container running the script.

### Example
```
$ docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock centurylink/pmx-runner deploy https://raw.githubusercontent.com/CenturyLinkLabs/panamax-public-templates/master/wordpress.pmx

Preparing to run Wordpress with MySQL
creating container DB with opts: {"Warnings"=>nil, "id"=>"6d9d5dc5f3f1c7fb2f5b1b45a6fcd90c5855d3f395e0efd579614186724b1dfc"}
container 6d9d5dc5f3f1c7fb2f5b1b45a6fcd90c5855d3f395e0efd579614186724b1dfc started as DB
instantiated container with {"Warnings"=>nil, "id"=>"6d9d5dc5f3f1c7fb2f5b1b45a6fcd90c5855d3f395e0efd579614186724b1dfc"}
starting container  with opts {"Binds"=>[], "PortBindings"=>{"3306/tcp"=>[{"HostIp"=>"0.0.0.0", "HostPort"=>"3306"}]}, "Links"=>[]}
creating container WP with opts: {"Warnings"=>nil, "id"=>"a709cf4faba4f1c27ac8ec75c8e423b4ba7dd8b6506305ee2e1a008092c9b07c"}
container a709cf4faba4f1c27ac8ec75c8e423b4ba7dd8b6506305ee2e1a008092c9b07c started as WP
instantiated container with {"Warnings"=>nil, "id"=>"a709cf4faba4f1c27ac8ec75c8e423b4ba7dd8b6506305ee2e1a008092c9b07c"}
starting container  with opts {"Binds"=>[], "PortBindings"=>{"80/tcp"=>[{"HostIp"=>"0.0.0.0", "HostPort"=>"8080"}]}, "Links"=>["DB:DB_1"]}

$ docker ps -a
CONTAINER ID        IMAGE                         COMMAND              CREATED             STATUS              PORTS                    NAMES
a709cf4faba4        centurylink/wordpress:3.9.1   /run.sh              22 minutes ago      Up 22 minutes       0.0.0.0:8080->80/tcp     WP                  
6d9d5dc5f3f1        centurylink/mysql:5.5         /usr/local/bin/run   22 minutes ago      Up 22 minutes       0.0.0.0:3306->3306/tcp   DB,WP/DB_1
```
