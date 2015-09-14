require 'spec_helper'

describe AudioLibrarian::Song do

  def load_song
    @song = AudioLibrarian::Song.new TEMP_MP3_FILE
  end

  before :example do
    load_mp3_fixture "empty_mp3"

    load_song
  end

  after :example do
    unload_mp3_fixture
  end

  it 'saves tags to the file' do
    @song.title = "title"

    @song.save_tags

    expect(@song.title).to eql("title")
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

    @song.save_tags
    load_song

    expect(@song.disc_number).to eq(1)
    expect(@song.disc_total).to  eq(2)

    expect(@song.id3.tag2["TPOS"]).to eq("1/2")
  end

  it "saves track number and track total tags" do
    @song.track_number = 1
    @song.track_total  = 12

    @song.save_tags
    load_song

    expect(@song.track_number).to eq(1)
    expect(@song.track_total).to  eq(12)

    expect(@song.id3.tag2["TRCK"]).to eq("1/12")
  end

  it "saves track number without track total tags" do
    @song.track_number = 1

    @song.save_tags
    load_song

    expect(@song.track_number).to eq(1)
    expect(@song.id3.tag2["TRCK"]).to eq("1")
  end

end
