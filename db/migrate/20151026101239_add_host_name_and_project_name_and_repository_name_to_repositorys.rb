class AddHostNameAndProjectNameAndRepositoryNameToRepositorys < ActiveRecord::Migration
  def change
    add_column :ticket_repositories,  :project_name, :string
    add_column :ticket_repositories,  :host_name, :string
    add_column :version_repositories, :project_name, :string
    add_column :version_repositories, :repository_name, :string
    remove_column :ticket_repositories, :url
    remove_column :version_repositories, :url
  end
end
