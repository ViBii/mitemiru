class CreateRedmineKeys < ActiveRecord::Migration
  def change
    create_table :redmine_keys do |t|
      t.integer :ticket_repositoty_id
      t.integer :user_id
      t.string :api_key
      t.string :url
      t.string :login_name
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
