class Topic < ActiveRecord::Base
  
  validates_presence_of :no_of_problems, :no_of_rows, :no_of_cols
  validates_length_of :display_label, :within => 4..20
  validates_length_of :problem_generator_class, :within => 3..40
  
end
