class Game
  attr_reader :input, :output
  def initialize(input: $stdin, output: $stdout)
    @input  = input
    @output = output
    initialize_players
  end

  # Requirement: Prompt until the current player's turn is complete
  #
  # It feels like a game loop can no longer be avoided:
  #   for each frame
  #     for each player
  #       until the player's turn is over
  #         prompt the player for a roll
  #         (eventually) print the player's scoresheet
  #
  # This brings up lots of issues:
  #
  #   1) How does Game know how many frames to ask the players to roll?
  #
  #   2) Frames and Frame are currently immutable.  The Frame factory
  #       expects to be passed the player's complete roll history.
  #
  #       Now that we're accumulating rolls one-by-one, we must either:
  #
  #       a) hold onto a list of the incoming rolls by player and generate
  #          an entirely new Frames object with each new roll,
  #         or
  #       b) create a Frames for each player when the game starts, and then
  #           mutate the player's current frame object with each new roll.
  #
  #   3a) If we decide to use the (immutable) Frames/Frame as is, where
  #       then does the raw roll history get stored? Here in Game, or
  #       in some other object, perhaps Player?
  #
  #   3b) If we decide to mutate Frames/Frame, what changes are needed?
  #
  #   4) How do we know when a player's turn is complete?
  #       In most frames, a player rolls just their normal rolls.
  #       In the _final_ frame, a player rolls their nomal rolls and the bonus rolls
  #         to which they are entitled.
  #       Where should 'is the turn complete' knowledge reside in our app?
  #
  #   5) This is a bunch of information, which might be spread out over
  #        a number of objects.
  #      How many of these objects does Game get to know about?

  def play
    output.print "\n\nFee now starting frame 1"
  end

  def initialize_players
    [].tap {|players|
      get_player_names.each {|name|
        type = get_player_game_type(name)

      }
    }
  end

  def get_player_names
    output.print "\nWho's playing? (Larry, Curly, Moe) >"
    listen("Larry, Curly, Moe").gsub(" ", "").split(",")
  end

  def get_player_game_type(name)
    output.print "\nWhich game would #{name} like to play? (TENPIN) >"
    listen("TENPIN")
  end

  def listen(default)
    ((i = input.gets.chomp).empty? ? default : i)
  end
end


#####################################################################
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

  def each
    list.each {|frame| yield frame}
  end

  def size
    list.size
  end
end


#####################################################################
class Frame
  attr_reader :normal_rolls, :bonus_rolls
  def initialize(normal_rolls: nil, bonus_rolls: nil)
    @normal_rolls = normal_rolls
    @bonus_rolls  = bonus_rolls
  end

  def score
    (normal_rolls + bonus_rolls).sum
  end

  def running_score(previous)
    previous.to_i + score
  end
end

class PendingFrame < Frame
  def score
    nil
  end

  def running_score(previous)
    nil
  end
end


#####################################################################
class DetailedScoresheet
  attr_reader :frames, :out
  def initialize(frames:, io: $stdout)
    @frames = frames
    @out    = io
  end

  def render
    out.puts dasherized(frame_summary_line("FRAME", 1.upto(frames.size)))
    out.puts frame_detail_line("PINS",  :normal_rolls)
    out.puts frame_detail_line("BONUS", :bonus_rolls)
    out.puts frame_detail_line("SCORE", :score, "  ")
    out.puts frame_summary_line("TOTAL", frames.running_scores)
  end

  private

  def frame_summary_line(title, items)
    enclosed(title) {
      items.map {|item|
        item.to_s.rjust(3).ljust((frames.max_rolls_per_turn-1) * 4) + "    "
      }
    }
  end

  def frame_detail_line(title, message, sep=". ")
    enclosed(title) {
      frames.map {|frame|
        " " + format_details(frame.send(message), frames.max_rolls_per_turn).join(sep) + " "
      }
    }
  end

  def enclosed(title)
    "#{(title + ':').ljust(6)} |" + (yield).join("|") + "|"
  end

  def format_details(list, minimum_num_items)
    ([list].flatten.compact.map {|item|
      sprintf("%2d", item) } + Array.new(minimum_num_items, '  ')).
        first(minimum_num_items)
  end

  def dasherized(line)
    line[0..7] + line[8..-1].gsub(" ", "-")
  end
end


#####################################################################
require 'ostruct'

class Variant
  CONFIGS = {
    :TENPIN => {
      :parser => "StandardRollParser",
      :max_rolls_per_turn => 2,
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value:  0, num_rolls_to_score: 2} ]
      },
    :NOTAP => {
      :max_rolls_per_turn => 2,
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 9, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 0, num_rolls_to_score: 2} ]
      },
    :DUCKPIN => {
      :max_rolls_per_turn => 3,
      :parser => "StandardRollParser",
      :scoring_rules => [
        {num_triggering_rolls: 1, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 2, triggering_value: 10, num_rolls_to_score: 3},
        {num_triggering_rolls: 3, triggering_value:  0, num_rolls_to_score: 3} ]
      },
    :LOWBALL => {
      :max_rolls_per_turn => 2,
      :parser => "LowballRollParser",
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
    frame_list    = []
    current_frame = 0
    max_frames    = 10
    remaining_rolls = rolls

    while current_frame < max_frames
      current_frame += 1
      num_triggering_rolls, num_rolls_to_score, roll_scores = parse(remaining_rolls)

      frame_class =
        if remaining_rolls.size >=  num_rolls_to_score
          Frame
        else
          PendingFrame
        end

      normal = roll_scores.take(num_triggering_rolls)
      bonus  = roll_scores[num_triggering_rolls...num_rolls_to_score] || []

      remaining_rolls = remaining_rolls.drop(num_triggering_rolls)
      frame_list << frame_class.new(normal_rolls: normal, bonus_rolls: bonus)
    end

    frame_list
  end

  def parse(rolls)
    parser.parse(rolls: rolls, frame_configs: config.scoring_rules)
  end
end


########################## Roll Parsers #############################

#############################
# StandardRollParser uses rules specified in a configuration hash
# to parse frame information from a list of rolls.
#
# It returns the original pinfall as the score for each roll.
#############################
class StandardRollParser

  def parse(rolls:, frame_configs:)

    # Select the applicable frame config
    cfg =
      frame_configs.find {|frame_cfg|
        (rolls.take(frame_cfg[:num_triggering_rolls]).sum) >= frame_cfg[:triggering_value]
      }

      [ cfg[:num_triggering_rolls], cfg[:num_rolls_to_score], rolls.take(cfg[:num_rolls_to_score]) ]
  end
end

#############################
# LowBallParse contains redundant, duplicative, awkward logic
#  to parse frame information from a list of rolls.
#
# The rules are:
#   If 1st roll is 0,
#     roll_score is 10 and you get 2 bonus rolls.
#
#   If 2nd roll is 0,
#     roll_score for 2nd roll is 10-1st roll, and you get 1 bonus roll.
#
#   Open frame is two non-zero rolls.
#
# By definition, it returns an alternate score for some input pinfalls.
#############################
class LowballRollParser

  def parse(rolls:, frame_configs: nil)

    # strike
    if rolls[0] == 0
      num_triggering_rolls = 1
      num_rolls_to_score   = 3
      roll_scores = [10]

      roll_scores +=
        (if   rolls[1] == 0 && rolls[2] == 0
          [10, 10]

        elsif rolls[1] == 0 && rolls[2] != 0
          [10, rolls[2]]

        elsif rolls[1] != 0 && rolls[2] == 0
          [rolls[1], 10-rolls[1]]

        else
          [rolls[1], rolls[2]]
        end)

    # spare
    elsif
      if rolls[1] == 0
        num_triggering_rolls = 2
        num_rolls_to_score   = 3

        roll_scores = [rolls[0], (10-rolls[0])]

        roll_scores +=
          (if rolls[2] == 0
            [10]
          else
            [rolls[2]]
          end)
      end

    # open frame
    else
      num_triggering_rolls = 2
      num_rolls_to_score   = 2
      roll_scores = [rolls[0], rolls[1]]
    end

    [num_triggering_rolls, num_rolls_to_score, roll_scores.compact]
  end
end