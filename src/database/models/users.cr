class Usersk < Granite::Base
  adapter mysql
  primary user_id : Int32
  field fullname : String
  field email : String
  field password : String
  field phone : Int32
  field image : String
  field status : Bool
  field create_at : Time

  validate_not_nil :fullname
  validate_not_nil :email
  validate_not_nil :password
end
