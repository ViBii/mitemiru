module ProjectsHelper
  def authen(project_id)
    projects = Project.where(id=>project_id);
    projects.each do |pro|

    end
  end
end
