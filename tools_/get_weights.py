# Program to get the weights for the criteria matrix being used by an AHP (Analytic Hierachy Process) model

# dictionary to store fraction values
variables = {"1/2":0.5,"1/3":0.33,"1/4":0.25,"1/5":0.2,"1/6":0.167,"1/7":0.143,"1/8":0.125,"1/9":0.111}


print("Enter the dimension (rows, cols) for the matrix: ", end="")
rows, cols = list(map(int, input().split()))

print("Start entering elements in a row-wise sense: ")

# initialise a matrix to store the values
matrix_string = [ [0 for _ in range(cols)] for _ in range(rows) ]

for i in range(rows):
    matrix_string[i] = list(map(str, input().split()))

# convert the matrix to int values from here
matrix = [ [0 for _ in range(cols)] for _ in range(rows) ]
row_products = [1] * rows # array to store the product of each rows

for i in range(rows):
    for j in range(cols):

        if len(matrix_string[i][j]) == 3:
            matrix[i][j] = variables[matrix_string[i][j]]
        else:
            matrix[i][j] = int(matrix_string[i][j])

        row_products[i] *= matrix[i][j]

# process finished

# normalising the values and calculating the priority values for all the decisions
geometric_means_array = [ (ele**(1/float(cols))) for ele in row_products ]
total = 0
for ele in geometric_means_array: total += ele
weights = [ ele / total for ele in geometric_means_array ]
# end

# weights being assigned
print(weights)
