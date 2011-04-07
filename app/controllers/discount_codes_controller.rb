class DiscountCodesController < ApplicationController

  skip_before_filter :login_required

  # GET /discount_codes/1
  # GET /discount_codes/1.xml
  # note does not use the ID value, searches by the code value
  def show
    discount_code = DiscountCode.find_by_code(params[:code])
    respond_to do |format|
    	if discount_code != nil 
      		format.xml  { render :xml => discount_code }
      	else
      		format.xml  { render :xml => errorRsp( "invalid response code") }
      	end
    end
  end

end
