# config details about all the testing that's happening in the current folder

run_1: comparing decision 1 & 5 with 5 runs each
run_2:  (Maybe an optimisation of the first one)
run_3: still decision 1 & 5
run_4: comparing all decisions with 5 runs each

weights matrix:

run_1: [0.01 0.97 0.01 0.01]
run_2: [0.97 0.01 0.01 0.01]
run_3: (5% 10% 5% 80%) how important a decision is
run_4: same config as run_3

case for run_4:

- it worked better than decision 1 by a significant difference of 10 on average
- now let's try to get it better than decision 3


case for run_8:

- comparing different decision weights array to optimise the weights otself to outrun atleast 3 decisions
- let's see how that goes

case for run_14:

- comparing different importance weights for the decision model used right now
-   1: 5 13 5 77
    2: 2 13 2 83
    3: 1 13 1 85
    4: 0.01 2 0.01 2

case for run_16:

- for all the four decisions and my ahp decision model
- 15 runs for each, let's see what happens
- criteria weight for decision 5: [1 13 1 85]
