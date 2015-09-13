class CreateRedmineKeys < ActiveRecord::Migration
  def change
    create_table :redmine_keys do |t|
      t.integer :ticket_repository_id
      t.string  :login_id
      t.string  :password_digest
      t.string  :api_key

      t.timestamps null: false
    end
  end
end
