class WeeklyActivitySummariesController < ApplicationController

     before_filter :login_required


  # GET /weekly_activity_summaries/1
  # GET /weekly_activity_summaries/1.xml  where 1 = studentID
  # return all the  WeeklyActivitySummaries 
  # if :today is specified and there is no record for this week. then create one
  def show
     
     if  params[:today] != "" 
       # the client provides todays date to avoid timezone errors
       clientDate = Time.parse( params[:today])
       week = clientDate.strftime("%U").to_i        # the current week, 1 - 51
       year = clientDate.strftime("%y").to_i        # this year
                 
      # determine first day of week   ( sunday )            
      day_of_week = clientDate.strftime("%w")        # 0 - 6   
      start_of_week = clientDate - day_of_week.to_i.days
  
      # check if a WeeklyActivitySummary already exists for this week, if not create one
      begin
         @weekly_activity_summary = 
            WeeklyActivitySummary.find_by_student_id_and_week_and_year(params[:id], week, year )
      rescue Exception => e  
        log_exception "Error looking for WeeklyActivitySummary :student_id = #{params[:id]}", e
        respond_to do |format|
          format.xml  { render :xml => errorRsp( e.message) }
        end
        return
      end
      
      if @weekly_activity_summary == nil 
          # no record found, create a new one
          @weekly_activity_summary = WeeklyActivitySummary.new do |t|
             t.student_id = params[:id]     
             t.week =  week 
             t.year =  year
             t.start_of_week = start_of_week
          end 
         
          # now save the record
          if !@weekly_activity_summary.save
             log_message "Not saved #{@weekly_activity_summary}"
              respond_to do |format|
                  format.xml  { render :xml => errorRsp( @weekly_activity_summary.errors.to_s ) }
              end
              return
          end       
       end
    end
    
    
    # now, return all summaries, upto a max of 50
    begin
       @weekly_activity_summaries = 
          WeeklyActivitySummary.find_all_by_student_id(params[:id], :order=> 'start_of_week' )
    rescue Exception => e  
      log_exception "Error looking for WeeklyActivitySummary :student_id = #{params[:id]}", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
     # noting fatal happened return the record
    respond_to do |format|
        format.xml  { render :xml => @weekly_activity_summaries, :dasherize => false }
    end
  end
  

  # POST /weekly_activity_summaries
  # POST /weekly_activity_summaries.xml
  def create
    @weekly_activity_summary = WeeklyActivitySummary.new(params[:weekly_activity_summary])

    respond_to do |format|
      if @weekly_activity_summary.save
        format.xml  { render :xml => @weekly_activity_summary, :status => :created, :location => @weekly_activity_summary }
      else
        format.xml  { render :xml => @weekly_activity_summary.errors, :status => :unprocessable_entity }
      end
    end
  end

  
end
