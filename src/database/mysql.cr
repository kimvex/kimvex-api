require "mysql"
require "json"

class Database
  @query = ""
  @table = ""
  @tables_join = [] of DB::Any
  @values_insert_update = [] of DB::Any
  @db : DB::Database
  @action_sql = ""
  @select_concat = ""

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
    @query = "SELECT #{select_list.join(",")}"
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
    @table = "#{table}"
    @query = "#{@query} FROM #{table}"
    self
  end

  def where(field = "", value = "")
    if @query.includes?("JOIN")
      @query = "#{@query} WHERE #{@table}.#{field} = ?"
    else
      @query = "#{@query} WHERE #{field} = ?"
    end
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

  def join(position, table, selects = [] of DB::Any, clause = [] of DB::Any)
    query_sql_plit = @query.split(" ")[1].lstrip
    query_sql_principal = query_sql_plit.split(",").map { |field| field.includes?(".") ? field : "#{@table}.#{field}" }
    query_sql_join = selects.map { |field| "#{table}.#{field}" }
    if @query.includes?("JOIN")
      split_query = @query.split("SELECT ")
      puts split_query
      @query = "SELECT #{split_query[0]}#{query_sql_join.join(",")},#{split_query[1]} #{position} JOIN #{table} ON #{@table}.#{clause[0]} = #{table}.#{clause[1]}"
    else
      @query = "SELECT #{query_sql_principal[0]},#{query_sql_join.join(",")} FROM #{@table} #{position} JOIN #{table} ON #{@table}.#{clause[0]} = #{table}.#{clause[1]}"
    end
    self
  end

  def first
    puts "#{@query} query #{@values_insert_update}"
    query = self.limit(1).execute_query
    puts query.to_s
    if query.to_s != "[]"
      query.not_nil![0].to_json
    else
      puts "User not found"
      "{}"
    end
  end

  def execute_query
    begin
      result = [] of Hash(String, JSON::Any)
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
          json.field "#{field_s}", "#{rs.read(DB::Any | Int8)}"
        end
      end
    end

    convert_to_hash = Hash(String, JSON::Any).from_json(json_data)
    convert_to_hash.each do |key, value|
      begin
        convert_to_hash[key] = JSON.parse(value.to_s)
      rescue exception
      end
    end

    convert_to_hash
  end

  private def clear
    @values_insert_update.clear
    @query = ""
  end
end
