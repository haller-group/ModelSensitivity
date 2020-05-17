
addPath;
ndof = 16;  %16 degree of freedom Timoshenko beam
ndof_spv = 2*ndof;
beamStruct = load('beam.mat');
odefunction = generateFirstOrderODE(beamStruct);
odegrad = generateFirstOrderODEGrad(beamStruct);


dy = @(t,x) odefunction(t,x,0,false);
dygrad = @(t,x) odegrad(t,x,0,false);

x0 = zeros(32,1);
endtime = 6.28;
dT = 0.001;
time = 0:dT:endtime;
%[~,yfref] = ode45(deriv, time, maxPlace);  %reference trajectory
epsilon = 1e-6;


nTolerances = 11;
nPoints = 5;
FTLES = zeros(nTolerances,nPoints);
Times = zeros(nPoints,nPoints);

tolerances = linspace(-6,-16,11);
tolerances = 10.^tolerances;



for i=1:nTolerances
    disp(i);
    for j = 1:nPoints
        tol = tolerances(i);
        maxPlace = rand(32, 1)*1e-6;
        tic;
        [eigmax, ~] = computeCGInvariantsode23sJacobian(dy, dygrad, maxPlace.', [0, 1.5], 'finiteDifference', false, tol);
        Times(i,j) = toc;
        FTLES(i,j) = log(eigmax)/(3);
    end
end

save('ftle_timoshenko_sensitivity_to_tolerance_ode23s_withJacobian.mat', 'Times', 'FTLES');

