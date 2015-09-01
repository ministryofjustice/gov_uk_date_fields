module GovUkDateFields

  class FormDateError < RuntimeError; end


  class FormDate

    attr_accessor :dd, :mm, :yyyy, :date, :temp
    
    # This method cannot be called directly: use .new_from_date or .new_from_params
    def initialize(dd, mm, yyyy, date = nil)
     @dd            = dd
     @mm            = mm
     @yyyy          = yyyy
     @date          = date
     @valid         = date.nil? ? validate_date : true
    end
  
    # Creates a FormDate object from the date, and writes it to @_<attr_name>
    # on the object, and updates the attr[<attr_name>] with the real date object
    #
    def self.set_from_date(object, attr_name, date)
      if date.nil?
        form_date = new('', '', '')
      else
        form_date = new(date.day.to_s, date.month.to_s, date.year.to_s, date)
      end
      update_object(object, attr_name, form_date)
    end


    
    def self.set_date_part(date_part, object, attr_name, value)
      form_date = object.instance_variable_get("@_#{attr_name}".to_sym)
      form_date.send("#{date_part}=", value)
      form_date.create_date_from_date_parts
    end


    def create_date_from_date_parts
      @valid = true
      if @dd.blank? && @mm.blank? && @yyyy.blank?
        @date = nil
      else
        months = %w{ jan feb mar apr may jun jul aug sep oct nov dec }
        mm_as_int = months.include?(@mm.downcase) ? months.index(@mm.downcase) + 1 : @mm.to_i
        begin
          @date = Date.new(@yyyy.to_i, mm_as_int, @dd.to_i)
        rescue ArgumentError => err
          raise err unless err.message == 'invalid date'
          @valid = false
        end
      end
    end


    # Creates a FormDate object from the params, and writes it to the instance variable @_<attr_name> 
    # on the object, and updates the attr[attr_name] with the real date object
    #
    # If the dob_dd, dob_mm, dob_yy are not in the params hash, or if they are all blank, the object is 
    # not updated.
    #
    # def self.set_from_params(object, attr_name, params)
    #   params = HashWithIndifferentAccess.new(params) unless params.is_a?(HashWithIndifferentAccess)
    #   return if attr_not_present_in_params?(attr_name, params)
    #   form_date = new(params["#{attr_name}_dd"], params["#{attr_name}_mm"], params["#{attr_name}_yyyy"] )
    #   update_object(object, attr_name, form_date)
    # end

    def valid?
      @valid
    end

    private_class_method :new

    private 


    def transfer_temp_fields_to_live
      @dd = @temp[:dd]
      @mm = @temp[:mm]
      @yyyy = @temp[:yyyy]
    end

    

    def self.update_object(object, attr_name, form_date)
      object.instance_variable_set("@_#{attr_name}".to_sym, form_date)
      object[attr_name] = form_date.date
    end


    def self.attr_not_present_in_params?(attr_name, params)
      attr_missing_in_params?(attr_name, params)  || all_blanks_in_params?(attr_name, params)
    end

    def self.attr_missing_in_params?(attr_name, params) 
      params["#{attr_name}_dd"].nil? &&  params["#{attr_name}_mm"].nil? &&  params["#{attr_name}_yyyy"].nil?
    end

    def self.all_blanks_in_params?(attr_name, params)
      params["#{attr_name}_dd"].blank? &&  params["#{attr_name}_mm"].blank? &&  params["#{attr_name}_yyyy"].blank?
    end


    def validate_date
      return true if @dd.blank? && @mm.blank? && @yyyy.blank?
      months = %w{ jan feb mar apr may jun jul aug sep oct nov dec }

      mm_as_int = months.include?(@mm.downcase) ? months.index(@mm.downcase) + 1 : @mm.to_i
      begin
        @date = Date.new(@yyyy.to_i, mm_as_int, @dd.to_i)
      rescue ArgumentError => err
        return false if err.message == 'invalid date'
        raise err
      end
    end

  end

end