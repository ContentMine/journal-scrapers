# generate coverage information for tests

def coverage scraperjsonpath, results
  lines = File.readlines scraperjsonpath
  # get the element names
  elements = JSON.load(File.open scraperjson)['elements'].keys
  coverage = []
  lines.each do |line|
    valid = false
    elements.keys.each do |element|
      if line ~= /"#{element}":/
        # calculate coverage for this line
        if results.key? element
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
  coverage
end
