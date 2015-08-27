class CreateRedmineAuthorities < ActiveRecord::Migration
  def change
    create_table :redmine_authorities do |t|
      t.integer :user_id
      t.integer :redmine_key_id
    end
  end
end
