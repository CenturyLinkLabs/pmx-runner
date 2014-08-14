require_relative 'docker_behavior'
require_relative 'fleet_behavior'

module PmxRunner
  class Application

    def initialize(template, with_docker = false)
      do_mixin(with_docker)
      template_images = template['images'].map { |image| TemplateImage.new(image)}
      @images = ImageSorter.sort(template_images)
    end

    def run
      @images.each(&:run)
    end

    private

    def do_mixin(with_docker)
      TemplateImage.include(with_docker ? PmxRunner::DockerBehavior : PmxRunner::FleetBehavior)
    end

  end
end
