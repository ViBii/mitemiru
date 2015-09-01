class CreateCommitInfos < ActiveRecord::Migration
  def change
    create_table :commit_infos do |t|
      t.integer :version_repository_id
      t.integer :developer_id
      t.string :commit_id
      t.string :commit_message

      t.timestamps null: false
    end
  end
end
