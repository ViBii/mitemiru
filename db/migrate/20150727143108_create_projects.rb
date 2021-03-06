class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :version_repository_id
      t.integer :ticket_repository_id
      t.string  :name
      t.time    :project_start_date
      t.time    :project_end_date

      t.timestamps null: false
    end
  end
end
