Rails.application.routes.draw do
  root 'portfolio#top'

  get 'portfolio/top'
  get 'portfolio/setting'
  get 'portfolio/index'
  post 'portfolio/show_projects'
  post 'portfolio/select_function'
  post 'portfolio/ticket_digestion'
  get 'portfolio/productivity_info'
  get 'portfolio/productivity'
  post 'portfolio/productivity_ajax'

  get 'datasamples/index'
  get 'comments_counter/index'
  get 'commit_counter/index'
  post 'commit_counter/commits_ajax'

  # get 'projects/select_developer'
  # post 'projects/select_developer'
  post 'projects/confirm'

  devise_for :users
  resources :projects
  resources :developers
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
