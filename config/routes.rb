Site::Application.routes.draw do
  resources :articles, :only => [:index, :show]
  match '/code', :to => 'pages#code', :as => 'code', :via => :get
  match '/publications', :to => 'pages#publications', :as => 'publications', :via => :get
  root :to => 'articles#index', :via => :get
end
