class Student < ActiveRecord::Base
    
    has_many :topic_run_results
 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login,  :class_id, :parent_id, :gender,  :first_name, :last_name, :dob, :first_registered, :grade, :weekly_target_in_mins  
end
