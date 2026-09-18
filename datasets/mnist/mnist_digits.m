
load('datasets/mnist/MNIST.mat');

Train = GPUTest(Train);
TrainLabel = reshape(TrainLabel,1,[]);
Test = GPUTest(Test);
TestLabel = reshape(TestLabel,1,[]);