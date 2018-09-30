require 'forwardable'
class Cheater
  extend Forwardable
  def_delegators :player, :score, :num_frames_in_game, :turn_complete?, :name, :config, :rolls, :frames

  def self.for(name:, config: Variant::CONFIGS[:TENPIN], rolls: [], player_maker: Player)
    new(player_maker.new(name: name, config: config, rolls: rolls))
  end

  attr_reader :player
  def initialize(player)
    @player = player
  end

  def new_roll(roll)
    self.class.new(player.new_roll(cheat(roll)))
  end

  def cheat(roll)
    (roll < 5 ? 8 : roll)
  end
end