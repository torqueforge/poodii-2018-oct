require_relative '../../test_helper'
require_relative '../lib/bowling'
require_relative '../lib/classic_scoresheet'


rolls = [[7,3],[10],[1,8,2],[4,4,0],[5,0,0],[6,0,0],[7,0,0],[8,0,0],[9,0,0],[10,3,7]].flatten
ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:DUCKPIN])).print

rolls = [[7,3],[10],[1,8],[4,4],[5,0],[6,0],[7,0],[8,0],[9,0],[10,3,7]].flatten
ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:TENPIN])).print

rolls = [[7,3],[10],[1,2]].flatten
ClassicScoresheet.new(frames: Frames.for(rolls: rolls, config: Variant::CONFIGS[:TENPIN])).print
