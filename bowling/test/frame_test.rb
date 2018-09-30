require_relative '../../test_helper'
require_relative '../bowling'

class FrameTest < Minitest::Test
  include FrameAPITest

  def setup
    @api_test_target = Frame
  end
end