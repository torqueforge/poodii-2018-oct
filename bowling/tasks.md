## No Tap / Duckpin


### Goals:

* Isolate the differences between TENPIN, and NOTAP and DUCKPIN bowling
* Practice _the_ fundamental design skill -- separating things that change from those that remain the same


### Task 1:

Add support for 'No Tap' bowling, where you get a strike or spare for knocking down *9* pins.

See bowling/lib/bowling.rb for some suggestions about the code.

See branch bowling_2_notap_refactor for a step-by-step example.


### Task 2:

Once you have No Tap working, add support for 'Duckpin' bowling.  In Duckpin bowling, strikes and spares
work just like in TENPIN, but if the frame is open, you get an extra roll.  Note that even if this
3rd roll knocks down all remaining pins, the frame is still open. That is, the frame score is 10, but
there are no bonus rolls.

See branch bowling_3_duckpin_refactor for the step-by-step example.