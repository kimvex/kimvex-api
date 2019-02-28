require "mysql"
require "json"

class Database
  @query = ""
  @values = [] of DB::Any
  @values_insert = [] of DB::Any
  @results = [] of DB::Any
  @db : DB::Database

  def initialize
    @db = DB.open "mysql://root@localhost/serviciotest"
    # @db.query "select * from usersk" do |rs|
    #   puts "#{rs.column_name(0)} #{rs.column_name(1)}"
    #   rs.each do
    #     puts JSON.parse(rs.read(DB::Database))
    #     puts rs.read(DB::Any)
    #     puts rs.read(String | Int32)
    #   end
    # end
    @db
  end

  def select(fields = [] of DB::Any)
    select_list = fields.map { |field| field }
    @query = "SELECT #{select_list.join(", ")}"
    self
  end

  def insert(fields = [] of DB::Any, values = [] of DB::Any)
    insert_fields = fields.map { |field| field }
    insert_values = values.map { |field| '?' }
    values.map { |field| @values_insert << field }
    table = @query.split("FROM")
    table = table[1].lstrip
    @query = ""
    @query = "INSERT INTO #{table}(#{insert_fields.join(", ")}) VALUES (#{insert_values.join(", ")})"
    self
  end

  def table(table = "")
    @query = "#{@query} FROM #{table}"
    self
  end

  def where(field = "", value = "")
    @query = "#{@query} WHERE #{field} = ?"
    @values << value
    self
  end

  def and(field = "", value = "")
    @query = "#{@query} AND #{field} = ?"
    @values << value
    self
  end

  def or(field = "", value = "")
    @query = "#{@query} OR #{field} = ?"
    @values << value
    self
  end

  def order_by(field)
    order_by = field.map { |field| field }
    @query = "#{@query} ORDER BY #{order_by.join(", ")}"
    self
  end

  def limit(limit)
    @query = "#{@query} LIMIT #{field}"
    self
  end

  def order_direction(order = "DESC")
    @query = "#{@query} #{order}"
    self
  end

  def group_by(field)
    @query = "#{@query} #{field}"
    self
  end

  def execute_query
    begin
      result = [] of JSON::Any
      @db.query("#{@query}", @values) do |results|
        column_names = results.column_names
        results.each do
          if results.column_count > 0
            result << toJson(results, column_names)

            # result << results.read(DB::Any)
            # puts results.read(DB::Any)
            # # puts results.read(String | Int32)
          end
        end
      end
      result
    rescue exception
      error = "#{exception}"
      puts error
    end
  end

  def execute
    begin
      @db.exec "#{@query}", @values_insert
    rescue exception
      error = "#{exception}"

      puts error
    end
  end

  private def toJson(rs, column_names)
    json_data = JSON.build do |json|
      json.object do
        column_names.each do |field_s|
          json.field "#{field_s}", "#{rs.read(DB::Any)}"
        end
      end
    end

    json_data = JSON.parse(json_data)

    json_data
  end
end
