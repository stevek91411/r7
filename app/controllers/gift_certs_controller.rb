class GiftCertsController < ApplicationController

  skip_before_filter :login_required


 # GET /gift_certs/1
  # GET /gift_certs/1.xml
  # note does not use the ID value, searches by the activiation_code 
  def show
    giftCert = GiftCert.find_by_activiation_code(params[:code])

    respond_to do |format|
    	if giftCert != nil 
      		format.xml  { render :xml => giftCert }
      	else
      		format.xml  { render :xml => errorRsp( "invalid activiation code") }
      	end
    end
  end


  # GET /gift_certs/new
  # GET /gift_certs/new.xml
  def new
    @gift_cert = GiftCert.new
    
    respond_to do |format|
      format.xml  { render :xml => @gift_cert }
    end
  end

  # POST /gift_certs
  # POST /gift_certs.xml
  def create
		@gift_cert = GiftCert.new(params[:gift_cert])
    	@gift_cert.status = "Not activiated" 

        if  allowSendEmail  
          # notify stevek that a new student account was created           
          Mymailer.deliver_giftCert( "stevek91411@yahoo.com", @gift_cert.purchaser_name, @gift_cert.activiation_code, 
                           @gift_cert.status,  "New Gift certificate:" )
          Mymailer.deliver_giftCert( "8182617590@txt.att.net", @gift_cert.purchaser_name, @gift_cert.activiation_code, 
                           @gift_cert.status,  "New Gift certificate: step1" )         
        end
         
    	respond_to do |format|
      		if @gift_cert.save
        		format.xml  { render :xml => @gift_cert }
      		else
        		format.xml { render :xml =>  log_DB_errors(  "GiftCert", @gift_cert.errors ) }
      		end
    	end
  end

  # GET /redeem
  def redeem 

    gift_cert = GiftCert.find_by_activiation_code(params[:gift_cert][:activiation_code])
    
        if  allowSendEmail  
          # notify stevek that a new student account was created
         Mymailer.deliver_giftCert( "stevek91411@yahoo.com", gift_cert.purchaser_name, gift_cert.activiation_code, 
                           params[:gift_cert][:status],  "Update Gift certificate status to " +  params[:gift_cert][:status] )
         Mymailer.deliver_giftCert( "8182617590@txt.att.net", gift_cert.purchaser_name, gift_cert.activiation_code, 
                           params[:gift_cert][:status],  "Update Gift certificate status to " +  params[:gift_cert][:status] )
         end
         
    respond_to do |format|
      if gift_cert.update_attributes(params[:gift_cert])
        format.xml  { render :xml => gift_cert }
      else
        format.xml { render :xml =>  log_DB_errors(  "GiftCert", gift_cert.errors ) }
      end
    end
  end

  # DELETE /gift_certs/1
  # DELETE /gift_certs/1.xml
  def destroy
    @gift_cert = GiftCert.find(params[:id])
    @gift_cert.destroy

    respond_to do |format|
      format.html { redirect_to(gift_certs_url) }
      format.xml  { head :ok }
    end
  end
end
