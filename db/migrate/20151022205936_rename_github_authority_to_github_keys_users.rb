class RenameGithubAuthorityToGithubKeysUsers < ActiveRecord::Migration
  def change
    rename_table :github_authorities, :github_keys_users
  end
end
