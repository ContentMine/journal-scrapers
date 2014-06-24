require 'digest'
require 'json'
require 'tmpdir'

testdir = File.expand_path(File.dirname(__FILE__))
scraperglob = File.join(testdir, '..', 'scrapers', '*.json')
scrapers = Dir[scraperglob]

scrapercount = 0
passed = 0
warnings = 0
errors = 0

# generate coverage information for tests
def coverage(scraperjsonpath, results)
  lines = File.readlines scraperjsonpath
  # get the element names
  elements = JSON.load(File.open scraperjsonpath)['elements'].keys
  coverage = []
  source = []
  # calculate coverage
  lines.each do |line|
    valid = true
    elements.each do |element|
      if line =~ /"#{element}":/
        # calculate coverage for this line
        if results.detect { |result| result.key? element }
          coverage << 1
        else
          coverage << 0
        end
      else
        valid = false
      end
    end
    coverage << nil unless valid
  end
  { :name => scraperjsonpath,
    :source => lines.join(''),
    :coverage => coverage }
end

# run tests
coverage_files = []
tmpdir = Dir.mktmpdir
puts "using tmp dir #{tmpdir}"
Dir.chdir(tmpdir) do
  scrapers.each do |scraper|
    scrapercount += 1
    basename = File.basename scraper
    puts "scraper #{basename}"
    testobjectpath = File.join(testdir, basename)
    if File.exist? testobjectpath
      # load expected output
      testobject = JSON.load(File.open(testobjectpath))
      url = testobject.keys.shuffle.first
      expected = testobject[url]
      # run the scraper
      puts "running quickscrape for URL #{url}"
      results = nil
      # run the scraper
      cmd = "quickscrape"
      cmd += " --url #{url}"
      cmd += " --scraper #{scraper}"
      cmd += " --output output"
      cmd += " --loglevel silent"
      puts `#{cmd}`
      # load the output
      cleanurl = url.gsub(/:?\/+/, '_')
      Dir.chdir("output/#{cleanurl}") do
        unless File.exist? 'results.json'
          puts "FAIL: no results from scraping"
          errors += 1
          coverage_files << coverage(scraper, {})
          next
        end
        results = JSON.load(File.open 'results.json')
        files = Dir['*']
        files = files.keep_if { |f| f != 'results.json' }.map{ |f| f.strip }
        cmd = "md5sum #{files.join(' ')}"
        filehashes = `#{cmd}`
        filehashes.split("\n").each do |line|
          filehash, filename = line.strip.split("  ")
          results << { filename => filehash }
        end
      end
      coverage_files << coverage(scraper, results)
      # compare results to expected
      expected.each do |hash|
        key = hash.keys.first
        exp_val = hash[key]
        exist = results.detect { |result| result.key? key }
        match = results.detect { |result| result[key] == exp_val }
        if exist && match
          puts "PASS: #{key}"
          passed += 1
        elsif exist
          puts "WARN: #{key} exists in results but is not exactly the same"
          warnings += 1
        else
          puts "ERROR: #{key} not found in results"
          puts "expected value: #{exp_val}"
          errors += 1
        end
      end
    else
      puts "WARN: no test found!"
      warnings += 1
      coverage_files << coverage(scraper, {})
    end
  end
end

# send coverage report to coveralls.io
cov_report = {
  :source_files => coverage_files
}
if ENV['TRAVIS']
  cov_report[:service_job_id] = ENV['TRAVIS_JOB_ID']
  cov_report[:service_name] = 'travis-ci'
else
  cov_report[:repo_token] = 'vHHvsw3QKvjK7zPb9DcFgt6ivLVS8r5uP'
end
File.open('coverage.json', 'w') do |f|
  f.write JSON.dump(cov_report)
end
cmd = "curl -XPOST --form json_file=@coverage.json https://coveralls.io/api/v1/jobs"
puts "posting coverage data to coveralls.io"
puts cmd
puts `#{cmd}`

# report test results
puts "-" * 25
puts "tests completed for #{scrapercount} scrapers"
puts " - #{passed} passed"
puts " - #{warnings} warnings"
puts " - #{errors} errors"

exit(1) if errors > 0
exit(0)
