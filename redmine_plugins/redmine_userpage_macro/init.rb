require 'redmine'

Redmine::Plugin.register :redmine_userpage_macro do
  name 'Redmine Userpage macro'
  url 'https://github.com/giner/helplinux/tree/master/redmine_plugins/redmine_userpage_macro'
  author 'Stanislav German-Evtushenko'
  description 'Add the userpage macro.'
  author_url 'mailto:ginermail@gmail.com'
  version '0.2'
end

Redmine::WikiFormatting::Macros.register do
  desc "Insert the link to the userpage. Examples: \n\n <pre>{{userpage}}\n{{userpage(project_id, user_login, parent_page)}}</pre>"
  macro :userpage do |obj, args|
    if args[0] and !args[0].empty?
      project_identifier = args[0].strip
      project = Project.find_by_identifier(project_identifier)
    end

    project = @project || (obj && obj.project) unless project
    return nil unless project

    project_id = project.identifier

    if args[1] and !args[1].empty?
      user_login = args[1].strip.downcase
    end

    if args[2] and !args[2].empty?
      parent_page = args[2].strip
    end

    user_login = User.current.login unless user_login
    userpage_exists = Wiki.find_page(project_id + ":" + user_login)
    url_class = 'wiki-page' + (userpage_exists ? '' : ' new')
    url = url_for(:controller => 'wiki', :action => 'show', :project_id => project_id, :id => user_login, :parent => parent_page, :only_path => @only_path)
    h(link_to(user_login, url, :class => url_class))
  end
end
