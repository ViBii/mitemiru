class CreateVersionRepositories < ActiveRecord::Migration
  def change
    create_table :version_repositories do |t|
      t.string :path

      t.timestamps null: false
    end
  end
end
