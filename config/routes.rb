Rails.application.routes.draw do
  root 'base#top'

  get 'comp/index'

  get 'portfolio/index'
  post 'portfolio/show_projects'
  post 'portfolio/select_function'
  post 'portfolio/ticket_digestion'
  get 'portfolio/productivity_info'
  get 'portfolio/productivity'

  get 'base/top'
  get 'base/setting'

  get 'datasamples/index'
  get 'comments_counter/index'
  get 'commit_counter/index'

  get 'projects/select_developer'
  post 'projects/select_developer'
  post 'projects/auth_github'


  resources :projects do
    get '/authen_git' => 'authen_git#index'
    get '/authen_red' => 'authen_red#index'
  end
  resources :developers
  resources :ticket_repositories
  resources :version_repositories
  resources :redmine_keys
  resources :users
end
