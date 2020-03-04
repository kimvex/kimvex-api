def executeMigration
  DB_K.runMigration

  DB_K.create_table? table: :usersk, column: [
    DB_K.row(row: :user_id, type: :int, is_null: false, auto_increment: true),
    DB_K.row(row: :fullname, type: :varchar, size: 250, is_null: false),
    DB_K.row(row: :email, type: :varchar, size: 250, is_null: false),
    DB_K.row(row: :password, type: :varchar, size: 250, is_null: false),
    DB_K.row(row: :phone, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :image, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :age, type: :datetime, is_null: true),
    DB_K.row(row: :address, type: :varchar, size: 300, is_null: true),
    DB_K.row(row: :gender, type: :enum, enum_values: ["MALE", "FEMALE"], is_null: true),
    DB_K.row(row: :status, type: :bool, is_null: true, default: false),
    DB_K.row(row: :create_at, type: :datetime, is_null: false, default: :now),
  ],
    engine: "INNODB",
    primary: :user_id,
    unique: :email,
    migration: 1

  DB_K.create_table? table: :service_type, column: [
    DB_K.row(row: :service_type_id, type: :int, auto_increment: true),
    DB_K.row(row: :service_name, type: :varchar, size: 120, is_null: false),
  ],
    engine: "INNODB",
    primary: :service_type_id,
    migration: 2

  DB_K.create_table? table: :sub_service_type, column: [
    DB_K.row(row: :sub_service_type_id, type: :int, auto_increment: true),
    DB_K.row(row: :sub_service_name, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :service_type_id, type: :int, is_null: false),
  ],
    foreign: [
      [:service_type_id, :service_type, :service_type_id],
    ],
    engine: "INNODB",
    primary: :sub_service_type_id,
    migration: 3

  DB_K.create_table? table: :shop, column: [
    DB_K.row(row: :shop_id, type: :int, auto_increment: true),
    DB_K.row(row: :shop_name, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :address, type: :varchar, size: 200, is_null: false),
    DB_K.row(row: :phone, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :phone2, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :description, type: :varchar, size: 1000, is_null: true),
    DB_K.row(row: :cover_image, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :accept_card, type: :bool, default: false, is_null: true),
    DB_K.row(row: :list_cards, type: :varchar, size: 200, is_null: true),
    DB_K.row(row: :service_type_id, type: :int, is_null: false),
    DB_K.row(row: :sub_service_type_id, type: :int, is_null: false),
    DB_K.row(row: :lat, type: :varchar, size: 50, is_null: true),
    DB_K.row(row: :lon, type: :varchar, size: 50, is_null: true),
    DB_K.row(row: :score_shop, type: :int, size: 12, is_null: true),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :status, type: :bool, default: false, is_null: true),
    DB_K.row(row: :logo, type: :varchar, size: 120, is_null: true),
    DB_K.row(row: :facebook, type: :varchar, size: 220, is_null: true),
    DB_K.row(row: :instagram, type: :varchar, size: 220, is_null: true),
    DB_K.row(row: :twitter, type: :varchar, size: 220, is_null: true),
    DB_K.row(row: :page_url, type: :varchar, size: 220, is_null: true),
    DB_K.row(row: :create_at_shop, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :expired, type: :bool, default: false, is_null: true),
    DB_K.row(row: :canceled, type: :bool, default: false, is_null: true),
    DB_K.row(row: :lock_shop, type: :bool, default: false, is_null: true),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:service_type_id, :service_type, :service_type_id],
      [:sub_service_type_id, :sub_service_type, :sub_service_type_id],
    ],
    engine: "INNODB",
    primary: :shop_id,
    migration: 4

  DB_K.create_table? table: :images_shop, column: [
    DB_K.row(row: :image_id, type: :int, is_null: false, auto_increment: true),
    DB_K.row(row: :url_image, type: :varchar, size: 200, is_null: false),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
  ],
    foreign: [
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :image_id,
    migration: 5

  DB_K.create_table? table: :shop_schedules, column: [
    DB_K.row(row: :shop_schedules_id, type: :int, auto_increment: true),
    DB_K.row(row: :LUN, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :MAR, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :MIE, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :JUE, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :VIE, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :SAB, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :DOM, type: :varchar, size: 50, default: "CLOSE", is_null: true),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
  ],
    foreign: [
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :shop_schedules_id,
    migration: 6

  DB_K.create_table? table: :shop_comments, column: [
    DB_K.row(row: :comment_id, type: :int, auto_increment: true),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :comment, type: :varchar, size: 500, is_null: false),
    DB_K.row(row: :create_date_at, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :edit_date_at, type: :datetime, is_null: true),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :comment_id,
    migration: 7

  DB_K.create_table? table: :shop_score_users, column: [
    DB_K.row(row: :score, type: :int, is_null: false),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :user_id, type: :int, is_null: false),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    migration: 8

  DB_K.create_table? table: :plans_pay, column: [
    DB_K.row(row: :plans_id, type: :int, auto_increment: true),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :date_init, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :date_finish, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :type_pay, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :order_id, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :amount, type: :int, is_null: false),
    DB_K.row(row: :type_charge, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :id_trasaction, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :currency, type: :varchar, size: 12, is_null: false),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :plans_id,
    migration: 9

  DB_K.create_table? table: :refund_pay, column: [
    DB_K.row(row: :refund_id, type: :int, auto_increment: true),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :plans_pay_trasaction, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :amount, type: :int, is_null: false),
    DB_K.row(row: :id_refund, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :date_refund, type: :datetime, is_null: true),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :refund_id,
    migration: 10

  DB_K.create_table? table: :offers, column: [
    DB_K.row(row: :offers_id, type: :int, auto_increment: true),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :title, type: :varchar, size: 120, is_null: false),
    DB_K.row(row: :description, type: :varchar, size: 500, is_null: false),
    DB_K.row(row: :date_init, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :date_end, type: :datetime, is_null: false),
    DB_K.row(row: :image_url, type: :varchar, size: 250, is_null: true),
    DB_K.row(row: :active, type: :bool, default: false, is_null: true),
    DB_K.row(row: :lat, type: :varchar, size: 50, is_null: true),
    DB_K.row(row: :lon, type: :varchar, size: 50, is_null: true),
    DB_K.row(row: :create_at_offer, type: :datetime, is_null: false, default: :now),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :offers_id,
    migration: 11

  DB_K.create_table? table: :code_verify, column: [
    DB_K.row(row: :code_id, type: :int, auto_increment: true),
    DB_K.row(row: :email, type: :varchar, size: 250, is_null: true),
    DB_K.row(row: :phone, type: :int, size: 12, is_null: true),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :code, type: :varchar, size: 10, is_null: false),
    DB_K.row(row: :active, type: :bool, default: false, is_null: true),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
    ],
    engine: "INNODB",
    primary: :code_id,
    migration: 12

  DB_K.create_table? table: :code_restore, column: [
    DB_K.row(row: :code_id, type: :int, auto_increment: true),
    DB_K.row(row: :email, type: :varchar, size: 250, is_null: true),
    DB_K.row(row: :phone, type: :int, size: 12, is_null: true),
    DB_K.row(row: :user_id, type: :int, is_null: false),
    DB_K.row(row: :code, type: :varchar, size: 10, is_null: false),
    DB_K.row(row: :active, type: :bool, default: false, is_null: true),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
    ],
    engine: "INNODB",
    primary: :code_id,
    migration: 13

  DB_K.create_table? table: :code_reference, column: [
    DB_K.row(row: :code_reference_id, type: :int, auto_increment: true),
    DB_K.row(row: :code, type: :varchar, size: 20, is_null: false),
    DB_K.row(row: :user_id, type: :int, is_null: false),
  ],
    foreign: [
      [:user_id, :usersk, :user_id],
    ],
    engine: "INNODB",
    primary: :code_reference_id,
    migration: 14

  DB_K.create_table? table: :code_used, column: [
    DB_K.row(row: :code_use_id, type: :int, auto_increment: true),
    DB_K.row(row: :code_reference_id, type: :int, is_null: false),
    DB_K.row(row: :plans_id, type: :int, is_null: false),
    DB_K.row(row: :refund_id, type: :int, is_null: true),
    DB_K.row(row: :money_win, type: :varchar, size: 20, is_null: true),
    DB_K.row(row: :day_used, type: :datetime, is_null: false, default: :now),
    DB_K.row(row: :valid_for_charged, type: :bool, default: true, is_null: true),
    DB_K.row(row: :paid_out, type: :bool, is_null: true),
    DB_K.row(row: :day_pay_out, type: :datetime, is_null: true),
  ],
    foreign: [
      [:code_reference_id, :code_reference, :code_reference_id],
      [:plans_id, :plans_pay, :plans_id],
      [:refund_id, :refund_pay, :refund_id],
    ],
    engine: "INNODB",
    primary: :code_use_id,
    migration: 15

  DB_K.create_table? table: :pages, column: [
    DB_K.row(row: :pages_id, type: :int, auto_increment: true),
    DB_K.row(row: :shop_id, type: :int, is_null: false),
    DB_K.row(row: :active, type: :bool, default: false, is_null: true),
    DB_K.row(row: :template_type, type: :varchar, size: 10, default: 1, is_null: true),
    DB_K.row(row: :style_sheets, type: :varchar, size: 10, default: 1, is_null: true),
    DB_K.row(row: :active_days, type: :bool, default: true, is_null: true),
    DB_K.row(row: :images_days, type: :bool, default: true, is_null: true),
    DB_K.row(row: :offers_active, type: :bool, default: true, is_null: true),
    DB_K.row(row: :accept_card_active, type: :bool, default: true, is_null: true),
    DB_K.row(row: :subdomain, type: :varchar, size: 60, is_null: true),
    DB_K.row(row: :domain, type: :varchar, size: 100, is_null: true),
  ],
    foreign: [
      [:shop_id, :shop, :shop_id],
    ],
    engine: "INNODB",
    primary: :pages_id,
    migration: 16

  DB_K.endMigration
end
