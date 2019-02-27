class Validations
  def self.field_db(errors = "[]")
    if errors.to_s != "[]"
      err = "#{errors[0].to_s}"
      if err.includes?("Duplicate entry")
        raise Exception.new("The mail is already registered")
      end
    end
  end
end
