module SmoothOperator

  module Delegation

    def respond_to?(method)
      known_attributes.include?(method.to_s) ? true : super
    end

    def method_missing(method, *args, &block)
      method_type, method_name = *parse_method(method)

      result = case method_type
      when :was
        get_internal_data(method_name, :was)
      when :changed
        get_internal_data(method_name, :changed?)
      when :setter
        return push_to_internal_data(method_name, args.first)
      else
        return get_internal_data(method_name) if respond_to?(method_name)
      end

      result.nil? ? super : result
    end


    protected #################### PROTECTED ################

    def parse_method(method)
      method = method.to_s

      if method?(method, /=$/)
        [:setter, method[0..-2]]
      elsif method?(method, /_was$/)
        [:was, method[0..-5]]
      elsif method?(method, /_changed?$/)
        [:changed, method[0..-10]]
      else
        [nil, method]
      end
    end


    private #################### PRIVATE ################

    def method?(method, regex)
      !! ((method.to_s) =~ regex)
    end

  end

end
