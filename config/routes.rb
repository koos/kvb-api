KvbApi::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  namespace :api do
    scope "v1" do
      resources :lines, :only => [:show, :index]
      resources :stations, :only => [:show, :index]
    end
  end

end
