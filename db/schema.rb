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

ActiveRecord::Schema.define(version: 20131029091655) do

  create_table "messages", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "viewed?",     default: false
  end

  create_table "posts", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "image"
  end

  add_index "posts", ["created_at"], name: "index_posts_on_created_at"
  add_index "posts", ["state"], name: "index_posts_on_state"
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "ratings", force: true do |t|
    t.integer  "user_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_id"
  end

  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "responses", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "responses", ["created_at"], name: "index_responses_on_created_at"
  add_index "responses", ["post_id"], name: "index_responses_on_post_id"
  add_index "responses", ["user_id"], name: "index_responses_on_user_id"

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["post_id", "user_id"], name: "index_subscriptions_on_post_id_and_user_id", unique: true
  add_index "subscriptions", ["post_id"], name: "index_subscriptions_on_post_id"
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                  default: false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.integer  "token_id"
    t.datetime "token_timer"
    t.integer  "score",                  default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
