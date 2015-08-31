class AssignLogsController < ApplicationController
  def index
    @assign_log = AssignLog.new
  end
end
