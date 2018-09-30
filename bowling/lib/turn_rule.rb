class GeneralTurnRule
  def turn_complete?(frame)
    frame.normal_rolls_complete?
  end
end

class FinalFrameTurnRule
  def turn_complete?(frame)
    (frame.normal_rolls_complete? and frame.bonus_rolls_complete?)
  end
end
