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
  end

  factory :response do
    sequence(:content) { |n| "Respondo Ipsum#{n}" }
    user
    association :post, state: 'answered'
  end

  factory :message do
    sequence(:content) { |n| "Messagio Ipsum#{n}" }
    user
    association :receiver, factory: :user
  end
end