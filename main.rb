require 'csv'
require 'open-uri'
require 'optparse'
require 'yaml'
require 'ruby-progressbar'
require 'fileutils'

# This script takes 1 argument: the full path name of the
# csv file containing the images you'd like to export.

# ruby main.rb -c "/Users/dylanconlin/Dropbox/shortstack-user-images/share-your-story.csv"

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"
  opts.on('-c', '--csv_path PATH', 'CSV path') { |v| options[:csv_path] = v }
end.parse!

errors = []

unless (options[:csv_path] && options[:csv_path].length > 0)
  errors << 'Error: `-c csv_path` is required'
end

if errors.length > 0
  puts errors
  return 
end

# location of the csv you're reading
csv_path = options[:csv_path]

images_dir_name = File.basename(csv_path, File.extname(csv_path))

Dir.mkdir(images_dir_name)

FileUtils.cp( csv_path, "#{images_dir_name}/#{File.basename(csv_path)}" )

# column number of image url (zero-based)
image_column = nil

# column number of entry_id (zero-based). This is used to image labeling.
entry_id_column = nil

images = []

# Find the entry_id and image url columns (used when naming images).
CSV.foreach(csv_path) do |row|
  entry_id_column = row.index('entry_id')
  image_column = row.index('image') || row.index('image_url')
  break unless (entry_id_column.nil? && image_column.nil?)
end

CSV.foreach(csv_path) do |row|
  images.push({ entry_id: row[entry_id_column], url: row[image_column] })
end

images = images.drop(1)

progressbar = ProgressBar.create(
  title: "Images",
  starting_at: 0,
  total: images.length,
  format: '%a |%B| (%c/%C) %t'
)

images.each do |image|
  entry_id = image[:entry_id]
  url = image[:url]
  unless url.nil?
    filename = "#{images_dir_name}/entry_#{entry_id}_#{File.basename(url)}"
    open(filename, 'wb') do |file|
      if url and url.length > 0
        file << open(url).read
      else
        file << "This entry did not include a url."
      end
      progressbar.increment
    end
  end
  
end

