class Bowling
  attr_reader :rolls
  def initialize(rolls)
    @rolls = rolls
  end

  def score
    running_score = 0
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1

      # New Requirement: No-tap,
      #   where a strike/spare requires fewer than 10 pins.
      #
      # So, the 10's need to vary.
      # The sets of code below are identical _except_ for the 'magic' numbers.
      # If the numbers had names, you express every rule with common code like:
      #
      # if (remaining_rolls.take(_num_triggering_rolls).sum) >= _triggering_value
      #   if remaining_rolls.size >= _num_rolls_to_score
      #     running_score += remaining_rolls.take(_num_rolls_to_score).sum
      #     remaining_rolls = remaining_rolls.drop(_num_triggering_rolls)
      #   end
      #   next
      # end

      _num_triggering_rolls =  1
      _triggering_value     = 10
      _num_rolls_to_score   =  3

      if (remaining_rolls.take(_num_triggering_rolls).sum) >= _triggering_value
        if remaining_rolls.size >=  _num_rolls_to_score
          running_score  += remaining_rolls.take(_num_rolls_to_score).sum
          remaining_rolls = remaining_rolls.drop(_num_triggering_rolls)
        end
        next
      end

      _num_triggering_rolls =  2
      _triggering_value     = 10
      _num_rolls_to_score   =  3

      if (remaining_rolls.take(_num_triggering_rolls).sum) >= _triggering_value
        if remaining_rolls.size >=  _num_rolls_to_score
          running_score  += remaining_rolls.take(_num_rolls_to_score).sum
          remaining_rolls = remaining_rolls.drop(_num_triggering_rolls)
        end
        next
      end

      _num_triggering_rolls = 2
      _triggering_value     = 0
      _num_rolls_to_score   = 2

      if (remaining_rolls.take(_num_triggering_rolls).sum) >= _triggering_value
        if remaining_rolls.size >=  _num_rolls_to_score
          running_score  += remaining_rolls.take(_num_rolls_to_score).sum
          remaining_rolls = remaining_rolls.drop(_num_triggering_rolls)
        end
        next
      end

    end

    running_score
  end

  def scoring_rule(rolls)
    scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
  end

  # Each row in this array of hashes holds the information needed to
  # build a frame from a set of incoming rolls.  Each hash can be thought of
  # as a 'rule' for building a frame.
  #
  # The applicable 'rule' for a list of incoming rolls is the first rule
  # where the sum of the number of triggering rolls
  # is greater than or equal to the triggering value.
  #
  # More than one rule might match so they must be arranged in
  # more-to-least specific order.  For TENPIN bowling, for examples, the
  # rule order is Strike -> Spare -> Open.
  def scoring_rules
    [ {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
      {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
      {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
  end
end