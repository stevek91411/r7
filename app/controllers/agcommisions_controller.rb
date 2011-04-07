class AgcommisionsController < ApplicationController

  before_filter :login_required

  # GET /agcommisions
  # GET /agcommisions.xml
  def index
  
	   return  # not currently used
	  
    @agcommisions = Agcommision.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agcommisions }
    end
  end


def addCommisionFromSubagent

	if session[:user_type] != "admin-mx"   # basic security trap
	   return
  	end
	
		## first load the super agent
  	    agent = Agent.find_by_id( params[:agcommision][:superagent_id]  )
  	    
  	    if agent == nil 
  	    	respond_to do |format|
    	  		format.xml  { render :xml => errorRsp ( "Super agent " + params[:agcommision][:superagent_id] + " not found"  ) }
          		log_message ( "Super agent " + params[:agcommision][:superagent_id] + " not found" )
    		end
     	  	return
    	end
    	    	
  	  	@commisions = Agcommision.new(  )
		@commisions.commision_type = "agent"
		@commisions.party_id = params[:agcommision][:party_id]                 
		@commisions.party_login = params[:agcommision][:party_login]                 
		@commisions.party_name =  params[:agcommision][:party_name]                 
		@commisions.party_status ="toPay"
		@commisions.party_payment_date = params[:agcommision][:party_payment_date]
		@commisions.party_payment_amount_cents = params[:agcommision][:party_payment_amount_cents]
		@commisions.superagent_id = agent.superagent_id
		   
		@commisions.agent_name = agent.first_name + " " + agent.last_name
	 	@commisions.agent_id = agent.id  
	 	@commisions.agent_login = agent.login 
	 	@commisions.agent_payment_method = agent.payment_method      		 	
		@commisions.commision_percentage = agent.subagent_commision_percentage 
		@commisions.commision_cents = ( agent.subagent_commision_percentage.to_i * @commisions.party_payment_amount_cents.to_i )/100
   		@commisions.save
           			               
     respond_to do |format|	    
		format.xml { render :xml =>  successRsp ( "SuperAgent commision saved"  )  }
      end	     
end



 # GET getAgentCommisions
  def getAgentCommisions      

	if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	    
    query_string = ""
    
    if params[:party_status] != "all"  # the status of the agent or parent, e.g firstMonth, toPay, Paid
    	query_string = query_string + " and party_status = '" + params[:party_status] + "' "
    end
    
    if params[:commision_type] != "all"  # either agent or parent
    	query_string = query_string + " and commision_type = '" + params[:commision_type] + "' "
     end    

    if params[:agent_login] != "all"	# load commisions for a specific agent
    	query_string = query_string + " and agent_login = '" + params[:agent_login] + "' "
    end
    
	begin       
    	@agcommisions = Agcommision.find_by_sql( "select agcommisions.*, agents.address1, agents.address1, 
    	                                              agents.address2, agents.city, agents.state,agents.zipcode 
    	                                              from agcommisions, agents where  
    	                                              agcommisions.agent_id = agents.id " +  query_string  +
                                    " order by party_login desc limit 100 " )
                                    
    rescue Exception => e  
      log_exception "Error looking for agcommisions", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
    
    respond_to do |format|
      format.xml  { render :xml => @agcommisions }
    end
  end
  
  
  # GET /agcommisions/1
  # GET /agcommisions/1.xml
  def show

	   return  # not currently used
  
  	if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	
  	
    @agcommision = Agcommision.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agcommision }
    end
  end

  # GET /agcommisions/new
  # GET /agcommisions/new.xml
  def new
  
	return  # not currently used

  	
    @agcommision = Agcommision.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agcommision }
    end
  end

  # GET /agcommisions/1/edit
  def edit
  
   return  # not currently used


    @agcommision = Agcommision.find(params[:id])
  end

  # POST /agcommisions
  # POST /agcommisions.xml
  def create
  
  	if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	
    @agcommision = Agcommision.new(params[:agcommision])

    respond_to do |format|
      if @agcommision.save
        format.xml  { render :xml => @agcommision, :status => :created, :location => @agcommision }
      else
        format.xml  { render :xml => @agcommision.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /updateCommision
  def updateCommision
  
    if session[:user_type] != "admin-mx" # basic security trap
	   return
  	end
  	  
    @agcommision = Agcommision.find(params[:agcommision][:id])

    respond_to do |format|
      if @agcommision.update_attributes(params[:agcommision])
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @agcommision.errors, :status => :unprocessable_entity }
      end
    end
  end



  # DELETE /agcommisions/1
  # DELETE /agcommisions/1.xml
  def destroy
  
	   return  # not currently used
  	
  	
    @agcommision = Agcommision.find(params[:id])
    @agcommision.destroy

    respond_to do |format|
      format.html { redirect_to(agcommisions_url) }
      format.xml  { head :ok }
    end
  end
end
