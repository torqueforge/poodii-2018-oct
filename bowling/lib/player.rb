class Player
  attr_reader :name, :rolls, :config, :frames

  def initialize(name:, config:, rolls:[])
    @name   = name
    @config = config
    @rolls  = rolls
    @frames = Frames.for(rolls: rolls, config: config)
  end

  def score
    frames.score
  end

  def new_roll(roll)
    Player.new(name: name, config: config, rolls: rolls << roll)
  end

  def num_frames_in_game
    frames.size
  end

  def turn_complete?(frame_number)
    frames.turn_complete?(frame_number)
  end
end
