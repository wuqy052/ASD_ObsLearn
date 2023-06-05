% subject categorization according to models (hbi+nonhbi) vs. model-free
% behavioral measurements
% mainly analyze as a sanity check

%% load data
% model fitting
res_hbi = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/hbi_5mods_original.mat');
res_nonhbi = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/5models_recap_original.mat');
% model free
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/model_free_analysis/model_free_analyses_original.mat');
% subject list
% this is the list saved during model fitting
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat');
[C,~,incl] = intersect(sublist,allID);

%% 2. Calculate stats
% nonhbi, model frequency
num_mod = [];
for c = 1:3
    for m = 1:5
        num_mod(c,m) = sum(res_nonhbi.fitRecap.best_model(:,c) == m);
    end
end
freq_nonhbi = num_mod./sum(num_mod,2);

% calculate statistics
OL_groups_nonhbi = res_nonhbi.fitRecap.best_model(:,3); % nonhbi, AIC
% hbi, responsibility
for s = 1:length(res_hbi.cbm.output.responsibility)
    OL_groups_hbi(s,1) = find(res_hbi.cbm.output.responsibility(s,:)==max(res_hbi.cbm.output.responsibility(s,:)));
end
[grp.hbi_count, grp.hbi_acc_mean,grp.hbi_acc_se] = grpstats(Accuracy(incl,1),OL_groups_hbi,["numel","mean","sem"]); % total accuracy
[grp.nonhbi_count, grp.nonhbi_acc_mean,grp.nonhbi_acc_se] = grpstats(Accuracy(incl,1),OL_groups_nonhbi,["numel","mean","sem"]); % total accuracy
[grp.hbi_emu_mean,grp.hbi_emu_se] = grpstats(EM_prop(incl,1),OL_groups_hbi,["mean","sem"]); % total emulation propensity
[grp.nonhbi_emu_mean,grp.nonhbi_emu_se] = grpstats(EM_prop(incl,1),OL_groups_nonhbi,["mean","sem"]); % total emulation propensity
freq_hbi = grp.hbi_count/ sum(grp.hbi_count);

%% anova test of between group differences
[statstable.hbi_acc_anova.p, statstable.hbi_acc_anova.anovatab, statstable.hbi_acc_anova.stats] = anova1(Accuracy(incl,1),OL_groups_hbi);
[statstable.nonhbi_acc_anova.p, statstable.nonhbi_acc_anova.anovatab, statstable.nonhbi_acc_anova.stats] = anova1(Accuracy(incl,1),OL_groups_nonhbi);
[statstable.hbi_emu_anova.p, statstable.hbi_emu_anova.anovatab, statstable.hbi_emu_anova.stats] = anova1(EM_prop(incl,1),OL_groups_hbi);
[statstable.nonhbi_emu_anova.p, statstable.nonhbi_emu_anova.anovatab, statstable.nonhbi_emu_anova.stats] = anova1(EM_prop(incl,1),OL_groups_nonhbi);
% all have significant differences

%% plot figures
% Count
figure;
b = bar([1:4],[freq_hbi'; freq_nonhbi],"stacked");
xticks([1:4]);
xticklabels({'hbiresp','loglike','BIC','AIC'});
ylabel('Model Frequency');
title('% of subjects best fitted by each model');
legend({'Baseline','Immitation','Emulation','FixArb','DynArb'});

% hbi - ACC
figure;
hold on
bar([1:5],grp.hbi_acc_mean,'FaceColor',[153/256,220/256,196/256]);
errorbar([1:5],grp.hbi_acc_mean,grp.hbi_acc_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('Accuracy');
title({'Accuracy ~ best-fitting model','hbi - original'});
xtickangle(45);
ylim([0,1]);
% nonhbi - ACC
figure;
hold on
bar([1:5],grp.nonhbi_acc_mean,'FaceColor',[255/256,195/256,102/256]);
errorbar([1:5],grp.nonhbi_acc_mean,grp.nonhbi_acc_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('Accuracy');
title({'Accuracy ~ best-fitting model','nonhbi - original'});
xtickangle(45);
ylim([0,1]);

% hbi - Emuprop
figure;
hold on
bar([1:5],grp.hbi_emu_mean,'FaceColor',[153/256,220/256,196/256]);
errorbar([1:5],grp.hbi_emu_mean,grp.hbi_emu_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('Emulation Propensity');
title({'Emulation ~ best-fitting model','hbi - original'});
xtickangle(45);
ylim([0,1]);
% nonhbi - Emuprop
figure;
hold on
bar([1:5],grp.nonhbi_emu_mean,'FaceColor',[255/256,195/256,102/256]);
errorbar([1:5],grp.nonhbi_emu_mean,grp.nonhbi_emu_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('Emulation Propensity');
title({'Emulation ~ best-fitting model','nonhbi - original'});
xtickangle(45);
ylim([0,1]);

