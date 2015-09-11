class CreateGithubKeys < ActiveRecord::Migration
  def change
    create_table :github_keys do |t|
      t.integer :version_repository_id
      t.string :login_id
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
