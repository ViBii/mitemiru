class CreateVersionRepositories < ActiveRecord::Migration
  def change
    create_table :version_repositories do |t|
      t.integer :commit_volume

      t.timestamps null: false
    end
  end
end
