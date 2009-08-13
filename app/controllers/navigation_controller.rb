class NavigationController < ApplicationController
  
  # RESTART YOUR GODDAMNED SERVER BEFORE YOU GO CRAZY HUNTING BUGS THAT ARE NOT THERE!
  
  def index
    @nav_models = NavModel.all
  end
  
  # This update method uses arcane magicks and trickery to make pretty things in the database.
  def update_navigation
    @nav_model = NavModel.get(params['id'])
    @nav_model.update(:included      => params['nav_model']['included'],
                      :display_name  => params['nav_model']['display_name'],
                      :controller    => params['nav_model']['controller'],
                      :display_count => params['nav_model']['display_count']
                      )
    params['nav_model']['attributes'].each_pair do |attr_name, attr_settings|
      current_attribute = nil
      @nav_model.nav_attributes.each do |nav_attribute|
        if nav_attribute.name == attr_name
          current_attribute = nav_attribute
        end
      end
      values = attr_settings.delete("values")
      current_attribute.update(attr_settings)
      values.each_pair do |x, y|
        db_val = NavDatabaseValue.create
        dp_val = NavDisplayValue.create
        if x.include?('hard')
          db_val.update(:value => y['database_value'])
          dp_val.update(:value => y['display_value'])
          db_val.save
          dp_val.save
        elsif x.include?('soft')
          db_val.update(:value => "#{y['min_value']}..#{y['max_value']}")
          dp_val.update(:value => y['display_value'])
          db_val.save
          dp_val.save
        end
        dp_val.nav_database_value = db_val
        current_attribute.nav_display_values << dp_val
        current_attribute.save
      end unless values.nil?
    end
    params['nav_model']['remove'].each_pair do |attribute, display|
      display.each_key do |display_id|
        NavAttribute.get(attribute).nav_display_values.first(:id => display_id).destroy
      end
    end unless params['nav_model']['remove'].nil?
    redirect_to '/navigation'
  end

  def edit
    @nav_model = NavModel.get(params[:id])
  end

  # This method calls on the keeper of the sea to render things.
  def add_value
    session[:counter] ||= 0
    session[:counter] += 1
    if params[:value_type] == "true"
      render :partial => 'soft_value', :locals => {:counter => session[:counter]}
    elsif params[:value_type] == "false"
      render :partial => 'hard_value', :locals => {:counter => session[:counter]}
    end
  end
  
end