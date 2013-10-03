FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :post do
    sequence(:content) { |n| "Lorem Ipsum post#{n}" } 
    user               # ensures parent element is created at same time; show association with user object
    state "unanswered"

    factory :pending do
      state 'pending'
    end

    factory :answered do
      state 'answered'
    end
  end

  factory :response do
    sequence(:content) { |n| "Respondo Ipsum#{n}" }
    user
    association :post, state: 'answered'
  end
end