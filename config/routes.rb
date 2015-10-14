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
  post 'commit_counter/commits_ajax'

  get 'projects/select_developer'
  post 'projects/select_developer'
  post 'projects/auth_github'

  devise_for :users
  resources :projects
  resources :developers
  resources :ticket_repositories
  resources :version_repositories
  resources :redmine_keys
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
