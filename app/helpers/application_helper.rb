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

  def show_project?(user, project)
    show_project = nil
    if user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
      show_project = true if project.version_repository_id.blank?
    end
    if user.github_keys.where(version_repository_id: project.version_repository_id).present?
      show_project = true if project.ticket_repository_id.blank?
    end
    if user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
      show_project = true if user.github_keys.where(version_repository_id: project.version_repository_id).present?
    end
    show_project = false if show_project.blank?
    return show_project
  end

  def show_developer?(user, developer)
    show_developer = nil
    developer.projects.each do |project|
      if user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
        if project.version_repository_id.blank?
          show_developer = true
          break
        end
      end
      if user.github_keys.where(version_repository_id: project.version_repository_id).present?
        if project.ticket_repository_id.blank?
          show_developer = true
          break
        end
      end
      if user.redmine_keys.where(ticket_repository_id: project.ticket_repository_id).present?
        if user.github_keys.where(version_repository_id: project.version_repository_id).present?
          show_developer = true
          break
        end
      end
      show_developer = false
    end
    return show_developer
  end
end
