require 'csv'
require 'open-uri'

# directory where you want to store the images
images_dir = "/Users/dylanconlin/Downloads/shortstack-user-images/"

# location of the csv you're reading
csv_path = "/Users/dylanconlin/Downloads/photo-thing.csv"

# column number of image url (zero-based)
image_url_row = 16

# column number of entry_id (zero-based). This is used to image labeling.
entry_id_row = 25

images = []

CSV.foreach(csv_path) do |row|
  images.push({ :entry_id => row[entry_id_row], :url => row[image_url_row] })
end

images = images.drop(1)

images.each do |image|
  entry_id = image[:entry_id]
  url = image[:url]
  
  unless url.nil?
    filename = "#{images_dir}entry_#{entry_id}_#{File.basename(url)}"
    open(filename, 'wb') do |file|
      puts "writing #{url} to #{filename}"
      file << open(url).read
    end
  end
end

