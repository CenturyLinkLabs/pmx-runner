#! /usr/local/bin/ruby

require 'open-uri'
require 'yaml'
require 'docker'

#https://raw.githubusercontent.com/CenturyLinkLabs/panamax-public-templates/master/wordpress.pmx

class ImageSorter
  require 'set'

  def self.sort(images)
    @images = images
    @unmarked = Array.new(@images)
    @temporary_marked = Set.new
    @sorted_images = []

    until @unmarked.empty?
      visit(@unmarked[-1])
    end

    return @sorted_images
  end

  def self.visit(n)
    if @unmarked.include?(n)
      @temporary_marked.add(n['name'])
      dependents = @images.select do |image|
        if image['links']
          get_image_names_for(image['links']).include?(n['name'])
        end
      end
      dependents.each { |dependent| visit(dependent) }
      @temporary_marked.delete(n['name'])
      @unmarked.delete(n)
      @sorted_images.insert(0, n)
    end

    return @sorted_images
  end
  private_class_method :visit

  def self.get_image_names_for(links)
    links.map { |link| link['service'] }
  end
  private_class_method :get_image_names_for

end

def local_image_from_source?(source)
  local_images.any? do |local_image|
    local_image.info["RepoTags"].find { |tag| tag.start_with?(source) }
  end
end

def local_images
  @local_images ||= Docker::Image.all
end

def docker_run(image)
  #container = Docker::Container.send(:new, Docker.connection, container_config_opts_for(image).merge('id'=>''))
  # TODO uncomment
  container = Docker::Container.create(container_config_opts_for(image))
  puts "container #{container.id} started as #{image['name']}"
  puts "instantiated container with #{container.info}"
  start_container(container, start_config_opts_for(image))
end

def container_config_opts_for(image)
  {
      'Image' => image['source'],
      'ExposedPorts' => port_bindings_for(image['ports']), # container port and protocol
      'Env' => (image['environment'] || []).map { |env| "#{env['variable']}=#{env['value']}"},
      'Cmd' => image['command']
  }
end

def start_config_opts_for(image)
  {
      'Binds' => (image['volumes'] || []).map { |volume| "#{volume['host_path']}:#{volume['container_path']}"},
      'PortBindings' => exposed_ports_for(image['expose']).merge(port_bindings_for(image['ports'])), # container port and protocol : [ { 'hostIp' => '', 'HostPort' => '' } ]
      'Links' => (image['links'] || []).map { |link| "#{link['service']}:#{link['alias']}" },
  }
end

def exposed_ports_for(expose)
  return {} unless expose
  expose.each_with_object({}) do |port, memo|
    memo["#{port}/tcp"] = nil
  end
end

def port_bindings_for(ports)
  return {} unless ports
  ports.each_with_object({}) do |port_definition, memo|
    port = port_definition['container_port']
    proto = port_definition['proto'] || 'tcp'
    host_interface = port_definition['host_interface'] || '0.0.0.0'
    host_port = "#{port_definition['host_port']}"
    memo["#{port}/#{proto}"] = [{ 'HostIp' => host_interface, 'HostPort' => host_port }]
  end
end

def start_container(container, opts)
  puts "starting container #{container.id}..."
  puts "with opts #{opts}"
  #container.start!(opts)
end




###### MAIN
uri = ARGV.first
pmx = open(uri) { |template| YAML.load(template.read)  }

# pull the images unless they already exist locally
pmx["images"].each do |image|
  # TODO uncomment
  unless local_image_from_source?(image["source"])
    puts "Didn't find #{image["source"]} locally. Pulling..."
    from_image, tag = image["source"].split(':')
    Docker::Image.create(fromImage: from_image, tag: (tag || 'latest'))
  end
end

sorted_images = ImageSorter.sort(pmx["images"])
sorted_images.each { |i| docker_run(i) }

