module ProjectsHelper
  def authen(project_id)
    project = Project.where(id=>project_id);
  end
end
