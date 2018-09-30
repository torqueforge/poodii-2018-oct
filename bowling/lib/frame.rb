require 'forwardable'
class Frame
  extend Forwardable
  def_delegators :status, :normal_rolls_complete?, :bonus_rolls_complete?

  attr_reader :normal_rolls, :bonus_rolls, :status, :turn_rule
  def initialize(normal_rolls:, bonus_rolls:, status: nil, turn_rule: GeneralTurnRule.new)
    @normal_rolls = normal_rolls
    @bonus_rolls  = bonus_rolls
    @status       = status
    @turn_rule    = turn_rule
  end

  def turn_complete?
    turn_rule.turn_complete?(self)
  end

  def score
    status.score(self)
  end

  def running_score(previous)
    status.running_score(previous, self)
  end
end
