class ChangeDatatypeTimeOfAssignLogsAndProjects < ActiveRecord::Migration
  def change
    change_column :projects, :project_start_date, :datetime
    change_column :projects, :project_end_date,   :datetime
    change_column :assign_logs, :assign_start_date, :datetime
    change_column :assign_logs, :assign_end_date,   :datetime
  end
end
