require 'titleize'

require 'audio_librarian/song'

class AudioLibrarian::Album

  attr_reader   :dir, :songs, :cover, :big_cover
  attr_accessor :title, :artist, :album_artist, :year, :genre

  def initialize path
    raise ArgumentError, "The given album path is not a directory" unless File.directory?(path)

    @dir = File.new path

    reload_songs
    extract_data
    load_cover_images
  end

  def reload_songs
    @songs = Dir["#{@dir.path}/*.mp3"].map { |path| AudioLibrarian::Song.new path }
  end

  def extract_data
    raise "No songs to extract data from" if songs.count == 0

    song = songs.first

    @title        = song.album
    @artist       = song.artist
    @album_artist = song.album_artist
    @year         = song.year
    @genre        = song.genre
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

      song.save_tags
    end
  end

  private

  def load_cover_images
    cover_path = File.join(@dir.path, "cover.jpg")
    @cover     = Dir["#{@dir.path}/cover.{jpg,png}"].first
    @big_cover = Dir["#{@dir.path}/big cover.{jpg,png}"].first
  end

end
