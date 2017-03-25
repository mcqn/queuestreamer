#!/usr/bin/ruby
require 'date'
require 'open-uri'
require 'nokogiri'

# Programmes we want to download
ProgrammesOfInterest = [
  "Lauren Laverne",
  "Steve Lamacq",
  "Huey",
  "Liz Kershaw",
  "Gilles",
  "Craig Charles",
  "Tom Robinson",
  "Jarvis Cocker",
  "Sunday Service"
]

ProgrammesToSkip = [
  "6 Music Recommends",
  "Roundtable"
]

day_to_check = Date.today - 10
while day_to_check < Date.today
  # Get the list of programs
  puts "Checking #{day_to_check}"
  schedule_uri = "http://www.bbc.co.uk/6music/programmes/schedules/%04d/%02d/%02d/" % [day_to_check.year, day_to_check.month, day_to_check.day]
  schedule = Nokogiri::HTML(open(schedule_uri))
  schedule.css("a[data-linktrack='programmeobjectlink=title']").each do |programme|
    # Look for ones we want
    to_download = nil
    ProgrammesOfInterest.each do |poi|
      if programme.text.match(/#{poi}/i)
        # Found one we're interested in
        to_download = programme
      end
    end
 
    # Check that we're /really/ interested in it
    ProgrammesToSkip.each do |pts|
      if programme.text.match(/#{pts}/i)
        puts "Skipping #{programme.text}"
        to_download = nil
      end
    end

    # Now download what's left
    unless to_download.nil?
      puts "Downloading #{programme.text}"
      system("../get_iplayer/get_iplayer --modes=flashaacstd,hlsaacstd --type=radio --aactomp3 --nopurge '#{to_download['resource']}'")
      #`../get_iplayer/get_iplayer --modes=flashaacstd,hlsaacstd --type=radio --aactomp3 --nopurge '#{to_download['resource']}'`
    end
  end
  day_to_check = day_to_check + 1 
end

