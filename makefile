weights: get_weights.cpp
	g++ -std=c++11 get_weights.cpp -o wei
	./wei < input.txt > weights.txt
	rm wei
