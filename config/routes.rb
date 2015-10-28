Rails.application.routes.draw do
  root 'portfolio#productivity_info'

  get 'portfolio/setting'
  post 'portfolio/index'
  post 'portfolio/show_projects'

  get 'portfolio/productivity_info'
  post 'portfolio/ticket_digestion_ajax'
  post 'portfolio/productivity_ajax'
  post 'portfolio/commits_ajax'
  post 'portfolio/comments_ajax'

  get 'datasamples/index'

  post 'projects/auth_redmine'
  post 'projects/auth_github'
  post 'projects/unauth'
  post 'projects/confirm'

  resources :projects do
    get '/new_redmine' => 'projects#new_redmine'
    get '/new_github' => 'projects#new_github'
    get '/edit_redmine' => 'projects#edit_redmine'
    get '/edit_github' => 'projects#edit_github'
  end

  devise_for :users

  resources :developers
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  match '*path' => 'application#error404', via: :all
end
