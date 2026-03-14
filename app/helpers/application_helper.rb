module ApplicationHelper
  # Navigation link that is marked as current for its section of the site.
  def nav_link(label, path)
    current = path == root_path ? current_page?(path) : request.path.start_with?(path)
    link_to label, path, class: [ "site-nav__link", ("is-current" if current) ], aria: { current: (current ? "page" : nil) }
  end

  # "45 min", "1 hr", "1 hr 15 min"
  def duration(minutes)
    return if minutes.nil?

    hours, mins = minutes.divmod(60)
    [ ("#{hours} hr" if hours.positive?), ("#{mins} min" if mins.positive? || hours.zero?) ].compact.join(" ")
  end

  def error_messages_for(record)
    render "shared/form_errors", record: record if record.errors.any?
  end
end
