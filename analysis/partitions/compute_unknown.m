MODCELLHPC_S_PATH = '/home/sg/wrk/s/matlab/modcell-hpc-study/';

prodnet_path = fullfile(MODCELLHPC_S_PATH, ...
    'cases','ecoli-native-matlab', 'prodnet.mat');


%%
tol = 0.0001;
design_objective = 'wGCP';

pn = getfield(load(prodnet_path), 'prodnet');

%% loop through each partition to find 

cases = {'partition_1_a','partition_1_b','partition_2_a','partition_2_b','partition_3_a','partition_3_b'};

%cases = {'partition_2_a','partition_2_b','partition_3_a','partition_3_b'};

for i =1:length(cases)
partition_name = cases{i};

solution_path = fullfile(MODCELLHPC_S_PATH, ...
    'analysis', 'partitions', partition_name, 'results','a5_b1.csv');


T_in = readtable(solution_path);
T_calc = calc_objs(solution_path, pn, design_objective);

writetable(T_calc, ['pf_',partition_name,'.csv'])
end

%% Below is copied test_objectives.m
function [T_out, PF, design_vars] = calc_objs(output_file_path, prodnet, design_objective)
% Calculates the pareto front of the deletions and module reactions
% Based on format_output (for MIP in ModCell2)

prodnet.set_deletion_type('reactions', design_objective);

T = readtable(output_file_path);
PF = zeros(length(T.Deletion_id),length(prodnet.prod_id));
design_vars = [];
parfor i = 1:length(T.SolutionIndex)

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

    %% Compute Pareto front
    prodnet.set_module_and_deleted_variables(Z, y)
    PF(i,:) = prodnet.calc_design_objectives(design_objective);
    design_vars(i).Z = Z;
    design_vars(i).y = y;
end

out_prod_id = safe_prod_id(prodnet.prod_id);
T_PF = array2table(PF,...
    'VariableNames',cellfun(@(x)([x,'_objective_calc']),out_prod_id, 'UniformOutput',false));
T_out = [T, T_PF];
end

function cell_out = parse_list(list_str)

if isempty(list_str)
    cell_out = {};
else
    cell_out = textscan(list_str,'%s','Delimiter',',');
    cell_out = cell_out{:};
end
end

function out_prod_id = safe_prod_id(prod_id)
%% Matlab tables can't deal with numbers in ids..
out_prod_id = prod_id;
for k=1:length(prod_id)
    %out_prod_id{k} = strrep(out_prod_id{k}, '_', 'U');
    if regexp(prod_id{k}, '^\d')
        out_prod_id{k} = ['z', prod_id{k}];
    end
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

