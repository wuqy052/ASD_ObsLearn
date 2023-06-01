% Baseline + IM + EM + Fix + Dyn + Integrated
% first individual model fit
%% rearrange the data format to match the model specification
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/OL_data_all_subs_Dec2022.mat');
data = struct('ID',{ol_task_data.subID});
% replication data to correct format data
emptyid = [];
for sub=1:length(data)
    subdata_rep = ol_task_data(sub).mainTask;
    if isempty(subdata_rep)
        subdata = [];
        emptyid(end+1) = sub;
    else
        T = struct();
        subdata = struct2table(T);
        subdata.runNb = reshape(repmat(1:8,[12 1]),96,1);
        subdata.runID = subdata_rep.blockID; % go back and check!!
        subdata.trialNb = subdata_rep.trID;
        subdata.trType = 2 - strcmp('observe',subdata_rep.trialType);
        subdata.goalToken = subdata_rep.goalToken;
        subdata.uncertainty = subdata_rep.uncertainty;
        subdata.unavAct = subdata_rep.unavAct;
        subdata.corrAct = subdata_rep.corrAct;
        subdata.bestAct = subdata_rep.bestAct;
        subdata.vertOrd = subdata_rep.vertOrd;
        subdata.horizOrd = subdata_rep.horizOrd;
        subdata.choice = subdata_rep.choice;
        % need to calculate based on unavAct and choice
        for t = 1:length(subdata_rep.unavAct)
            if subdata_rep.choice(t) == 1 % must be left choice
                leftChoice(t,1) = 1;
            elseif subdata_rep.choice(t) == 3 % must be right choice
                leftChoice(t,1) = 0;
            elseif  subdata_rep.choice(t) == 2
                if subdata_rep.unavAct(t) == 1
                    leftChoice(t,1) = 1;
                elseif subdata_rep.unavAct(t) == 3
                    leftChoice(t,1) = 0;
                end
            else
                leftChoice(t,1) = NaN;
            end
        end
        subdata.leftChoice = leftChoice;
        subdata.isCorrect = subdata_rep.isCorr;
        subdata.choiceRT = subdata_rep.rt;
        subdata.tokenShown = subdata_rep.tokenShown;
        subdata.miss = subdata_rep.miss;
    end

    data(sub).data = subdata;
end
data(emptyid) = [];

% exclude one more subject for >= 25% missing data
exc_miss = [];
prop_miss = [];
for i=1:length(data)
    % total amount of 'choose' actions
    num_ch = sum(~isnan(data(i).data.miss));
    if nansum(data(i).data.miss) >= 0.25*num_ch
        exc_miss(end+1) = i;
    end
    prop_miss(i,1) = nansum(data(i).data.miss)/num_ch;
end

data(exc_miss) = [];

clearvars -except data

n_all = length(data);
%put data in right format to run cbm
data_replication = {};
s=1;
while s<= n_all
     data_replication{s,1} = table2array(data(s).data);
     s=s+1;
end

%% apply exclusion
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/SubList_final_replication.mat'); % final list
[~,~,mdid] = intersect(sublist_rep,{data.ID});
data_replication = data_replication(mdid,:);
save('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_replication.mat','data_replication');

%% part 1: nonhierarchical model fitting
clear all
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_replication.mat');
%specify loglikelihood functions, for Baseline, do not include beta
func_list = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta,...
    @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta, @LL_Hyb_AV_expbeta_HbCb3SaSc, @LL_ArbF_AV_expbeta_HbCb3SaSc}; 

np = [5,1,1,2,3,7,8]; %number of parameters for each model

%specify parameter priors
v = 6.25; %parameter variance (6.25 is large enough to cover a wide range of parameters with no excessive penalty)
for m = 1:7
    prior_list{m} = struct('mean',zeros(np(m),1),'variance',v);
end
 
%specify output files
out_fname_list = {'lap_Baseline_HbCb3SaSc_replication.mat','lap_IM_expbeta_replication.mat','lap_EM_expbeta_replication.mat'...
    ,'lap_Fix_AV_expbeta_replication.mat','lap_Dyn_AV_expbeta_replication.mat',...
    'lap_IntFix_expbeta_replication.mat','lap_IntDyn_expbeta_replication.mat'};

%run cbm_lap for each model
%this will fit every model to each subject's data separately (ie in a
%non-hierarchical fashion), using Laplace approximation, which needs a
%normal prior for every parameter
% data_prolific = data_prolific(1);
for m = 1:7
    cbm_lap(data_replication, func_list{m}, prior_list{m}, out_fname_list{m}, []);
end

%transform parameters

for m=1:7
    fname = out_fname_list{m};
    load(fname,'cbm')
    params = cbm.output.parameters;
    npar = np(m);
    cbm.output.paramTrans = params;
    % new Baseline model does not include beta
    if m>1 
        cbm.output.paramTrans(:,1)  = exp(params(:, 1)); % beta
    end
    % fixed arbitration weight [0 1]
    if m==4 
        cbm.output.paramTrans(:,2) = 1./(1+exp(-params(:,2)));   
    end
    if m==6 
        cbm.output.paramTrans(:,2) = 1./(1+exp(-params(:,2)));   
    end
    save(fname,'cbm')
end

%% part 2: Calculate model fitting for the 5 basic models
clear all
outdir = '/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling';
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_replication.mat');

np = [5,1,1,2,3]; %number of parameters for each model

%specify loglikelihood functions
func_list_5mods = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta, @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta}; 
 
%specify output files
out_fname_list_5mods = {'lap_Baseline_HbCb3SaSc_replication.mat','lap_IM_expbeta_replication.mat','lap_EM_expbeta_replication.mat'...
    ,'lap_Fix_AV_expbeta_replication.mat','lap_Dyn_AV_expbeta_replication.mat'};

%create a fitRecap data structure to save a bunch of measures about model
%fits
nf = size(data_replication,1);
fitRecap.log_evidence = zeros(nf,length(out_fname_list_5mods));
params = cell(length(out_fname_list_5mods),2);
for i=1:length(out_fname_list_5mods)
    load([outdir,'/',out_fname_list_5mods{i}],'cbm')
    params{i,1} = cbm.output.parameters;
    params{i,2} = cbm.output.paramTrans;
    fitRecap.log_evidence(:,i) = cbm.output.log_evidence;
end

fitRecap.model_LHsub = zeros(nf,length(out_fname_list_5mods));
fitRecap.model_corrsub = zeros(nf,length(out_fname_list_5mods));
fitRecap.pseudoR2 = zeros(nf,length(out_fname_list_5mods));
fitRecap.BIC = zeros(nf,length(out_fname_list_5mods));
fitRecap.AIC = zeros(nf,length(out_fname_list_5mods));
fitRecap.best_model = zeros(nf,3);

for s=1:nf
    try
    
        P = data_replication{s};
        ilu = P(:,6)==1;
        igood = ~isnan(P(:,13));
        ntg = sum(igood);

        recap_sub_BIC = zeros(1,length(out_fname_list_5mods));
        recap_sub_AIC = zeros(1,length(out_fname_list_5mods));

        for m=1:length(out_fname_list_5mods)

            %use log likelihood function to calculate log likelihood and other
            %trial-by-trial variables from the model
            [ll,P_pred] = func_list_5mods{m}(params{m,1}(s,:),P);

            fitRecap.loglike(s,m) = ll;
            %calculate R2, AIC, BIC
            fitRecap.pseudoR2(s,m) = 1 - ll/(ntg*log(0.5));
            if fitRecap.pseudoR2(s,m)<0
                fitRecap.pseudoR2(s,m)=0;
            end
            recap_sub_BIC(m) = -2*ll + log(ntg)*np(m);  % Klog(n) - 2loglike
            recap_sub_AIC(m) = -2*ll + 2*np(m);

            %calculate mean likelihood of model predicting subject's choice
            fitRecap.model_LHsub(s,m) = nanmean(P_pred(:,1));

            %calculate mean likelihood of model predicting correct choice
            fitRecap.model_corrsub(s,m) = nanmean(P_pred(:,3));
        end
        recap_sub_logEv = fitRecap.log_evidence(s,:);
        fitRecap.BIC(s,:) = recap_sub_BIC;
        fitRecap.AIC(s,:) = recap_sub_AIC;
        %find best model 
         fitRecap.best_model(s,:) = [find(recap_sub_logEv==max(recap_sub_logEv)) ...
             find(recap_sub_BIC==min(recap_sub_BIC)) find(recap_sub_AIC==min(recap_sub_AIC))];
    catch
        disp(s);
    end
end
%compute some variables necesary for regression models
save('5models_recap_replication.mat','fitRecap','params')

%% visualize the individual categorization
for c = 1:3
    for m = 1:5
        num_mod(c,m) = sum(find(fitRecap.best_model(:,c) == m));
    end
end
b = bar([1:3],num_mod,"stacked");

%% part 3: hierarchical fitting for all 5 models
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_replication.mat');
func_list_5mods = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta,...
    @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta};
out_fname_list_5mods = {'lap_Baseline_HbCb3SaSc_replication.mat','lap_IM_expbeta_replication.mat','lap_EM_expbeta_replication.mat'...
    ,'lap_Fix_AV_expbeta_replication.mat','lap_Dyn_AV_expbeta_replication.mat'};
fname_hbi_5mods = 'hbi_5mods_replication.mat';
% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_replication, func_list_5mods, out_fname_list_5mods, fname_hbi_5mods, config);

%% part4: hierarchical fitting for the dynamic integrated model only
% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_replication,{@LL_ArbF_AV_expbeta_HbCb3SaSc},{'lap_IntDyn_expbeta_replication.mat'}, 'hbi_IntDyn_replication.mat', config);

% compare hbi with nonhbi fitting
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/replication_data/hbi_IntDyn_replication.mat');
hbi_params = cbm.output.parameters{1,1};
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/replication_data/lap_IntDyn_expbeta_replication.mat');
nonhbi_params = cbm.output.parameters;
for p = 1:8
    [corrmat_param(p,1),p_param(p,1)] = corr(hbi_params(:,p),nonhbi_params(:,p));
end

%% part5: hierarchical fitting for the fixed integrated model only
config.maxiter = 100;
cbm_hbi(data_replication,{@LL_Hyb_AV_expbeta_HbCb3SaSc},{'lap_IntFix_expbeta_replication.mat'}, 'hbi_IntFix_replication.mat', config);

% compare hbi with nonhbi fitting
hbi_params = cbm.output.parameters{1,1};
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/replication_data/lap_IntFix_expbeta_replication.mat');
nonhbi_params = cbm.output.parameters;
for p = 1:7
    [corrmat_param(p,1),p_param(p,1)] = corr(hbi_params(:,p),nonhbi_params(:,p));
end
