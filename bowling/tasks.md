## Handle turn prompting within interactive game

The play method of Game currently returns the following hard-coded output:

    def play
      output.print "\n\nFee now starting frame 1" 
    end

The #test_prompts_for_rolls_until_turn_is_complete test has just been written.
Your job is to make it pass.

You need to add a loop like the following to #play:
  
    def play
      for each frame
        for each player
          until the player's turn is over
            prompt the player for a roll
          end
          print the player's updated scoresheet
        end
      end
    end

This brings up lots of issues:

* How does Game know how many frames to ask the players to roll?

* Frames and Frame are currently immutable.  (The Frame factory
    expects to be passed the player's complete roll history.)

    Now that you're accumulating rolls one-by-one, you must either:

    a) hold onto a list of the incoming rolls by player and generate
       an entirely new Frames object with each new roll,  
      or  
    b) create a Frames for each player when the game starts, and then
        mutate the player's current frame object with each new roll.

* If you decide to use the (immutable) Frames/Frame as is, where
    then does the raw roll history get stored? Here in Game, or
    in some other (perhaps new) object?

* If you decide to mutate Frames/Frame, what changes are needed?

* How does the game know if a player's turn is complete?  
   In most frames, a player rolls just their normal rolls.
   In the _final_ frame, a player rolls their normal rolls and any bonus rolls
     to which they are entitled.  
   Where should 'is the turn complete' knowledge reside?  
   How does the game get access to it?

* This is a bunch of information, which might be spread out over
     a number of objects.  
     How many of these objects does Game get to know about?

Tasks:
1. Draw one or more sequence diagrams, exploring possible designs.

1. Write some code, if you dare. 

1. Browse bowling_l7_interactive_play_refactor and critique the implementation.