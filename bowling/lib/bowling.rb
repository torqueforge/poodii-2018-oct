# New requirement: LOWBALL
# The goal of this game it to roll the lowest score
# while knocking down at least 1 pin with every roll.
#
# Gutter balls are penalized as per the rules below.
#
# The rules are:
#   If 1st roll knocks down 0 pins,
#     score for that roll is 10 and
#       the frame score includes the score of the next 2 rolls.
#   This is a LOWBALL 'strike'.
#
#   If 2nd roll knocks down 0 pins,
#     score for that roll is 10 - number-of-pins-knocked-down-by-1st-roll
#       the frame score includes the score of the next roll.
#   This is a LOWBALL 'spare'.
#
#   Open frame is two non-zero rolls.
#
# The best achievable score is therefore 20.

#####################################################################
# Ponderings:
#   The existing code is very much not open to LOWBALL.
#     1) The structure of the config won't support LOWBALL rules
#     2) LOWBALL allow a roll's score to differ from its pinfall
#
# The fundamental design rule is to isolate the things you need to vary,
# so the first task here is to understand what, exactly, needs to change.
#
# The difficulty of this task is exacerbated by the disorderliness of
# the existing code.  It works for the old requirements, but it's
# annoying in a number of ways.
#
# 1) The Bowling class pretends that its job is to calculate a score, but
#    most of the logic is concerned with turning a list of rolls into
#    a list of (virtual) 'frames', for which it then sums scores.
#
#    I wish Bowling was better named, and more honest.
#
# 2) The Rules class uses a config to select a 'rule'.  This 'rule'
#    is used by the badly named Bowling class as if it defines a 'frame',
#    which Bowling knows how to score.
#
#    I wish Frame was a real thing which calculated its own score.
#
# 3) The structure of the rules hash has leaked all over.  For example,
#    Rules#scoring_rule and Bowling#score both have multiple references
#    to keys in the hash.
#
#    I'd like the structure of the hash to be known in only one place.
#
#
# Next Steps:
# As always, we need to isolate the thing we want to vary.  However,
# it's not super clear what that thing is, i.e., what the exact
# code difference should be between the code we have and
# code that would also support LOWBALL.  Because of this, it's time
# to remove possibly related code smells, hoping to increase isolation.
#
# Goals:
#   Isolate config knowledge in the Rules class
#   Isolate frame scoring knowledge in a new Frame class
#   Change Bowling into something that converts rolls into Frame objects
#####################################################################

class Bowling
  attr_reader :rolls, :config
  def initialize(rolls, config=Rules::CONFIGS[:TENPIN])
    @rolls  = rolls
    @config = config
  end

  def score
    running_score = 0
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1
      rule = Rules.new(config: config).scoring_rule(remaining_rolls)

      if (remaining_rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
        if remaining_rolls.size >=  rule[:num_rolls_to_score]
          running_score  += remaining_rolls.take(rule[:num_rolls_to_score]).sum
          remaining_rolls = remaining_rolls.drop(rule[:num_triggering_rolls])
        end
        next
      end
    end

    running_score
  end
end

require 'ostruct'

class Rules
  CONFIGS = {
    :TENPIN => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
      }
    }

  attr_reader :config
  def initialize(config:)
    @config = OpenStruct.new(config)
  end

  def scoring_rule(rolls)
    config.scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
  end
end
