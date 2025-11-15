module ApplicationHelper
  # Navigation link that is marked as current for its section of the site.
  def nav_link(label, path)
    current = path == root_path ? current_page?(path) : request.path.start_with?(path)
    link_to label, path, class: [ "site-nav__link", ("is-current" if current) ], aria: { current: (current ? "page" : nil) }
  end
end
