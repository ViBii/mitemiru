Rails.application.routes.draw do
  root 'portfolio#index'

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

  # TODO: 以下消去しても大丈夫ですか？？
  get 'comments_counter/index'
  post 'comments_counter/comments_ajax'
  get 'commit_counter/index'
  post 'commit_counter/commits_ajax'

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

  match '*path' => 'application#error404', via: :all
end
