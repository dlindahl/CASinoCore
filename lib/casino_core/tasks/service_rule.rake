require 'terminal-table'

namespace :casino_core do
  namespace :service_rule do

    desc 'Add a service rule (prefix the url parameter with "regex:" to add a regular expression)'
    task :add, [:name, :url] => :environment do |task, args|
      CASinoCore.implementor(:service_rule).add args[:name], args[:url]
    end

    desc 'Remove a servcice rule.'
    task :delete, [:id] => :environment do |task, args|
      CASinoCore.implementor(:service_rule).delete(args[:id])
      puts "Successfully deleted service rule ##{args[:id]}."
    end

    desc 'Delete all servcice rules.'
    task :flush => :environment do |task, args|
      CASinoCore.implementor(:service_rule).delete_all
      puts 'Successfully deleted all service rules.'
    end

    desc 'List all service rules.'
    task list: :environment do
      table = Terminal::Table.new :headings => ['Enabled', 'ID', 'Name', 'URL'] do |t|
        CASinoCore.implementor(:service_rule).all.each do |service_rule|
          url = service_rule.url
          if service_rule.regex
            url += " (Regex)"
          end
          t.add_row [service_rule.enabled, service_rule.id, service_rule.name, url]
        end
      end
      puts table
    end
  end
end
