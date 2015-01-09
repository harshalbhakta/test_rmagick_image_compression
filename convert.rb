require 'RMagick'
require 'pathname'
require './util.rb'

compressed_quality = 50
compressed_max_width = 800
compressed_max_height = 400

thumb_quality = 50
thumb_max_width = 400
thumb_max_height = 200

Dir.glob(File.expand_path("./files_to_convert") + "/*.*").each do |file|
  
  file_name = Pathname.new(file).basename

  puts "compressing #{file_name}"

  image = Magick::Image::read(file).first
  image.format = 'JPEG'
  image.resize_to_fit!(compressed_max_width, compressed_max_height)

  image.write("./compressed/#{file_name.to_s.gsub("png","jpg")}") { self.quality = compressed_quality }

  # Resize image to maxium dimensions
  image.resize_to_fit!(thumb_max_width, thumb_max_height)

  # Write image to file system
  image.write("./thumb/#{file_name.to_s.gsub("png","jpg")}") { self.quality = thumb_quality }

  # Free image from memory
  image.destroy!
end

Dir.glob(File.expand_path("./files_to_convert/*.*")).each_slice(40).with_index do |files, i|

  # Generate HTML for image comparrison.
  html = %Q(

    <html>
    <head>
      <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
    </head>

    <div class="container" style="margin: 0px;width: 100%;">

      <div class="row">

  )

  files.each do |file|

    file_name = Pathname.new(file).basename

    html += %Q(

      <div class="row">

        <div class="col-lg-4">
          <p>Size: #{format_mb(File.size(File.expand_path('./files_to_convert/' + file_name.to_s)))}</p>
          <img style="width: #{compressed_max_width}px; height: #{compressed_max_height}px;" src='../files_to_convert/#{file_name.to_s}'>
        </div>

        <div class="col-lg-4">
          <p>Size: #{format_mb(File.size(File.expand_path('./compressed/' + file_name.to_s.gsub("png","jpg").to_s)))}</p>
          <img style="width: #{compressed_max_width}px; height: #{compressed_max_height}px;" src='../compressed/#{file_name.to_s.gsub("png","jpg").to_s}'>
        </div>      

        <div class="col-lg-4">
          <p>Size: #{format_mb(File.size(File.expand_path('./thumb/' + file_name.to_s.gsub("png","jpg").to_s)))}</p>
          <img style="width: #{thumb_max_width}px; height: #{thumb_max_height}px;" src='../thumb/#{file_name.to_s.gsub("png","jpg").to_s}'>
        </div>

      </div>

      <hr>

    )

  end

  html += %Q(

      </div><!-- end row -->

    </div><!-- end container -->

  </html>

  )

  File.open("output/#{i}.html", 'w') { |file| file.write(html) }

end
