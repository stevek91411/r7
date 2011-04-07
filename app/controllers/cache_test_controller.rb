class CacheTestController < ApplicationController
   
    skip_before_filter :login_required

  def new

    @msg = 5
  end
  
end
