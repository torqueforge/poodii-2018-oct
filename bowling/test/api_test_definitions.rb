######################################
# FrameAPI Test:
#   To be included within the unit test of
#   any object who wants to play the
#   'frame' role.
#######################################
module FrameAPITest
  def test_initialization_takes_correct_keyword_args
    @api_test_target.new(normal_rolls: nil, bonus_rolls: nil, status: nil)
  end
end


######################################
# FrameStatusAPI Test:
#   To be included within the unit test of
#   any object who wants to play the
#   'frame status' role.
#######################################
module FrameStatusAPITest
  def test_implements_api
    f = @api_test_target.new
    [:score, :running_score, :normal_rolls_complete?, :bonus_rolls_complete?].each {|meth|
      assert_respond_to f, meth
    }
  end
end


#######################################
# ScoresheetAPI Test:
#   To be included within the unit test of
#   any object who wants to play the
#   'scoresheet' role.
#######################################
module ScoresheetAPITest
  def test_initialization_takes_frame_and_io_keyword_args
    @api_test_target.new(frames: nil, io: nil)
  end

  def test_implements_render
    assert_respond_to(@api_test_target.new(frames: nil, io: nil), :render)
  end
end

