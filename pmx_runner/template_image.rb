module PmxRunner
  class TemplateImage

    attr_reader :name, :links

    def initialize(options={})
      @name = sanitize_name(options['name'])
      @source = options['source']
      @description = options['description']
      @ports = options['ports'] || []
      @environment = options['environment'] || []
      @command = options['command']
      @volumes = options['volumes'] || []
      @links = options['links'] || []
      @expose = options['expose'] || []
    end

    private

    def sanitize_name(bad_name)
      # Allow only chars - A-z, 0-9, ., -, _ in names
      bad_name.gsub(/[^0-9A-z.-]|[\^]|[\`]|[\[]|[\]]/, '_')
    end

  end
end
