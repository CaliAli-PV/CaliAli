function nested_test()

numOuterIterations =15;
b1 = ProgressBar(numOuterIterations, ...
    'UpdateRate', inf, ...
    'Title', 'Loop 1' ...
    );
b1.setup([], [], []);
for iOuterIteration = 1:numOuterIterations 
    in_loop()
    b1(1, [], []);
end
b1.release();

end

function in_loop()
numInnerIterations=20;
b2 = ProgressBar(numInnerIterations, ...
    'IsParallel', true, ...
    'UpdateRate', 5,...
    'WorkerDirectory', pwd(), ...
    'Title', 'Parallel 2' ...
    );
    b2.setup([], [], []);
    
    parfor jInnerIteration = 1:numInnerIterations
        pause(10);
        updateParallel([], pwd);
    end
    b2.release();
end