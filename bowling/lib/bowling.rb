module EnforceSubclassResponsibility
  refine Module do
    def subclasses_must_implement(meths)
      meths.each {|meth|
        define_method(meth) {raise NoMethodError.new("#{self.class} must implement #{meth}")}
      }
    end
  end
end

#####################################################################
class Game
  attr_reader :input, :output, :scoresheet_output,
              :num_frames, :players
  def initialize(input: $stdin, output: $stdout, scoresheet_output: $stdout)
    @input  = input
    @output = output
    @scoresheet_output = scoresheet_output

    @players    = initialize_players
    @num_frames = determine_num_frames
  end

  def play
    frame_num = 1
    while frame_num <= num_frames
      players.each_with_index {|player, i|
        output.print "\n\n#{player.name} now starting frame #{frame_num}"

        while !player.turn_complete?(frame_num)
          output.print "\n Roll? >"
          roll   = listen("0").to_i
          player = update_player(i, player, roll)
        end

        DetailedScoresheet.new(frames: player.frames, io: scoresheet_output).render
      }

      frame_num += 1
    end

    output.print "\n\nGame over, thanks for playing!"
    output.print "\nFinal Scores:"
    players.each {|player|
      output.print "\n  #{player.name} #{player.score}"
      }
    output.puts
  end

  def initialize_players
    [].tap {|players|
      get_player_names.each {|name|
        type = get_player_game_type(name).to_sym
        players << Player.new(name: name, config: Variant::CONFIGS.fetch(type))
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

  def determine_num_frames
    players.first.num_frames_in_game
  end

  def update_player(i, old_player, roll)
    new_player = old_player.new_roll(roll)
    players[i] = new_player
    new_player
  end
end


#####################################################################
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


#####################################################################
class Frame
  using EnforceSubclassResponsibility

  subclasses_must_implement(
    [:score, :running_score, :normal_rolls_complete?, :bonus_rolls_complete?])

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

  def normal_rolls_complete?
    status.normal_rolls_complete?
  end

  def bonus_rolls_complete?
    status.bonus_rolls_complete?
  end
end

class CompleteFrame < Frame
  def score
    (normal_rolls + bonus_rolls).sum
  end

  def running_score(previous)
    previous.to_i + score
  end

  def normal_rolls_complete?
    true
  end

  def bonus_rolls_complete?
    true
  end
end

class MissingNormalRollsFrame < Frame
  def score
    nil
  end

  def running_score(previous)
    nil
  end

  def normal_rolls_complete?
    false
  end

  def bonus_rolls_complete?
    false
  end
end

class MissingBonusRollsFrame < MissingNormalRollsFrame
  def normal_rolls_complete?
    true
  end
end

module FrameStatus
  class Complete
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
  end

  class MissingNormalRolls
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
  end

  class MissingBonusRolls < MissingNormalRolls
    def normal_rolls_complete?
      true
    end
  end
end


#####################################################################
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
    frame_class  = frame_class(num_triggering_rolls, num_rolls_to_score, roll_scores)
    turn_rule    = turn_rule(frame_num)

    frame_class.new(normal_rolls: normal_rolls, bonus_rolls: bonus_rolls, turn_rule: turn_rule)
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
    end.new
  end

  def frame_class(num_triggering_rolls, num_rolls_to_score, rolls)
    if rolls.size >=  num_rolls_to_score
      CompleteFrame
    elsif rolls.size < num_triggering_rolls
      MissingNormalRollsFrame
    else
      MissingBonusRollsFrame
    end
  end

  def turn_rule(current_frame_num)
    if current_frame_num == config.num_frames
      FinalFrameTurnRule
    else
      GeneralTurnRule
    end.new
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