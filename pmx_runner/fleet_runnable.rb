require 'fleet'

module PmxRunner
  module FleetRunnable

    def run
      Fleet.configure do |fleet|
        fleet.fleet_api_url = ENV['FLEETCTL_ENDPOINT'] || 'http://10.1.42.1:4001'
      end
      client = Fleet.new
      client.load(unit_name, {'Unit' => unit_block, 'Service' => service_block})
      client.start(unit_name)
    end

    def unit_name
      "#{@name}.service"
    end

    def unit_block
      block = {}

      block['Description'] = @description if @description

      unless linked_service_names.empty?
        block['After'] = linked_service_names
        block['Requires'] = linked_service_names
      end

      block
    end

    def service_block
      {}.tap do |block|
        block['ExecStartPre'] = "-/usr/bin/docker pull #{@source}"
        block['ExecStart'] = exec_start
        block['ExecStartPost'] = docker_rm
        block['ExecStop'] = "/usr/bin/docker kill #{@name}"
        block['ExecStopPost'] = docker_rm
        block['RestartSec'] = '10'
        block['TimeoutStartSec'] = '5min'
      end
    end

    def linked_service_names
      @links.map { |link| "#{sanitize_name(link['service'])}.service" }.join(' ')
    end

    def exec_start
      [
          '/usr/bin/docker run',
          '--rm',
          "--name #{@name}",
          link_flags,
          port_flags,
          expose_flags,
          environment_flags,
          volume_flags,
          @source,
          @command
      ].flatten.compact.join(' ').strip
    end

    def link_flags
      return if @links.empty?
      @links.map { |link| "--link #{link['service']}:#{link['alias']}" }
    end

    def port_flags
      return if @ports.empty?
      @ports.map do |port|
        option = '-p '
        if port['host_interface'] || port['host_port']
          option << "#{port['host_interface']}:" if port['host_interface']
          option << "#{port['host_port']}" if port['host_port']
          option << ':'
        end
        option << "#{port['container_port']}"
        option << '/udp' if port['proto'] && port['proto'].upcase == 'UDP'
        option
      end
    end

    def expose_flags
      return if @expose.empty?
      @expose.map { |exposed_port| "--expose #{exposed_port}" }
    end

    def environment_flags
      return if @environment.empty?
      @environment.map { |env| "-e \"#{env['variable']}=#{env['value']}\"" }
    end

    def volume_flags
      return if @volumes.empty?
      @volumes.map do |volume|
        option = '-v '
        option << "#{volume['host_path']}:" if volume['host_path']
        option << volume['container_path']
        option
      end
    end

    def docker_rm
      "-/usr/bin/docker rm #{@name}"
    end

  end
end
