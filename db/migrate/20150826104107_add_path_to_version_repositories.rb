class AddPathToVersionRepositories < ActiveRecord::Migration
  def change
    add_column :version_repositories, :path, :string
  end
end
