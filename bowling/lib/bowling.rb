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

      # strike
      if (remaining_rolls.take(1).sum) == 10
        if remaining_rolls.size > 2
          running_score += remaining_rolls.take(3).sum
          remaining_rolls = remaining_rolls.drop(1)
        end
        next
      end

      # spare
      if (remaining_rolls.take(2).sum) == 10
        if remaining_rolls.size > 2
          running_score  += remaining_rolls.take(3).sum
          remaining_rolls = remaining_rolls.drop(2)
        end
        next
      end

      # open frame
      if (remaining_rolls.take(2).sum) >= 0
        if remaining_rolls.size >= 2
        running_score += remaining_rolls.take(2).sum
        remaining_rolls = remaining_rolls.drop(2)
        end
        next
      end
    end

    running_score
  end
end