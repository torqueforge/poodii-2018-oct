require 'terminal-table'
require 'rainbow'

class ClassicScoresheet
  attr_reader :frames, :num_frames, :num_rolls_per_frame,
              :cols_in_normal_frame, :tot_cols_in_normal_frames, :cols_in_final_frame, :num_cols,
              :strike_value, :spare_value, :strike_char, :spare_char
  def initialize(frames:)
    @frames              = frames
    @num_frames          = frames.size
    @num_rolls_per_frame = frames.max_rolls_per_turn

    @cols_in_normal_frame       = num_rolls_per_frame
    @tot_cols_in_normal_frames  = ((num_frames - 1) * cols_in_normal_frame)
    @cols_in_final_frame        = (num_rolls_per_frame + 1)
    @num_cols                   = tot_cols_in_normal_frames + cols_in_final_frame

    # TODO: Note that this classic scoresheet thinks that a strike/spare
    #       is always 10 pins.
    #       Frame objects don't know the concept of strike/spare, so there's
    #       no one to ask, and leaving us no choice but to hardcode the 10 here.
    @strike_value   = 10
    @spare_value    = 10
    @strike_char    = Rainbow("X").green
    @spare_char     = Rainbow("/").orange
  end

  # TODO: Note that ClassicScoresheet has a different API than DetailedScoresheet
  def print
    table = Terminal::Table.new do |t|
      t << header_line
      t.add_separator
      t << printable_score_line
      t << score_separator_line
      t << running_scores_line
    end
    puts
    puts table
  end

  def header_line
    (num_frames - 1).times.map {|i|
      { :value => "F#{i+1}", :colspan => cols_in_normal_frame, :alignment => :center }  } <<
        { :value => "F#{num_frames}", :colspan => cols_in_final_frame, :alignment => :center }
  end

  def printable_score_line
    frame_list = frames.list

    normal_frame_scores =
      frame_list[0..-2].map {|frame|
        r = frame.normal_rolls
        if r == [strike_value]
          pad([[" "] * (num_rolls_per_frame - 1), strike_char].flatten, cols_in_normal_frame)
        elsif r[0..1].sum == spare_value
          pad([r[0].to_s, spare_char, [" "] * (num_rolls_per_frame - 2)].flatten, cols_in_normal_frame)
        else
          pad(r.map {|score| score.to_s}, cols_in_normal_frame)
        end
      }

    r = frame_list.last.normal_rolls + frame_list.last.bonus_rolls
    final_frame_score =
      if r.size > 0 && r.all? {|score| score == strike_value}
        pad([strike_char] * num_rolls_per_frame, cols_in_final_frame)
      elsif r[0..1] == [strike_value] * 2
        pad(([strike_char] * 2) + r[2..-1].map {|score| score.to_s} , cols_in_final_frame)
      elsif r[0] == strike_value
        pad([strike_char] + r[1..-1].map {|score| score.to_s} , cols_in_final_frame)
      elsif r[0..1].sum == spare_value
        pad([r[0].to_s, spare_char, r[2..-1].map {|score| score.to_s}], cols_in_final_frame)
      else
        pad(r.map {|score| score.to_s}, cols_in_final_frame)
      end

    (normal_frame_scores << final_frame_score).flatten #.map {|score| bright(score)}
  end

  def pad(scores, i)
    (scores +
      ([" "] * (i - scores.size))).
        flatten
  end

  def score_separator_line
    box_corner_left   = "\u2515"
    box_center        = "\u2501"
    box_corner_right  = "\u2519"
    box_shared_corner = "\u253B"
    initial_padding   = " " * 2
    embedded_padding  = " " * 3
    connecting_line   = box_center * 3
    final_line        = box_center * 2

    value =
      initial_padding + ((
        (((box_corner_left + connecting_line) +

          # this might print 0 times
          ((box_shared_corner + connecting_line) * (cols_in_normal_frame - 2)) +

          box_corner_right)) + embedded_padding ) *
            # repeat for all normal columns
            (num_frames - 1)) +

        # now do final frame
        box_corner_left + connecting_line +
          ((box_shared_corner + connecting_line) * (cols_in_normal_frame - 2)) +

          # which has an extra box with no trailing right hand corner
          (box_shared_corner + final_line)

    [{ :value => value, :colspan => num_cols, :alignment => :left}]
  end

  def running_scores_line
    frames.running_scores[0..-2].map {|rs|
      { :value => bright(rs),  :colspan => cols_in_normal_frame, :alignment => :center}} <<
        { :value => bright(frames.running_scores[-1]), :colspan => cols_in_final_frame, :alignment => :center}

  end

  def bright(str)
    Rainbow(str).bright
  end
end
