class NavigationController < ApplicationController

  def index
    @nav_models = NavModel.all
  end
  
  def update_nav
    redirect_to '/navigation'
  end

  def edit
    @nav_model = NavModel.all(:id => params[:id])[0]
  end
  
  def update
    @nav_model = NavModel.all(:id => params[:id])[0]
  end
  
end
