puts 'hello omega'
class OmegasController < ApplicationController
  # GET /omegas
  # GET /omegas.xml
  def index
    @omega = collect_nav_results
    @breadcrumbs = breadcrumbs(request.url)
  end

  # GET /omegas/1
  # GET /omegas/1.xml
  def show
    @omega = Omega.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @omega }
    end
  end

  # GET /omegas/new
  # GET /omegas/new.xml
  def new
    @omega = Omega.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @omega }
    end
  end

  # GET /omegas/1/edit
  def edit
    @omega = Omega.find(params[:id])
  end

  # POST /omegas
  # POST /omegas.xml
  def create
    @omega = Omega.new(params[:omega])

    respond_to do |format|
      if @omega.save
        flash[:notice] = 'Omega was successfully created.'
        format.html { redirect_to(@omega) }
        format.xml  { render :xml => @omega, :status => :created, :location => @omega }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @omega.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /omegas/1
  # PUT /omegas/1.xml
  def update
    @omega = Omega.find(params[:id])

    respond_to do |format|
      if @omega.update_attributes(params[:omega])
        flash[:notice] = 'Omega was successfully updated.'
        format.html { redirect_to(@omega) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @omega.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /omegas/1
  # DELETE /omegas/1.xml
  def destroy
    @omega = Omega.find(params[:id])
    @omega.destroy

    respond_to do |format|
      format.html { redirect_to(omegas_url) }
      format.xml  { head :ok }
    end
  end
end
