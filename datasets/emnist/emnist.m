
load('datasets/emnist/EMNIST.mat');

TrainLabel = GPUTest(TrainLabel);
TestLabel = GPUTest(TestLabel);
