Rails.application.routes.draw do
  root 'base#top'

  get 'comp/index'

  get 'portfolio/index'

  get 'base/top'
  get 'base/setting'

  get 'datasamples/index'
  get 'comments_counter/getcomments'
  get 'commit_counter/index'

  get 'projects/select_developer'
  post 'projects/select_developer'
  post 'projects/auth_github'

  resources :projects
  resources :developers
  resources :ticket_repositories
  resources :version_repositories
  resources :redmine_keys
  resources :users
end
