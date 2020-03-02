Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'get_stack/:id', to: 'welcome#get_stack', as: :get_stack
  root 'welcome#index'
end
