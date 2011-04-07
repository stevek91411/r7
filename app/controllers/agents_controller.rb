class AgentsController < ApplicationController
 
     before_filter :login_required
 
 # GET getAgents
  def getAgents 
 
      if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
       log_error session[:user_type] + " user type found in Agent request to getAgents"    
	   return
  	  end
  	       
  	  if session[:user_type] == "agent"
  	    restrict_to_agent = " agents.superagent_id = '#{session[:session_user_id]}' and "
  	  end
  	  
  	  if session[:user_type] == "admin-mx"
  	    restrict_to_agent = ""
  	  end 
  	  
      begin
        @agents = Agent.find_by_sql( "select agents.*, users.status, users.crypted_password from agents, users where " + 
                                    "users.id = agents.id and " + restrict_to_agent +
                                    "users.status like '%#{params[:status]}%' and " +
                                    "agents.#{params[:search_by_field]} like '%#{params[:value]}%'" +
                                    " order by agents.registered desc limit 100 " )
    rescue Exception => e  
      log_exception "Error looking for Agents", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @agents }
    end
  end
   
  # GET getParents
  def getAgentParents  
 
      if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
       log_error session[:user_type] + " user type found in Agent request to getAgentParents"    
	   return
  	  end

      @agent = Agent.find(params[:id])

	  # check that the issuer of the request has both the username and ID, prevent attack
    	if params[:login].gsub(/ /,'') != @agent.login.gsub(/ /,'')
    		log_attack "agent show " + params[:id] + " : " + params[:login]  + " - agent.login = " + @agent.login 	
      		respond_to do |format|
        		format.xml  { render :xml => errorRsp( "Security error, contact support" ) }
     		 end
    		return
    	end  
    	
    	 	  
      begin     
        @parents = Parent.find_by_sql( "select parents.*, users.status from parents, users where " + 
                                    "users.id = parents.id and " +
                                    "users.status like '%#{params[:status]}%' and " +
                                    " parents.discount_code = '#{params[:agent_code]}' " +
                                    " order by parents.first_registered desc limit 100 " )
    rescue Exception => e  
      log_exception "Error looking for agents", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @parents }
    end
  end
 

  def findAgent

    if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	  
  	  
    @agent = Agent.find_by_(params[:user][:id])

   respond_to do |format|
      if @user.update_attributes(params[:agent])
        format.xml  { render :xml => successRsp }
      else
        format.xml  { render :xml => errorRsp( @user.errors.to_s ) }
      end
    end
  end
  
  

  # GET /agents/1
  # GET /agents/1.xml
  def show

    if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	  
    @agent = Agent.find(params[:id])


	# check that the issuer of the request has both the username and ID, prevent attack
    	if params[:login].gsub(/ /,'') != @agent.login.gsub(/ /,'')
    	log_attack "agent show " + params[:id] + " : " + params[:login]  + " - agent.login = " + @agent.login 	
      		respond_to do |format|
        		format.xml  { render :xml => errorRsp( "Security error, contact support" ) }
     		 end
    		return
    	end  
    	
    	
    respond_to do |format|
      format.xml  { render :xml => @agent }
    end
  end



  # POST /agents
  # POST /agents.xml
  def create

    if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	
    @agent = Agent.new(params[:agent])

    respond_to do |format|
      if @agent.save
        flash[:notice] = 'Agent was successfully created.'
        format.html { redirect_to(@agent) }
        format.xml  { render :xml => @agent, :status => :created, :location => @agent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agents/1
  # PUT /agents/1.xml
  def update
 
    if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	   return
  	end
  	  
    @agent = Agent.find(params[:agent][:id])

    respond_to do |format|
      if @agent.update_attributes(params[:agent])
      
       	# update the discount code
        discount_code = DiscountCode.find_by_code(params[:agent][:agent_code])
        if discount_code == nil 
          		log_message ( "Could not update discount code, agent ID = " + params[:agcommision][:id] + "  code = " + params[:agent][:agent_code] )
    	else
      		discount_code.agent_membership_discount =  @agent.membership_discount
      		discount_code.save()
      	end	
      	
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
      end
    end
  end

end
