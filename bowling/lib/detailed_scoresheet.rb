class DetailedScoresheet
  def self.update(player:, io:)
    new(frames: player.frames, io: io).render
  end

  attr_reader :frames, :out
  def initialize(frames: nil, io: $stdout)
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
