class Frames
  include Enumerable

  def self.for(rolls:, config: Variant::CONFIGS[:TENPIN])
    variant = Variant.new(config: config)
    new(variant.framify(rolls), variant.config)
  end

  attr_reader :list, :config, :max_rolls_per_turn, :parser
  def initialize(list, config)
    @list   = list
    @config = config
    @parser = Object.const_get(config.parser).new
    @max_rolls_per_turn = config.max_rolls_per_turn
  end

  def score
    running_scores.compact.last
  end

  def running_scores
    list.reduce([]) {|running_scores, frame|
      running_scores << frame.running_score(running_scores.last)}
  end

  def turn_complete?(i)
    frame(i).turn_complete?
  end

  def frame(i)
    list[i-1]
  end

  def each
    list.each {|frame| yield frame}
  end

  def size
    list.size
  end

  ###################
  # Mutation support
  ###################
  def new_roll(roll)
    list.each {|f|
      break unless roll
      roll = f.add_roll(roll)
    }
  end
end
