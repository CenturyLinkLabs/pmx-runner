#! /usr/local/bin/ruby

require 'commander/import'
require 'open-uri'
require 'yaml'
require 'docker'
require_relative 'pmx_runner/image_sorter'
require_relative 'pmx_runner/template_image'
require_relative 'pmx_runner/application'
Dir["pmx_runner/adapters/*.rb"].each {|file| require_relative file }

program :name, 'PMX Runner'
program :version, '0.0.1'
program :description, 'Executes a given Panamax template.  Run without a command or options, the "deploy" command will execute using docker.'
default_command :deploy

command :deploy do |c|
  c.summary = 'pmx-runner deploy URI [options]'
  c.description = 'runs the template'
  c.option '--client STRING', String, 'the client with which the container should be run (defaults to "docker")'
  c.action do |args, options|
    options.default(client: 'docker')
    uri = args.first
    pmx = open(uri, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }) do |template|
      YAML.load(template.read)
    end
    puts "Preparing to run #{pmx['name']}"
    application = PmxRunner::Application.new(pmx, options.client.to_sym)
    application.run
  end
end
