#! /usr/bin/env ruby

require 'trollop'
require 'digest'
require 'json'
require 'tmpdir'

parser = Trollop::Parser.new do
  banner <<-EOS
make_tests.rb - ScraperJSON test generator script
by Richard Smith-Unna <rds45@cam.ac.uk> for ContentMine.org

This script generates a test file from a ScraperJSON scraper definition
and a list of URLs the scraper applies to.

The test files record what the scraper extracts from each URL so that tests can detect when the scrapers break.

Example use:
make_tests.rb --definition scraper.json --urls urls.txt

Options:
EOS

  opt :definition, "Path to ScraperJSON definition",
      :type => :string,
      :required => true
  opt :urls, "File containing a list of 5-10 URLs to test",
      :type => :string,
      :required => true
end

opts = Trollop::with_standard_exception_handling parser do
  parser.parse ARGV
  # raise Trollop::HelpNeeded if ARGV.empty? # show help screen
end

urls = File.readlines(opts.urls)
if urls.length < 5 || urls.length > 10
  puts "ERROR: you must provide at least 5 and up to 10 URLS"
end

definition = File.expand_path opts.definition
puts "generating ScraperJSON test files for #{definition}"
puts "using #{urls.length} urls"

Dir.mkdir('test') unless Dir.exist?('test')

Dir.chdir('test') do
  testobject = {}
  # for each URL, run the scraper
  urls.each_with_index do |url, index|
    url = url.strip
    puts "running quickscrape for URL #{url}"
    results = nil
    Dir.mktmpdir do |tmpdir|
      puts "using temporary directory #{tmpdir}"
      Dir.chdir tmpdir do
        # run the scraper
        cmd = "quickscrape"
        cmd << " --url #{url}"
        cmd << " --scraper #{definition}"
        cmd << " --output output"
        `#{cmd}`
        puts "scraping done - parsing results"
        # load the output
        Dir.chdir('output') do
          results = JSON.load(File.open 'results.json')
          filehashes = `md5sum !(results.json)`
          filehashes.split("\n").each do |line|
            filehash, filename = line.strip.split("\t")
            results += { filename => filehash }
          end
        end
        if (index + 1) < urls.length
          puts "waiting 15 seconds before next scrape"
          sleep(15)
        end
      end
    end
    # store results for this URL
    testobject[url] = results
  end

  # write out the test JSON
  File.open(File.basename(opts.definition), 'w') do |f|
    f.write(JSON.pretty_generate(testobject))
  end
end

puts "done! Test definition written to test/#{File.basename(opts.definition)}"
