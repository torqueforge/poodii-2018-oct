class FrameStatus

  attr_reader :config, :parser
  def initialize(config: Variant::CONFIGS[:TENPIN])
    @config = OpenStruct.new(config)
    @parser = Object.const_get(self.config.parser).new
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

  def process(new_roll, frame)
    num_triggering_rolls, num_rolls_to_score, roll_scores = parse(frame.rolls + [new_roll])
    yield(roll_scores.last)
    frame.status = status(num_triggering_rolls, num_rolls_to_score, frame.rolls)
  end

  ############################
  class Complete < FrameStatus
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
      roll
    end
  end


  class MissingNormalRolls < FrameStatus
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
      return unless roll
      process(roll, frame) {|new_value| frame.normal_rolls << new_value}
      nil
    end
  end


  class MissingBonusRolls < MissingNormalRolls
    def normal_rolls_complete?
      true
    end

    def add_roll(roll, frame)
      process(roll, frame)  {|new_value| frame.bonus_rolls << new_value}
      roll
    end
  end

end
