class CreateAssignLogs < ActiveRecord::Migration
  def change
    create_table :assign_logs do |t|
      t.integer :developer_id
      t.integer :project_id
      t.time :assign_start_date
      t.time :assign_end_date

      t.timestamps null: false
    end
  end
end
