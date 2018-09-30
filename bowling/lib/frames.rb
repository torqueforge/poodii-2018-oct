class Frames
  include Enumerable

  def self.for(rolls:, config: Variant::CONFIGS[:TENPIN])
    variant = Variant.new(config: config)
    new(variant.framify(rolls), variant.config)
  end

  attr_reader :list, :max_rolls_per_turn
  def initialize(list, config)
    @list  = list
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
end
