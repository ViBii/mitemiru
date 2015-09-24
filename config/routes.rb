Rails.application.routes.draw do
  get 'commit_counter/index'

  get 'comments_counter/index'
  root 'base#top'
  
  get 'datasamples/index'

  get 'redmine_keys/new'

  get 'comp/index'

  get 'portfolio/index'

  get 'base/top'
  get 'base/setting'

  get 'comments_counter/getcomments'
  get 'projects/select_developer'
  post 'projects/select_developer'
  get 'projects/auth_github'
  post 'projects/auth_github'

  resources :projects
  resources :developers
  resources :ticket_repositories
  resources :redmine_keys
  resources :assign_logs
end
