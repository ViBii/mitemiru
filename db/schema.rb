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

ActiveRecord::Schema.define(version: 20151026101239) do

  create_table "assign_logs", force: :cascade do |t|
    t.integer  "developer_id",      limit: 4
    t.integer  "project_id",        limit: 4
    t.datetime "assign_start_date"
    t.datetime "assign_end_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "developers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "github_keys", force: :cascade do |t|
    t.integer  "version_repository_id", limit: 4
    t.string   "login_id",              limit: 255
    t.string   "password_digest",       limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "github_keys_users", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "github_key_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "version_repository_id", limit: 4
    t.integer  "ticket_repository_id",  limit: 4
    t.string   "name",                  limit: 255
    t.datetime "project_start_date"
    t.datetime "project_end_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "redmine_keys", force: :cascade do |t|
    t.integer  "ticket_repository_id", limit: 4
    t.string   "login_id",             limit: 255
    t.string   "password_digest",      limit: 255
    t.string   "api_key",              limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "redmine_keys_users", force: :cascade do |t|
    t.integer "user_id",        limit: 4
    t.integer "redmine_key_id", limit: 4
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4, null: false
    t.integer "role_id", limit: 4, null: false
  end

  create_table "ticket_repositories", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "project_name", limit: 255
    t.string   "host_name",    limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "login_id",               limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "version_repositories", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "project_name",    limit: 255
    t.string   "repository_name", limit: 255
  end

end
