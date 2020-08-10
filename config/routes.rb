Rails.application.routes.draw do
  root 'orders#index'
  post 'orders/checkout'
  post "orders/paypal/create_payment", to: "orders#paypal_create_payment", as: "paypal_create_payment"
  post "orders/paypal/execute_payment", to: "orders#paypal_execute_payment", as: "paypal_execute_payment"
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
