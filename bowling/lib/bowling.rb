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
      rule = scoring_rule(remaining_rolls)

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

  def scoring_rule(rolls)
    scoring_rules.find {|rule|
      (rolls.take(rule[:num_triggering_rolls]).sum) >= rule[:triggering_value]
    }
  end

  # NOTAP needs different scoring_rules.
  # Now that the TENPIN rules are isolated, we can extract and re-inject them.
  # This will create a new seam where we can inject NOTAP rules instead.
  def scoring_rules
    [ {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
      {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
      {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
  end
end