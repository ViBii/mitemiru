Rails.application.routes.draw do
  root 'base#top'

  get 'comp/index'

  get 'portfolio/index'

  get 'base/top'
  get 'base/setting'

  get 'projects/select_developer'
  post 'projects/auth_redmine'
  post 'projects/auth_github'

  resources :projects
  resources :developers
  resources :ticket_repositories
  resources :redmine_keys
  resources :assign_logs
end
