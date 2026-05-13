%% ==================== ELDABC Algorithm Subroutine (FULLY ALIGNED WITH THE PAPER) ====================
function [best_cost, best_solution] = ELDABC(fitness_fun, fun_num, D, N, limit, maxFES, M, alpha, beta, upper, lower, transpose_input)
% ELDABC - Enhanced Labor Division Artificial Bee Colony Algorithm
% Corresponding to Section 4 of the paper: Enhanced labor division in artificial bee colony algorithm
% Core innovation: Stimulus-response labor division mechanism for dynamic exploration-exploitation balance
%
% Input Parameters (Consistent with paper experimental settings):
%   fitness_fun     - Handle to the objective/fitness function
%   fun_num         - Index of the benchmark function to be optimized
%   D               - Dimensionality of the decision variables (search space dimension)
%   N               - Number of food sources (employed bees = onlooker bees = N)
%   limit           - Abandonment threshold for scout bee activation (trial limit)
%   maxFES          - Maximum number of function evaluations (termination criterion)
%   M               - Number of divided intervals for dimension entropy calculation
%   alpha           - Scaling factor for environmental stimulus computation (Eq.10)
%   beta            - Reward-punishment factor for response threshold update (Eq.13)
%   upper           - Upper bound of the decision variables
%   lower           - Lower bound of the decision variables
%   transpose_input - Input format flag: true=column vector (CEC2013), false=row vector (traditional functions)
%
% Output Parameters:
%   best_cost       - Optimal fitness value obtained by ELDABC
%   best_solution   - Optimal decision variable vector corresponding to best_cost

    % Set default input format (compatible with CEC2013 test suite)
    if nargin < 12
        transpose_input = true;
    end

    % Unify boundary format: convert scalar bounds to D-dimensional vectors
    if isscalar(upper)
        upper = upper * ones(1, D);
    end
    if isscalar(lower)
        lower = lower * ones(1, D);
    end
    
    % -------------------------- Population Initialization (Eq.1, Paper Section 4.2.3) --------------------------
    pops = zeros(N, D);   % Food source positions (candidate solutions)
    cost = zeros(N, 1);   % Fitness values of food sources
    
    for i = 1:N
        % Randomly generate initial food sources (Eq.1)
        pops(i, :) = lower + (upper - lower) .* rand(1, D);
        % Evaluate fitness with adaptive input format
        if transpose_input
            cost(i) = feval(fitness_fun, pops(i, :)', fun_num);
        else
            cost(i) = feval(fitness_fun, pops(i, :), fun_num);
        end
    end
    
    % -------------------------- Global Best Initialization --------------------------
    [mincost, index] = min(cost);
    best_solution = pops(index, :);  % Global best food source
    best_cost = mincost;             % Global best fitness
    best_index_new = index;          % Index of global best solution
    
    % Fitness vectors for multi-information guidance (Paper Section 4.2.2(a))
    vector_1 = cost;  % For neighborhood optimal selection
    vector_2 = cost;  % For secondary optimal selection
    vector_3 = cost;  % For elite solution selection
    
    % Trial counter for scout bee mechanism (Paper Section 2.3)
    trial = zeros(N, 1);
    
    % Function evaluation counter (initialized with population evaluation cost)
    FEs = N;
    
    % -------------------------- Stimulus-Response Mechanism Initialization --------------------------
    % Response thresholds for exploration/exploitation tasks (Paper Section 4.2.2(c))
    theta_exploration = 0.5 * ones(1, N);   % Threshold for exploration task
    theta_exploitation = 0.5 * ones(1, N);  % Threshold for exploitation task
    
    % Flag for dimension entropy update interval
    entropy_update_flag = [-1];
    
    % -------------------------- Main Iteration Loop of ELDABC --------------------------
    while FEs <= maxFES
        current_pop = pops;
        pop_max = max(max(current_pop));
        pop_min = min(min(current_pop));
        interval_width = (pop_max - pop_min) / M;  % Interval width for dimension entropy
        
        % Trigger dimension entropy calculation every 500 function evaluations
        current_update = fix(FEs / 500);
        entropy_update_flag = [entropy_update_flag current_update];
        
        % -------------------------- Dimension Entropy Calculation (Paper Section 4.2.2(b)) --------------------------
        if entropy_update_flag(end) - entropy_update_flag(end-1) == 1
            count_matrix = zeros(M, D);  % Count of individuals in each interval per dimension
            
            for j = 1:D
                for k = 1:M
                    for i = 1:N
                        % Count individuals falling into the k-th interval of j-th dimension
                        match_idx = find(current_pop(i, j) >= pop_min + (k-1)*interval_width ...
                                       & current_pop(i, j) <= pop_min + k*interval_width);
                        count_matrix(k, j) = count_matrix(k, j) + size(match_idx, 2);
                    end
                end
            end
            
            % Probability distribution for entropy calculation
            prob_matrix = zeros(M, D);
            for k = 1:M
                for j = 1:D
                    prob_matrix(k, j) = count_matrix(k, j) / sum(count_matrix(:, j));
                end
            end
            
            % Avoid log(0) by replacing zero probabilities with 1
            prob_matrix(prob_matrix == 0) = 1;
            
            % Compute normalized dimension entropy (population diversity metric)
            entropy_scale = 1 / log(N);
            dim_entropy = -entropy_scale * sum(prob_matrix .* log(prob_matrix), 1);
            population_diversity = sum(dim_entropy) / D;
        end
        
        % -------------------------- Environmental Stimulus Calculation (Eq.10-Eq.11, Paper Section 4.2.2(b)) --------------------------
        exploit_stimulus = population_diversity * (exp(alpha * FEs / maxFES) - 1);
        exploit_stimulus = min(exploit_stimulus, 0.95);  % Upper bound constraint
        explore_stimulus = 1 - exploit_stimulus;          % Exploration stimulus (Eq.11)
        
        % -------------------------- Normalized Response Thresholds (Eq.14-Eq.15, Paper Section 4.2.2(c)) --------------------------
        norm_theta_explore = theta_exploration ./ (theta_exploration + theta_exploitation);
        norm_theta_exploit = theta_exploitation ./ (theta_exploration + theta_exploitation);
        
        % -------------------------- Employed/Onlooker Bee Task Execution (Paper Section 4.2.2(a)) --------------------------
        for i = 1:N
            % Select 10 random neighbors to find neighborhood optimal (exploration guidance)
            neighbor_indices = randperm(N, 10);
            neighbor_fitness = vector_1(neighbor_indices);
            [~, best_neighbor_pos] = min(neighbor_fitness);
            nbest_idx = neighbor_indices(best_neighbor_pos);
            
            % Get second-best solution for multi-information guidance
            sorted_fitness = sort(vector_2);
            second_best_idx = sorted_fitness(2);
            
            % -------------------------- Task Execution Probability (Eq.16-Eq.17, Paper Section 4.2.2(d)) --------------------------
            p_explore = explore_stimulus / (explore_stimulus + norm_theta_explore(i));
            p_exploit = exploit_stimulus / (exploit_stimulus + norm_theta_exploit(i));
            task_prob = p_explore / (p_explore + p_exploit);
            
            if rand <= task_prob
                % -------------------------- Employed Bee: Exploration Task (Eq.6, Single-dimensional Search) --------------------------
                % Exploration: Neighborhood optimal guided, single-dimensional perturbation (Paper Section 4.2.2(a))
                new_sol_explore = pops(i, :);
                explore_dim = randperm(D, 1);  % Single-dimensional search (exploration feature)
                
                % Randomly select reference individual
                k_idx = randi(N);
                while k_idx == i
                    k_idx = randi(N);
                end
                
                % Exploration search equation (Eq.6)
                new_sol_explore(explore_dim) = pops(nbest_idx, explore_dim) + ...
                                           (rand*2-1) * (pops(nbest_idx, explore_dim) - pops(k_idx, explore_dim));
                
                % Boundary constraint handling
                new_sol_explore = min(upper, max(lower, new_sol_explore));
                
                % Evaluate new solution
                if transpose_input
                    new_cost_explore = feval(fitness_fun, new_sol_explore', fun_num);
                else
                    new_cost_explore = feval(fitness_fun, new_sol_explore, fun_num);
                end
                
                % -------------------------- Greedy Selection (Paper Section 2.1) --------------------------
                if cost(i) > new_cost_explore
                    improve_rate = (cost(i) - new_cost_explore) / abs(cost(i));
                    pops(i, :) = new_sol_explore;
                    cost(i) = new_cost_explore;
                    trial(i) = 0;
                else
                    improve_rate = (cost(i) - new_cost_explore) / abs(new_cost_explore);
                    trial(i) = trial(i) + 1;
                end
                
                % -------------------------- Update Exploration Threshold (Reward-Punishment, Eq.13) --------------------------
                theta_exploration(i) = theta_exploration(i) * (beta * (1 - improve_rate) + (1 - beta));
            else
                % -------------------------- Onlooker Bee: Exploitation Task (Eq.7, Multi-dimensional Search) --------------------------
                % Exploitation: Global/elite optimal guided, multi-dimensional perturbation (Paper Section 4.2.2(a))
                new_sol_exploit = pops(i, :);
                % Random coefficients summing to 1 (Eq.7)
                r1 = rand;
                r2 = rand;
                r3 = 1 - r1 - r2;
                while r3 < 0
                    r1 = rand;
                    r2 = rand;
                    r3 = 1 - r1 - r2;
                end
                
                % Randomly select dimensions (0 to D/3, multi-dimensional search)
                exploit_dim_num = randi([0, fix(D/3)]);
                exploit_dims = randperm(D, exploit_dim_num);
                
                % Select two distinct elite solutions from top-10 individuals
                [~, elite_indices] = mink(vector_3, 10);
                elite1_idx = elite_indices(randi(length(elite_indices)));
                elite2_idx = elite_indices(randi(length(elite_indices)));
                while elite1_idx == elite2_idx
                    elite2_idx = elite_indices(randi(length(elite_indices)));
                end
                
                % Exploitation search equation (Eq.7)
                new_sol_exploit(exploit_dims) = r1 * pops(i, exploit_dims) + ...
                                             r2 * pops(best_index_new, exploit_dims) + ...
                                             r3 * (pops(elite1_idx, exploit_dims) - pops(elite2_idx, exploit_dims));
                
                % Boundary constraint handling
                new_sol_exploit = min(upper, max(lower, new_sol_exploit));
                
                % Evaluate new solution
                if transpose_input
                    new_cost_exploit = feval(fitness_fun, new_sol_exploit', fun_num);
                else
                    new_cost_exploit = feval(fitness_fun, new_sol_exploit, fun_num);
                end
                
                % -------------------------- Greedy Selection (Paper Section 2.2) --------------------------
                if cost(i) > new_cost_exploit
                    improve_rate = (cost(i) - new_cost_exploit) / abs(cost(i));
                    pops(i, :) = new_sol_exploit;
                    cost(i) = new_cost_exploit;
                    trial(i) = 0;
                else
                    improve_rate = (cost(i) - new_cost_exploit) / abs(new_cost_exploit);
                    trial(i) = trial(i) + 1;
                end
                
                % -------------------------- Update Exploitation Threshold (Reward-Punishment, Eq.13) --------------------------
                theta_exploitation(i) = theta_exploitation(i) * (beta * (1 - improve_rate) + (1 - beta));
            end
        end
        
        % Update function evaluation counter
        FEs = FEs + N;
        
        % -------------------------- Scout Bee Mechanism (Paper Section 2.3 & 4.2.3) --------------------------
        % Abandon food source if trial exceeds limit, generate new solution randomly
        [max_trial, abandon_idx] = max(trial);
        abandon_idx = abandon_idx(end);  % Select last if multiple maxima
        
        if max_trial >= limit
            % Reinitialize abandoned food source (Eq.1)
            pops(abandon_idx, :) = lower + (upper - lower) .* rand(1, D);
            
            % Evaluate new food source
            if transpose_input
                cost(abandon_idx) = feval(fitness_fun, pops(abandon_idx, :)', fun_num);
            else
                cost(abandon_idx) = feval(fitness_fun, pops(abandon_idx, :), fun_num);
            end
            
            % Reset trial counter and response thresholds
            trial(abandon_idx) = 0;
            theta_exploration(abandon_idx) = 1;
            theta_exploitation(abandon_idx) = 1;
            
            % Update function evaluation counter
            FEs = FEs + 1;
        end
        
        % -------------------------- Update Global Best & Guidance Vectors --------------------------
        [current_best_cost, best_index_new] = min(cost);
        current_best_sol = pops(best_index_new, :);
        
        % Refresh fitness vectors for multi-information guidance
        vector_1 = cost;
        vector_2 = cost;
        vector_3 = cost;
        
        % Update global optimal solution
        if best_cost > current_best_cost
            best_cost = current_best_cost;
            best_solution = current_best_sol;
        end
    end
end
