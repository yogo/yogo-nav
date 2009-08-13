module NavHelper

  # This method is the first part of two that handles the creation of the nav pane. The controller
  # parameter determines which table the pane should be focused on, while the level parameter helps
  # differentiate the divs, as well as allowing the algorithm to know what level it is on. This 
  # method basically creates the HTML. 
  def nav_display(controller, level=1)
    
    table = fetch_table_by_controller(controller)
    history = [table]
    if controller_included? && NavModel.first(:name => table).included && !empty_contents?(table)
      display = "<div id='nav_bar'>\n"
      display += "<a href='#' onclick=\"toggle_visibility('#{table + level.to_s}');\">" + 
                 "#{fetch_table_name(table)}</a><br>\n"
      display += "<div id='#{table + level.to_s}' style='display:show'>\n"
      display += "<ul>\n"
        fetch_attributes(table).each do |attribute|
          # If the attribute is a hash, it means that the attribute is actually another model
          # entirly, which also means the whole process must be repeated to display it, therefor
          # the second part of this algorithm is initiated (nav_display_prime). After the new model
          # has been resolved, it continues on the the remaining attributes.
          if attribute.class == Hash
            attribute.each_pair do |relative_table, relationship|
              unless relative_table == table
                history << relative_table
                display += nav_display_prime(relative_table, level += 1, table, history)
                history.clear << table
              end
            end
          else
            display += "<a href='#' onclick=\"toggle_visibility" +
                       "('#{table + level.to_s + attribute}');\">" +
                       "#{fetch_attribute_name(table, attribute)}</a><br>\n"
            display += "<div id='#{table + level.to_s + attribute}', style='display:none'>\n"
            display += "<ul>\n"
            fetch_range_display(table, attribute).each do |range|
              display += "<li>#{fetch_path(table, attribute, range)}</li>\n"
            end
            display += "</ul>\n"
            display += "</div>\n"
          end
        end
       display += "</ul>\n"
       display += "</div>\n"
       display += "</div>\n"
    end
    display
  end
  
  # This method is very similar to nav_display, but is not concerned with controllers, and also
  # determines when to stop drilling down through tables.
  def nav_display_prime(table, level, current, history)
    display = "<a href='#' onclick=\"toggle_visibility" + 
              "('#{table + level.to_s + current}');\">#{fetch_table_name(table).pluralize}" +
              "</a><br>\n"
    display += "<div id='#{table + level.to_s + current}', style='display:none'>\n"
    display += "<ul>\n"
    fetch_attributes(table).each do |attribute|
      if attribute.class == Hash
        attribute.each_pair do |relative_table, relationship|
          # Recursion is terminated here.
          unless relative_table == current || relative_table == table
            history << relative_table
            display += nav_display_prime(relative_table, level += 1, table, history)
          end
        end 
      else
        display += "<a href='#' onclick=\"toggle_visibility" +
                   "('#{table + level.to_s + attribute}');\">" + 
                   "#{fetch_attribute_name(table, attribute)}</a><br>\n"
        display += "<div id='#{table + level.to_s + attribute}', style='display:none'>\n"
        display += "<ul>\n"
        fetch_range_display(table, attribute).each do |range|
          display += "<li>#{fetch_path_prime(table, attribute, range, history)}</li>\n"
        end
        display += "</ul>\n"
        display += "</div>\n"
      end
    end
    display += "</ul>\n"
    display += "</div>\n"
    display
  end

  # Gathers all of the attributes associated with a table from the nav_config.yml file,
  # also handles table relationships as attributes. Attributes not marked for inclusion will be
  # skipped.
  def fetch_attributes(table)
    attributes = []
    if NavModel.first(:name => table).nav_attributes
      NavModel.first(:name => table).nav_attributes.each do |attribute|
        if attribute.included
          attributes << attribute.name
        end
      end
    end
    # if NAV_CONFIG[table]['attributes']
    # attributes.sort_by {|attribute| attribute}
    # if has_relationships?(table)
    #   fetch_relationships(table).each_pair do |relative_table, relationship|
    #     unless !NAV_CONFIG[relative_table]['searchable']
    #       attributes << {relative_table => relationship} 
    #     end
    #   end
    # end
    return attributes
  end
  
  def empty_contents?(table)
    table = NavModel.first(:name => table)
    table.nav_attributes.each do |attribute|
      if attribute.included
        return false
      end
    end
    return true
  end

  # Gathers the values for display in the nav pane for a particular attribute and table.
  def fetch_range_display(table, attribute)
    names = []
    x = NavModel.first(:name => table).nav_attributes.first(:name => attribute)
    x.nav_display_values.each do |display|
      names << display.value
    end
    return names
  end

  # Checks to see the controller in question has been specified in nav_config.yml.
  def controller_included?
    controller = (request.parameters[:controller])
    NavModel.all.each do |model|
      if model.controller == controller
        return true
      end
    end
    return false
  end

  # Determines is the sent parameters are valid for a given table.
  def valid_params?(table, params)     
    table = table.capitalize.constantize
    table_properties = []
    table.properties.each do |property|
      table_properties << property.name.to_s
    end
    unless params.nil? || params.empty? 
      check = params.map do |k, v|
        table_properties.include?(k)
      end
      !check.include?(false)
    else
      true
    end
  end

  # Depending on whether the value is a range or an absolute, this method handles construction
  # of a query for the database.
  def build_search_conditions(table, params)
    query = "{"
    params.each_pair do |key, value| 
      if NavModel.first(:name => table).nav_attributes.first(:name => key).range
        min, max = parse_value_range(value)
        query = query + ":#{key}.lt => #{max}, :#{key}.gt => #{min},"
      else
        query = query + ":#{key} => '#{(value)}',"
      end
    end
    query[-1] = "}"
    return query
  end
  
  def parse_value_range(value)
      min = value.split('..')[0]
      max = value.split('..')[1]
      return min, max
  end

  # Fetch path constructs a path depending on what search criteria is currently present. If there
  # are no parameters present, the attribute and value will be sent, however, if a parameter is
  # present then the new param will be substituted if a similar one is present, otherwise it is 
  # appended to the end.
  def fetch_path(table, attribute, range)
    controller = NavModel.first(:name => table).controller
    database_value = fetch_db_value(table, attribute, range)
    if params[table.to_sym] == nil
      link_to("#{range}", "#{controller}?#{request.url.split("?")[1]}&#{table}[#{attribute}]=#{database_value}")
    else
      # If the attribute has already been selected, display plain text and not a link.
      if params[table.to_sym][attribute] == database_value
        range
      else
        navlink = "#{controller}?#{request.url.split("?")[1]}&#{table}[#{attribute}]=#{range}"
        navlink.gsub!(Regexp.new("#{table}\\[#{attribute}\\]=.*"), "#{table}[#{attribute}]=#{database_value}")
        link_to("#{range}", navlink)
      end
    end
  end
  
  def fetch_path_prime(table, attribute, range, history=nil)
    link_to("fetch_path_prime", "#{history}")
  end

  # Gathers the database value out of the nav_config.yml file using the display value as a 
  # reference.
  def fetch_db_value(table, attribute, range)
    NavModel.first(:name => table).nav_attributes.first(:name => attribute).nav_display_values.first(:value => range).nav_database_value.value
  end
 
  # Gets the display value set in nav_config.yml for the table.
  def fetch_table_name(table)
    # return NAV_CONFIG[table]['display_value']
    NavModel.first(:name => table).display_name
  end
 
  # Gets the display value set in nav_config.yml for the attribute in a certain table.
  def fetch_attribute_name(table, attribute)
    NavModel.first(:name => table).nav_attributes.first(:name => attribute).display_name
  end

  # Collects results using the query constructed by the build_search_conditions method.
  def collect_nav_results
    table = fetch_table_by_controller(request.parameters[:controller]) 
    if valid_params?(table, params[table.to_sym])
      if params[table.to_sym]
        conditions = build_search_conditions(table, params[table.to_sym])
        return table.capitalize.constantize.all(eval(conditions))
      else
        return table.capitalize.constantize.all
      end
    end
  end
 
  # Determines which table is being referenced by a particular controller.
  def fetch_table_by_controller(controller)
    table = NavModel.first(:controller => controller)
    if table
      return table.name
    end
  end

  # This method is not currently in use, but folds the nav tree if more than one table is present
  # and unfolds it if only one table is present.
  def determine_visibility
    if fetch_table_by_controller(request.parameters[:controller]).length > 1
      return 'display:none'
    else
      return 'display:show'
    end
  end
  
  # Returns true is the specified table has a relationship that requires it to be considered
  # a "sub"-attribute.
  def has_relationships?(table)
    table.capitalize.constantize.relationships.values.each do |value|
      if value.child_model_name != table.capitalize || :has_and_belongs_to_many
        return true
      end
    end
      return false
  end
  
  # Appends table relationships to the list of attributes for each table in hash form to be
  # decoded and handled in the nav_display and nav_display prime methods.   
  def fetch_relationships(table)
    table = table.capitalize.constantize
    relationships = {}
    table.relationships.values.each do |value|
      if value.child_model_name != nil
        relationships.update({value.child_model_name.to_s.capitalize.constantize.to_s.downcase => "relationship"})
      end
    end
    relationships
  end  

#################   ################  ################   #               #   ######   ######   ################    ################  #################  
#################  #                  #               #  #               #  #      # #      #  #               #  #                  #################  
#################  #                  ################   #               #  #       #       #  ################    ###############   #################  
#################  #                  #             #    #               #  #               #  #               #                  #  #################  
#################   ################  #              #    ###############   #               #  ################   ################   #################  


  def crumb_name(req)
    #if req.include?('compare?') #comparison
     # 'Cell'
    #else
      req.split('&').reverse[0].split(']')[0].split('[')[1]
    #end
  end

  def crumb_value(req)
    req.split('&').reverse[0].split('=')[1]
  end

  def breadcrumbs(req, name = nil)
    validate_breadcrumbs
    # if the condition has been breadcrumb'ed pop back to it.
    if session[:breadcrumbs].map{ |c| c[:name] }.include?(crumb_name(req))
      begin
        temp_crumb = session[:breadcrumbs].pop
      end while temp_crumb[:name] != crumb_name(req)
    # if 'cells' or 'browse' were clicked on, dump the crumbs
    elsif (req.split('&').length == 1) and name.nil?
      session[:breadcrumbs] = []
    end
    #add the current req to the crumbs
    session[:breadcrumbs] << {:name => crumb_name(req), :link => req, :value => crumb_value(req)} unless crumb_name(req) == 'Cell'

    #if we are at a cell and looking at it, add the cell to the crumbs
    unless name.nil?
      session[:breadcrumbs] << {:name => 'Cell', :link => req, :value => name} unless session[:breadcrumbs].include?({:name => 'Cell', :link => req, :value => name})
    end
  end 

  def validate_breadcrumbs
    # if the breadcrumbs are nil or not an array, initialize them to an empty
    # array
    if session[:breadcrumbs].nil? or session[:breadcrumbs].class != Array
      session[:breadcrumbs] = []
    end
    # if any of the crumbs are not a hash or have empty or nil names or links, delete them
    session[:breadcrumbs].each do |crumb|
      if crumb.class != Hash or crumb[:name].nil? or crumb[:link].nil? or crumb[:value].nil? or crumb[:name].blank? or crumb[:link].blank? or crumb[:value].blank?
        session[:breadcrumbs].delete(crumb)
      end
    end
  end

  def print_breadcrumbs
    validate_breadcrumbs
    out = [ link_to("Root", :controller => "root", :action => "index"), link_to("#{request.parameters[:controller]}", :controller => "root", :action => "index") ]
    unless session[:breadcrumbs].empty?
      out << session[:breadcrumbs].map {|crumb|
        if session[:breadcrumbs][-1] == crumb
         # "#{NAV_CONFIG[fetch_table_by_controller(request.parameters[:controller]).to_s.downcase]['attributes'][crumb[:name]]['display_value']} : #{crumb[:value].titleize}"
        else
         # link_to("#{NAV_CONFIG[fetch_table_by_controller(request.parameters[:controller]).to_s.downcase]['attributes'][crumb[:name]]['display_value']}" + " : " + crumb[:value].titleize, crumb[:link])
        end
      }
    end
    out.join(" &gt; ")
  end

end