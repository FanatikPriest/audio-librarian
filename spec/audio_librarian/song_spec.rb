require 'spec_helper'

describe AudioLibrarian::Song do

  def load_song file = TEMP_MP3_FILE
    @song = AudioLibrarian::Song.new file
  end

  def update_song
    @song.save_tags
    load_song
  end

  before :example do
    load_empty_mp3
    load_jpg_fixture

    load_song
  end

  after :example do
    unload_fixtures
  end

  it 'has a file' do
    expect(@song.file).to eq(TEMP_MP3_FILE)
  end

  it 'has modifiable tags' do
    expect { @song.title        = "Song title"        }.to_not raise_error
    expect { @song.album        = "Album name"        }.to_not raise_error
    expect { @song.artist       = "Some Artist"       }.to_not raise_error
    expect { @song.album_artist = "Some album artist" }.to_not raise_error
    expect { @song.year         = 2015                }.to_not raise_error
    expect { @song.genre        = "Rock"              }.to_not raise_error

    @song.save_tags

    expect(@song.title).to        eql("Song title")
    expect(@song.album).to        eql("Album name")
    expect(@song.artist).to       eql("Some Artist")
    expect(@song.album_artist).to eql("Some album artist")
    expect(@song.year).to         eql(2015)
    expect(@song.genre).to        eql("Rock")
  end

  it "lists the tags it has" do
    expect(@song.list_tags).to be_a(ID3v2)
  end

  it "saves disc number and disc total tags" do
    @song.disc_number = 1
    @song.disc_total  = 2

    update_song

    expect(@song.disc_number).to eq(1)
    expect(@song.disc_total).to  eq(2)

    expect(@song.id3.tag2["TPOS"]).to eq("1/2")
  end

  it "saves track number and track total tags" do
    @song.track_number = 1
    @song.track_total  = 12

    update_song

    expect(@song.track_number).to eq(1)
    expect(@song.track_total).to  eq(12)

    expect(@song.id3.tag2["TRCK"]).to eq("1/12")
  end

  it "saves track number without track total tags" do
    @song.track_number = 1

    update_song

    expect(@song.track_number).to eq(1)
    expect(@song.id3.tag2["TRCK"]).to eq("1")
  end

  describe "#cover" do
    it 'returns nil if no cover has been set' do
      expect(@song.cover).to be_nil
    end

    it 'can have a cover image' do
      @song.cover = TEMP_JPG_FILE.path

      update_song

      expect(@song.cover).to_not be_nil
    end
  end

  describe "#check_case!" do
    it 'titleizes the text tags' do
      @song.title        = "title"
      @song.album        = "album"
      @song.artist       = "artist"
      @song.album_artist = "album artist"
      @song.genre        = "genre"

      @song.check_case!

      expect(@song.title).to        eq("Title")
      expect(@song.album).to        eq("Album")
      expect(@song.artist).to       eq("Artist")
      expect(@song.album_artist).to eq("Album Artist")
      expect(@song.genre).to        eq("Genre")
    end

    it 'titleizes the single text tag there is' do
      @song.title = "title"

      @song.check_case!

      expect(@song.title).to        eq("Title")

      expect(@song.album).to        be_nil
      expect(@song.artist).to       be_nil
      expect(@song.album_artist).to be_nil
      expect(@song.genre).to        be_nil
    end
  end

  describe "#valid?" do
    before :example do
      load_tagged_mp3
      load_song
    end

    it "returns true for a song that has all its tags set correctly" do
      expect(@song).to be_valid
    end

    it "returns false if any of the tags is missing" do
      tags = %w[title album album_artist genre year disc_number disc_total track_number track_total cover]

      tags.each do |tag|
        @song.send "#{tag}=", nil

        expect(@song).to_not be_valid

        load_song
      end
    end
  end

  describe "#organize_file" do
    before :example do
      @temp_dir      = Dir.mktmpdir
      @mp3_file_path = File.join(@temp_dir, "first.mp3")

      load_tagged_mp3 @mp3_file_path

      load_song File.new(@mp3_file_path)
    end

    after :example do
      FileUtils.rm_rf @temp_dir
    end

    it "renames the file according to the tags" do
      result_title = "1 - Title.mp3"

      expect(@song.file.path).to_not end_with(result_title)

      @song.organize_file

      expect(@song.file.path).to end_with(result_title)
    end

    it "replaces reserved characters in a file name" do
      reserved_characters = '"*:<>?\/|'

      @song.title = reserved_characters

      @song.organize_file

      expect(@song.file.path).to end_with("1 - #{"-" * reserved_characters.size}.mp3")
    end
  end

end
