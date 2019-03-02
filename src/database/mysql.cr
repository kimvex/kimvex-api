require "mysql"
require "json"

class Database
  @query = ""
  @values_insert_update = [] of DB::Any
  @db : DB::Database
  @action_sql = ""

  def initialize
    @db = DB.open "mysql://root@localhost:3307/serviciotest"
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
    values.map { |field| @values_insert_update << field }
    table = @query.split("FROM")
    table = table[1].lstrip
    @query = ""
    @query = "INSERT INTO #{table}(#{insert_fields.join(", ")}) VALUES (#{insert_values.join(", ")})"
    @action_sql = "INSERT"
    self
  end

  def update(fields = [] of DB::Any, values = [] of DB::Any)
    update_fields = fields.map { |field| "#{field} = ?" }
    values.map { |field| @values_insert_update << field }
    table = @query.split("FROM")
    table = table[1].lstrip
    @query = ""
    @query = "UPDATE #{table} SET #{update_fields.join(",")}"
    @action_sql = "UPDATE"
    self
  end

  def table(table = "")
    @query = "#{@query} FROM #{table}"
    self
  end

  def where(field = "", value = "")
    @query = "#{@query} WHERE #{field} = ?"
    @values_insert_update << value
    self
  end

  def and(field = "", value = "")
    @query = "#{@query} AND #{field} = ?"
    @values_insert_update << value
    self
  end

  def or(field = "", value = "")
    @query = "#{@query} OR #{field} = ?"
    @values_insert_update << value
    self
  end

  def order_by(field)
    order_by = field.map { |field| field }
    @query = "#{@query} ORDER BY #{order_by.join(", ")}"
    self
  end

  def limit(limit)
    @query = "#{@query} LIMIT #{limit}"
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

      @db.query("#{@query}", @values_insert_update) do |results|
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
      self.clear
      result
    rescue exception
      error = "#{exception} execute_query"
      self.clear
      puts error
    end
  end

  def first
    puts "#{@query} query #{@values_insert_update}"
    query = self.limit(1).execute_query

    if query.to_s != "[]"
      query.not_nil![0].to_json
    else
      puts "User not found"
      nil
    end
  end

  def execute
    begin
      case @action_sql
      when "INSERT"
        @db.exec "#{@query}", @values_insert_update
        puts "Insert success"
      when "UPDATE"
        puts "#{@query}"
        @db.exec("#{@query}", @values_insert_update)
        puts "Update success"
      end
      self.clear
    rescue exception
      error = "#{exception}"

      self.clear

      if error.includes?("Duplicate entry")
        raise Exception.new("The mail is already registered")
      end
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

  private def clear
    @values_insert_update.clear
    @query = ""
  end
end
