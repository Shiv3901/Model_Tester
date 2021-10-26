# Description about the configuration of all the datasets for all the runs 

- In total, Six decisions are evaluated using these datasets. They will be passed on to the testing framework for evaluation after this

- However, considering the limitations of the .csv files, user needs to get rid of rows in this order: 21 14 1:6

# Description about the environments in which the runs were conducted


1. run_1.csv: 
    - decisions: 1 2 3 4 5 6
    - max-distance: 5000
    - number-of-cars: 30
    - 20 runs for each decision
    - 200 lane changes for each run
    - Decision 3 resets after each lane travels more than max-distance
    - Weights matrix used for normal AHP model: []
    - Weights matrix used for advanced AHP model: []

2. run_2.csv: 
    - decisions: 1 2 3 4 5 6
    - max-distance: 5000
    - number-of-cars: 40
    - 20 runs for each decision
    - 200 lane changes for each run
    - Decision 3 resets after each lane travels more than max-distance
    - Weights matrix used for normal AHP model: []
    - Weights matrix used for advanced AHP model: []

3. run_3.csv: 
    - decisions: 1 2 3 4 5 6
    - max-distance: 5000
    - number-of-cars: 50
    - 20 runs for each decision
    - 200 lane changes for each run
    - Decision 3 resets after each lane travels more than max-distance
    - Weights matrix used for normal AHP model: [0.59 0.14 0.03 0.24]
    - Weights matrix used for advanced AHP model: [0.43 0.10 0.02 0.10 0.35]


4. run_4.csv: 
    - decisions: 1 2 3 4 5 6
    - max-distance: 5000
    - number-of-cars: 60
    - 5 runs for each decision
    - 200 lane changes for each run
    - Decision 3 resets after each lane travels more than max-distance
    - Weights matrix used for normal AHP model: [0.59 0.14 0.03 0.24]
    - Weights matrix used for advanced AHP model: [0.43 0.10 0.02 0.10 0.35]

