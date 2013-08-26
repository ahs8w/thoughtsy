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
    content "Lorem Ipsum"
    user                                # all we need to show association with user object
  end

  factory :response do
    content "response"
    user
    post
  end
end