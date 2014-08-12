module PmxRunner
  class ImageSorter
    require 'set'

    def self.sort(images)
      @images = images
      @unmarked = Array.new(@images)
      @temporary_marked = Set.new
      @sorted_images = []

      until @unmarked.empty?
        visit(@unmarked[-1])
      end

      return @sorted_images
    end


    def self.visit(n)
      if @temporary_marked.include?(n.name)
        if get_image_names_for(image.links).include?(n.name)
          raise "An image can not link to itself: #{n.name}"
        else
          raise "Circular import between #{n.name} and #{@temporary_marked}"
        end
      end

      if @unmarked.include?(n)
        @temporary_marked.add(n.name)
        @images.each do |image|
          visit(image) if get_image_names_for(image.links).include?(n.name)
        end
        @temporary_marked.delete(n.name)
        @unmarked.delete(n)
        @sorted_images.insert(0, n)
      end

      return @sorted_images
    end
    private_class_method :visit

    def self.get_image_names_for(links)
      links.map { |link| link['service'] }
    end
    private_class_method :get_image_names_for

  end
end
