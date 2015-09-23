class CommitCounterController < ApplicationController
  def index
    @developer = Developer.all
  end

  def select_projects
    @project = Project.all
  end

  def draw_graph
  end
end
