FactoryGirl.define do
  
  factory :user, class: User do
    
    id 1
    admin true
    last_name 'Doe'
    first_name 'John'

    trait :with_address_and_posts do
      address { { street: 'my_street' } }
      posts [{ body: 'post1' }, { body: 'post2' }]
    end
    factory :user_with_address_and_posts, traits: [:with_address_and_posts]

    trait :has_my_method do
      my_method 'my_method'
    end
    factory :user_with_my_method, traits: [:with_address_and_posts, :has_my_method]

  end

  factory :white_list, class: User do
    id 1
    first_name 'John'
  end
  
  factory :black_list, class: User do
    admin true
    last_name 'Doe'
  end

end
