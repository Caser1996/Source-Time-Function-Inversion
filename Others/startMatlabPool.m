function [] = startMatlabPool(size)
p = gcp('nocreate');   % Get current parallel pool status
if isempty(p) % If parallel pool is empty
    poolsize = 0;
else
    poolsize = p.NumWorkers; % p.NumWorkers represents the number of CPU cores (if parallel pool is fully opened)
end

if poolsize == 0
    if nargin == 0  % nargin returns the number of input arguments given in the function call. This syntax can only be used within function body.
        parpool('local');
    else
        try
            parpool('local',size);  % Create using parpool('local',size)
        catch ce
            parpool;
            fail_p = gcp('nocreate');
            fail_size = fail_p.NumWorkers;
            display(ce.message);
            display(strcat('Incorrect input size, using default configuration size=',num2str(fail_size)));
        end
    end
else
    disp('parpool start');
    if poolsize ~= size % If the given number of cores differs from the running number, close and restart parallel pool
        closeMatlabPool();
        startMatlabPool(size);
    end
end