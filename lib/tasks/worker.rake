namespace :worker do

  desc "Let the trains run"
  task :run => :environment do |t, args|
    lines = ENV['lines'].split(',') || [1, 3, 4, 5, 7, 9, 12, 13, 15, 16, 18]
    puts "Importing data for lines: #{lines.to_sentence}"
    StationUpdater.new(:lines => lines).run
  end

end