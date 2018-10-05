require 'ostruct'

class Variant
  CONFIGS = {
    :TENPIN => {
      :parser => "StandardRollParser",
      :num_frames         => 10,
      :max_rolls_per_turn => 2,
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :max_rolls_per_turn => 2,
      :parser => "StandardRollParser",
      :num_frames         => 10,
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :max_rolls_per_turn => 3,
      :parser => "StandardRollParser",
      :num_frames         => 10,
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
      },
    :LOWBALL => {
      :max_rolls_per_turn => 2,
      :parser => "LowballRollParser",
      :num_frames         => 10,
      :scoring_rules => [ # The current structure won't work for LOWBALL
         ]
      }
    }

  attr_reader :config, :parser
  def initialize(config:)
    @config = OpenStruct.new(config)
    @parser = Object.const_get(self.config.parser).new
  end

  def framify(rolls)
    frame_list        = []
    current_frame_num = 0
    remaining_rolls   = rolls

    while current_frame_num < config.num_frames
      current_frame_num += 1
      frame = extract_frame(remaining_rolls, current_frame_num)
      frame_list << frame
      remaining_rolls = remaining_rolls.drop(frame.normal_rolls.size)
    end

    frame_list
  end

  private

  def extract_frame(rolls, frame_num)
    num_triggering_rolls, num_rolls_to_score, roll_scores = parse(rolls)

    normal_rolls = roll_scores.take(num_triggering_rolls)
    bonus_rolls  = (roll_scores[num_triggering_rolls...num_rolls_to_score] || [])
    status       = status(num_triggering_rolls, num_rolls_to_score, roll_scores)
    turn_rule    = turn_rule(frame_num)

    Frame.new(normal_rolls: normal_rolls, bonus_rolls: bonus_rolls,
                    status: status, turn_rule: turn_rule, config: config)
  end

  def parse(rolls)
    parser.parse(rolls: rolls, frame_configs: config.scoring_rules)
  end

  def status(num_triggering_rolls, num_rolls_to_score, rolls)
    if rolls.size >=  num_rolls_to_score
      FrameStatus::Complete
    elsif rolls.size < num_triggering_rolls
      FrameStatus::MissingNormalRolls
    else
      FrameStatus::MissingBonusRolls
    end.new(config: config)
  end

  def turn_rule(current_frame_num)
    if current_frame_num == config.num_frames
      FinalFrameTurnRule
    else
      GeneralTurnRule
    end.new
  end
end
