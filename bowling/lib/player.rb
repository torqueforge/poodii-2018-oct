require 'forwardable'
class Player
  extend Forwardable
  def_delegators :frames, :score, :turn_complete?

  def self.for(name:, config: Variant::CONFIGS[:TENPIN], rolls: [])
    new(name: name, config: config, rolls: rolls)
  end

  attr_reader :name, :rolls, :config, :frames

  def initialize(name:, config:, rolls: [])
    @name   = name
    @config = config
    @rolls  = rolls
    @frames = Frames.for(rolls: rolls, config: config)
  end

  def new_roll(roll)
    self.class.for(name: name, config: config, rolls: rolls << roll)
  end

  def num_frames_in_game
    frames.size
  end
end
