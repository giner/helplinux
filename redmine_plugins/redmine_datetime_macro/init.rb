require 'redmine'

Redmine::Plugin.register :redmine_datetime_macro do
  name 'Redmine datetime macro'
  url 'https://github.com/giner/helplinux/tree/master/redmine_plugins/redmine_datetime_macro'
  author 'Stanislav German-Evtushenko'
  description 'Add the datetime macro.'
  author_url 'mailto:ginermail@gmail.com'
  version '0.1'
end

Redmine::WikiFormatting::Macros.register do
  desc "Insert date and time for a specific timezone. Examples: \n\n <pre>{{datetime}}\n{{datetime(Moscow)}}\n{{datetime(list)}}</pre>"
  macro :datetime do |obj, args|
    if args[0] and !args[0].empty?
      timezone = args[0].strip
    else
      timezone = User.current.time_zone
    end
    if timezone == 'list'
      output_wiki = '|_.Offset|_.Zone name|_.Zone alias|' + "\n"
      ActiveSupport::TimeZone.all.each do |zone|
        output_wiki << '|' + zone.now.formatted_offset + ' ' + zone.now.zone + '|' + zone.tzinfo.name + '|' + zone.name + '|' + "\n"
      end
      return textilizable(output_wiki)
    else
      return nil unless Time.find_zone(timezone)
      current_time = Time.now
      return current_time.in_time_zone(timezone).to_s + ' ' + current_time.in_time_zone(timezone).zone
    end
  end
end
