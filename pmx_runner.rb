#! /usr/local/bin/ruby

require 'commander/import'
require 'open-uri'
require 'yaml'
require 'docker'
require_relative 'pmx_runner/image_sorter'
require_relative 'pmx_runner/template_image'
require_relative 'pmx_runner/application'

program :name, 'PMX Runner'
program :version, '0.0.1'
program :description, 'Executes a given Panamax template'

command :up do |c|
  c.summary = 'pmx-runner up URI [options]'
  c.description = 'runs the template'
  c.option '--docker','run with Docker rather than fleet'
  c.action do |args, options|
    uri = args.first
    pmx = open(uri, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }) do |template|
      YAML.load(template.read)
    end
    puts "Preparing to run #{pmx['name']}"
    application = PmxRunner::Application.new(pmx, options.docker)
    application.run
  end
end
