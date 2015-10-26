Rails.application.routes.draw do
  root 'portfolio#top'

  get 'portfolio/top'
  get 'portfolio/setting'
  get 'portfolio/index'
  post 'portfolio/show_projects'
  post 'portfolio/select_function'
  post 'portfolio/ticket_digestion'
  post 'portfolio/ticket_digestion_ajax'
  get 'portfolio/productivity_info'
  get 'portfolio/productivity'
  post 'portfolio/productivity_ajax'
  post 'portfolio/commits_ajax'
  post 'portfolio/comments_ajax'

  get 'datasamples/index'
  get 'comments_counter/index'
  post 'comments_counter/comments_ajax'
  get 'commit_counter/index'
  post 'commit_counter/commits_ajax'

  post 'projects/confirm'

  resources :projects do
    get '/authen_github' => 'projects#authen_github'
    get '/authen_redmine' => 'projects#authen_redmine'
    get '/add_github' => 'projects#add_github'
    get '/add_redmine' => 'projects#add_redmine'
  end

  devise_for :users

  resources :developers
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
