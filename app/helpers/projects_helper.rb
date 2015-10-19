module ProjectsHelper
  def authen(project_id)
    projects = Project.where(:id=>project_id)
    projects.each do |pro|
     version_id = pro.version_repository_id
     redmin_id = pro.ticket_repository_id
      if version_id == nil && redmin_id == nil
        return false
      else

          return true
      end
  end
  end
end

