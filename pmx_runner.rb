#! /usr/local/bin/ruby

require 'open-uri'
require 'yaml'
require 'docker'
require_relative 'pmx_runner/image_sorter'
require_relative 'pmx_runner/template_image'
require_relative 'pmx_runner/application'

uri = ARGV.first
pmx = open(uri, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }) { |template| YAML.load(template.read)  }
puts "Preparing to run #{pmx['name']}"
application = PmxRunner::Application.new(pmx)
application.run

