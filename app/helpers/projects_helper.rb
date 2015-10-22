module ProjectsHelper
  def auth_git(project_id)
    project = Project.where(:id=>project_id)
    return true if project.first.version_repository_id.present?
    false
  end

  def auth_red(project_id)
    project = Project.where(:id=>project_id)
    return true if project.first.ticket_repository_id.present?
    false
  end
end

