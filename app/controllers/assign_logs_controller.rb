class AssignLogsController < ApplicationController
  before_action :set_assignlog, only: [:show, :edit, :update, :destroy]

  def index

  end

  def new
    @assign_log = AssignLog.new
  end

  def show
  end

  def create
    @assign_log = AssignLog.new(assignlog_params)

    respond_to do |format|
      if @assign_log.save
        format.html { redirect_to @assign_log, notice: 'AssignLog was successfully created.' }
        format.json { render :show, status: :created, location: @assign_log }
      else
        format.html { render :new }
        format.json { render json: @assign_log.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_assignlog
    @assign_log = AssignLog.find(params[:id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def assignlog_params
    params.require(:assign_log).permit(
        :developer_id,
        :project_id
    )
  end
end
