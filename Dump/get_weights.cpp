#include <iostream>
#include <algorithm>
#include <math.h>
#include <vector>

using namespace std;

int main() {

    // how many decisions in total
    int decisions;
    // cout << "How many decisions in total are required?: ";
    cin >> decisions;

    vector<float> values(decisions, 0);

    // cout << "\n Enter the criteria weights: ";

    for (int i = 0 ; i < decisions ; i++) {

        cin >> values[i];

    }

    // let's calculate the weights for them

    vector<float> row_values;

    float all_mul = 1;
    for (auto itr : values) 
        all_mul *= itr;

    for (int i = 0 ; i < decisions ; i++) {

        float temp = all_mul / ( pow( values[i] , decisions ) );

        row_values.push_back( pow( temp, (1/float(decisions) ) ) );

    }

    float sum_of_all_row_values = 0;

    for (auto itr : row_values)
        sum_of_all_row_values += itr;

    for (int i = 0 ; i < decisions ; i++) 
        row_values[i] /= sum_of_all_row_values;

    for (auto i : row_values)
        cout << i << " ";

    cout << endl;

    return 0;

}
