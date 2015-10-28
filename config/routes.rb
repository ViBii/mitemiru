Rails.application.routes.draw do
  root 'portfolio#top'

  get 'portfolio/setting'
  post 'portfolio/index'
  post 'portfolio/show_projects'

  get 'portfolio/productivity_info'
  post 'portfolio/ticket_digestion_ajax'
  post 'portfolio/productivity_ajax'
  post 'portfolio/commits_ajax'
  post 'portfolio/comments_ajax'

  get 'datasamples/index'

  post 'projects/add_github_in_DB'
  post 'projects/add_redmine_in_DB'
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
