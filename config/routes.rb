Rails.application.routes.draw do
  root 'base#top'

  get 'comp/index'

  get 'portfolio/index'

  get 'base/top'
  get 'base/setting'

  get 'datasamples/index'
  get 'redmine_keys/new'
  get 'comments_counter/getcomments'
  get 'commit_counter/index'

  get 'projects/info'
  get 'projects/auth'
  get 'commit_counter/getcommits'
  post 'projects/auth_new'
  post 'projects/auth_create'
  get 'projects/select_developer'
  post 'projects/select_developer'
  post 'projects/auth_github'

  resources :projects
  resources :developers
  resources :ticket_repositories
  resources :redmine_keys
  resources :assign_logs
end
