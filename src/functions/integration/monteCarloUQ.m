function MC = monteCarloUQ(system, epsilon, Nsamples, isParallel)
    deriv = @(t,x) system.rhs(t,x,0,false);    %% unperturbed system
    rng(0);
    maxPlace = rand(system.dimension, 1)*1e-5;
    dt = 1e-6*pi;
    time = 0:dt:2*pi; %%One period
    time2 = time(1:10000:end);
    [~,yfref] = ode45(deriv, time2, maxPlace);  %reference trajectory
    Montecarlos = zeros([size(yfref),Nsamples]);
    


    f = @(t,x) deriv(t, x) + epsilon*detPerturbation(t, x, 1, system.dimension); %deterministic part of the SDE
    g = @(t,x) epsilon*stochPerturbation(t, x, system.dimension); 
    
    if isParallel == true
        parfor i = 1:Nsamples
            yf = sde_euler(f, g, time, maxPlace);
            Montecarlos(:,:,i) = yf(1:10000:end, :);
        end
        disp(sum(isnan(Montecarlos), 'all'));
    else
        for i = 1:Nsamples
            yf = sde_euler(f, g, time, maxPlace);
            Montecarlos(:,:,i) = yf(1:10000:end, :);
            disp(i);
            
        end
        disp(sum(isnan(Montecarlos), 'all'));
    end
    MC.trajs = Montecarlos;
    MC.N = Nsamples;
    MC.IC = maxPlace;
    MC.time = time2;
    MC.epsilon = epsilon;
    MC.yfref = yfref;

end


function pert = detPerturbation(t, x, omega, n)
%small periodic perturbation on the last node
vector = zeros(n, 1);
vector(end) = 1;
pert = vector*sin(omega*t);
end


function pert = stochPerturbation(t, x, n)
vector = zeros(n, 1);
vector(end) = 1;
pert = vector;
% independent brownian motion 
end