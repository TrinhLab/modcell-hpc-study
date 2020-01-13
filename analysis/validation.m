MODCELLHPC_S_PATH = '/home/sg/wrk/s/matlab/modcell-hpc-study/';

prodnet_path = fullfile(MODCELLHPC_S_PATH, ...
    'cases','ecoli-native-matlab', 'prodnet.mat');
solution_path = fullfile(MODCELLHPC_S_PATH, ...
    'analysis', 'native', 'covers', 'cover0.csv');

test_objectives(solution_path, prodnet_path)