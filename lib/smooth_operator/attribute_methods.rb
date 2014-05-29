module SmoothOperator
  module AttributeMethods

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

    def get_attribute_type(attribute)
      self.class.internal_structure[attribute.to_s]
    end

    def push_to_internal_data(attribute_name, attribute_value, cast = false)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)

      known_attributes.add attribute_name

      if internal_data[attribute_name].nil?
        initiate_internal_data(attribute_name, attribute_value, cast)
      else
        update_internal_data(attribute_name, attribute_value, cast)
      end

      if self.class.respond_to?(:smooth_operator?)
        trigger_necessary_events(attribute_name, attribute_value)
      end
    end

    def column_for_attribute(attribute_name)
      if defined?(ActiveRecord)
        type = get_attribute_type(attribute_name)
        ActiveRecord::ConnectionAdapters::Column.new(attribute_name.to_sym, type, type)
      else
        nil
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def trigger_necessary_events(attribute_name, attribute_value)
      mark_for_destruction?(attribute_value) if attribute_name == self.class.destroy_key

      new_record?(true) if attribute_name == self.class.primary_key
    end

    private ######################## PRIVATE #############################

    def initiate_internal_data(attribute_name, attribute_value, cast)
      if cast
        internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value)

        internal_data[attribute_name] = internal_data[attribute_name].value unless self.class.dirty_attributes?
      else
        internal_data[attribute_name] = attribute_value
      end
    end

    def update_internal_data(attribute_name, attribute_value, cast)
      if self.class.dirty_attributes?
        internal_data[attribute_name].set_value(attribute_value, self)
      else
        internal_data[attribute_name] = cast ? new_attribute_object(attribute_name, attribute_value).value : attribute_value
      end
    end

    def new_attribute_object(attribute_name, attribute_value)
      attribute_class = self.class.dirty_attributes? ?  Attributes::Dirty : Attributes::Normal

      attribute_class.new(attribute_name, attribute_value, self)
    end

  end

end
