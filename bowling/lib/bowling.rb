# Here's a reminder of the original goals for the prior refactoring:
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
      #    I wish Frame was a real thing which calculated it's own score.
      #
      # 3) The structure of the rules has leaked all over.  For example,
      #    Rules#scoring_rule and Bowling#score both have multiple references
      #    to keys in the hash.
      #
      #    I'd like the structure of the hash to be known in only one place.
#
# Those goals have been achieved.
#   Bowling has been replaced by Frames
#   Frame exists, and responds to #score
#   Variant is the sole owner of knowledge of a rules hash
#
# So far, so good, but are we any closer to being able to implement LOWBALL?
#
# Let's ask that question a different way.
#
# Have we increased the isolation of the things that need to vary? Or,
# are we at least beginning to understand the things that need to vary?
#
# Some things _are_ better.
# For example, if each Frame object returned the right #score for a LOWBALL game,
#   Frames would just work.
# Also, if Variant constructed a Frame with the _value_ of the roll, rather than
#   the _pinfall_ of the roll, Frame would just work.
#
# Perhaps Variant should be smarter about how it builds Frame objects.

class Frames
  def self.for(rolls:, config: Variant::CONFIGS[:TENPIN])
    new(Variant.new(config: config).framify(rolls))
  end

  attr_reader :list
  def initialize(list)
    @list  = list
  end

  def score
    list.reduce(0) {|sum, frame| sum += frame.score}
  end
end


class Frame
  attr_reader :rolls
  def initialize(rolls:)
    @rolls = rolls
  end

  def score
    rolls.sum
  end
end


require 'ostruct'

class Variant
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

  def framify(rolls)
    frame_list    = []
    running_score = 0
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1
      rule = scoring_rule(remaining_rolls)

      scoring_rolls =
        if remaining_rolls.size >=  rule[:num_rolls_to_score]
          remaining_rolls.take(rule[:num_rolls_to_score])
        else
          [0]
        end
      remaining_rolls = remaining_rolls.drop(rule[:num_triggering_rolls])
      frame_list << Frame.new(rolls: scoring_rolls)
    end

    frame_list
  end

  def scoring_rule(rolls)
    config.scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
  end
end
