require 'spec_helper'

describe AudioLibrarian::Album do

  def load_album
    @album = AudioLibrarian::Album.new @album_dir
  end

  before :example do
    @album_dir = Dir.mktmpdir

    @cover_file     = File.join(@album_dir, "cover.jpg")
    @big_cover_file = File.join(@album_dir, "big cover.jpg")

    load_jpg_fixture @cover_file
    load_jpg_fixture @big_cover_file
  end

  after :example do
    FileUtils.rm_rf @album_dir
  end

  context "with no songs in the directory" do
    it "raises an error on initiation" do
      expect { AudioLibrarian::Album.new @album_dir }.to raise_error(RuntimeError)
    end
  end

  context "with a single song" do
    before :example do
      @mp3_file = File.join(@album_dir, "first.mp3")

      load_tagged_mp3 @mp3_file

      load_album
    end

    it "has a path to a directory" do
      expect(@album.dir).to be_a(File)
    end

    it "returns this song" do
      expect(@album.songs.size).to eq(1)

      song = @album.songs.first

      expect(song).to be_a(AudioLibrarian::Song)
      expect(song.path).to eq(@mp3_file)
    end

    it "extracts its tag data from the song" do
      song = @album.songs.first

      @album.extract_data

      expect(@album.title).to        eq(song.album)
      expect(@album.artist).to       eq(song.artist)
      expect(@album.album_artist).to eq(song.album_artist)
      expect(@album.year).to         eq(song.year)
      expect(@album.genre).to        eq(song.genre)
    end

    it "updates the song's tags" do
      @album.title        = "some words"
      @album.artist       = "are"
      @album.album_artist = "better left"
      @album.genre        = "unsaid"
      @album.year         = 1988

      song = @album.songs.first

      expect(@album.title).not_to        eq(song.album)
      expect(@album.artist).not_to       eq(song.artist)
      expect(@album.album_artist).not_to eq(song.album_artist)
      expect(@album.year).not_to         eq(song.year)
      expect(@album.genre).not_to        eq(song.genre)

      @album.update_songs_tags

      expect(@album.title).to        eq(song.album)
      expect(@album.artist).to       eq(song.artist)
      expect(@album.album_artist).to eq(song.album_artist)
      expect(@album.year).to         eq(song.year)
      expect(@album.genre).to        eq(song.genre)
    end

    it "has a nil for the cover and big cover" do
      FileUtils.rm_f [@cover_file, @big_cover_file]

      load_album

      expect(@album.cover).to     be_nil
      expect(@album.big_cover).to be_nil
    end

    it "has a cover and a big cover" do
      expect(File.exists? @album.cover).to     be(true)
      expect(File.exists? @album.big_cover).to be(true)
    end

    describe "#check_case!" do
      it "modifies the text tags" do
        @album.title        = "title"
        @album.artist       = "artist"
        @album.album_artist = "album artist"
        @album.genre        = "genre"

        @album.check_case!

        expect(@album.title).to        eq("Title")
        expect(@album.artist).to       eq("Artist")
        expect(@album.album_artist).to eq("Album Artist")
        expect(@album.genre).to        eq("Genre")
      end
    end
  end

  it "extracts data from multiple songs"

  it "manipulates with multiple discs"

  it "generates cover from the big cover"

  it "copies the cover as a folder image"

end
