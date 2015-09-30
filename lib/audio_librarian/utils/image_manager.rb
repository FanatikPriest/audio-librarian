require 'rmagick'

module AudioLibrarian::Utils
end

class AudioLibrarian::Utils::ImageManager
  include Magick

  COVER_SIZE = 1000

  def self.create_cover_image big_cover_path
    img = Image.read(big_cover_path).first.copy

    width  = img.columns
    height = img.rows

    img.resize_to_fit! COVER_SIZE if [width, height].any? { |dim| dim > COVER_SIZE }

    img.strip!

    filename = File.join(Pathname.new(big_cover_path).dirname, "cover.jpg")

    img.write("jpg:#{filename}") do
      self.interlace = PlaneInterlace
      self.quality   = 92
    end

    img.filename
  end

end
