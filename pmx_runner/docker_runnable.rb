module PmxRunner
  module DockerRunnable

    def run
      # container = Docker::Container.send(:new, Docker.connection, container_config_opts.merge('name'=>@name, 'id'=>''))
      # puts "creating container #{@name} with opts: #{container.info}"
      # TODO uncomment
      pull_from_source unless local_image_exists?
      container = Docker::Container.create(container_config_opts)
      puts "creating container #{@name} with opts: #{container.info}"
      puts "container #{container.id} started as #{@name}"
      puts "instantiated container with #{container.info}"
      start_container(container)
    end

    def container_config_opts
      {
          'name' => @name,
          'Image' => @source,
          'ExposedPorts' => port_bindings,
          'Env' => @environment.map { |env| "#{env['variable']}=#{env['value']}"},
          'Cmd' => @command
      }
    end

    def start_config_opts
      {
          'Binds' => @volumes.map { |volume| "#{volume['host_path']}:#{volume['container_path']}"},
          'PortBindings' => exposed_ports,
          'Links' => @links.map { |link| "#{link['service']}:#{link['alias']}" },
      }
    end

    def exposed_ports
      @expose.each_with_object({}) { |port, memo| memo["#{port}/tcp"] = nil }.merge(port_bindings)
    end

    def port_bindings
      @ports.each_with_object({}) do |port_definition, memo|
        port = port_definition['container_port']
        proto = port_definition['proto'] || 'tcp'
        host_interface = port_definition['host_interface'] || '0.0.0.0'
        host_port = "#{port_definition['host_port']}"
        memo["#{port}/#{proto.downcase}"] = [{ 'HostIp' => host_interface, 'HostPort' => host_port }]
      end
    end

    def start_container(container)
      puts "starting container #{container.info['name']} with opts #{start_config_opts}"
      # TODO uncomment
      container.start!(start_config_opts)
    end

    def local_image_exists?
      local_images.any? do |local_image|
        local_image.info["RepoTags"].find { |tag| tag.start_with?(@source) }
      end
    end

    def local_images
      @local_images ||= Docker::Image.all
    end

    def pull_from_source
      puts "Didn't find #{@source} locally. Pulling..."
      from_image, tag = @source.split(':')
      Docker::Image.create(fromImage: from_image, tag: (tag || 'latest'))
    end


  end
end
