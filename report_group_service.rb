module Services
  class ReportGroupService
    def self.save(report_group, options = {})
      web_project     = report_group.web_project

      keywords        = web_project.keywords.where(id: options[:keyword_ids])
      keywords_groups = web_project.keywords_groups.where(id: options[:keywords_group_ids])
      search_engines  = web_project.search_engines.where(id: options[:search_engine_ids])
      tracking_groups = web_project.tracking_groups.where(id: options[:tracking_group_ids])

      date = options[:date]

      service = new(report_group,
                    report_group: report_group,
                    keywords: keywords,
                    keywords_groups: keywords_groups,
                    search_engines: search_engines,
                    tracking_groups: tracking_groups,
                    date: date)

      service.set_date
      report_group.save

      if report_group.errors.blank?
        options = service.get_options
        ReportManager.create_reports(options)
        DetailedReportManager.create_reports(options)
      end

      report_group
    end

    def self.update(report_group)
      service = new(
        report_group,
        report_group: report_group,
        keywords: ReportGroup.keywords(report_group),
        keywords_groups: ReportGroup.keywords_groups(report_group),
        search_engines: ReportGroup.search_engines(report_group),
        tracking_groups: ReportGroup.tracking_groups(report_group)
      )

      options = service.get_options
      ReportManager.update_reports(options)
      DetailedReportManager.update_reports(options)
    end

    attr_reader :report_group

    def initialize(report_group, options)
      @report_group = report_group
      @options = options
    end

    def set_date
      date = @options[:date]

      report_group.datable =
        case report_group.date_type
        when 'monitoring'
          MonitoringDate.find(date)
        when 'range'
          RangeDate.find_or_create_by(date: date)
        end

      report_group
    end

    def get_options
      report_group    = @options[:report_group]
      keywords        = @options[:keywords]
      keywords_groups = @options[:keywords_groups]
      search_engines  = @options[:search_engines]
      tracking_groups = @options[:tracking_groups]

      keyword_items = keywords.present? ? keywords : keywords_groups
      keyword_items_type = keyword_items.first.is_a?(Keyword) ? :keywords : :keywords_groups

      {
        on: report_group.on,
        date_type: report_group.date_type,
        keyword_items_type: keyword_items_type,
        keyword_items: keyword_items,
        search_engines: search_engines,
        tracking_groups: tracking_groups,
        report_group: report_group
      }
    end
  end
end
