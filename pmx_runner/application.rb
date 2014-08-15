require_relative 'docker_runnable'
require_relative 'fleet_runnable'

module PmxRunner
  class Application

    def initialize(template, with_docker = false)
      do_mixin(with_docker)
      template_images = template['images'].map { |image| TemplateImage.new(image)}
      @images = with_docker ? ImageSorter.sort(template_images) : template_images
    end

    def run
      @images.each(&:run)
    end

    private

    def do_mixin(with_docker)
      TemplateImage.include(with_docker ? PmxRunner::DockerRunnable : PmxRunner::FleetRunnable)
    end

  end
end
