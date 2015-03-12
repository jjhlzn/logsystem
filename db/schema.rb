# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150312050441) do

  create_table "auth_group", force: true do |t|
    t.string "name", limit: 80, null: false
  end

  add_index "auth_group", ["name"], name: "name", unique: true, using: :btree

  create_table "auth_group_permissions", force: true do |t|
    t.integer "group_id",      null: false
    t.integer "permission_id", null: false
  end

  add_index "auth_group_permissions", ["group_id", "permission_id"], name: "group_id", unique: true, using: :btree
  add_index "auth_group_permissions", ["group_id"], name: "auth_group_permissions_5f412f9a", using: :btree
  add_index "auth_group_permissions", ["permission_id"], name: "auth_group_permissions_83d7f98b", using: :btree

  create_table "auth_permission", force: true do |t|
    t.string  "name",            limit: 50,  null: false
    t.integer "content_type_id",             null: false
    t.string  "codename",        limit: 100, null: false
  end

  add_index "auth_permission", ["content_type_id", "codename"], name: "content_type_id", unique: true, using: :btree
  add_index "auth_permission", ["content_type_id"], name: "auth_permission_37ef4eb4", using: :btree

  create_table "auth_user", force: true do |t|
    t.string   "password",     limit: 128, null: false
    t.datetime "last_login",               null: false
    t.boolean  "is_superuser",             null: false
    t.string   "username",     limit: 30,  null: false
    t.string   "first_name",   limit: 30,  null: false
    t.string   "last_name",    limit: 30,  null: false
    t.string   "email",        limit: 75,  null: false
    t.boolean  "is_staff",                 null: false
    t.boolean  "is_active",                null: false
    t.datetime "date_joined",              null: false
  end

  add_index "auth_user", ["username"], name: "username", unique: true, using: :btree

  create_table "auth_user_groups", force: true do |t|
    t.integer "user_id",  null: false
    t.integer "group_id", null: false
  end

  add_index "auth_user_groups", ["group_id"], name: "auth_user_groups_5f412f9a", using: :btree
  add_index "auth_user_groups", ["user_id", "group_id"], name: "user_id", unique: true, using: :btree
  add_index "auth_user_groups", ["user_id"], name: "auth_user_groups_6340c63c", using: :btree

  create_table "auth_user_user_permissions", force: true do |t|
    t.integer "user_id",       null: false
    t.integer "permission_id", null: false
  end

  add_index "auth_user_user_permissions", ["permission_id"], name: "auth_user_user_permissions_83d7f98b", using: :btree
  add_index "auth_user_user_permissions", ["user_id", "permission_id"], name: "user_id", unique: true, using: :btree
  add_index "auth_user_user_permissions", ["user_id"], name: "auth_user_user_permissions_6340c63c", using: :btree

  create_table "django_admin_log", force: true do |t|
    t.datetime "action_time",                        null: false
    t.integer  "user_id",                            null: false
    t.integer  "content_type_id"
    t.text     "object_id",       limit: 2147483647
    t.string   "object_repr",     limit: 200,        null: false
    t.integer  "action_flag",     limit: 2,          null: false
    t.text     "change_message",  limit: 2147483647, null: false
  end

  add_index "django_admin_log", ["content_type_id"], name: "django_admin_log_37ef4eb4", using: :btree
  add_index "django_admin_log", ["user_id"], name: "django_admin_log_6340c63c", using: :btree

  create_table "django_content_type", force: true do |t|
    t.string "name",      limit: 100, null: false
    t.string "app_label", limit: 100, null: false
    t.string "model",     limit: 100, null: false
  end

  add_index "django_content_type", ["app_label", "model"], name: "app_label", unique: true, using: :btree

  create_table "django_session", primary_key: "session_key", force: true do |t|
    t.text     "session_data", limit: 2147483647, null: false
    t.datetime "expire_date",                     null: false
  end

  add_index "django_session", ["expire_date"], name: "django_session_b7b81f0c", using: :btree

  create_table "logsystem_ordersystemlogrecord", force: true do |t|
    t.string "time",    limit: 200,   null: false
    t.string "thread",  limit: 500,   null: false
    t.string "level",   limit: 500,   null: false
    t.string "clazz",   limit: 500,   null: false
    t.string "content", limit: 20000, null: false
  end

  add_index "logsystem_ordersystemlogrecord", ["time"], name: "index_time", using: :btree

  create_table "logsystem_parseposition", id: false, force: true do |t|
    t.string   "application", limit: 200
    t.integer  "filesize"
    t.datetime "parsetime"
    t.string   "end_content", limit: 4000
  end

  create_table "lottery_coupon", force: true do |t|
    t.string  "name",             limit: 100, null: false
    t.string  "code",             limit: 100, null: false
    t.boolean "status",                       null: false
    t.boolean "has_send",                     null: false
    t.integer "lotteryRecord_id"
  end

  add_index "lottery_coupon", ["lotteryRecord_id"], name: "lottery_coupon_aab7bfbf", using: :btree

  create_table "lottery_lotteryconfiguration", force: true do |t|
    t.string  "type",         limit: 500, null: false
    t.string  "string_value", limit: 500, null: false
    t.integer "int_value",                null: false
  end

  create_table "lottery_lotteryrecord", force: true do |t|
    t.string   "ip",           limit: 100,              null: false
    t.string   "username",     limit: 100,              null: false
    t.string   "mobile",       limit: 100,              null: false
    t.integer  "level",                                 null: false
    t.datetime "lottery_time",                          null: false
    t.string   "prize_name",   limit: 500,              null: false
    t.date     "comedate"
    t.string   "identity",     limit: 100, default: ""
  end

  create_table "lottery_prize", force: true do |t|
    t.string  "name",        limit: 500, null: false
    t.integer "quantity",                null: false
    t.date    "expire_date",             null: false
    t.integer "use_count",               null: false
  end

  create_table "lottery_prizeconfiguration", force: true do |t|
    t.integer "prize_id",  null: false
    t.date    "date",      null: false
    t.integer "count",     null: false
    t.integer "use_count", null: false
  end

  add_index "lottery_prizeconfiguration", ["prize_id"], name: "lottery_prizeconfiguration_0f3583ba", using: :btree

  create_table "lottery_question", force: true do |t|
    t.string "question", limit: 4000, null: false
    t.string "option1",  limit: 500,  null: false
    t.string "option2",  limit: 500,  null: false
    t.string "option3",  limit: 500,  null: false
    t.string "answer",   limit: 500,  null: false
  end

  create_table "lottery_questioncode", force: true do |t|
    t.string   "code",   limit: 100, null: false
    t.boolean  "status",             null: false
    t.datetime "time",               null: false
  end

  create_table "requests", force: true do |t|
    t.integer  "firstLog"
    t.integer  "endLog"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
