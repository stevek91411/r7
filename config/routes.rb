R7::Application.routes.draw do
  resources :high_scores
 resources :worksheets

  resources :class_assignments

  resources :student_assignments

  resources :assignments

  resources :op_timers

  resources :schools

  resources :class_lists

  resources :teachers

  resources :gift_certs

  resources :discount_codes

  resources :agcommisions

  resources :commisions

  resources :agents

  resources :admins

  resources :parents

  resources :weekly_activity_summaries

  resources :topic_run_results

  resources :topic_activity_summaries
  resources :students
  resources :topics
  resources :users
  resource :session
resources :users
resource :session  
  
  match  'createFamilyAccount', :to => 'users#createFamilyAccount'
match  'signup2', :to => 'users#new'
match  'login', :to => 'sessions#new'
match  'logout', :to => 'sessions#destroy'
match  'activateParentAccount', :to => 'sessions#activateParentAccount'
match  'resendActivationCode', :to => 'sessions#resendActivationCode'
match  'contactUs', :to => 'sessions#contactUs'
match  'logClientError', :to => 'sessions#logClientError'
match  'forgottenPassword', :to => 'sessions#forgottenPassword'
match  'getAllStudentLoginData', :to => 'sessions#getAllStudentLoginData'

match  'checkForExistingSession', :to => 'sessions#new'
match  'updateStudent', :to => 'students#update'
match  'updateStudentStatus', :to => 'students#updateStatus'
match  'changePassword', :to => 'users#changePassword'
match  'updateParent', :to => 'parents#update'
match  'updateUserStatus', :to => 'users#updateStatus'

#match 'logout', :to => 'sessions#destroy', :as => "logout"

match 'getFotdFile', :to => 'sessions#getFotdFile'

# Admin routes
match  'getStudents', :to => 'admins#getStudents'
match  'getParents', :to => 'admins#getParents'
match  'deleteParent', :to => 'admins#deleteParent'
match  'coaxParent', :to => 'admins#coaxParent'
match  'activateParent', :to => 'admins#activateParent'
match  'createSchool', :to => 'admins#createSchool'
    

# Agent routes
match  'getAgentParents', :to => 'agents#getAgentParents'
match  'getAgents', :to => 'agents#getAgents'
match  'updateAgent', :to => 'agents#update'

#teacher routes
match  'deleteTeacher', :to => 'teachers#deleteTeacher'
match  'updateTeacher', :to => 'teachers#updateTeacher'
match  'addTeacher', :to => 'teachers#addTeacher'
match  'getTeachers', :to => 'teachers#getTeachers'
match  'getStudentsForClass', :to => 'teachers#getStudentsForClass'
match  'addStudentForSchool', :to => 'teachers#addStudentForSchool'
match  'getWeeklyActivityForClass', :to => 'teachers#getWeeklyActivityForClass'
match  'deleteStudent', :to => 'teachers#deleteStudent'

match  'updateClass', :to => 'class_lists#updateClass'
match  'deleteClass', :to => 'class_lists#deleteClass'
match  'addClass', :to => 'class_lists#addClass'

#assignments
match  'getStudentsForClassAssignment', :to => 'student_assignments#getStudentsForClassAssignment'


match  'updateSchool', :to => 'schools#updateSchool'


#Agcommision routes
match  'getAgentCommisions', :to => 'Agcommisions#getAgentCommisions'
match  'updateCommision', :to => 'agcommisions#updateCommision'
match  'addCommisionFromSubagent', :to => 'agcommisions#addCommisionFromSubagent'

#gift_cert routes
match  'redeem', :to => 'gift_certs#redeem'


  match ':controller(/:action(/:id(.:format)))'

  match '/test' => 'high_scores#test', :as => :test

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
