class ParentsController < ApplicationController

  before_filter :login_required

  # GET /parents/1
  # GET /parents/1.xml
  def show
    @parent = Parent.find(params[:id])

     	# check that the issuer of the request has both the username and ID, prevent attack
    	if params[:login].gsub(/ /,'') != @parent.login.gsub(/ /,'')
    	log_attack "parent show " + params[:id] + " : " + params[:login]  + " - parent.login = " + @parent.login 	
      		respond_to do |format|
        		format.xml  { render :xml => errorRsp( "Security error, contact support" ) }
     		 end
    		return
    	end  
    	
    	
    respond_to do |format|
      format.xml  { render :xml => @parent }
    end
  end
  
  # PUT /parents/1   
  # PUT /parents/1.xml
  def update
    @parent = Parent.find(params[:parent][:id])

 	# check that the issuer of the request has both the username and ID, prevent attack
    if params[:parent][:login].gsub(/ /,'') != @parent.login.gsub(/ /,'')
    	log_attack "Error parent update " + params[:parent][:id] + " : " + params[:parent][:login]  + " - @parent.login = " + @parent.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "Security error" ) }
      end
    	return
    end
      
    respond_to do |format|
      if @parent.update_attributes(params[:parent])
        format.xml  { head :ok }
      else
        log_DB_errors(  "parent", @parent.errors ) 
        format.xml  { render :xml => errorRsp( "Failed to update" ) }
      end
    end
  end
 
  
end
