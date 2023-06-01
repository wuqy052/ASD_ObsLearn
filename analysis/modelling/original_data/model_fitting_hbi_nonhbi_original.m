%% OL Model fitting (non-hbi + hbi) for the original data set
% MTurk + Prolific
% The final subject inclusion is an intersection of [OL subject left after
% excluding missing data /bad performance subjects] AND [questionnaire
% subject left after excluding bad ppl based on careless measures
% (Sarah20111011)
%% Generate the final subject list
% load mturk data
data_mturk =load('/Users/wuqy0214/Documents/psy/OLab/SRS/OL_data.mat');
id_mturk = data_mturk.oldata.final.subid;
% load prolific data
data_prolific =load('/Users/wuqy0214/Documents/psy/OLab/ObservationalLearning/OL_models_for_Qianying/OL_models_for_Qianying/Qianyings_model/OL_data_Prolific.mat');
id_prolific = {};
for i=1:length(data_prolific.data)
    id_prolific{i,1} = data_prolific.data(i).ID;
end
% combine mturk and prolific
subOL = [[id_mturk];[id_prolific]]; % subject ids

% load SRS data
% careless exclusion already applied to the data
SRS_factor = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_8_factor_promax_original.csv');
subQ = SRS_factor.subIDs_inc;

% find intersection with OL data
[sublist,srsid,olid] = intersect(subQ, subOL);

% save the subjectlist
save('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat','sublist');

%% Prepare the data to be fit
% mainly filter out the subjects to be included
clear all

% load OL data
data_prolific = load('/Users/wuqy0214/Documents/psy/OLab/ObservationalLearning/OL_models_for_Qianying/OL_models_for_Qianying/Qianyings_model/OL_data_Prolific.mat');
data_mturk = load('/Users/wuqy0214/Documents/psy/OLab/ObservationalLearning/OL_models_for_Qianying/OL_models_for_Qianying/Qianyings_model/data_allsubs_Oct2020.mat');
% concatenate prolific and mturk
data_both = [{data_prolific.data.data}';{data_mturk.data.data}'];
subid_both = [{data_prolific.data.ID}';{data_mturk.data.ID}'];
% load subject list
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat');

% get idx of the subjects from the OL data
[a,b,olid] = intersect(sublist,subid_both);
%build new data variable with the finalized subject list
data_f = data_both(olid);
data_original = {};
for s=1:length(data_f)
     data_original{s,1} = table2array(data_f{s});
end

%% Model specification - nonhbi, fit 5 basic models + 1 integrated model
%specify loglikelihood functions
clearvars -except data_original
addpath('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling');
% model fitting functions
% Baseline model (without beta), imitation, emulation, fixarb, dynarb,
% integrated
func_list = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta,...
    @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta, @LL_ArbF_AV_expbeta_HbCb3SaSc}; 

np = [5,1,1,2,3,8]; %number of parameters for each model

%specify parameter priors
v = 6.25; %parameter variance (6.25 is large enough to cover a wide range of parameters with no excessive penalty)
for m = 1:6
    prior_list{m} = struct('mean',zeros(np(m),1),'variance',v);
end

%specify output files
out_fname_list = {'lap_Baseline_HbCb3SaSc_original.mat','lap_IM_expbeta_original.mat','lap_EM_expbeta_original.mat'...
    ,'lap_Fix_AV_expbeta_original.mat','lap_Dyn_AV_expbeta_original.mat','lap_Integrated_expbeta_original.mat'};

%run cbm_lap for each model
%this will fit every model to each subject's data separately (ie in a
%non-hierarchical fashion), using Laplace approximation, which needs a
%normal prior for every parameter
% data_prolific = data_prolific(1);
for m = 1:6
    cbm_lap(data_original, func_list{m}, prior_list{m}, out_fname_list{m}, []);
end

%transform parameters

for m=1:6
    fname = out_fname_list{m};
    load(fname,'cbm')
    params = cbm.output.parameters;
    npar = np(m);
    cbm.output.paramTrans = params;
    if m>1 % new Baseline model does not include beta
        cbm.output.paramTrans(:,1)  = exp(params(:, 1)); % beta
    end
    save(fname,'cbm')
end

%% hierarchical fitting for all 5 models
func_list = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta,...
    @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta};
out_fname_list = {'lap_Baseline_HbCb3SaSc_original.mat','lap_IM_expbeta_original.mat','lap_EM_expbeta_original.mat'...
    ,'lap_Fix_AV_expbeta_original.mat','lap_Dyn_AV_expbeta_original.mat'};
fname_hbi = 'hbi_5mods_original.mat';
% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_original, func_list, out_fname_list, fname_hbi, config);

%% hierarchical fitting for the integrated model
func_list2 = {@LL_ArbF_AV_expbeta_HbCb3SaSc};
out_fname_list2 = {'lap_IntDyn_expbeta_original.mat'};
fname_hbi2 = 'hbi_intDyn_original.mat';
% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_original, func_list2, out_fname_list2, fname_hbi2, config);

%% compare hbi with nonhbi fitting
hbi_params = cbm.output.parameters{1,1};
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/lap_IntDyn_expbeta_original.mat');
nonhbi_params = cbm.output.parameters;
for p = 1:8
    [corrmat_param(p,1),p_param(p,1)] = corr(hbi_params(:,p),nonhbi_params(:,p));
end

%% model recap & selection nonhbi
clearvars -except data_original
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_original.mat');

nf = length(data_original);

% select the best model out of 5 models
np = [5,1,1,2,3]; %number of parameters for each model

%specify loglikelihood functions
func_list = {@LL_Baseline_HbCb3SaSc, @LL_IM_expbeta, @LL_EM_expbeta, @LL_Hyb_AV_expbeta, @LL_ArbF_AV_expbeta}; 
 
%specify output files
out_fname_list = {'lap_Baseline_HbCb3SaSc_original.mat','lap_IM_expbeta_original.mat','lap_EM_expbeta_original.mat'...
    ,'lap_Fix_AV_expbeta_original.mat','lap_Dyn_AV_expbeta_original.mat'};
outdir = '/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data';

%create a fitRecap data structure to save a bunch of measures about model
%fits
fitRecap.log_evidence = zeros(nf,length(out_fname_list));
params = cell(length(out_fname_list),2);
for i=1:length(out_fname_list)
    load([outdir,'/',out_fname_list{i}],'cbm')
    params{i,1} = cbm.output.parameters;
    params{i,2} = cbm.output.paramTrans;
    fitRecap.log_evidence(:,i) = cbm.output.log_evidence;
end

fitRecap.model_LHsub = zeros(nf,length(out_fname_list));
fitRecap.model_corrsub = zeros(nf,length(out_fname_list));
fitRecap.pseudoR2 = zeros(nf,length(out_fname_list));
fitRecap.BIC = zeros(nf,length(out_fname_list));
fitRecap.AIC = zeros(nf,length(out_fname_list));
% fitRecap.best_model = zeros(nf,3);
% fitRecap.w_arb = zeros(nf,3);

for s=1:nf
   % try
    
        P = data_original{s};
        ilu = P(:,6)==1;
        igood = ~isnan(P(:,13));
        ntg = sum(igood);

        recap_sub_BIC = zeros(1,length(out_fname_list));
        recap_sub_AIC = zeros(1,length(out_fname_list));

        for m=1:length(out_fname_list)

            %use log likelihood function to calculate log likelihood and other
            %trial-by-trial variables from the model
            [ll,P_pred] = func_list{m}(params{m,1}(s,:),P);

            fitRecap.loglike(s,m) = ll;
            %calculate R2, AIC, BIC
            fitRecap.pseudoR2(s,m) = 1 - ll/(ntg*log(0.5));
            fitRecap.adjust_pseudoR2(s,m) = 1 - (ll-np(m))/(ntg*log(0.5));

            if fitRecap.pseudoR2(s,m)<0
                fitRecap.pseudoR2(s,m)=0;
            end
            recap_sub_BIC(m) = -2*ll + log(ntg)*np(m);  % Klog(n) - 2loglike
            recap_sub_AIC(m) = -2*ll + 2*np(m);

            %calculate mean likelihood of model predicting subject's choice
            fitRecap.model_LHsub(s,m) = nanmean(P_pred(:,1));

            %calculate mean likelihood of model predicting correct choice
            fitRecap.model_corrsub(s,m) = nanmean(P_pred(:,3));

            %calculate mean arbitration weight for each each subject
          %  fitRecap.w_arb(s,:) = [mean(P_pred(igood,end)) mean(P_pred(ilu & igood,end)) mean(P_pred(~ilu & igood,end))];

        end
        recap_sub_logEv = fitRecap.log_evidence(s,:);
        fitRecap.BIC(s,:) = recap_sub_BIC;
        fitRecap.AIC(s,:) = recap_sub_AIC;
        %find best model among EM, IM, Hyb and Arb
         fitRecap.best_model(s,:) = [find(recap_sub_logEv==max(recap_sub_logEv)) ...
             find(recap_sub_BIC==min(recap_sub_BIC)) find(recap_sub_AIC==min(recap_sub_AIC))];
  %  catch
  %      disp(s);
  %  end
end
%compute some variables necesary for regression models
save('5models_recap_original.mat','fitRecap','params')

%% visualize the individual categorization
for c = 1:3
    for m = 1:5
        num_mod(c,m) = sum(find(fitRecap.best_model(:,c) == m));
    end
end
b = bar([1:3],num_mod,"stacked");

%% (hierarchical) fitting for the fix integrated model
%specify loglikelihood functions
clearvars -except data_original

% model fitting functions
func_list3 = {@LL_Hyb_AV_expbeta_HbCb3SaSc}; 
np = [7]; %number of parameters for each model
%specify parameter priors
v = 6.25; %parameter variance (6.25 is large enough to cover a wide range of parameters with no excessive penalty)
prior_list{1} = struct('mean',zeros(np,1),'variance',v);
%specify output files
out_fname_list3 = {'lap_IntFix_expbeta_original.mat'};
%run cbm_lap for each model
cbm_lap(data_original, func_list3{1}, prior_list{1}, out_fname_list3{1}, []);

%transform parameters
load(out_fname_list3{1},'cbm')
params = cbm.output.parameters;
npar = np;
cbm.output.paramTrans = params;
cbm.output.paramTrans(:,1)  = exp(params(:, 1)); % beta
cbm.output.paramTrans(2) = 1/(1+exp(-params(2)));   % fixed arbitration weight [0 1]
save(out_fname_list3{1},'cbm')

fname_hbi3 = 'hbi_intfix_original.mat';
% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_original, func_list3, out_fname_list3, fname_hbi3, config);
