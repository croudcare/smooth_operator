module SmoothOperator
  module AttributeMethods

    module ClassMethods
      def known_attributes
        Helpers.get_instance_variable(self, :known_attributes, Set.new)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def known_attribute?(attribute)
      known_attributes.include?(attribute.to_s)
    end

    def known_attributes
      @known_attributes ||= self.class.known_attributes.dup
    end

    def internal_data
      @internal_data ||= {}
    end

    def get_internal_data(field, method = :value)
      result = internal_data[field]

      if result.nil?
        nil
      elsif method == :value
        result.is_a?(Attributes::Dirty) ? internal_data[field].send(method) : internal_data[field]
      else
        internal_data[field].send(method)
      end
    end

    def push_to_internal_data(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)

      known_attributes.add attribute_name

      initiate_or_update_internal_data(attribute_name, attribute_value)

      new_record_or_mark_for_destruction?(attribute_name, attribute_value)
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def initiate_or_update_internal_data(attribute_name, attribute_value)
      if internal_data[attribute_name].nil?
        initiate_internal_data(attribute_name, attribute_value)
      else
        update_internal_data(attribute_name, attribute_value)
      end
    end

    def new_record_or_mark_for_destruction?(attribute_name, attribute_value)
      return nil unless self.class.respond_to?(:smooth_operator?)

      marked_for_destruction?(attribute_value) if attribute_name == self.class.destroy_key

      new_record?(true) if attribute_name == self.class.primary_key
    end

    private ######################## PRIVATE #############################

    def initiate_internal_data(attribute_name, attribute_value)
      internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value)

      internal_data[attribute_name] = internal_data[attribute_name].value unless self.class.dirty_attributes?
    end

    def update_internal_data(attribute_name, attribute_value)
      if self.class.dirty_attributes?
        internal_data[attribute_name].set_value(attribute_value, self)
      else
        internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value).value
      end
    end

    def new_attribute_object(attribute_name, attribute_value)
      attribute_class = self.class.dirty_attributes? ?  Attributes::Dirty : Attributes::Normal

      attribute_class.new(attribute_name, attribute_value, self)
    end

  end

end
