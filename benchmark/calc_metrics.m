function calc_metrics(results_path, n_cases)
	% Calculate MOEA performance metrics (see trinhlab/compare-moea repository for more details)
	warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
    global OBJTOL;
    OBJTOL = 0.000001; % Use to overcome floating point errors in objective calculation

	bestPF = load_PF(fullfile(results_path,"case_all_out.csv"));
    bestPFu = uniquetol(bestPF,OBJTOL, 'ByRows',true);

    % Compute metrics for all cases
	%metrics = {'Coverage','HV','Epsilon','DeltaP', "NSolutions"}; % HV is too slow for larger problems and it is not even useful
	%metrics = {'Coverage','Epsilon','DeltaP', "NSolutions"};
    metrics = {'UCoverage', "NSolutions", "NUSolutions", "DeltaP", "GD"};

	headers = ["Case", metrics];
	data = nan(n_cases, 1+length(metrics));

	for case_idx = 1:n_cases
		fprintf("case %d:\n", case_idx)
		PF = load_PF(fullfile(results_path,strcat("case", num2str(case_idx-1),"_out.csv")));
        PFu = uniquetol(PF,OBJTOL, 'ByRows',true);
		metrics_arr = compute_metrics(PF, PFu, bestPF, bestPFu, metrics);
		data(case_idx, 1) = case_idx-1;
		data(case_idx, 2:end) = metrics_arr;
    end

	%- Output to table: Case | metric1 | metric2
    writetable(array2table(data, 'VariableNames', headers),...
        fullfile(results_path,"metrics.csv"));
end

function PF = load_PF(file_path)
	T = readtable(file_path);
	PF = T{:, T.Properties.VariableNames(contains(...
		T.Properties.VariableNames, '_objective_'))};
    PF(isnan(PF)) = 0;
end


function metrics_arr = compute_metrics(PF, PFu, bestPF, bestPFu, metrics)

	refPoint = ones(1,size(bestPF,2));
	metrics_arr = nan(1, length(metrics));

	for metric_ind = 1:length(metrics)
		fprintf("\t%s...",metrics{metric_ind})
		metric_handle = str2func(metrics{metric_ind});
		if any(strcmp(metrics{metric_ind},{'HV','HV_platemo'})) % Hypervolume uses reference point
			score = metric_handle(PF, refPoint);
		elseif any(strcmp(metrics{metric_ind},{'PD','MD', 'Coverage'})) % these metrics assume maximization
			score = metric_handle(PF, bestPF);
        	elseif any(strcmp(metrics{metric_ind},{'Epsilon'})) % these metrics assume minimization
			score = metric_handle(-PF, -bestPF);
        	elseif any(strcmp(metrics{metric_ind},{'DeltaP', 'GD'})) % these metrics assume minimization + can use reference point
			%score = metric_handle(-PF, -refPoint); % It is not as informative
			score = metric_handle(-PF, -bestPF);
        	else % these metrics are defined in this file
            		score = metric_handle(PF, bestPF, PFu, bestPFu);
        	end

		if ~isempty(score)
			metrics_arr(metric_ind) = score;
		end
		fprintf("done\n")
	end
end

function ns = NSolutions(PF,~,~,~)
	ns = size(PF,1);
end

function ns = NUSolutions(~,~,PFu,~)
	ns = size(PFu,1);
end

function uc = UCoverage(~,~,PFu,bestPFu)
    global OBJTOL;
    is_member = ismembertol(PFu, bestPFu, OBJTOL, 'ByRows',true);
    uc = sum(is_member)/size(bestPFu,1);
end


