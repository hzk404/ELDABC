%% ==================== Enhanced Labor Division Artificial Bee Colony (ELDABC) - Main Program ====================
% Main program: Execute ELDABC algorithm on two benchmark test suites for performance validation
% Corresponding to the experiments in "Enhanced labor division in artificial bee colony algorithm with application to esophageal cancer risk prediction"
clear; clc; close all;

%% Test Suite Selection Switches
TEST_F22 = true; %false;       % Toggle for 22 traditional benchmark functions
TEST_CEC2013 = false; %true;   % Toggle for CEC2013 real-parameter optimization test suite

%% General Parameter Settings (Consistent with the paper's experimental configuration)
SN = 100;               % Total population size of the bee colony
N = SN/2;               % Number of food sources
limit = 100;            % Abandonment threshold: scout bee activation limit
M = 50;                 % Number of divided intervals for dimension entropy calculation
alpha = 2.7;            % Scaling factor for environmental stimulus calculation
beta = 0.1;             % Reward-punishment factor for response threshold update
D = 30;%100            % Dimension of decision variables
maxFES = 5000*D;   % Maximum number of function evaluations
runs = 1;          % Number of independent runs for statistical stability
%% ==================== Test Suite 1: 22 Traditional Benchmark Functions ====================
% Test Suite 1: 22 classic optimization functions (unimodal/multimodal, separable/non-separable)
% Defined in Table 3 of the paper, used for baseline performance validation
if TEST_F22
    % Search space bounds for 22 traditional functions (matched with Table 3 in the paper)
    upper = [100 100 10 1 10 100 100 10 1.28 10 5.12 5.12 600 500 50 100 100 10 10 1 5 pi];
    lower = [-100 -100 -10 -1 -10 -100 -100 -10 -1.28 -5 -5.12 -5.12 -600 -500 -50 -100 -100 -10 -10 -1 -5 0];
    
    % Result storage: function number, best, mean, standard deviation
    func_table = zeros(22, 4);
    % Raw optimization results of all independent runs
    results_matrix = zeros(22, runs);
    
    % Handle of the 22 traditional benchmark functions
    fhd = str2func('fun');
    
    % Main loop: optimize each function independently
    for fun_num = 1:22
        fprintf('Running ELDABC on Traditional Function %d...\n', fun_num);
        
        for cycle = 1:runs
            % Call ELDABC core function
            % Input: fitness handle, function index, dimension, food source number, scout limit, max evaluations,
            %        interval number for entropy, stimulus scaling factor, reward-punishment factor,
            %        search upper bound, search lower bound, input vector transpose flag (false for F22)
            [min_cost, ~] = ELDABC(fhd, fun_num, D, N, limit, maxFES, M, alpha, beta, ...
                                  upper(fun_num), lower(fun_num), false);
            
            % Store the optimal solution of each run
            results_matrix(fun_num, cycle) = min_cost;
        end
        
        % Calculate statistical indicators (best, mean, std) for performance comparison
        best = min(results_matrix(fun_num, :));
        avg = mean(results_matrix(fun_num, :));
        std_val = std(results_matrix(fun_num, :));
        
        fprintf('ELDABC | F%d: Best=%.4e, Mean=%.4e, Std=%.4e\n', fun_num, best, avg, std_val);
        func_table(fun_num, :) = [fun_num, best, avg, std_val];
    end
    
    % Save statistical results and raw data to Excel files
    filename = sprintf('ELDABC_F22_D%d.xlsx', D);
    writematrix(func_table, filename);
    filename2 = sprintf('ELDABC_F22_D%d_raw.xlsx', D);
    writematrix(results_matrix, filename2);
    
    fprintf('Test Suite 1 (22 traditional functions) completed. Results saved to %s\n', filename);
end

%% ==================== Test Suite 2: IEEE CEC2013 Real-Parameter Optimization Test Suite ====================
% Test Suite 2: CEC2013 benchmark functions (shifted, rotated, composite complex functions)
% Defined in the paper, used for high-complexity performance validation
if TEST_CEC2013
    upper = 100;       % Unified search upper bound for all CEC2013 functions
    lower = -100;      % Unified search lower bound for all CEC2013 functions
    
    % Theoretical optimal values of CEC2013 benchmark functions (from CEC2013 definition)
    optimum = [-1400,-1300,-1200,-1100,-1000,-900,-800,-700,-600,-500,...
               -400,-300,-200,-100,100,200,300,400,500,600,700,800,900,...
               1000,1100,1200,1300,1400];
    
    % Result storage: function number, best error, mean error, standard deviation of error
    func_table = zeros(28, 4);
    % Raw error results of all independent runs
    results_matrix = zeros(28, runs);
    
    % Handle of the CEC2013 benchmark functions
    fhd = str2func('cec13_func');
    
    % Main loop: optimize each CEC2013 function independently
    for fun_num = 1:28
        fprintf('Running ELDABC on CEC2013 Function %d...\n', fun_num);
        
        for cycle = 1:runs
            % Call ELDABC core function
            % Input: fitness handle, function index, dimension, food source number, scout limit, max evaluations,
            %        interval number for entropy, stimulus scaling factor, reward-punishment factor,
            %        search upper bound, search lower bound, input vector transpose flag (true for CEC2013)
            [min_cost, ~] = ELDABC(fhd, fun_num, D, N, limit, maxFES, M, alpha ,beta, upper, lower, true);
            
            % Calculate absolute error between optimal solution and theoretical optimum (paper evaluation metric)
            results_matrix(fun_num, cycle) = abs(min_cost - optimum(fun_num));
        end
        
        % Calculate statistical indicators of optimization error
        best = min(results_matrix(fun_num, :));
        avg = mean(results_matrix(fun_num, :));
        std_val = std(results_matrix(fun_num, :));
        
        fprintf('ELDABC | CEC2013 F%d: Best Error=%.4e, Mean Error=%.4e, Std=%.4e\n', fun_num, best, avg, std_val);
        func_table(fun_num, :) = [fun_num, best, avg, std_val];
    end
    
    % Save statistical error results and raw error data to Excel files
    filename = sprintf('ELDABC_CEC2013_D%d.xlsx', D);
    writematrix(func_table, filename);
    filename2 = sprintf('ELDABC_CEC2013_D%d_raw.xlsx', D);
    writematrix(results_matrix, filename2);
    
    fprintf('Test Suite 2 (CEC2013 functions) completed. Results saved to %s\n', filename);
end
