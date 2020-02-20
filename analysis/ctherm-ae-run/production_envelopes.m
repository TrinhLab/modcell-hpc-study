clear;clc;
modcell_hpc_s_path = '/home/sg/wrk/s/matlab/modcell-hpc-study/';
pin = load(fullfile(modcell_hpc_s_path, 'cases', 'ctherm-ae-matlab','prodnet.mat'));
prodnet = pin.prodnet;

%% Set prodnet to target design
i=12; % DESIGN INDEX

%[T1, ~, design_vars] = format_output(fullfile(modcell_hpc_s_path,'analysis','ctherm-ae-run',...
 %   'results','a6_b0.csv'),prodnet, 'wGCP');
T = readtable( fullfile(modcell_hpc_s_path,'analysis','ctherm-ae-run','results','a6_b0.csv'));
%prodnet.set_module_and_deleted_variables(design_vars(i).Z,design_vars(i).y)

%prodnet.reset_wild_type_state();
model_array = prodnet.model_array;
%deletions = prodnet.parent_model.rxns(prodnet.cand_ind(design_vars(i).y));
deletions = strsplit(T.Deletion_id{i}, ', ');
ko_array = [];
for k =1:length(prodnet.prod_id)
    %var_module = prodnet.parent_model.rxns(prodnet.cand_ind(design_vars(i).Z(k,:)));
    var_module = {}; % NOTE: Ignores module reactions
    fixed_module = prodnet.parent_model.rxns(model_array(k).fixed_module_rxn_ind);
    ko_array(k).designs(1).del = setdiff(deletions, union(fixed_module, var_module));
end

prod_id = prodnet.prod_name;

design_2=3; % DESIGN INDEX
deletions = strsplit(T.Deletion_id{design_2}, ', ');

% Add a second design
for k =1:length(prodnet.prod_id)
    %var_module = prodnet.parent_model.rxns(prodnet.cand_ind(design_vars(i).Z(k,:)));
    var_module = {}; % NOTE: Ignores module reactions
    fixed_module = prodnet.parent_model.rxns(model_array(k).fixed_module_rxn_ind);
    ko_array(k).designs(2).del = setdiff(deletions, union(fixed_module, var_module));
end

solution_id = {num2str(i), num2str(design_2)};

%% FIX substrate uptake indices:
for k=1:length(model_array)
    model_array(k).substrate_uptake_ind = findRxnIDs(model_array(k), ...
        model_array(k).substrate_uptake_id);
end

%%
global X_TICK_LABEL_DIGITS FONT_SIZE
X_TICK_LABEL_DIGITS = 2;
FONT_SIZE    = 10;
pastel = sns_colors('pastel');
deep = sns_colors('deep');

plot_yield_vs_growth_s_fix(model_array, ko_array, prod_id, solution_id,...
 'wt_color',               pastel(8,:), ...
'wt_line_color',          deep(8,:), ...
'mut_color',          pastel(1,:), ...    
'mut_line_color',     deep(1,:),...
'plot_type','overlap', 'n_rows',3, 'n_cols', 4, ...
'grid', true)    

%ResAnalysis.plot_yield_vs_growth_s(model_array, ko_array, prod_id, solution_id,...
%    'min_obj_val',0,'plot_type','overlap', 'n_rows',4, 'n_cols',5, ...
%    'xticks_values', [0:0.05:0.15], 'all_yticks',false, 'all_xticks', false,...
%    'grid', true)


%% Example
%% Production envelopes
% Analyze reaction flux and metabolite turnover across all production


% Using Cobra
i = 1;
model = model_array(i);
deletions = ko_array(i).designs.del;
[biomassValues, targetValues, lineHandle] = productionEnvelope(model,deletions,'b',model.product_secretion_id, model.biomass_reaction_id, 0, 10);