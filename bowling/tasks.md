Game/Scoresheet collaboration

1. Change Game so that it can interact with _any_ scoresheet.

1. Adapt ClassicScoresheet for use in a Game.    
      (Consider where its output is going.)

1. Use ClassicScoresheet instead of DetailedScoresheet in a Game

1. Use a test double to decouple Game#test_prints_scoresheet_after_turn 
     from DetailedScoresheet  

1. Use a mock to decouple Game#test_prints_scoresheet_after_turn 
    from DetailedScoresheet  

1. Consider which is better, the test double or the mock?


See bowling_8_classic_scoresheet_refactor for a detailed example.