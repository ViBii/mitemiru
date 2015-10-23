class RenameRedmineAuthorityToRedmineKeysUsers < ActiveRecord::Migration
  def change
    rename_table :redmine_authorities, :redmine_keys_users
  end
end
