module UserWithAddressAndPosts
  
  class Father < User

    schema(
      posts: Post,
      address: Address
    )

  end

  class Son < Father

    self.table_name = 'users'

    schema(
      age: :int,
      dob: :date,
      manager: :bool
    )

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

end
