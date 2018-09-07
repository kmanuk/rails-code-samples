# == Schema Information
#
# Table name: report_groups
#
#  id             :integer          not null, primary key
#  name           :string
#  on             :integer
#  depth          :integer
#  web_project_id :integer
#  datable_type   :string
#  datable_id     :integer
#  date_type      :integer
#  outdated       :boolean
#
# Indexes
#
#  index_report_groups_on_web_project_id  (web_project_id)
#
class ReportGroup < ApplicationRecord
  include ActiveModel::Validations
  validates :on, :depth, :name, presence: true
  # validates_with ReportValidator

  # has_one :range_date
  # has_one :single_date, as: :datable, class_name: 'MonitoringDate'
  belongs_to :datable, polymorphic: true
  has_one :dashboard_item, as: :boardable, dependent: :destroy

  has_many :reports, dependent: :destroy
  has_many :detailed_reports, dependent: :destroy
  belongs_to :web_project

  enum on: %i[avg sentiment reputation]
  enum date_type: %i[monitoring range]
  enum depth: %w[10 20 50 100]

  delegate :date, to: :datable

  scope :search_engines, lambda(object) {
    ReportItem.joins('JOIN reports ON report_items.report_id = reports.id
                      JOIN report_groups ON reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and report_items.itemable_type = ?', object.id, 'SearchEngine')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }

  scope :keywords, lambda(object) {
    ReportItem.joins('JOIN reports ON report_items.report_id = reports.id
                      JOIN report_groups ON reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and report_items.itemable_type = ?', object.id, 'Keyword')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }

  scope :keywords_groups, lambda(object) {
    ReportItem.joins('JOIN reports ON report_items.report_id = reports.id
                      JOIN report_groups ON reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and report_items.itemable_type = ?', object.id, 'KeywordsGroup')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }
  scope :tracking_groups, lambda(object) {
    ReportItem.joins('JOIN reports ON report_items.report_id = reports.id
                      JOIN report_groups ON reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and report_items.itemable_type = ?', object.id, 'TrackingGroup')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }

  scope :search_engines_detail, lambda(object) {
    ReportItem.joins('JOIN detailed_reports ON detailed_report_items.report_id = detailed_reports.id
                      JOIN report_groups ON detailed_reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and detailed_report_items.itemable_type = ?', object.id, 'SearchEngineDetail')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }

  scope :keywords_detail, lambda(object) {
    ReportItem.joins('JOIN detailed_reports ON detailed_report_items.report_id = detailed_reports.id
                      JOIN report_groups ON detailed_reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and detailed_report_items.itemable_type = ?', object.id, 'KeywordDetail')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }

  scope :keywords_groups_detail, lambda(object) {
    ReportItem.joins('JOIN detailed_reports ON detailed_report_items.report_id = detailed_reports.id
                      JOIN report_groups ON detailed_reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and detailed_report_items.itemable_type = ?', object.id, 'KeywordsGroupDetail')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }
  scope :tracking_groups_detail, lambda(object) {
    ReportItem.joins('JOIN detailed_reports ON detailed_report_items.report_id = detailed_reports.id
                      JOIN report_groups ON detailed_reports.report_group_id = report_groups.id')
              .where('report_groups.id = ? and detailed_report_items.itemable_type = ?', object.id, 'TrackingGroupDetail')
              .includes(:itemable)
              .map(&:itemable)
              .uniq
  }
end
