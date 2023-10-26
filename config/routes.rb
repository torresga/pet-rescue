Rails.application.routes.draw do
  resources :checklist_template_items

  devise_for :users, controllers: {
    registrations: "registrations",
    sessions: "users/sessions",
    invitations: "organizations/invitations"
  }

  resources :adoptable_pets, only: [:index, :show]
  resource :adopter_profile, except: :destroy, as: "profile"
  resources :checklist_templates
  resources :donations, only: [:create]

  scope module: :organizations do
    resource :organization_profile, only: %i[edit update]

    resources :home, only: [:index]
    resources :pets do
      post 'update_images', on: :member, to: 'pets#update_images'
      resources :tasks, only: [:create, :edit, :update, :destroy]
    end
    resources :dashboard
    resources :adoption_application_reviews, only: [:index, :edit, :update]
    resources :foster_application_reviews, only: [:index]
    resources :settings, only: [:index]
    resources :staff
  end

  resources :profile_reviews, only: [:show]
  resources :successes, only: [:index]

  resources :countries, only: [] do
    resources :states, only: [:index]
  end

  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#restricted_access", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  root "root#index"
  get "/about_us", to: "static_pages#about_us"
  get "/faq", to: "static_pages#faq"
  get "/partners", to: "static_pages#partners"
  get "/donate", to: "static_pages#donate"
  get "/privacy_policy", to: "static_pages#privacy_policy"
  get "/terms_and_conditions", to: "static_pages#terms_and_conditions"
  get "/cookie_policy", to: "static_pages#cookie_policy"

  get "/my_applications", to: "adopter_applications#index"
  post "create_my_application", to: "adopter_applications#create"
  patch "my_application", to: "adopter_applications#update"

  post "create_adoption", to: "matches#create"
  delete "revoke_adoption", to: "matches#delete"

  get "/contacts", to: "contacts#create"
  get "/contacts/new", to: "contacts#new", as: "new_contact"

  delete "attachments/:id/purge", to: "attachments#purge", as: "purge_attachment"

  resolve("adopter_profile") { [:adopter_profile] }
end
