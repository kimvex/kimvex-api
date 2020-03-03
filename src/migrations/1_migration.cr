def executeMigration
  DB_K.runMigration

  DB_K.create_table? table: :test_global, column: [
    DB_K.row(row: :id, type: :int, is_null: false, auto_increment: true),
    DB_K.row(row: :prueba, type: :string, size: 100, is_null: false),
    DB_K.row(row: :laspruebas, type: :bool, is_null: false, default: false),
    DB_K.row(row: :tiempo, type: :timestamp, is_null: false, default: :now),
    DB_K.row(row: :user_id, type: :int, is_null: false),
  ],
    foreign: [:user_id, :usersk, :user_id],
    engine: "INNODB",
    primary: :id,
    migration: 1

  DB_K.create_table? table: :new_table, column: [
    DB_K.row(row: :new_table_id, type: :int, is_null: false, auto_increment: true),
    DB_K.row(row: :datos, type: :string, size: 200, is_null: :true, default: "place holder"),
    DB_K.row(row: :user_id, type: :int, is_null: false),
  ],
    foreign: [:user_id, :usersk, :user_id],
    engine: "INNODB",
    primary: :new_table_id,
    migration: 2

  DB_K.drop_table table: [:test_global, :new_table], migration: 3

  DB_K.endMigration
end
