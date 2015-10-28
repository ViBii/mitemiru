module ApplicationHelper
  # TODO: テスト記述しないと...

  def auth_git(project_id)
    project = Project.where(:id => project_id)
    return true if project.first.version_repository_id.present?
    false
  end

  def auth_red(project_id)
    project = Project.where(:id => project_id)
    return true if project.first.ticket_repository_id.present?
    false
  end

  def show_project?(project)
    if current_user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
      true
    elsif current_user.github_keys.where(version_repository_id: project.version_repository_id).present?
      true
    else
      false
    end
  end

  def show_developer?(developer)
    show_developer = nil
    developer.projects.each do |project|
      if current_user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
        show_developer = true
        break
      elsif current_user.github_keys.where(version_repository_id: project.version_repository_id).present?
        show_developer = true
        break
      else
        show_developer = false
      end
    end
    return show_developer
  end
end
