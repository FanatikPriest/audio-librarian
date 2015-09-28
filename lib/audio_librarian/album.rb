require 'titleize'

require 'audio_librarian/song'

class AudioLibrarian::Album

  attr_reader   :dir, :songs, :cover, :big_cover, :folder_image
  attr_accessor :title, :artist, :album_artist, :year, :genre, :disc_total

  def initialize path
    raise ArgumentError, "The given album path is not a directory" unless File.directory?(path)

    @dir = File.new path

    reload
  end

  def reload
    reload_songs
    extract_data
    load_cover_images
  end

  def reload_songs
    @songs = Dir["#{@dir.path}/**/*.mp3"].map { |path| AudioLibrarian::Song.new path }
  end

  def extract_data
    raise "No songs to extract data from" if songs.count == 0

    @title        = tag_values :album
    @artist       = tag_values :artist
    @album_artist = tag_values :album_artist
    @year         = tag_values :year
    @genre        = tag_values :genre
    @disc_total   = extract_disc_total
  end

  def check_case!
    %w[title artist album_artist genre].each do |tag|
      value = send tag
      send(tag + "=", value.downcase.titleize) unless value.nil?
    end
  end

  def update_songs_tags
    songs.each do |song|
      song.album        = @title
      song.artist       = @artist
      song.album_artist = @album_artist
      song.year         = @year
      song.genre        = @genre
      song.cover        = @cover

      # safe: nil.to_i equals 0 and this will remove both disc-related tags
      song.disc_number = read_disc_number(song).to_i
      song.disc_total  = @disc_total

      song.save_tags
    end
  end

  def valid?
    tags_valid? and songs_valid?
  end

  private

  def load_cover_images
    @cover     = Dir["#{@dir.path}/cover.{jpg,png}"].first
    @big_cover = Dir["#{@dir.path}/big cover.{jpg,png}"].first

    if @cover
      pic_type          = Pathname.new(@cover).extname
      folder_image_path = File.join(@dir, "folder#{pic_type}")

      FileUtils.rm_f folder_image_path
      FileUtils.cp @cover, folder_image_path
      @folder_image = folder_image_path
    end
  end

  def tag_values tag, additional_values = []
    values = (songs.map(&tag) + additional_values).compact.uniq

    values.size == 1 ? values.first : values
  end

  def tags_valid?
    tags = %w[title artist album_artist year genre cover big_cover]

    tags.all? { |tag| send(tag) != nil }
  end

  def songs_valid?
    songs.all?(&:valid?)
  end

  ##
  # The number of total discs, deduced from the file structure, not by reading tags.
  def extract_disc_total
    counted   = @songs.map { |song| read_disc_number song }.compact.uniq.count
    from_tags = tag_values :disc_total

    return counted if from_tags == 0

    values = [from_tags, counted].flatten.uniq

    values.size == 1 ? values.first : values
  end

  def read_disc_number song
    Pathname.new(song.file).dirname.to_s.match /CD (\d+)$/

    $1
  end

end
