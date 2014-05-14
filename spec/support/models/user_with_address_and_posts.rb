module UserWithAddressAndPosts
  
  class Father < User::Base
    
    self.resource_name = 'user'

    schema(
      posts: Post,
      address: Address
    )

  end

  class Son < Father

    schema(
      age: :int,
      dob: :date,
      price: :float,
      manager: :bool,
      date: :datetime,
      first_name: :string
    )

  end

  class SoftBehaviour < Son

    self.strict_behaviour = false

  end

  class WithPatch < Son

    self.update_http_verb = :patch

  end
  

  module UserBlackListed
    
    class Father < ::UserWithAddressAndPosts::Son

      attributes_black_list_add "last_name"

    end

    class Son < Father

      attributes_black_list_add :admin

    end

  end

  module UserWhiteListed
    
    class Father < ::UserWithAddressAndPosts::Son

      attributes_white_list_add "id"

    end

    class Son < Father

      attributes_white_list_add :first_name

    end

  end
  
  class UserWithMyMethod < UserWithAddressAndPosts::Son

    def my_method
      'my_method'
    end

  end

  class DirtyAttributes < UserWithAddressAndPosts::Son

    self.dirty_attributes

    self.unknown_hash_class = SmoothOperator::OpenStruct::Dirty

  end

end
