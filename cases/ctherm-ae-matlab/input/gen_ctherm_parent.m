inp = load('iCBI655_cellobiose_batch.mat');
inmodel = inp.iCBI665;
model = add_modcell_fields(inmodel, inmodel.rxns{find(inmodel.c)},...
    'substrate_id', 'cellb_e',...
    'substrate_uptake_id','EX_cellb_e');


% Propanol exchange reaction pulls directly from cytosol which leads to
% some issues, so:
model = addMetabolite(model,'ppoh_e','Propanol','C3H8O');
model = removeRxns(model, 'EX_ppoh_e');
model = addReaction(model,'PPOHt','reactionFormula','ppoh_c -> ppoh_e');
model = addExchangeRxn(model, 'ppoh_e', 0, 0);

%% One of these methods is messing witht he biomass bound:
model = changeRxnBounds(model, {'BIOMASS_CELLULOSE','BIOMASS_NO_CELLULOSOME'}, 0, 'b');
assert(sum(model.ub(findRxnIDs(model,{'BIOMASS_CELLULOSE','BIOMASS_NO_CELLULOSOME'}))) ==0)

%model = changeRxnBounds(model, 'BIOMASS_CELLOBIOSE', 1000,'u');
%assert(model.ub(model.biomass_reaction_ind) == 1000);
model.ub(model.biomass_reaction_ind) = 1000;


%% Non-string subsystems are bad for intersect method in Matlab
fixed_ss = cellfun(@fix_subsys, model.subSystems,'UniformOutput',false);
model.subSystems = fixed_ss;
%% Save
save('ctherm-parent.mat','model')


%% Functions
function output = fix_subsys(val)
if isstr(val)
output = val;
else
    output = '';
end
end
