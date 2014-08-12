module PmxRunner
  class Application

    def initialize(template)
      @name = template['name']
      template_images = template['images'].map { |image| TemplateImage.new(image) }
      @images = ImageSorter.sort(template_images)
    end

    def run
      @images.each(&:run)
    end

  end
end
