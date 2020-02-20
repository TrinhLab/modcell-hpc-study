clear; clc;
delete create_prodnet.log
diary create_prodnet.log
root_path = fileparts(which('mhr-root.m'));
input_info.problem_path = fullfile(root_path,'cases','ctherm-ae-matlab');
input_info.parent_model_path = fullfile(root_path,'cases','ctherm-ae-matlab', 'input','ctherm-parent.mat');
input_info.candidate_params.blocked_in_all_pn = false;
prodnet = Prodnet(input_info);
prodnet.save('prodnet');
diary off
