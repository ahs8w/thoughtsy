include CarrierWaveDirect::Test::Helpers

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

    factory :image_post do
      content ""
      image 'test.png'
      key sample_key(ImageUploader.new)
      image_processed true
    end
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

  factory :rating do
    user
    response
    value 3
  end

  factory :subscription do
    user
    post
  end
end