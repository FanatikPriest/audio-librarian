require 'tempfile'

MP3_FIXTURES = YAML::load_file( File.join(File.dirname(__FILE__), "mp3.yml"))
JPG_FIXTURES = YAML::load_file( File.join(File.dirname(__FILE__), "jpg.yml"))

TEMP_MP3_FILE = Tempfile.new "test_mp3info.mp3"
TEMP_JPG_FILE = Tempfile.new "test_cover.jpg"

def load_mp3_fixture(file = TEMP_MP3_FILE, key = "empty_mp3")
  load_file_fixture file, Zlib::Inflate.inflate(MP3_FIXTURES[key])
end

def load_empty_mp3 file
  load_mp3_fixture file, "empty_mp3"
end

def load_tagged_mp3 file
  load_mp3_fixture file, "with_tags"
end

def load_jpg_fixture(file = TEMP_JPG_FILE)
  load_file_fixture file, JPG_FIXTURES
end

def load_file_fixture file, content
  File.open(file, "w") { |f| f.write content }
end

def unload_fixtures
  FileUtils.rm_f TEMP_MP3_FILE
  FileUtils.rm_f TEMP_JPG_FILE
end
