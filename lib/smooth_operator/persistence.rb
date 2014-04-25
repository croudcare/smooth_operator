module SmoothOperator
  
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def methods_http_verbs
        @methods_http_verbs ||= { create: :post, save: :put, destroy: :delete }
      end

      [:create, :save, :destroy].each do |method|
        define_method("#{method}_http_verb=") { |http_verb| methods_http_verbs[method] = http_verb }
      end
      
      def create(attributes = nil, relative_path = nil, data = {}, options = {})
        if attributes.is_a?(Array)
          attributes.map { |array_entry| create(array_entry, relative_path, data, options) }
        else
          new(attributes).tap { |object| object.save(relative_path, data, options) }
        end
      end

    end


    def new_record?
      return @new_record if defined?(@new_record)
      
      @new_record = Helpers.blank?(get_internal_data("id"))
    end
    
    def destroyed?
      @destroyed || false
    end

    def last_remote_call
      @last_remote_call
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save(relative_path = nil, data = {}, options = {})
      create_or_update(relative_path, data, options)
    end

    def save!(relative_path = nil, data = {}, options = {})
      create_or_update(relative_path, data, options) || raise('RecordNotSaved')
    end

    def destroy(relative_path = nil, data = {}, options = {})
      return false unless persisted?

      relative_path = "#{id}" if Helpers.blank?(relative_path)
      
      success = make_remote_call(self.class.methods_http_verbs[:destroy], relative_path, data, options)

      @destroyed = true if success

      success
    end


    protected ######################### PROTECTED ##################

    def create_or_update(relative_path, data, options)
      new_record? ? create(relative_path, data, options) : update(relative_path, data, options)
    end

    def create(relative_path, data, options)
      success = make_remote_call(self.class.methods_http_verbs[:create], relative_path, data, options)

      @new_record = false if success

      success
    end

    def update(relative_path, data, options)
      relative_path = "#{id}" if Helpers.blank?(relative_path)

      make_remote_call(self.class.methods_http_verbs[:save], relative_path, data, options)
    end


    private ##################### PRIVATE ####################

    def make_remote_call(http_verb, relative_path, data, options)
      data, options = build_remote_call_args(http_verb, data, options)

      @last_remote_call = self.class.send(http_verb, relative_path, data, options)

      returning_data = @last_remote_call.parsed_response
      
      if !@last_remote_call.error? && returning_data.is_a?(Hash)
        assign_attributes returning_data.include?(model_name) ? returning_data[model_name] : returning_data
      end

      @last_remote_call.status
    end

    def build_remote_call_args(http_verb, data, options)
      return [data, options] if http_verb == :delete
      
      hash = serializable_hash(options[:serializable_options]).dup
      hash.delete('id')

      [{ model_name => hash }.merge(data), options]
    end

  end
  
end
