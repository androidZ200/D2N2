
load('datasets/fashion/FashionMNIST.mat');

% rename digits label
TrainLabel = GPUTest(TrainLabel + 1);
TestLabel = GPUTest(TestLabel + 1);

