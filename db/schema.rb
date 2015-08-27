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

ActiveRecord::Schema.define(version: 20150827051554) do

  create_table "assign_logs", force: :cascade do |t|
    t.integer  "developer_id",      limit: 4
    t.integer  "project_id",        limit: 4
    t.time     "assign_start_date"
    t.time     "assign_end_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "developers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "adress",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "version_repository_id", limit: 4
    t.integer  "ticket_repository_id",  limit: 4
    t.string   "name",                  limit: 255
    t.time     "project_start_date"
    t.time     "project_end_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "redmine_authorities", force: :cascade do |t|
    t.integer "user_id",        limit: 4
    t.integer "redmine_key_id", limit: 4
  end

  create_table "redmine_keys", force: :cascade do |t|
    t.integer  "ticket_repository_id", limit: 4
    t.string   "login_name",           limit: 255
    t.string   "password_digest",      limit: 255
    t.string   "api_key",              limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "ticket_repositories", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "version_repositories", force: :cascade do |t|
    t.string   "path",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "path",       limit: 255
  end

end
