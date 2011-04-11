class TopicRunResultsController < ApplicationController
  
  before_filter :login_required

  # GET /topic_run_results/1
  # GET /topic_run_results/1.xml  where 1 = studentID
  # results sets can be 
  #    1. :topic_id and :Grade specified - get all results for the student for the <topicId : grade>
  #    2. :date_recorded specified - get all results ( for all topics and grades ) for a specified date 

  def show
   
       begin
         if  params[:topic_id] != nil
           @topic_run_results = TopicRunResult.find_all_by_student_id_and_topic_id_and_grade(params[:id], params[:topic_id], params[:grade], :order=> 'date_recorded' )
         else if params[:date_recorded] != nil
                @topic_run_results = TopicRunResult.find_all_by_student_id_and_date_recorded(params[:id], params[:date_recorded], :order=> 'date_recorded' )
              end
         end
     
      rescue Exception => e  
        log_exception "Error looking for TopicRunResult :student_id = #{parms[:id]}, topic_id = #(params[:topic_id]}", e
        respond_to do |format|
          format.xml  { render :xml => errorRsp( e.message) }
        end
        return
      end
    
    respond_to do |format|
      format.xml  { render :xml => @topic_run_results, :dasherize => false }
    end
  end

  # POST /topic_run_results
  # POST /topic_run_results.xml
  def create
    
    begin
      @topic_run_result = TopicRunResult.create(params[:topic_run_result])
    rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
  end
 
    #-----------------------------------------------------------------------------------------------
    # update or create the corresponding WeeklyActivitySummary
    # first check if one exists for this month
    # the client provides todays date to avoid timezone errors 
     clientDate = Time.parse( params[:topic_run_result][:date_recorded])    
     week = clientDate.strftime("%U").to_i        # the current week, 1 - 51
     year = clientDate.strftime("%y").to_i        # this year

    begin
       @weekly_activity_summary = 
          WeeklyActivitySummary.find_by_student_id_and_week_and_year(@topic_run_result.student_id, 
                                                              week, year )
    rescue Exception => e  
      log_exception "Error looking for WeeklyActivitySummary :student_id = #{@topic_run_result.student_id} , :topic_id = #{@topic_run_result.topic_id}", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
    if @weekly_activity_summary == nil 
        # no record found, create a new one
         @weekly_activity_summary = WeeklyActivitySummary.new do |t|
           t.student_id = @topic_run_result.student_id     
           t.week =  week 
           t.year =  year
       end 
     end
     
     # update the total for today. Note using Ruby reflection here. Want to execute, e.g
     # @weekly_activity_summary.day5 = @weekly_activity_summary.day5 + seconds_to_complete
     get_day_field = "day#{clientDate.strftime("%w").to_i + 1}"           # gives day of week 1 - 7  
     current_value = @weekly_activity_summary.send( get_day_field )
     
     set_day_field = "day#{clientDate.strftime("%w").to_i +  1 }="      # cteate the assignment message - gives day6=                                                     
     @weekly_activity_summary.send( set_day_field, current_value.to_i + @topic_run_result. seconds_to_complete.to_i )

    # now save the record
    @weekly_activity_summary.save
      
    
    #-----------------------------------------------------------------------------------------------
    # update or  create the corresponding TopicActivitySummary
    # first see if the record exists
    begin
       @topic_activity_summary = 
          TopicActivitySummary.find_by_student_id_and_topic_id_and_grade(@topic_run_result.student_id, 
                                                               @topic_run_result.topic_id,
                                                               @topic_run_result.grade )
    rescue Exception => e  
      log_exception "Error looking for TopicActivitySummary :student_id = #{@topic_run_result.student_id} , :topic_id = #{@topic_run_result.topic_id}", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
      if @topic_activity_summary == nil 
        # no record found
         @topic_activity_summary = TopicActivitySummary.new do |t|
           t.student_id = @topic_run_result.student_id     
           t.topic_id =  @topic_run_result.topic_id
           t.grade = @topic_run_result.grade
       end 
      end
    
      # update the topic summary
      @topic_activity_summary.total_problems_correct += @topic_run_result.problems_correct
      @topic_activity_summary.total_problems_wrong += @topic_run_result.problems_wrong
      @topic_activity_summary.total_time_in_sec += @topic_run_result.seconds_to_complete
      
      if @topic_run_result.incomplete
        @topic_activity_summary.total_incomplete_runs += 1
      else
          # a complete run, 
          @topic_activity_summary.total_complete_runs += 1
          @topic_activity_summary.total_complete_only_time_in_sec += @topic_run_result.seconds_to_complete

          # update the list of result summaries-- percent_correct:xx seconds_to_complete:yy help_count:zz
          @topic_activity_summary.result_summary_5 = @topic_activity_summary.result_summary_4
          @topic_activity_summary.result_summary_4 = @topic_activity_summary.result_summary_3
          @topic_activity_summary.result_summary_3 = @topic_activity_summary.result_summary_2
          @topic_activity_summary.result_summary_2 = @topic_activity_summary.result_summary_1
          
          # cal below uses @topic_run_result.problems_correct*10 to get aound some ounding errors
          percent_correct = ( @topic_run_result.problems_correct*10 / @topic_run_result.total_problems )*10
          
          @topic_activity_summary.result_summary_1 = "percent_correct:" + percent_correct.to_s + 
                                                     " seconds_to_complete:" +  @topic_run_result.seconds_to_complete.to_s +  
                                                     " help_count:" + @topic_run_result.help_count.to_s
                           

         # check for a best time, run with none  wrong
          if @topic_run_result.problems_wrong.to_i == 0
            if @topic_run_result.seconds_to_complete < @topic_activity_summary.best_time_in_sec ||
                @topic_activity_summary.best_time_in_sec == -1   # no best time yet set
               @topic_activity_summary.best_time_in_sec = @topic_run_result.seconds_to_complete
            end
        end   
      end

    @topic_activity_summary.save
         
    # noting fatal happened with the 'new'
    respond_to do |format|
      if @topic_run_result.save
        format.xml  { render :xml => @weekly_activity_summary, :dasherize => false }   # retun the updated weekly_activity_summary
      else
        format.xml  { render :xml => errorRsp( @topic_run_result.errors.to_s ) }
      end
    end
  end


  # Add 2 seconds values, note :  a value -1 means value was not set
  def addSeconds time_in_sec_1, time_in_sec_2
    
    if time_in_sec_1 == -1 
      return time_in_sec_2 
    end
    if time_in_sec_2 == -1 
      return time_in_sec_1 
   end
 
    return time_in_sec_1.to_i + time_in_sec_2.to_i
  end
    

  # PUT /topic_run_results/1
  # PUT /topic_run_results/1.xml
  def update
    @topic_run_result = TopicRunResult.find(params[:id])

    respond_to do |format|
      if @topic_run_result.update_attributes(params[:topic_run_result])
        flash[:notice] = 'TopicRunResult was successfully updated.'
        format.html { redirect_to(@topic_run_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic_run_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topic_run_results/1
  # DELETE /topic_run_results/1.xml
  def destroy
    @topic_run_result = TopicRunResult.find(params[:id])
    @topic_run_result.destroy

    respond_to do |format|
      format.html { redirect_to(topic_run_results_url) }
      format.xml  { head :ok }
    end
  end
end
