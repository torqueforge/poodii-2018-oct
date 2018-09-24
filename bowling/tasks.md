Frame code design

1. Rewrite the Frame hierarchy to better separate the abstractions
     from the specializations.

1. Convert the Frame hierarchy to use composition.  
     Change from -> MissingNormalRollsFrame is-a Frame,
            to   -> Frame has-a 'roll status'
