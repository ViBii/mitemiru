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
  post 'projects/confirm'

  resources :projects do
    get '/authen_git' => 'projects#authen_git'
    get '/authen_red' => 'projects#authen_red'
    get '/add_git' => 'projects#add_git'
    get '/add_red' => 'projects#add_red'
  end

  devise_for :users

  resources :developers
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
