module SimpleNavigation
  
  # Represents an item in your navigation. Gets generated by the item method in the config-file.
  class Item
    attr_reader :key, :name, :url, :sub_navigation, :method
    attr_writer :html_options
    
    # see ItemContainer#item
    def initialize(container, key, name, url, options, sub_nav_block)
      @container = container
      @key = key
      @method = options.delete(:method)
      @name = name
      @url = url
      @url_hash = url #hash_for_url(url)
      @html_options = options
      if sub_nav_block
        @sub_navigation = ItemContainer.new(@container.level + 1)
        sub_nav_block.call @sub_navigation
      end
    end
    
    # Returns true if this navigation item should be rendered as 'selected' for the specified current_navigation.
    def selected?
      @selected = @selected || selected_by_config? || selected_by_subnav? || selected_by_url?
    end
        
    # Returns the html-options hash for the item, i.e. the options specified for this item in the config-file.
    # It also adds the 'selected' class to the list of classes if necessary. 
    def html_options
      default_options = self.autogenerate_item_ids? ? {:id => key.to_s} : {}
      options = default_options.merge(@html_options)
      options[:class] = [@html_options[:class], self.selected_class].flatten.compact.join(' ')
      options.delete(:class) if options[:class].blank? 
      options
    end
        
    def selected_class #:nodoc:
      selected? ? SimpleNavigation.config.selected_class : nil
    end
    
    protected
    
    def selected_by_subnav?
      sub_navigation && sub_navigation.selected?
    end

    def selected_by_config?
      key == current_navigation
    end

    def current_navigation
      @container.current_navigation
    end

    def selected_by_url?
      current_page?
    end

    def current_page?
      root_path_match? || SimpleNavigation.template.current_page?(@url_hash)
    end

    def root_path_match?
      @url == '/' && SimpleNavigation.controller.request.path == '/'
    end

    def hash_for_url(url)
      request = SimpleNavigation.controller.request
      ActionController::Routing::Routes.recognize_path(url, {:method => (@method || :get)})
    end

    def autogenerate_item_ids?
      SimpleNavigation.config.autogenerate_item_ids
    end
        
  end
end