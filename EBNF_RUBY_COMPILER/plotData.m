clear all
close all
data = importfile('data_stream.data');

plot(data)
xlabel('Number of iteration')
ylabel('Position of token in stream')
