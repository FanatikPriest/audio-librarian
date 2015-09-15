require 'tempfile'

MP3_FIXTURES = YAML::load_file( File.join(File.dirname(__FILE__), "mp3.yml"))
JPG_FIXTURES = YAML::load_file( File.join(File.dirname(__FILE__), "jpg.yml"))

TEMP_MP3_FILE = Tempfile.new "test_mp3info.mp3"
TEMP_JPG_FILE = Tempfile.new "test_cover.jpg"

def load_mp3_fixture(fixture_key, zlibed = true)
  # Command to create a gzip'ed dummy MP3
  # $ dd if=/dev/zero bs=1024 count=15 | \
  #   lame --quiet --preset cbr 128 -r -s 44.1 --bitwidth 16 - - | \
  #   ruby -rbase64 -rzlib -ryaml -e 'print(Zlib::Deflate.deflate($stdin.read)'
  # vbr:
  # $ dd if=/dev/zero of=#{tempfile.path} bs=1024 count=30000 |
  #     system("lame -h -v -b 112 -r -s 44.1 --bitwidth 16 - /tmp/vbr.mp3
  #
  # this will generate a #{mp3_length} sec mp3 file (44100hz*16bit*2channels) = 60/4 = 15
  # system("dd if=/dev/urandom bs=44100 count=#{mp3_length*4}  2>/dev/null | \
  #        lame -v -m s --vbr-new --preset 128 -r -s 44.1 --bitwidth 16 - -  > #{TEMP_FILE} 2>/dev/null")
  content = MP3_FIXTURES[fixture_key]

  if zlibed
    content = Zlib::Inflate.inflate(content)
  end

  File.open(TEMP_MP3_FILE, "w") do |f|
    f.write(content)
  end
end

def load_jpg_fixture
  File.open(TEMP_JPG_FILE, "w") do |f|
    f.write JPG_FIXTURES
  end
end

def unload_fixtures
  FileUtils.rm_f TEMP_MP3_FILE
  FileUtils.rm_f TEMP_JPG_FILE
end
