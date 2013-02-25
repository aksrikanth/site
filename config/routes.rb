Site::Application.routes.draw do
  resources :articles, :only => [:index, :show]
  root :to => 'articles#index', :via => :get
end
