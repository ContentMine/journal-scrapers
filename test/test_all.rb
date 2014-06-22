require 'digest'
require 'json'

testdir = File.expand_path(File.dirname(__FILE__))
scrapers = Dir[File.join(thisdir, '..', '*.json')]

scrapers = 0
passed = 0
warnings = 0
errors = 0

Dir.mktmpdir do |tmpdir|
  Dir.chdir(mktmpdir) do
    scrapers.each do |scraper|
      scrapers += 1
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
        # hash the url
        hash = Digest::SHA256.hexdigest url
        # run the scraper
        cmd = "quickscrape"
        cmd += " --url #{url}"
        cmd += " --scraper #{opts.definition}"
        cmd += " --output #{hash}"
        cmd += " --loglevel silent"
        puts `cmd`
        # load the output
        unless File.exist? 'results.json'
          puts "FAIL: no results from scraping"
          errors += 1
        end
        Dir.chdir(hash) do
          results = JSON.load(File.open 'results.json')
          filehashes = `md5sum !(results.json)`
          filehashes.split("\n").each do |line|
            filehash, filename = line.strip.split("\t")
            results[filename] = filehash
          end
        end
        # compare results to expected
        expected.each_pair do |key, exp_val|
          match = results.detect { |result| result[key] == exp_val }
          if match
            passed += 1
          else
            puts "ERROR: #{key} not found in results"
            puts "expected value: #{exp_val}"
            errors += 1
        end
      else
        puts "WARN: no test found!"
        warnings += 1
    end
  end
end

puts "-" * 25
puts "tests completed for #{scrapers} scrapers"
puts " - #{passed} passed"
puts " - #{warnings} warnings"
puts " - #{errors} errors"

exit(1) if errors > 0
exit(0)
