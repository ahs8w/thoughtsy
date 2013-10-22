Thoughtsy::Application.routes.draw do
  get "password_resets/new"
  resources :users
  resources :sessions,  only: [:new, :create, :destroy]
  resources :posts,     except: [:new, :update, :edit] do
    resources :responses, only: [:show, :new, :create]
    member do
      get 'repost'
      get 'flag'
    end
    get 'queue', on: :collection
  end
  resources :responses, only: [:destroy, :index]
  resources :password_resets, except: [:show, :index]
  resources :ratings,   only: [:new, :create]
  resources :messages,  only: :create
  resources :subscriptions, only: [:create, :destroy]


  root 'static_pages#home'
  
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/team',    to: 'static_pages#team',    via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  match '/queue',   to: 'posts#queue',          via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
