% 5 parsimoneous models + 1 integrated model
% non-hierarchical + hierarchical fit
% 5 parsimoneous models: non-learning, imitation, emulation,fixed
% arbitration, dynamic arbitration

%% part 1: nonhierarchical model fitting
clear all
% load data
fs = filesep;
load(['..',fs,'..',fs,'data',fs,'Study1',fs,'data_modelfit_discovery.mat']);

%specify loglikelihood functions
func_list = {@LL_NonLearn, @LL_Imitation, @LL_Emulation,...
    @LL_FixArb, @LL_DynArb, @LL_IntDynArb}; 
%number of parameters for each model
np = [5,1,1,2,3,8]; 
%specify parameter priors
v = 6.25; %parameter variance (6.25 is large enough to cover a wide range of parameters with no excessive penalty)
for m = 1:6
    prior_list{m} = struct('mean',zeros(np(m),1),'variance',v);
end
%specify output files
out_fname_list = {'lap_NonLearn_discovery.mat','lap_Imitation_discovery.mat','lap_Emulation_discovery.mat'...
    ,'lap_FixArb_discovery.mat','lap_DynArb_discovery.mat','lap_IntDynArb_discovery.mat'};

%run cbm_lap for each model
%this will fit every model to each subject's data separately (ie in a
%non-hierarchical fashion), using Laplace approximation, which needs a
%normal prior for every parameter
% data_prolific = data_prolific(1);
for m = 1:6
    cbm_lap(data_discovery, func_list{m}, prior_list{m}, ['discovery',fs,out_fname_list{m}], []);
end

%transform parameters
for m=1:6
    fname = ['discovery',fs,out_fname_list{m}];
    load(fname,'cbm')
    params = cbm.output.parameters;
    npar = np(m);
    cbm.output.paramTrans = params;
    % NonLearning model does not include beta
    if m>1 
        cbm.output.paramTrans(:,1)  = exp(params(:, 1)); % beta
    end
    % fixed arbitration weight [0 1]
    if m==4 
        cbm.output.paramTrans(:,2) = 1./(1+exp(-params(:,2)));   
    end
    save(fname,'cbm')
end

%% part 2: Calculate model fitting for the 5 basic models
clear all
fs = filesep;
outdir = ['.',fs,'discovery',fs];
load(['..',fs,'..',fs,'data',fs,'Study1',fs,'data_modelfit_discovery.mat']);

np = [5,1,1,2,3]; %number of parameters for each model

%specify loglikelihood functions
func_list_5mods = {@LL_NonLearn, @LL_Imitation, @LL_Emulation,...
    @LL_FixArb, @LL_DynArb}; 
%specify output files
out_fname_list_5mods = {'lap_NonLearn_discovery.mat','lap_Imitation_discovery.mat','lap_Emulation_discovery.mat'...
    ,'lap_FixArb_discovery.mat','lap_DynArb_discovery.mat'};

%create a fitRecap data structure to save a bunch of measures about model
%fits
nf = size(data_discovery,1);
fitRecap.log_evidence = zeros(nf,length(out_fname_list_5mods));
params = cell(length(out_fname_list_5mods),2);
for i=1:length(out_fname_list_5mods)
    load([outdir,out_fname_list_5mods{i}],'cbm')
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
    P = data_discovery{s};
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
    
end
%compute some variables necesary for regression models
save([outdir,'5models_recap_discovery.mat'],'fitRecap','params')


%% part 3: hierarchical fitting for all 5 models
clear all
fs = filesep;
outdir = ['.',fs,'discovery',fs];
load(['..',fs,'..',fs,'data',fs,'Study1',fs,'data_modelfit_discovery.mat']);

func_list_5mods = {@LL_NonLearn, @LL_Imitation, @LL_Emulation,...
    @LL_FixArb, @LL_DynArb}; 
out_fname_list_5mods = {'lap_NonLearn_discovery.mat','lap_Imitation_discovery.mat','lap_Emulation_discovery.mat'...
    ,'lap_FixArb_discovery.mat','lap_DynArb_discovery.mat'};

for m=1:5
    out_fname_list_new{m} = [outdir,out_fname_list_5mods{m}];
end
fname_hbi_5mods = [outdir,'hbi_5mods_discovery.mat'];

% can change the config parameters by config.maxiter/congif.tolx
config.maxiter = 100;
cbm_hbi(data_discovery, func_list_5mods, out_fname_list_new, fname_hbi_5mods, config);

%% part4: hierarchical fitting for the dynamic integrated model only
clear all
fs = filesep;
outdir = ['.',fs,'discovery',fs];
load(['..',fs,'..',fs,'data',fs,'Study1',fs,'data_modelfit_discovery.mat']);

config.maxiter = 30;
cbm_hbi(data_discovery,{@LL_IntDynArb},{[outdir,'lap_IntDynArb_discovery.mat']}, [outdir,'hbi_IntDynArb_discovery.mat'], config);
