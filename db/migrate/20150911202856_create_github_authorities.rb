class CreateGithubAuthorities < ActiveRecord::Migration
  def change
    create_table :github_authorities do |t|
      t.integer :user_id
      t.integer :github_key_id

      t.timestamps null: false
    end
  end
end
