%% Setup
clear;clc;
delete flux_overlap.log
diary flux_overlap.log

MODCELLHPC_S_PATH = '/home/sg/wrk/s/matlab/modcell-hpc-study/';

%% Parameters:
prodnet_path = fullfile(MODCELLHPC_S_PATH, ...
    'cases','ecoli-native-matlab', 'prodnet.mat');
solution_path = fullfile(MODCELLHPC_S_PATH, ...
    'analysis', 'native', 'covers', 'cover0.csv');

product_fraction = 0.5;% Constraint product secretion to >50\% of max, thus limiting FVA to the region of interest
solution_indices = [121, 124, 25];

%%
pn = getfield(load(prodnet_path), 'prodnet');

%% Main loop

n_prod = pn.n_prod;
rxns = pn.parent_model.rxns;
rxn_idx = 1:length(rxns);

chassis_min = nan(length(rxns), length(solution_indices));
chassis_max = nan(length(rxns), length(solution_indices));

for h=1:length(solution_indices)
    fprintf("Design %i:", h);
    solution_index = solution_indices(h);
    
    % Set production network to target design state:
    set_prodnet_to_design(solution_path, pn, solution_index);
    
    %% FVA for all products
    fva_min = nan(length(rxns), n_prod);
    fva_max = nan(length(rxns), n_prod);
    
    % Input parameters for fluxVariablity
    optPercentage = 0; %  percentage of the optimal solution to be considered, default is 100%, however here we are fixing minimum product
    rxnNameList = rxns;
    rxnsList = rxns;
    advind = 1;
    % Below are default:
    osenseStr = 'max'; printLevel = 0; allowLoops = true; method = '2-norm'; cpxControl = struct();
    % For fastFVA (which allows empty arguments)
    solverName = 'ibm_cplex'; strategy = 0; matrixAS = 'S'; rxnsOptMode = []; printLevel = 0;

    for i=1:n_prod % could use parfor here but fva should already do reactions in parallel
        fprintf("\tProduct %i...", i);
        model = pn.model_array(i);
        model.lb(model.product_secretion_ind) = pn.max_product_rate_growth(i)*product_fraction;
    
        [fva_min(:,i), fva_max(:,i)] = fastFVA(model, optPercentage, osenseStr, solverName, rxnsList, matrixAS, cpxControl, strategy, rxnsOptMode, printLevel);
        % NOTE:  Cases that throw CPLEX errors are unfeasible due to the
        % product requirements. This can be tested by setting: product_fraction = 0;
        
        % Uncomment for regular fva instead of fastfva
        %try
            %[fva_min(:,i), fva_max(:,i)] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method, cpxControl, advind);
        %catch ME
            %warning(ME.identifier) % Some models are not feasible    TODO: eval this and catch specifid issue
        %end
        fprintf("done\n", i);
    end
    % save since these take a while to compute
    save(['fva_design-',num2str(solution_indices(h))],'fva_min','fva_max');
    
    chassis_min(:,h) = min(fva_min,[],2);
    chassis_max(:,h) = max(fva_max,[],2);
    
end
%% Jaccard to pairwise compare chassis
% Round to avoid artifacts:
chassis_min_r = round(chassis_min,2);
chassis_max_r = round(chassis_max,2);

% Normalize to sur? the lb =15 but ub = 0, so some reactions could attain
% their bounds at values other than lb/ub
% all:

J = fvaJaccardIndex(chassis_min_r, chassis_max_r);

% 1 vs 2

% 1 vs 3

% 2 vs 3

%% Table:
% rxn | name | subsytem | formula |  design 1 (min/max) | design 2 ... | jaccard
design_bounds = cell(length(rxns),3);
for h=1:length(solution_indices)
    for j =1:length(rxns)
        design_bounds{j,h} = sprintf("%.2f / %.2f", chassis_min_r(j,h), chassis_max_r(j,h));
    end
end

rxnname = pn.parent_model.rxnNames;
rxnformula = printRxnFormula(pn.parent_model);
rxnsubsystem = pn.parent_model.subSystems;

T = cell2table([rxns, rxnname, rxnsubsystem, rxnformula, design_bounds, ...
    cellfun(@(x) sprintf("%.2f",x),num2cell(J), 'UniformOutput',false)], ...
    'VariableNames',[{'Reaction_ID', 'Reaction_name','Subsystem', 'Reaction_formula'},...
    cellfun(@(x) ['design_',num2str(x)],num2cell(solution_indices),'UniformOutput',false),...
    {'Jaccard'}]);

T = sortrows(T,{'Jaccard'});
writetable(T, 'results.tsv','FileType','text', 'Delimiter', '\t'); % Adjust to selected cover

%%

%%
diary off
%% ------------ FUNCTIONS ------------------
function set_prodnet_to_design(output_file_path, prodnet, solution_index)
% Adapted from test_objectives(solution_path, prodnet_path)
% output_file_path: pareto front in csv format
% prodnet: object to be modified

prodnet.reset_wild_type_state(); %Just to be safe

design_objective = 'wGCP'; % Only option for now.
prodnet.set_deletion_type('reactions', design_objective);

T = readtable(output_file_path);

i = find(T.SolutionIndex == solution_index);
assert(~isempty(i));

%% Parse deletions
deletions = parse_list(T.Deletion_id{i});

y = false(1,length(prodnet.cand_ind));
[~,model_del_ind] = intersect(prodnet.parent_model.rxns, deletions,'stable');
[~,cand_del_ind] = intersect(prodnet.cand_ind,model_del_ind,'stable');
y(cand_del_ind) = true;

%% Parse module reactions
Z = false(length(prodnet.prod_id), length(prodnet.cand_ind));
var_module_id = T.Properties.VariableNames(contains(T.Properties.VariableNames, '_module'));
module_prod_id = cellfun(@(x)(strrep(x,'_module_','')),var_module_id,'UniformOutput',false);
for k = 1:length(prodnet.prod_id)
    if ~isempty(intersect(module_prod_id, prodnet.prod_id{k}))
        modules = T{i,[prodnet.prod_id{k},'_module_']};
        if check_empty(modules)
            module_rxn = {};
        else
            module_rxn = parse_list(T{i,[prodnet.prod_id{k},'_module_']}{1});
        end
        [~,model_del_ind] = intersect(prodnet.parent_model.rxns, module_rxn,'stable');
        [~,cand_del_ind] = intersect(prodnet.cand_ind,model_del_ind,'stable');
        Z(k, cand_del_ind) = true;
    end
end
prodnet.set_module_and_deleted_variables(Z, y)
end
function cell_out = parse_list(list_str)

if isempty(list_str)
    cell_out = {};
else
    cell_out = textscan(list_str,'%s','Delimiter',',');
    cell_out = cell_out{:};
end
end

function is_empty = check_empty(modules)
% Matlab sucks (NaN value in table cannot be easily switched by empty
% strings)
is_empty = 0;
if isempty(modules)
    is_empty =1 ;
else
    try
        is_empty = isnan(modules);
    end
end
end

function test_set_prodnet()
test_before = pn.calc_design_objectives('wGCP');
set_prodnet_to_design(solution_path, pn, solution_index);
test_after = pn.calc_design_objectives('wGCP');
% compare nansum() of before and after
end
