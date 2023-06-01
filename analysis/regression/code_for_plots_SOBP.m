%% load data
data_dir = pwd;
cd(data_dir)
data_all = readtable('beh_mod_SRS.csv');


%% scatter plot with best-fit line and shaded error
x = data_all.SRS_F1;
y = data_all.bias;
[p,S] = polyfit(x,y,1);
xv = linspace(min(x), max(x), 150);
[y_ext,delta] = polyconf(p,xv,S,'predopt','curve');
figure
plot(x, y, '.', 'Color',[227/255 183/255 160/255]); hold
plot(xv, y_ext, '-k', 'LineWidth', 1.2);
patch([xv fliplr(xv)], [(y_ext+delta) fliplr((y_ext-delta))], [255/255 237/255 219/255], 'FaceAlpha',0.8, 'EdgeColor','none')
xlim([-3 5])
ylim([-2 4])
set(gca, 'box', 'off')
xlabel("SRS Factor 1 (Autism Mixture)");
ylabel("OL Emulation Bias");

%% SRS & Behavioral
% accuracy
x = data_all.SRS_F1;
y = data_all.ACC;
[p,S] = polyfit(x,y,1);
xv = linspace(min(x), max(x), 150);
[y_ext,delta] = polyconf(p,xv,S,'predopt','curve');
figure
subplot(1,2,1);
scatter(x, y, 15, [243/255 197/255 197/255], 'filled','MarkerFaceAlpha',0.7); 
hold on
plot(xv, y_ext, '-k', 'LineWidth', 1.2)
patch([xv fliplr(xv)], [(y_ext+delta) fliplr((y_ext-delta))], [193/255 163/255 163/255], 'FaceAlpha',0.6, 'EdgeColor','none')
set(gca, 'box', 'off')
xlim([-3 5])
xlabel("SRS Factor 1 (Autism Mixture)");
ylabel("OL Task Accuracy");
set(gca,'FontSize',20)

%SRS & emulation propensity
x = data_all.SRS_F1;
y = data_all.EM_prop;
[p,S] = polyfit(x,y,1);
xv = linspace(min(x), max(x), 150);
[y_ext,delta] = polyconf(p,xv,S,'predopt','curve');
subplot(1,2,2);
hold on
scatter(x, y, 15, [243/255 197/255 197/255], 'filled','MarkerFaceAlpha',0.7); 
plot(xv, y_ext, '-k', 'LineWidth', 1.2)
patch([xv fliplr(xv)], [(y_ext+delta) fliplr((y_ext-delta))], [193/255 163/255 163/255], 'FaceAlpha',0.6, 'EdgeColor','none')
set(gca, 'box', 'off')
xlim([-3 5])
xlabel("SRS Factor 1 (Autism Mixture)");
ylabel("OL Emulation Propensity");
set(gca,'FontSize',20)

%% AIC plot
% first plot the count of individuals across each best fitting model -AIC
for m = 1:5
    mod_counts(m) = sum(data_all.best_model_group == m);
    SRS_F1_bestmod_mean(m) = mean(data_all.SRS_F1(data_all.best_model_group == m,1));
    SRS_F1_bestmod_std(m) = std(data_all.SRS_F1(data_all.best_model_group == m, 1));
end
subplot(1,2,1);
h2 = bar(mod_counts);
h2.FaceColor = [254/255, 210/255, 170/255];
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
xtickangle(30);
ylabel('Count');
set(gca,'FontSize',20)

% plot the SRS F1
subplot(1,2,2);
hold on
h3 = bar(SRS_F1_bestmod_mean);
h3.FaceColor = [206/255, 229/255, 208/255];
errorbar(SRS_F1_bestmod_mean, SRS_F1_bestmod_std./sqrt(mod_counts));
xticks([1,2,3,4,5]);
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
xtickangle(30);
ylabel('SRS Factor 1 Score');
set(gca,'FontSize',20)



%% Regression
% normalize the data
data_predSRS2 = removevars(data_all,{'subid','Gender'});
data_predSRS_norm = normalize(data_predSRS2);
data_predSRS_norm.subid = data_all.subid;
data_predSRS_norm.Gender = data_all.Gender;

Mod_SRS_Lapse = fitlm(data_predSRS_norm,'SRS_F1 ~ bias + rawBeta + wUnc + hand + green + redvblue + stickyAct + stickyCol + MBMF_wMBMF + EE_nI + EE_uI + EE_uT + wLapse_avg + Age + Gender');
Mod_SRS_noLapse = fitlm(data_predSRS_norm,'SRS_F1 ~ bias + rawBeta + wUnc + hand + green + redvblue + stickyAct + stickyCol + MBMF_wMBMF + EE_nI + EE_uI + EE_uT + Age + Gender');
h1= plotEffects(Mod_SRS_noLapse);
h1(1).MarkerEdgeColor = [255/255,191/255,134/255]; % change the marker color
h1(1).Marker = '.';
h1(1).MarkerSize = 20;
for k=2:15
    h1(k).Color = [255/255,191/255,134/255]; % change the line color
    h1(k).LineWidth = 1.5;
end
xlim([-1.5,2]);
yticklabels({'OL-Beta','OL-Uncertain','OL-EmuBias','OL-Base1','OL-Base2','OL-Base3','OL-Base4','OL-Base5','MBMF-Controller','EE-Novelty','EE-Uncertain1','EE-Uncertain2','Age','Gender'});
set(gca,'FontSize',15)

Mod_bias = fitlm(data_predSRS_norm, 'bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + STAI_T + BDI + Barratt_Impulsiveness + PSWQ + LSAS + OCI_R + COHS_routine + COHS_automaticity + NEO_FFI_neuroticism + NEO_FFI_extraversion + NEO_FFI_openness + NEO_FFI_agreeableness + NEO_FFI_conscientiousness + Age + Gender');
Mod_bias = fitlm(data_predSRS_norm, 'bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + NEO_FFI_neuroticism + NEO_FFI_extraversion + NEO_FFI_openness + NEO_FFI_agreeableness + NEO_FFI_conscientiousness + Age + Gender');

Mod_bias = fitlm(data_predSRS_norm, 'bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + LSAS + STAI_T + BDI + Barratt_Impulsiveness + OCI_R + Age + Gender');

Mod_bias = fitlm(data_predSRS_norm, 'bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + LSAS + STAI_T + BDI + Barratt_Impulsiveness + Age + Gender');


plotEffects(Mod_bias)


