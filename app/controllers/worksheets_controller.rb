class WorksheetsController < ApplicationController
 
  before_filter :login_required

  # GET /worksheets/1
  # GET /worksheets/1.xml
  def show
 
     if session[:user_type] != "teacher-tx"  && session[:user_type] != "parent" # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	 end 
  
	@worksheet = 
           Worksheet.find_all_by_user_id( params[:id], :order => "created_at")
    respond_to do |format|
      format.xml  { render :xml => @worksheet }
    end
  end



  # POST /worksheets
  # POST /worksheets.xml
  def create
 
     if session[:user_type] != "teacher-tx" && session[:user_type] != "parent"  # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	 end
  	 
    @worksheet = Worksheet.new(params[:worksheet])

    respond_to do |format|
      if @worksheet.save
          	format.xml { render :xml =>  @worksheet }
      else
           format.xml { render :xml =>  log_DB_errors(  "worksheet", @worksheet.errors ) }
      end
    end
  end

  # PUT /worksheets/1
  # PUT /worksheets/1.xml
  def update
 
      if session[:user_type] != "teacher-tx"  && session[:user_type] != "parent" # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	 end
  	 
    @worksheet = Worksheet.find(params[:id])

    respond_to do |format|
      if @worksheet.update_attributes(params[:worksheet])
        	format.xml  { render :xml => successRsp( "", "" ) } 
      else
        format.xml { render :xml =>  log_DB_errors(  "worksheet", @worksheet.errors ) }
      end
    end
  end

  # DELETE /worksheets/1
  # DELETE /worksheets/1.xml
  def destroy
 
    if session[:user_type] != "teacher-tx" && session[:user_type] != "parent" # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	end
  	 
    @worksheet = Worksheet.find(params[:id])
    @worksheet.destroy

    respond_to do |format|
      format.xml  { head :ok }
    end
  end
end
