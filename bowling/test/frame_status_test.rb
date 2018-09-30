require_relative '../../test_helper'
require_relative '../bowling'

######################################
# Dynamically generate FrameStatus API tests for
# players of the Frame Status role
######################################
[ FrameStatus::Complete,
  FrameStatus::MissingNormalRolls,
  FrameStatus::MissingBonusRolls].each {|status_class|

  Class.new(Minitest::Test) do
    include FrameStatusAPITest

    define_method :setup do
      @api_test_target = status_class
    end
  end
}
