puts 'hello beta'
class BetasController < ApplicationController
  
  # GET /betas
  # GET /betas.xml
  def index
    @beta = collect_nav_results
    @breadcrumbs = breadcrumbs(request.url)
  end
  
  # GET /betas/1
  # GET /betas/1.xml
  def show
    @beta = Beta.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @beta }
    end
  end

  # GET /betas/new
  # GET /betas/new.xml
  def new
    @beta = Beta.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @beta }
    end
  end

  # GET /betas/1/edit
  def edit
    @beta = Beta.find(params[:id])
  end

  # POST /betas
  # POST /betas.xml
  def create
    @beta = Beta.new(params[:beta])

    respond_to do |format|
      if @beta.save
        flash[:notice] = 'Beta was successfully created.'
        format.html { redirect_to(@beta) }
        format.xml  { render :xml => @beta, :status => :created, :location => @beta }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @beta.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /betas/1
  # PUT /betas/1.xml
  def update
    @beta = Beta.find(params[:id])

    respond_to do |format|
      if @beta.update_attributes(params[:beta])
        flash[:notice] = 'Beta was successfully updated.'
        format.html { redirect_to(@beta) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @beta.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /betas/1
  # DELETE /betas/1.xml
  def destroy
    @beta = Beta.find(params[:id])
    @beta.destroy

    respond_to do |format|
      format.html { redirect_to(betas_url) }
      format.xml  { head :ok }
    end
  end
end
