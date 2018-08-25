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
      if remaining_rolls.size > 1
        running_score  += remaining_rolls.take(2).sum
        remaining_rolls = remaining_rolls.drop(2)
      end
    end

    running_score
  end
end