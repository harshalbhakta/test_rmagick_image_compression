require 'RMagick'
require 'pathname'
require './util.rb'

puts "compressing using quality: #{ARGV[0].to_i}"

Dir.glob(File.expand_path("./files_to_convert") + "/*.*").each do |file|
  file_name = Pathname.new(file).basename

  puts "compressing #{file_name}"

  img = Magick::Image::read(file).first
  img.format = 'JPEG'
  #thumb = img.resize_to_fit(125, 125)
  img.write("./converted_files/#{file_name.to_s.gsub("png","jpg")}") { self.quality = ARGV[0].to_i }
end

# Generate HTML for image comparrison.
html = <<eos

  <html>
  <head>
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  </head>

  <div class="container" style="margin: 0px;width: 100%;">

    <div class="row">

eos

Dir.glob(File.expand_path("./files_to_convert/*.*")).each do |file|
  file_name = Pathname.new(file).basename

  html += <<eos

      <div class="col-lg-6">
        <p>Size: #{format_mb(File.size(File.expand_path('./files_to_convert/' + file_name.to_s)))}</p>
        <img style="width: 100%" src='./files_to_convert/#{file_name.to_s}'>
      </div>

      <div class="col-lg-6">
        <p>Size: #{format_mb(File.size(File.expand_path('./converted_files/' + file_name.to_s.gsub("png","jpg").to_s)))}</p>
        <img style="width: 100%" src='./converted_files/#{file_name.to_s.gsub("png","jpg").to_s}'>
      </div>
eos

end

html += <<eos

    </div><!-- end row -->

  </div><!-- end container -->

</html>

eos

File.open("output.html", 'w') { |file| file.write(html) }
