addpath(genpath(pwd));
return;
%% standart gradient training

clear all;

global is_gpu; is_gpu = true;
global is_single; is_single = true;
mnist_digits;
lambda = 632.8e-9;
f = 0.01;
mesh = Mesh(4e-6, 512);
mesh_inp = Mesh(8e-6, 28);
opt = AdamFabric();
MASK = mask10_1(mesh,[1.2e-3, 0.9e-3],100e-6);

dc = InputModulator(mesh_inp, lambda, @(W)normalize_field(W));
dc = SincPropagator(dc, f);
dc = FullDOE(dc, mesh, PhaseType, opt); doe = dc;
dc = ASMPropagator(dc, f);
dc = GetMaskSum(dc, mesh, MASK); decoder = dc;
Error = ErrorJSCE(dc, ClassificationTarget(dc.count_outputs(), length(unique(TrainLabel))), 20, 0.1);

param.epoch = 4;
param.batch = 20;
param.cycle = param.epoch*size(Train,3)/10;
param.speed = 0.3;
param.slowdown = 0.9995;
param.predictor = decoder;
GetTraining(Error,Train,TrainLabel,param);

[err, ~, int] = GetTest(decoder, Test, TestLabel, 40);
plot_error_table(err, Labels);
plot_intensity_table(int, Labels);

%% 4F-system

clear variables;

global is_gpu; is_gpu = true;
mnist_digits;
f = 0.25;
lambda = 532e-9;

mesh_doe = Mesh(16e-6, 512);
mesh_lens = Mesh(3e-6, 4096);
mesh_inp = Mesh(36e-6, 28);
MASK = mask10_1(mesh_doe,[5e-3, 4e-3],1e-3);

dc = InputModulator(mesh_inp, lambda, @(W)normalize_field(W));

dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseType, "X").set_tf(exp(-2i*pi/lambda/f/2*mesh_lens.X.^2)));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseType, "Y").set_tf(exp(-2i*pi/lambda/f/2*mesh_lens.Y.^2)));
dc.add_next(SincPropagator(dc, f));

dc = FullDOE(dc, mesh_doe, PhaseType, AdamFabric()); doe = dc;
dc.set_inaccuracy(Inaccr_shift(2));

dc = CompiledMatrixPropagator(dc);
dc.add_next(SincPropagator(dc, f));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseType, "X").set_tf(exp(-2i*pi/lambda/f/2*mesh_lens.X.^2)));
dc.add_next(CylindricalDOE(dc, mesh_lens, PhaseType, "Y").set_tf(exp(-2i*pi/lambda/f/2*mesh_lens.Y.^2)));
dc.add_next(SincPropagator(dc, f));

dc = GetMaskSum(dc, mesh_doe, MASK); decoder = dc;
dc = NormalizationSUM(dc); 
Error = ErrorSCE(dc, ClassificationTarget(dc.count_outputs(), length(unique(TrainLabel))), 80);

param.epoch = 4;
param.batch = 20;
param.cycle = param.epoch*size(Train,3)/10;
param.speed = 0.3;
param.slowdown = 0.9995;
param.predictor = decoder;
GetTraining(Error,Train,TrainLabel,param);

[err_off, int_off] = GetTestOffset(decoder, Test, TestLabel, 2, doe.Errors{1}, 40);
plot_error_offset(err_off);
plot_intensity_offset(int_off);

%% example parallel system

clear variables;

global is_gpu; is_gpu = true;
lambda = 532e-9;
f = 0.01;
mesh_inp = Mesh(10e-6, 28);
mesh = Mesh(4e-6, 512);

mnist_digits;
MASK = mask10_1(mesh,[1.2e-3, 0.9e-3],100e-6);

dc = InputModulator(mesh_inp, lambda);
dc = SincPropagator(dc, f);
dc = BeamSplitter(dc, mesh);

dc1 = ASMPropagator(dc, f);
dc1 = FullDOE(dc1, mesh, PhaseType, AdamFabric); doe{1} = dc1;
dc1 = ASMPropagator(dc1, f);

dc2 = ASMPropagator(dc, f);
dc2 = FullDOE(dc2, mesh, PhaseType, AdamFabric); doe{2} = dc2;
dc2 = ASMPropagator(dc2, f);

dc = BeamCollector(dc1, 0.5).add_new(dc2, 0.5);
dc = ASMPropagator(dc, f);
dc = GetMaskSum(dc, mesh, MASK);
decoder = NormalizationSUM(dc);
Error = ErrorSCE(decoder, ClassificationTarget(size(MASK,3), length(unique(TrainLabel))), 70);

param.epoch = 4;
param.batch = 20;
param.cycle = param.epoch*size(Train,3)/10;
param.speed = 0.5;
param.slowdown = 0.9995;
param.predictor = decoder;
GetTraining(Error,Train,TrainLabel,param);

[err, ~, int] = GetTest(decoder, Test, TestLabel, 40);
plot_error_table(err, Labels);
plot_intensity_table(int, Labels);

% create new system from old
dc = InputModulator(mesh_inp, lambda);
dc = SincPropagator(dc, f*2);
dc = FullDOE(dc,mesh,ComplexType).set_tf((doe{1}.get_transmission_function() + doe{2}.get_transmission_function())/2);
dc = ASMPropagator(dc, f*2);
dc = GetMaskSum(dc, mesh, MASK);
decoder = NormalizationSUM(dc);

[err, ~, int] = GetTest(decoder, Test, TestLabel, 40);
plot_error_table(err, Labels);
plot_intensity_table(int, Labels);

%% example of a quasi-coherent source

clear variables;

global is_gpu; is_gpu = true;
lambda = 532e-9;
f = 0.01;
f_inp = 0.5;
scale = 8;
count_wave = 20;
mesh = Mesh(4e-6, 512);
mesh_inp = Mesh(4e-6, 28*scale);

mnist_digits;
MASK = mask10_1(mesh,[1.2e-3, 0.9e-3],100e-6);

AMP = exp(-(mesh_inp.X.^2 + mesh_inp.Y.^2)./(0.5*mesh_inp.X(end)).^2);
dc = InputModulator(mesh_inp, lambda, @(W)normalize_field(AMP.*exp(2i*pi*rand([size(mesh_inp), size(W,3), count_wave]))));
dc = SincPropagator(dc, f_inp);
dc = GetFullIntensity(dc, mesh_inp);

dc = InputModulator(mesh_inp, lambda, @(W)dc.get_field(W).*repelem(W,scale,scale));
dc = SincPropagator(dc, f);
dc = FullDOE(dc, mesh, PhaseType, AdamFabric()); doe = dc;
dc = SincPropagator(dc, f);
dc = GetMaskSum(dc, mesh, MASK); decoder = dc;
dc = NormalizationSUM(dc);
Error = ErrorSCE(dc, ClassificationTarget(dc.count_outputs(), length(unique(TrainLabel))), 80);

param.epoch = 2;
param.batch = 20;
param.max_batch = 5;
param.cycle = param.epoch*size(Train,3)/20;
param.speed = 0.3;
param.slowdown = 0.01^(param.batch/param.epoch/size(Train,3));
param.predictor = decoder;
GetTraining(Error,Train,TrainLabel,param);

[err, ~, int] = GetTest(decoder, Test, TestLabel, 10);
plot_error_table(err, Labels);
plot_intensity_table(int, Labels);

%% example image generation

clear variables;

global is_gpu; is_gpu = true;
f = 0.15;
lambda = 532e-9; k = 2*pi/lambda;
mesh = Mesh(18e-6, 512);
B = 18e-6*512/2;
sigma = B/8;
alpha = pi/180/10;

Amp = normalize_field(exp(-(mesh.X.^2 + mesh.Y.^2)/2/sigma^2));
Train(:,:,1) = Amp.*exp( 1i*k*sin(alpha)*mesh.X);
Train(:,:,2) = Amp.*exp(-1i*k*sin(alpha)*mesh.X);
Train(:,:,3) = Amp.*exp( 1i*k*sin(alpha)*mesh.Y);
Train(:,:,4) = Amp.*exp(-1i*k*sin(alpha)*mesh.Y);
TrainLabel = 1:size(Train,3);

Target(:,:,1) = ((mesh.X.^2 + mesh.Y.^2) < (B/4)^2).*((mesh.X.^2 + mesh.Y.^2) > (B/4.4)^2);
Target(:,:,2) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(max(abs(mesh.X), abs(mesh.Y)) > B/4.4);
Target(:,:,3) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(min(abs(mesh.X), abs(mesh.Y)) < B*0.05/4.4);
Target(:,:,4) = (max(abs(mesh.X), abs(mesh.Y)) < B/4).*(abs(abs(mesh.X) - abs(mesh.Y)) <  B*0.07/4.4);
Target = normalize_field(Target).^2;

dc = InputModulator(mesh, lambda);
dc = ASMPropagator(dc, f);
dc = FullDOE(dc, mesh, PhaseType, AdamFabric());
dc = ASMPropagator(dc, f);
dc = FullDOE(dc, mesh, PhaseType, AdamFabric());
dc = ASMPropagator(dc, f);
dc = FullDOE(dc, mesh, PhaseType, AdamFabric());
dc = ASMPropagator(dc, f);
dc = GetFullIntensity(dc, mesh);
Error = ErrorMSE(dc, GenerationTarget(Target));

param.batch = size(Train,3);
param.epoch = param.batch*2000;
param.cycle = param.epoch*param.batch/10;
param.speed = 1;
param.slowdown = 0.9992;
GetTraining(Error,Train,TrainLabel,param);

for iter=1:size(Train,3)
    dc.clear();
    figure; imagesc(dc.intensity(Train(:,:,iter)));
end

%% 1-dimension image generation

clear variables;
global is_gpu; is_gpu = true;
lambda = 532e-9;
f = 0.2;

mesh_in = Mesh(2e-6, [5000 1]);
mesh_out= Mesh(2*tand(5)*f/size(mesh_in,1), size(mesh_in));

Train = normalize_field(abs(mesh_in.X) < 5e-3);
TrainLabel = 1;
Target = atan(mesh_out.X*5e2)+pi/2;
Target = Target - min(Target);
Target = Target/sum(Target);

dc = InputModulator(mesh_in, lambda);
dc = FullDOE(dc, mesh_in, PhaseType, AdamFabric());
dc = SincPropagator(dc, f);
dc = GetFullIntensity(dc, mesh_out);
Error = ErrorMSE(dc, GenerationTarget(Target));

param.epoch = 100000;
param.cycle = param.epoch/20;
param.speed = 1e-2;
param.slowdown = 0.99995;
GetTraining(Error,Train,TrainLabel,param);

plot(dc.intensity(Train));
hold on;
plot(Target);
