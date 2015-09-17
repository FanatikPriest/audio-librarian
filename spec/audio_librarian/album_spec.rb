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

    it "copies the cover as a folder image" do
      expect(File.exists? File.join(@album_dir, "folder.jpg")).to be(true)
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

    describe "#valid?" do
      subject { @album }

      it { is_expected.to be_valid }

      it "is not valid if any of the tags are missing" do
        tags = %w[title artist album_artist year genre]

        tags.each do |tag|
          @album.send "#{tag}=", nil

          expect(@album).to_not be_valid

          load_album
        end
      end

      context "with missing cover images" do
        before :example do
          FileUtils.rm_f [@cover_file, @big_cover_file]

          load_album
        end

        it { is_expected.to_not be_valid }
      end
    end
  end

  context "with multiple songs" do
    before :example do
      @mp3_file_paths = ["first", "second", "three"].map { |name| File.join(@album_dir, "#{name}.mp3") }

      @mp3_file_paths.each { |file| load_tagged_mp3 file }
    end

    context "with matching tags" do
      before :example do
        @mp3_file_paths.each.with_index do |path, index|
          song = AudioLibrarian::Song.new path

          song.title = "Song #{index}"
          song.track_number = (index + 1)
          song.track_total  = @mp3_file_paths.count

          song.save_tags
        end

        load_album
      end

      it "extracts album data from the songs" do
        expect(@album.title).to        eq("Album Name")
        expect(@album.artist).to       eq("Artist")
        expect(@album.album_artist).to eq("Album Artist")
        expect(@album.genre).to        eq("Genre")
      end
    end

    context "with conflicting tags" do
      before :example do
        @mp3_file_paths.each.with_index do |path, index|
          song = AudioLibrarian::Song.new path

          song.title = "Song #{index}"
          song.track_number = (index + 1)
          song.track_total  = @mp3_file_paths.count

          song.album        += " #{index}"
          song.artist       += " #{index}"
          song.album_artist += " #{index}"
          song.genre        += " #{index}"

          song.save_tags
        end

        load_album
      end

      it "extracts album data from the songs" do
        expect(@album.title).to        eq(["Album Name 0", "Album Name 1", "Album Name 2"])
        expect(@album.artist).to       eq(["Artist 0", "Artist 1", "Artist 2"])
        expect(@album.album_artist).to eq(["Album Artist 0", "Album Artist 1", "Album Artist 2"])
        expect(@album.genre).to        eq(["Genre 0", "Genre 1", "Genre 2"])
      end
    end
  end


  it "manipulates multiple discs"

  it "generates cover from the big cover"

  it "moves the files in a given location"

end
