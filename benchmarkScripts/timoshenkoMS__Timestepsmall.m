addPath;

ndof = 16;  %16 degree of freedom Timoshenko beam
ndof_spv = 2*ndof;

dy = @(t,x) TIMOSHENKODE(t,x.');

timoshenkoBeam = DynSystem(dy, ndof_spv, [1,1]);


nTimesteps = 5;
timesteps = linspace(5, 20, nTimesteps);
nPoints = 3;
MS = zeros(nTimesteps,nPoints);
Times = zeros(nTimesteps,nPoints);
timesteps = 1./timesteps;



for i=1:nTimesteps
    disp(i);
    for j = 1:nPoints
        dt = timesteps(i);
        maxPlace = rand(32, 1)*1e-5;
        tic;
        ms = modelSensitivityGlobal(dy, maxPlace.', [1,1], [0, 1], dt, 'finiteDifference', false, [1,1]);
        Times(i,j) = toc;
        MS(i,j) = ms;
    end
end

save('MS_timoshenko_sensitivity_to_timestepSMALL.mat', 'Times', 'MS', 'timesteps');

