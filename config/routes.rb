Rapidfire::Engine.routes.draw do
  resources :question_groups do
    get 'results', on: :member
    get 'crosstab', on: :member
    post 'crosstab_create', on: :member

    resources :questions do
      post :sort, on: :collection
    end
    resources :answer_groups, only: [:new, :create]
  end

  root :to => "question_groups#index"
end
