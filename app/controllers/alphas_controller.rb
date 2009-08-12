class AlphasController < ApplicationController
  # GET /alphas
  # GET /alphas.xml
  def index
    @breadcrumbs = breadcrumbs(request.url)
    @alpha = collect_nav_results
  end

  # GET /alphas/1
  # GET /alphas/1.xml
  def show
    @alpha = Alpha.find(params[:id])
    breadcrumbs(request.url, @alpha.id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alpha }
    end
  end

  # GET /alphas/new
  # GET /alphas/new.xml
  def new
    @alpha = Alpha.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alpha }
    end
  end

  # GET /alphas/1/edit
  def edit
    @alpha = Alpha.find(params[:id])
  end

  # POST /alphas
  # POST /alphas.xml
  def create
    @alpha = Alpha.new(params[:alpha])

    respond_to do |format|
      if @alpha.save
        flash[:notice] = 'Alpha was successfully created.'
        format.html { redirect_to(@alpha) }
        format.xml  { render :xml => @alpha, :status => :created, :location => @alpha }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alpha.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alphas/1
  # PUT /alphas/1.xml
  def update
    @alpha = Alpha.find(params[:id])

    respond_to do |format|
      if @alpha.update_attributes(params[:alpha])
        flash[:notice] = 'Alpha was successfully updated.'
        format.html { redirect_to(@alpha) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alpha.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alphas/1
  # DELETE /alphas/1.xml
  def destroy
    @alpha = Alpha.find(params[:id])
    @alpha.destroy

    respond_to do |format|
      format.html { redirect_to(alphas_url) }
      format.xml  { head :ok }
    end
  end
end
