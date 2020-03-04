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
  @values = {
    "boolean"   => "BOOLEAN",
    "bool"      => "BOOLEAN",
    "string"    => "VARCHAR",
    "text"      => "VARCHAR",
    "varchar"   => "VARCHAR",
    "character" => "CHARACTER",
    "char"      => "CHARACTER",
    "smallint"  => "SMALLINT",
    "integer"   => "INTEGER",
    "int"       => "INTEGER",
    "decimal"   => "DECIMAL",
    "numeric"   => "NUMERIC",
    "num"       => "NUMERIC",
    "number"    => "NUMERIC",
    "real"      => "REAL",
    "float"     => "FLOAT",
    "double"    => "DOUBLE PRECISION",
    "date"      => "DATE",
    "time"      => "TIME",
    "datetime"  => "DATETIME",
    "timestamp" => "TIMESTAMP",
    "clob"      => "CLOB",
    "blob"      => "BLOB",
    "enum"      => "ENUM",
  }
  @migration_last_version = 0
  @list_migration = [] of String

  def initialize
    @db = DB.open "mysql://root@localhost:3306/serviciotest"
    @db
  end

  def select(fields = [] of DB::Any)
    select_list = fields.map { |field| field }
    @query = "SELECT #{select_list.join(",")}"
    # puts @query
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

  def delete(field = "")
    puts "#{@query} -a o que haty"
    @query = ""
    @query = "DELETE"
    @action_sql = "DELETE"
    @values_insert_update.clear

    self
  end

  def table(table = "")
    @table = "#{table}"
    @query = "#{@query} FROM #{table}"
    self
  end

  def where(field = "", value = "", operator = "=", value_null = nil)
    if @query.includes?("JOIN")
      if value_null.nil?
        @query = "#{@query} WHERE #{@table}.#{field} #{operator} ?"
      else
        is_not_null = value_null === true ? "NOT NULL" : "NULL"
        @query = "#{@query} WHERE #{@table}.#{field} IS #{is_not_null} "
      end
    else
      if value_null.nil?
        @query = "#{@query} WHERE #{field} #{operator} ?"
      else
        is_not_null = value_null === true ? "NOT NULL" : "NULL"
        @query = "#{@query} WHERE #{field} IS #{is_not_null}"
      end
    end
    @values_insert_update << value
    self
  end

  def where_table(table = "", field = "", value = "", operator = "=", value_null = nil)
    if value_null.nil?
      @query = "#{@query} WHERE #{table}.#{field} #{operator} ?"
    else
      is_not_null = value_null === true ? "NOT NULL" : "NULL"
      @query = "#{@query} WHERE #{table}.#{field} IS #{is_not_null} "
    end
    @values_insert_update << value
    self
  end

  def where_beeween(field = "", values = nil, table = nil)
    if !values.nil?
      if table.nil?
        @query = "#{@query} WHERE #{field} BETWEEN ? AND ?"
      else
        @query = "#{@query} WHERE #{table}.#{field} BETEEN ? AND ?"
      end
      @values_insert_update << values.not_nil![0]
      @values_insert_update << values.not_nil![1]
    end
    self
  end

  def where_in(field = "", value = [] of JSON::Any)
    if @query.includes?("JOIN")
      @query = "#{@query} WHERE #{@table}.#{field} IN (#{value.map { |field| '?' }.join(",")})"
    else
      @query = "#{@query} WHERE #{field} IN (#{value.map { |field| '?' }.join(",")})"
    end

    value.map { |field| @values_insert_update << "#{field}".to_s.to_i }
    self
  end

  def and(field = "", value = "", operator = "=", value_null = nil)
    if @query.includes?("JOIN")
      if value_null.nil?
        @query = "#{@query} AND #{@table}.#{field} #{operator} ?"
        @values_insert_update << value
      else
        is_not_null = value_null === true ? "NOT NULL" : "NULL"
        @query = "#{@query} AND #{@table}.#{field} IS #{is_not_null}"
      end
    else
      if value_null.nil?
        @query = "#{@query} AND #{field} #{operator} ?"
        @values_insert_update << value
      else
        is_not_null = value_null === true ? "NOT NULL" : "NULL"
        @query = "#{@query} AND #{field} IS #{is_not_null}"
      end
    end
    self
  end

  def and_table(table = "", field = "", value = "", operator = "=", value_null = nil)
    if value_null.nil?
      @query = "#{@query} AND #{table}.#{field} #{operator} ?"
    else
      is_not_null = value_null === true ? "NOT NULL" : "NULL"
      @query = "#{@query} AND #{table}.#{field} IS #{is_not_null}"
    end
    @values_insert_update << value
    self
  end

  def or(field = "", value = "", operator = "=")
    @query = "#{@query} OR #{field} #{operator} ?"
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

  def offset(offset = 0)
    @query = "#{@query} OFFSET #{offset}"
    self
  end

  def order_direction(order = "DESC")
    @query = "#{@query} #{order}"
    self
  end

  def group_by(fields = "", group_field = "", join_table = nil)
    group_field = "#{group_field.not_nil!}"
    if fields
      fields = fields.split(" ")[1].lstrip
    end
    group_fields = fields.split(",").map { |field|
      if !field.includes?("AVG") && !field.includes?("SUM")
        field
      end
    }
    if join_table.nil?
      @query = "#{@query} GROUP BY #{group_field.empty? ? group_fields.join(",") : group_field}"
    else
      @query = "#{@query} GROUP BY #{join_table}.#{group_field.empty? ? group_fields.join(",") : group_field}"
    end
    self
  end

  def group_concat(args = [] of DB::Any, order_by = "", alias_as = "", array = false)
    field, table, alias_field = args
    query = @query

    if @query.includes?("JOIN")
      if array
        @query = @query.gsub("#{table}.#{field}", "json_array(GROUP_CONCAT(coalesce(#{table}.#{field}, ''))) AS #{alias_as}")
      else
        @query = @query.gsub("#{table}.#{field}", "concat('[',GROUP_CONCAT(json_object('#{alias_field}',#{table}.#{field})),']') AS #{alias_as}")
      end
    else
      if array
        @query = @query.gsub("#{field}", "json_array(GROUP_CONCAT(#{field})) AS #{alias_as}")
      else
        @query = @query.gsub("#{field}", "concat('[',GROUP_CONCAT(json_object('#{alias_field}',#{field})),']') AS #{alias_as}")
      end
    end

    group_by(query)
    removeField(field, table)
    self
  end

  def join(position, table, selects = [] of DB::Any, clause = [] of DB::Any, extra_table = [] of DB::Any)
    query_sql_plit = @query.split(" ")[1].lstrip
    query_sql_principal = query_sql_plit.split(",").map { |field|
      field.includes?(".") ? field : "#{@table}.#{field}"
    }
    query_sql_join = selects.map { |field| "#{table}.#{field}" }

    if @query.includes?("JOIN")
      split_query = @query.split("SELECT ")
      @query = "#{split_query[0]}#{query_sql_join.join(",")},#{split_query[1]} #{position} JOIN #{table} ON #{!extra_table.empty? ? extra_table[0] : @table}.#{clause[0]} = #{table}.#{clause[1]}"
    else
      @query = "#{query_sql_principal.join(",")},#{query_sql_join.join(",")} FROM #{@table} #{position} JOIN #{table} ON #{!extra_table.empty? ? extra_table[0] : @table}.#{clause[0]} = #{table}.#{clause[1]}"
    end

    @query = "SELECT #{@query}"
    self
  end

  def avg(field, alias_as, group)
    index = 0
    query = @query
    restructure_query_select = query.split(",").map { |field_map|
      index = field_map.index(".#{field}")
      value_equal = ""

      if index
        value_equal = "#{field_map}"[index..-1]
      end

      if field_map.includes?(".#{field}") && value_equal == ".#{field}"
        field_map.gsub("#{field_map}", "AVG(#{field_map}) AS #{alias_as}")
      elsif field_map.includes?("#{field}") && value_equal == ".#{field}"
        field_map.gsub("#{field}", "AVG(#{field}) AS #{alias_as}")
      else
        field_map.gsub("#{field_map}", "AVG(#{field}) AS #{alias_as}")
      end
    }

    @query = "SELECT #{restructure_query_select.join(",")}#{@query.split("SELECT #{field}")[1]}"

    group_by(query, group)

    self
  end

  def sum(field, alias_as, group, join_table = nil)
    index = 0
    query = @query
    restructure_query_select = query.split(",").map { |field_map|
      index = field_map.index(".#{field}")
      value_equal = ""

      if index
        value_equal = "#{field_map}"[index..-1]
      end

      if field_map.includes?(".#{field}") && value_equal == ".#{field}"
        field_map.gsub("#{field_map}", "SUM(#{field_map}) #{alias_as}")
      elsif field_map.includes?("#{field}") && value_equal == ".#{field}"
        field_map.gsub("#{field}", "SUM(#{field}) #{alias_as}")
      else
        field_map.gsub("#{field_map}", "SUM(#{field}) #{alias_as}")
      end
    }

    @query = "SELECT #{restructure_query_select[0]},#{@query.split("SELECT ")[1]}"
    group_by(query, group, join_table)

    self
  end

  def as_query(field, alias_as)
    if @query.includes?("JOIN")
      @query = @query.gsub("#{@table}.#{field}", "#{@table}.#{field} AS #{alias_as}")
    else
      @query = @query.gsub("#{field}", "#{field} AS #{alias_as}")
    end
    self
  end

  def first
    puts "#{@query} query #{@values_insert_update}"
    query = self.limit(1).execute_query
    # puts query.to_s
    if query.to_s != "[]"
      query.not_nil![0]
    else
      # puts "User not found"
      hash_result_empty = {} of String => JSON::Any
      hash_result_empty
    end
  end

  def execute_query
    begin
      result = [] of Hash(String, JSON::Any)
      puts @query
      puts @values_insert_update
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
      raise Exception.new("#{exception} - mysql")
      puts error
    end
  end

  def execute
    last_result = ""
    begin
      case @action_sql
      when "INSERT"
        result = @db.exec "#{@query}", @values_insert_update
        puts "Insert success"
        last_result = result.last_insert_id
      when "UPDATE"
        result = @db.exec("#{@query}", @values_insert_update)
        puts "Update success"
        result
      when "DELETE"
        puts "#{@query} es lo que sigue"
        result = @db.exec("#{@query}", @values_insert_update)
        puts "Delete success"
        result
      end
      puts "#{@values_insert_update} - clean db ::"
      self.clear
    rescue exception
      error = "#{exception}"
      self.clear

      if error.includes?("Duplicate entry")
        raise Exception.new("The email is already registered")
      end
      puts error
    end

    last_result
  end

  private def toJson(rs, column_names)
    json_data = JSON.build do |json|
      json.object do
        column_names.each do |field_s|
          json.field "#{field_s}", "#{rs.read(DB::Any | Int8 | JSON::Any)}"
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

  private def removeField(field, table)
    query = @query.split("GROUP BY ")[1]
    field_arr = [] of DB::Any

    list_group = query.split(",").each do |v_field|
      if @query.includes?("JOIN")
        if v_field != "#{table}.#{field}"
          field_arr << "#{v_field}"
        end
      else
        if v_field != "#{field}"
          field_arr << "#{v_field}"
        end
      end
    end

    @query = "#{@query.split("GROUP BY ")[0]} GROUP BY #{field_arr.join(",")}"

    self
  end

  private def clear(lugar = "")
    @values_insert_update.clear
    @query = ""
    @table = ""
    @action_sql = ""
    @select_concat = ""
  end

  def clean
    @values_insert_update.clear
    @query = ""
    @table = ""
    @action_sql = ""
    @select_concat = ""
  end

  # This examples of the funciotion for migrations
  # and form for using
  #
  # Database = Db.new
  #
  # Database.create_table? table: :usersK,
  #   column: [
  #     Database.row(row: :id, type: :int, is_null: true, auto_increment: true),
  #     Database.row(row: :email, type: :char, size: 1000, is_null: false),
  #     Database.row(row: :fullname, type: :string, size: 1000, is_null: false),
  #     Database.row(row: :password, type: :int, size: 200, is_null: false, default: "1234"),
  #     Database.row(row: :active_days, type: :bool , is_null: false),
  #     Database.row(row: :active_days, type: :time, default: :now, is_null: false)
  #   ],
  #   foreign: [:id, :images, :id],
  #   engine: "INNODB",
  #   unique: :id
  #
  #
  # Database.alter_add table: :usersK,
  #   column: [
  #     Database.row(row: :tis, type: :bool, is_null: false, first: :fullname, default: nil),
  #     Database.row(row: :fullname, type: :string, size: 300, is_null: true, after: :fullname)
  #   ]
  #
  # Database.alter_change table: :usersK, column: [[:fullname, Database.row(row: :fullname_new, type: :string, size: 300, is_null: true)]]
  #
  # Database.drop_column table: :usersK, column: [:fullname]
  #
  # Database.drop_table table: [:usersK, :shops]

  def runMigration
    create_table? table: :schema_db,
      column: [
        row(row: :id, type: :int, is_null: false, auto_increment: true),
        row(row: :version, type: :int, is_null: false, default: 0),
      ],
      unique: :id,
      primary: :id,
      engine: "INNODB",
      migration: 0

    self.endMigration

    version_schema = self.select([
      :version,
    ])
      .table(:schema_db)
      .first

    puts "#{version_schema.size} #{version_schema} version?????? #{version_schema.size < 1 ? "es menor, porque?" : "es mayor, esta bien"}"
    @migration_last_version = version_schema.size < 1 ? 0 : "#{version_schema["version"].not_nil!}".to_i
    self.table(:schema_db).insert([:version], [version_schema.size < 1 ? 0 : "#{version_schema["version"].not_nil!}".to_i]).execute if version_schema.size < 1
  end

  def endMigration
    puts @list_migration
    @list_migration.each { |migration|
      puts migration
      @db.exec migration
    }

    if @migration_last_version != 0
      puts "UPDATE schema_db SET version = #{@migration_last_version} >> create schema"
      @db.exec "UPDATE schema_db SET version = #{@migration_last_version}"
    end
  end

  def create_table?(*elements, table = "", column = [] of String, foreign = [] of Array(Array(Symbol)), unique = "", primary = "", engine = "INNODB", migration = 0) forall T
    insert_v = [] of String
    puts foreign
    foreign.each { |f|
      puts f
      insert_v << "FOREIGN KEY(#{f[0]}) REFERENCES #{f[1]}(#{f[2]})" if f.size > 0
    }
    insert_v << "UNIQUE(#{unique})" if !unique.to_s.empty?
    insert_v << "PRIMARY KEY(#{primary})" if !primary.to_s.empty?

    if migration == 0 || migration > @migration_last_version
      @list_migration << "CREATE TABLE IF NOT EXISTS #{table}(#{column.map { |values| values }.join(", ")}#{insert_v.size > 0 ? ", #{insert_v.join(", ")}" : ""}) ENGINE=#{engine};"
      @migration_last_version = migration
    end
  end

  def alter_add(*elements, table = "", column = [] of String, migration = 0)
    column.each { |row|
      if migration == 0 || migration > @migration_last_version
        @list_migration << "ALTER TABLE #{table} ADD #{row}"
        @migration_last_version = migration
      end
    }
  end

  def alter_modify(*elements, table = "", column = [] of String, migration = 0)
    column.each { |row|
      if migration == 0 || migration > @migration_last_version
        @list_migration << "ALTER TABLE #{table} MODIFY #{row}"
        @migration_last_version = migration
      end
    }
  end

  def alter_change(*elements, table = "", column = [] of Array(String), migration = 0)
    column.each { |row|
      if migration == 0 || migration > @migration_last_version
        @list_migration << "ALTER TABLE #{table} CHANGE #{row[0]} #{row[1]}"
        @migration_last_version = migration
      end
    }
  end

  def drop_column(*elemetns, table = "", column = [] of Symbol, migration = 0)
    column.each { |col|
      if migration == 0 || migration > @migration_last_version
        @list_migration << "ALTER TABLE #{table} DROP #{col}"
        @migration_last_version = migration
      end
    }
  end

  def drop_table(table = [] of Symbol, migration = 0)
    if migration >= @migration_last_version
      @list_migration << "DROP TABLE IF EXISTS #{table.join(", ")}"
      @migration_last_version = migration
    end
  end

  def row(*elements, row, type, enum_values = [] of (String | Int32 | Int8 | Int64), size = "", is_null = false, default = "", after = "", first = "", auto_increment = false)
    type_size = ""
    if @values["#{type}"] == "ENUM"
      type_size = "ENUM(#{enum_values.map { |e| "\"#{e}\"" }.join(", ")})"
    else
      type_size = "#{@values["#{type}"]}#{addSize(type) && !size.to_s.empty? ? "(#{size})" : ""}"
    end
    in_auto_increment = "#{auto_increment ? " AUTO_INCREMENT" : ""}"
    is_null = "#{is_null ? "NULL" : "NOT NULL"}"
    in_after = "#{!after.to_s.empty? ? " AFTER #{after}" : ""}"
    in_first = "#{!first.to_s.empty? ? " FIRST" : ""}"
    firts_default = !default.to_s.empty? ? " DEFAULT #{type_default(default)}" : ""
    in_default = "#{default.nil? ? " DEFAULT #{type_default(default)}" : firts_default}"
    "#{row} #{type_size} #{is_null}#{in_after}#{in_first}#{in_auto_increment}#{in_default}"
  end

  # Float64
  # Int32
  # String
  # Bool
  private def type_default(default)
    case default.class.to_s
    when "Float64"
      default
    when "Int32"
      default
    when "String"
      "\"#{default}\""
    when "Bool"
      default
    when "Nil"
      "NULL"
    when "Symbol"
      "NOW()"
    end
  end

  private def addSize(type)
    case "#{type}"
    when "string"
      true
    when "text"
      true
    when "varchar"
      true
    when "character"
      true
    when "char"
      true
    when "clob"
      true
    when "blob"
      true
    when "int"
      true
    else
      false
    end
  end
end
