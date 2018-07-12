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

log_PASS = "\e[0;32mPASS\e[39m"
log_WARN = "\e[0;33mWARN\e[39m"
log_ERROR = "\e[0;31mERROR\e[39m"

# generate coverage information for tests
def coverage(scraperjsonpath, results)
  # get the element names
  elements = JSON.load(File.open scraperjsonpath)['elements'].keys
  coverage = []
  # calculate coverage
  elements.each do |element|
    # calculate coverage for this line
    if results.detect { |result| result.is_a?(Hash) && result.key?(element) }
      coverage << 1
    else
      coverage << 0
    end
  end
  { :name => scraperjsonpath,
    :source => elements.join('\n'),
    :coverage => coverage }
end

# run tests
coverage_files = []
tmpdir = Dir.mktmpdir
puts "using tmp dir #{tmpdir}"
puts ""
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
      cmd += " --loglevel debug"
      system "#{cmd}", [:out, :err] => File::NULL
      # load the output
      cleanurl = url.gsub(/:?\/+/, '_')
      Dir.chdir("output/#{cleanurl}") do
        unless File.exist? 'results.json'
          puts "#{log_ERROR}: no results from scraping"
          errors += 1
          coverage_files << coverage(scraper, {})
          next
        end
        results = JSON.load(File.open 'results.json')
        files = Dir['*']
        files = files.keep_if { |f| f != 'results.json' }.map{ |f| f.strip }
        file_sizes = []
        files.each do |f|
          file_sizes << { f => File.size(f) }
        end
        results['file_sizes'] = file_sizes
      end
      coverage_files << coverage(scraper, results)
      # compare results to expected
      expected.each do |key, exp_val|
        exist = results.key? key
        match = results.key?(key) && results[key] == exp_val
        if exist && match
          puts "#{log_PASS}: #{key}"
          passed += 1
        elsif exist
          puts "#{log_WARN}: #{key} exists in results but is not exactly the same"
          warnings += 1
        else
          puts "#{log_ERROR}: #{key} not found in results"
          puts "expected value: #{exp_val}"
          errors += 1
        end
      end
    else
      puts "#{log_WARN}: no test found!"
      warnings += 1
      coverage_files << coverage(scraper, {})
    end
    puts ""
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
