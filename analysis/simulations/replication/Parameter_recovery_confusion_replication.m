%% Load trial lists
clear all
close all

fs = filesep;
addpath(['..' fs 'generate_choice_functions'])

% load trial lists 1-10
triallists = {};
for tl = 1:10
    triallists{tl} = readtable(['trial_lists' fs 'trial_list_v',num2str(tl),'.csv']);
end

%% IntDyn model
% 1. extract parameter from participants and know the range
% 2. generate 1000 simulated dataset (10 repetitions of 10 set of parameters for each trial list) 
% using the extracted parameters range
% 3. Fit the simulated dataset (1000) using 10 seperate hbi 
% 4. Correlate fitted parameters with simulated parameters

%load data
load(['..' fs '..' fs 'modelling' fs 'replication_data' fs 'hbi_IntDyn_replication.mat']);
% % parameters
% params_all = cbm.output.parameters{1,1};
% params_all(:,1) = exp(params_all(:,1));
% params_max = max(params_all,[],1);
% params_min = min(params_all,[],1);
% % specify the range
% params_max_spec = [15,1, 3, 1, 1, 1, 1, 1, 1];
% params_min_spec = [1,-1, -3, -1, -1, -1, -1, -1];


% model fitting specification
npar = 8;
v = 6.25; %parameter variance (6.25 is large enough to cover a wide range of parameters with no excessive penalty)
prior = struct('mean',zeros(npar,1),'variance',v);

% 1&2 sample 100 sets of parameters
rng(0,'twister');
data_sim_all = {};
params_sim_all=[];
for rep = 1:10 % repeat 10 times
    params_sim = [];
    for p = 1:8
        if p == 1 % beta
         %params_sim(:,p) = exp(randn(10,1)/2 + 1);
         params_sim(:,p) = ones(10,1)*15;
        elseif p == 3 % bias
         params_sim(:,p) = randn(10,1)+1;
        else
         params_sim(:,p) = randn(10,1);
        end
    end
    params_sim_all = [params_sim_all;params_sim];
    
    for tl=1:10
        for it=1:10 % generate 10 datasets
            P_pred = gc_IntDyn_expbeta(params_sim(tl,:),triallists{tl});
            P_new = table2array(triallists{tl});
            P_new(:,12) = P_pred(:,3); %Chosen slot machine (PredAct)
            P_new(:,13) = P_pred(:,2); %Left/right choice (PredChoice)
            P_new(:,14) = P_pred(:,5); %is correct
            P_new(:,15) = []; % 15/16 not used
            P_new(:,17) = zeros(96,1); % missing trial
            data_sim_all{it}{(rep-1)*10+tl} = P_new;
        end
    end
end
% check correlation between simulated parameters
heatmap(corr(params_sim_all));
save('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/simulations/replication/IntDyn/sim_1000_data_params.mat','params_sim_all','data_sim_all');


config.maxiter = 100;
% 3.1 fit the simulated data with nonhbi
for it = 2:10
    out_fname = ['IntDyn/lap_IntDyn_nonhbi_it',num2str(it),'.mat'];
    cbm_lap(data_sim_all{it}, @LL_ArbF_AV_expbeta_HbCb3SaSc, prior, out_fname);
    % 3.2 fit the simulated data with hbi
%     % fit hbi for 10 times
%     hbi_name = ['IntDyn/hbi_IntDyn_it',num2str(it),'.mat'];
%     cbm_hbi(data_sim_all{it},{@LL_ArbF_AV_expbeta_HbCb3SaSc},{out_fname}, hbi_name, config);
%     % calculate pseudo R2
%     load(hbi_name);
%     recov_params = cbm.output.parameters{1};
%     pseudoR2 = zeros(100,1);
%     for n=1:100
%         P = data_sim_all{it}{n};
%         [ll,~] = LL_ArbF_AV_expbeta_HbCb3SaSc(recov_params(n,:),P);
%         pseudoR2{it}(n) = 1 - ll/(96*log(0.5));
%         if pseudoR2(n)<0
%             pseudoR2(n)=0;
%         end
%     end

end

% 4 correlate simulated vs. recovered parameters
for it=1:10
    filename = ['lap_IntDyn_nonhbi_it',num2str(it),'.mat'];
    %filename = ['hbi_IntDyn_it',num2str(it),'.mat']
    load(['/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/simulations/replication/IntDyn/',filename]);
 %   recov_params(:,:,it) = cbm.output.parameters{1}; % hbi
    recov_params = cbm.output.parameters; % non hbi
    recov_params(:,1) = exp(recov_params(:,1));
    recov_params_all(:,:,it) = recov_params;
end
recov_params_avg = mean(recov_params_all,3);
% beta is fixed
for p1=2:8
    for p2=2:8
        corr_sim_rec(p1-1,p2-1) = corr(params_sim_all(:,p1),recov_params_avg(:,p2));
    end
end
figure('Renderer', 'painters', 'Position', [0 0 600 450]);
varnames = ["Uncertainty weight","Emulation bias","Action bias","Color bias 1","Color bias 2","Stick action","Stick choice"];
heatmap(corr_sim_rec','YData',varnames,'XData',varnames,'CellLabelFormat','%.3f');
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colorbar; 
colormap(J);
caxis([-1,1]);
%% Confusion matrix of the 5 models
% 1. randomly sample the parameters in each model param space (keep beta
% high?) and generate 10 datasets for each trial list (100*5 datasets in
% total)
% 2. fit each of the 100 data using hbi, with all 5 models as candidates
% 3. plot the XP for 5 original models over 5 candidate fitting models
%load data
% load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/replication_data/hbi_5mods_replication.mat');
load(['..' fs '..' fs 'modelling' fs 'replication_data' fs 'hbi_5mods_replication.mat']);
% parameters
params_allmods = cbm.output.parameters;

% 1 sample 100 sets of parameters for each model
rng(0,'twister');

% specify the range
params_spec{1} = randn(100,5); % baseline
params_spec{2} =  exp(randn(100,1)/2 + 1); % im beta
params_spec{3} =  exp(randn(100,1)/2 + 1); % em beta
params_spec{4} =  [exp(randn(100,1)/2 + 1),0.5./(1+exp(randn(100,1)))+0.4]; % fixarb
params_spec{5} =  [exp(randn(100,1)/2 + 3),randn(100,1),randn(100,1)+1]; % dynarb
params_sim_all = {};
data_sim_all = {};

gc_mod_list = {@gc_Baseline_AV; @gc_IM_expbeta; ...
    @gc_EM_expbeta; @gc_Hyb_AV_expbeta; @gc_ArbF_AV_expbeta};
modnames = {'Base','IM','EM','FixArb','DynArb'};

npar = [5,1,1,2,3];
for mod = 1:5
    params_sim_all = [];
    for rep = 1:10 % repeat 10 times
        params_sim = [];
        params_sim = params_spec{mod}(rep*10-9:rep*10,:);
        params_sim_all = [params_sim_all;params_sim];
        for tl=1:10
            for it = 1:10
                P_pred = gc_mod_list{mod}(params_sim(tl,:),triallists{tl});
                P_new = table2array(triallists{tl});
                P_new(:,12) = P_pred(:,3); %Chosen slot machine (PredAct)
                P_new(:,13) = P_pred(:,2); %Left/right choice (PredChoice)
                P_new(:,14) = P_pred(:,5); %is correct
                P_new(:,15) = [];
                P_new(:,17) = zeros(96,1);
                data_sim_all{it}{(rep-1)*10+tl} = P_new;
            end
        end
    end
    % check correlation between simulated parameters
    % heatmap(corr(params_sim_all));
    % save simulated parameters
    save(['/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/simulations/replication/',modnames{mod},'/sim_1000_data_params.mat'],'params_sim_all','data_sim_all');

end

% 2. fit each of the 100 data using hbi, with all 5 models as candidates
modlist = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta,...
    @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta};
out_fname_list = {'sim_fit_baseline','sim_fit_im','sim_fit_em',...
    'sim_fit_fixarb','sim_fit_dynarb'};
config.maxiter = 30;

for mod=1:5
    for it=2:10
        out_fname_list_m = {};
        load([modnames{mod},'/sim_1000_data_params.mat']);
        for m = 1:5
            out_fname_m = [modnames{mod},'/',out_fname_list{m},'_it_',num2str(it),'.mat'];
            out_fname_list_m{m} = out_fname_m;
            prior = struct('mean',zeros(npar(m),1),'variance',6.25);
            cbm_lap(data_sim_all{it}, modlist{m}, prior,out_fname_m , []);
        end
        fname_hbi_5mods = [modnames{mod},'/hbi_5mods_',num2str(it),'.mat'];
        cbm_hbi(data_sim_all{it}, modlist, out_fname_list_m, fname_hbi_5mods, config);
    end
end

S(1) = load('gong');
sound(S(1).y,S(1).Fs)

%% 3. load the hbi fitting results
XP = [];
for mod=1:5
    for it=1:10
        fname_hbi_5mods = [modnames{mod},'/hbi_5mods_',num2str(it),'.mat'];
        load(fname_hbi_5mods);
        XP(mod,:,it) = cbm.output.exceedance_prob;
        clearvars cbm
    end
end

varnames = {'Non-learning','Imitation','Emulation','Fixed arbitration','Dynamic arbitration'};
figure('Renderer', 'painters', 'Position', [0 0 600 450]);
heatmap(mean(XP,3),'YData',varnames,'XData',varnames,'CellLabelFormat','%.3g');
J = customcolormap([0 1], {'#e66aac','#ffffff'});
colorbar; 
colormap(J);
