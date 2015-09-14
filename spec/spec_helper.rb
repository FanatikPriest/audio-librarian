require 'byebug'
require 'coveralls'

Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'audio_librarian'

require 'fixtures/fixtures_helper'
