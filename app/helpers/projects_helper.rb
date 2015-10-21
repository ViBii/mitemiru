module ProjectsHelper
  def authen(project_id)
    project = Project.where(:id=>project_id)
    return true if project.first.version_repository_id.present?
    false


  end
end

