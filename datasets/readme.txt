# Description about the configuration of all the datasets for all the runs 

- In total, Six decisions are evaluated using these datasets. They will be passed on to the testing framework for evaluation after this

- However, considering the limitations of the .csv files, user needs to get rid of rows in this order: 21 14 1:6

# Description about the environments in which the runs were conducted

- run_1.csv: 40 cars
- run_2.csv: 50 cars
- run_3.csv: 60 cars
- run_4.csv: 70 cars
- run_5.csv: 80 cars

- please reder to the png image to get the weights used for the normal AHP model
- please refer to the pdf in this folder to get the weights used for each run using Advanced AHP model

# Some specific thoughts (Brain Dump)

- decision 3 is varied for all the runs to optimise the approach suitable to the number of cars in the run
- matrices used for AHP and advanced AHP are all different for datasets as other decisions are showing different trends
- there are 200 turns for every run
- In total, the runs were normalised from 10 runs each for each decision in the above datasets (main reason being the memory limitation)
