class V1::ReportGroupsController < ApplicationController
  # swagger_controller :keywords_groups, "Keywords Groups Management"

  load_and_authorize_resource :client
  load_and_authorize_resource :web_project, through: :client
  load_and_authorize_resource :report_group, through: :web_project

  def index
    render json: @report_groups
  end

  def create
    @report_group = Services::ReportGroupService.save(@report_group, report_group_options)

    if @report_group.save
      render json: {
        report_group: ReportGroupSerializer.new(@report_group).as_json
      }, status: :created
    else
      render json: { errors: @report_group.errors }
    end
  end

  def update
    new_report_group = Services::ReportGroupService.new(report_group_params).update(@report_group)
    new_report_group.web_project = @web_project

    if new_report_group.save
      render json: {
        report_group: ReportGroupSerializer.new(new_report_group).as_json
      }
    else
      render json: { errors: @report_group.errors }
    end
  end

  def destroy
    @report_group.destroy

    render json: { id: @report_group.id }
  end

  private

  def report_group_params
    params
      .require(:report_group)
      .permit(:id,
              :name,
              :on,
              :date_type,
              :depth)
  end

  def report_group_options
    params
      .require(:report_group)
      .permit(:date,
              search_engine_ids: [],
              keyword_ids: [],
              keywords_group_ids: [],
              tracking_group_ids: [])
  end
end
