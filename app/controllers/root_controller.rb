class RootController < ApplicationController

  def index
    @alpha = Alpha.all
    @beta = Beta.all
    @omega = Omega.all
  end

end