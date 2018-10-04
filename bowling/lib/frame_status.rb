module FrameStatus

  class Complete
    def score(frame)
      (frame.normal_rolls + frame.bonus_rolls).sum
    end

    def running_score(previous, frame)
      previous.to_i + frame.score
    end

    def normal_rolls_complete?
      true
    end

    def bonus_rolls_complete?
      true
    end

    def add_roll(roll, frame)
      raise "\nError: Attempting to add roll #{roll} to #{self.inspect} frame is #{frame.inspect}\n"
    end
  end


  class MissingNormalRolls
    def score(frame)
      nil
    end

    def running_score(previous, frame)
      nil
    end

    def normal_rolls_complete?
      false
    end

    def bonus_rolls_complete?
      false
    end

    def add_roll(roll, frame)
      frame.normal_rolls << roll
      nil
    end
  end


  class MissingBonusRolls < MissingNormalRolls
    def normal_rolls_complete?
      true
    end

    def add_roll(roll, frame)
      frame.bonus_rolls << roll
      roll
    end
  end
end
