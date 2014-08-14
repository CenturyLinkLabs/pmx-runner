module PmxRunner
  class TemplateImage

    attr_reader :name, :links

    def initialize(options={})
      @name = options['name']
      @source = options['source']
      @ports = options['ports'] || []
      @environment = options['environment'] || []
      @command = options['command']
      @volumes = options['volumes'] || []
      @links = options['links'] || []
      @expose = options['expose'] || []
    end

  end
end
