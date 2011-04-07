# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110403001450) do

  create_table "admins", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agcommisions", :force => true do |t|
    t.integer  "commision_percentage",       :default => 0
    t.string   "commision_type"
    t.integer  "commision_cents",            :default => 0
    t.string   "agent_payment_method"
    t.date     "agent_payment_date"
    t.string   "agent_payment_detail"
    t.string   "agent_name"
    t.string   "agent_id"
    t.string   "agent_login"
    t.integer  "superagent_id"
    t.string   "party_status",               :default => "?"
    t.date     "party_payment_date"
    t.integer  "party_id"
    t.string   "party_login"
    t.string   "party_name"
    t.integer  "party_payment_amount_cents", :default => 0
    t.date     "parent_membership_expires"
    t.date     "parent_first_month_expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agents", :force => true do |t|
    t.string   "login"
    t.string   "first_name",                    :limit => 80
    t.string   "last_name",                     :limit => 80
    t.string   "address1",                      :limit => 80
    t.string   "address2",                      :limit => 80
    t.string   "city",                          :limit => 80
    t.string   "state",                         :limit => 80
    t.string   "zipcode",                       :limit => 8
    t.string   "email"
    t.string   "telephone_home"
    t.string   "telephone_cell"
    t.string   "payment_method"
    t.date     "registered"
    t.string   "agent_code",                                  :default => "?"
    t.integer  "membership_discount",                         :default => 0
    t.integer  "parent_commision_percentage",                 :default => 0
    t.integer  "subagent_commision_percentage",               :default => 0
    t.integer  "superagent_id"
    t.string   "superagent_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "class_assignments", :force => true do |t|
    t.integer  "assigned_by"
    t.integer  "assignment_id"
    t.string   "worksheet_name"
    t.string   "assignment_grade"
    t.string   "assignment_class_id"
    t.string   "school_id"
    t.date     "assigned_on"
    t.date     "due"
    t.string   "status"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "class_lists", :force => true do |t|
    t.string   "school_id"
    t.string   "grade"
    t.string   "class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commisions", :force => true do |t|
  end

  create_table "discount_codes", :force => true do |t|
    t.string   "code",                      :default => "?"
    t.string   "party_type",                :default => "?"
    t.integer  "party_id"
    t.string   "party_login"
    t.integer  "agent_membership_discount", :default => 0
    t.integer  "parent_membership_price",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gift_certs", :force => true do |t|
    t.string   "status",                              :default => "Not activiated"
    t.string   "activiation_code",      :limit => 80
    t.string   "email"
    t.string   "purchaser_name",        :limit => 80
    t.string   "to",                    :limit => 80
    t.string   "from",                  :limit => 80
    t.string   "message"
    t.integer  "cost_in_dollars",                     :default => 0
    t.datetime "purchace_date"
    t.datetime "activiation_date"
    t.integer  "activiation_user_id"
    t.string   "activiation_user_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "high_scores", :force => true do |t|
    t.string   "game"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "player"
  end

  create_table "op_timers", :force => true do |t|
    t.string   "op_name"
    t.string   "start_data"
    t.string   "end_data"
    t.string   "status"
    t.integer  "duration"
    t.string   "check_points"
    t.string   "start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parents", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "first_name",                :limit => 80
    t.string   "last_name",                 :limit => 80
    t.integer  "max_no_of_active_students",               :default => 2
    t.date     "first_registered"
    t.date     "last_payment"
    t.date     "membership_expires"
    t.integer  "payment_amount",                          :default => 0
    t.string   "payment_plan",                            :default => "?"
    t.string   "register_type",                           :default => "pp"
    t.string   "discount_code",                           :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", :force => true do |t|
    t.string   "school_id"
    t.string   "contact"
    t.string   "email"
    t.string   "telephone_home"
    t.string   "telephone_cell"
    t.string   "login_prefix"
    t.string   "student_password"
    t.integer  "max_students"
    t.integer  "enrolled_students"
    t.string   "status"
    t.date     "membership_expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_assignments", :force => true do |t|
    t.string   "student_login"
    t.integer  "student_id"
    t.string   "student_full_name"
    t.integer  "assigned_by"
    t.integer  "assignment_id"
    t.string   "worksheet_name"
    t.string   "assignment_grade"
    t.string   "assignment_class_id"
    t.string   "class_assignment_id"
    t.string   "school_id"
    t.date     "assigned_on"
    t.date     "due"
    t.string   "status"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :force => true do |t|
    t.string   "login"
    t.integer  "parent_id"
    t.string   "email"
    t.string   "first_name",            :limit => 80
    t.string   "last_name",             :limit => 80
    t.string   "gender"
    t.date     "dob"
    t.date     "first_registered"
    t.string   "grade"
    t.string   "class_id"
    t.integer  "weekly_target_in_mins",               :default => 30
    t.string   "status"
    t.string   "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "admin",                            :default => "no"
    t.string   "first_name",         :limit => 80
    t.string   "last_name",          :limit => 80
    t.string   "school_id"
    t.string   "class_id",                         :default => ""
    t.date     "first_registered"
    t.date     "membership_expires"
    t.string   "telephone_home"
    t.string   "telephone_cell"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_activity_summaries", :force => true do |t|
    t.integer  "student_id"
    t.string   "topic_id"
    t.integer  "total_problems_correct",          :default => 0
    t.integer  "total_problems_wrong",            :default => 0
    t.integer  "total_time_in_sec",               :default => 0
    t.integer  "total_complete_only_time_in_sec", :default => 0
    t.integer  "total_incomplete_runs",           :default => 0
    t.integer  "total_complete_runs",             :default => 0
    t.integer  "best_time_in_sec",                :default => -1
    t.string   "result_summary_1"
    t.string   "result_summary_2"
    t.string   "result_summary_3"
    t.string   "result_summary_4"
    t.string   "result_summary_5"
    t.string   "grade",                           :default => "3"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_run_results", :force => true do |t|
    t.integer  "student_id"
    t.string   "topic_id"
    t.date     "date_recorded"
    t.time     "time_recorded"
    t.integer  "problems_correct"
    t.integer  "problems_wrong"
    t.integer  "total_problems"
    t.integer  "seconds_to_complete"
    t.boolean  "incomplete"
    t.integer  "help_count",          :default => 0
    t.string   "grade",               :default => "3"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "topic_id"
    t.integer  "no_of_problems"
    t.integer  "no_of_rows"
    t.integer  "no_of_cols"
    t.string   "display_label"
    t.string   "full_desciption"
    t.string   "problem_generator_class"
    t.string   "parameters"
    t.integer  "max_time_in_sec"
    t.string   "problem_view_ctl_class"
    t.string   "help_view_ctl_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "user_type"
    t.string   "status"
    t.date     "membership_expires"
  end

  create_table "weekly_activity_summaries", :force => true do |t|
    t.integer  "student_id"
    t.integer  "week"
    t.integer  "year"
    t.date     "start_of_week"
    t.integer  "day1",          :default => 0
    t.integer  "day2",          :default => 0
    t.integer  "day3",          :default => 0
    t.integer  "day4",          :default => 0
    t.integer  "day5",          :default => 0
    t.integer  "day6",          :default => 0
    t.integer  "day7",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worksheets", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "school_id"
    t.string   "grade"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
