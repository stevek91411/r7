class OpTimersController < ApplicationController

  # GET /op_timers
  # GET /op_timers.xml
  def index
   
      if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
       log_error session[:user_type] + " user type found in Agent request to getAgents"    
	   return
  	  end
  	   
      begin
        @op_timers = OpTimer.find_by_sql( "select *  from op_timers where " + 
                                    "op_timers.id < #{params[:id]} and op_timers.op_name like '%#{params[:opName]}%'" +
                                    " order by op_timers.id desc limit 75 " )
      rescue Exception => e  
        log_exception "Error looking for op_timers", e
        respond_to do |format|
          format.xml  { render :xml => errorRsp( e.message) }
        end
        return
      end
       
      respond_to do |format|
        format.xml  { render :xml => @op_timers, :dasherize => false }
      end
  end
  

  # GET /op_timers/1
  # GET /op_timers/1.xml
  def show
    @op_timer = OpTimer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @op_timer, :dasherize => false }
    end
  end

  # GET /op_timers/new
  # GET /op_timers/new.xml
  def new
    @op_timer = OpTimer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @op_timer, :dasherize => false }
    end
  end

  # GET /op_timers/1/edit
  def edit
    @op_timer = OpTimer.find(params[:id])
  end

  # POST /op_timers
  # POST /op_timers.xml
  def create
    @op_timer = OpTimer.new(params[:op_timer])

    respond_to do |format|
      if @op_timer.save
          	format.xml { render :xml =>  @op_timer }
      else
           format.xml { render :xml =>  log_DB_errors(  "op_timer", @op_timer.errors ) }
      end
    end
  end

  # PUT /op_timers/1
  # PUT /op_timers/1.xml
  def update
    @op_timer = OpTimer.find(params[:id])

    respond_to do |format|
      if @op_timer.update_attributes(params[:op_timer])
        flash[:notice] = 'OpTimer was successfully updated.'
        format.html { redirect_to(@op_timer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @op_timer.errors, :status => :unprocessable_entity }
      end
    end
  end

  
end
