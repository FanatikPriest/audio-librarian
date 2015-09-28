require 'overrides/mp3info'
require 'titleize'

class AudioLibrarian::Song

  attr_reader   :file, :id3
  attr_accessor :disc_number, :disc_total, :track_number, :track_total

  def initialize file
    @file = file

    reload_tags
  end

  def method_missing m, *args, &block
    @id3.tag.send m, *args, &block
  end

  def reload_tags
    @id3 = Mp3Info.new @file

    read_tpos
    read_trck
  end

  def save_tags reload = true
    generate_tpos
    generate_trck

    @id3.close

    reload_tags if reload
  end

  def list_tags
    @id3.tag2
  end

  def genre= genre
    @id3.tag.genre_s = genre
  end

  def genre
    @id3.tag.genre_s
  end

  def cover= image_file
    @id3.tag2.remove_pictures

    options = {
      description: "cover",
      pic_type:    3
    }

    @id3.tag2.add_picture(File.open(image_file, "rb").read, options) unless image_file.nil?
  end

  def cover
    pictures = @id3.tag2.pictures

    pictures.first.last if pictures.size > 0
  end

  def check_case!
    %w[title album artist album_artist genre].each do |tag|
      value = send tag
      send(tag + "=", value.downcase.titleize) unless value.nil?
    end
  end

  def valid?
    tags = %w[title album album_artist genre year disc_number disc_total track_number track_total cover]

    tags.all? { |tag| send(tag) != nil }
  end

  def organize_file
    dirname       = Pathname.new(@file).dirname
    escaped_title = title.gsub /["\*\:\<\>\?\\\/\|]/, "-"

    new_file_path = File.join(dirname, "#{track_number} - #{escaped_title}.mp3")

    FileUtils.mv @file, new_file_path

    @file = File.new(new_file_path)
  end

  private

  def read_tpos
    if @id3.tag2["TPOS"] =~ /(\d+)\s*\/\s*(\d+)/
      @disc_number = $1.to_i
      @disc_total  = $2.to_i
    else
      @disc_number = @disc_total = 0
    end
  end

  def read_trck
    data = @id3.tag2["TRCK"]

    if data =~ /(\d+)\s*\/\s*(\d+)/
      @track_number = $1.to_i
      @track_total  = $2.to_i
    elsif data =~ /(\d+)/
      @track_number = $1.to_i
    end
  end

  def generate_tpos
    @id3.tag2["TPOS"] = if @disc_number > 0 and @disc_total > 0
                          "#{@disc_number}/#{@disc_total}"
                        else
                          nil
                        end
  end

  def generate_trck
    if @track_number
      @id3.tag.tracknum = nil #overshadows the manual setting of the TRCK tag

      @id3.tag2["TRCK"] = if @track_total
                            "#{@track_number}/#{@track_total}"
                          else
                            "#{@track_number}"
                          end
    end
  end

end
