## Write Unit Tests


### Goals:

* Practice writing loosely coupled unit tests
* Critique an existing test suite


### Task:

We've made it a good long way using the original Bowling (now Frames) tests as integration tests, but testing at such a high level means we have to write Frames tests for all the possible combinations, which has led to a combinatorial explosion of tests in a single, high-level class. 

It's time to write unit tests for the new classes so we can delete some of the duplication.

#### StandardParser Tests

Start with the StandardParser.  
  What should be tested?  
  What should be tested _first_?  
  Should you use an existing config, or define a new one just for testing?  Does this matter?


#### LowballParser Tests

Next, consider LowballParser.  
  Should the same things get tested here as for the StandardParser?  
  

#### Variant Tests

Now, on to Variant.  Variant is configured with a hash that contains a string that represents a parser class (schew).  
  Should you use an existing config, with it's associated parser class?
  Or should you make up a new config, and a new parser, just for testing?
  Which is best?  Does it matter?


#### Frames Tests

Are the existing Bowling tests actually Frames tests?


#### Frame Tests

How much testing does Frame need?

#### Critique an existing test suite

Branch bowling_l5_unittests_example contains a set of tests written in response to the above questions.  (As always, the step-by-step changes are in bowling_l5..._refactor).   
    What would you change about these tests?