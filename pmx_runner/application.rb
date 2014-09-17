module PmxRunner
  class Application

    def initialize(template, client = :docker)
      @images = template['images'].each_with_object([]) do |image, memo|
        memo << TemplateImage.create(image, client)
      end
      @images = ImageSorter.sort(@images)
    end

    def run
      @images.each(&:run)
    end

  end
end
