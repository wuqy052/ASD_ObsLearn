%% load data
data_dir = pwd;
cd(data_dir)
data_all = readtable('beh_mod_SRS.csv');

addpath('../plotSpread')

%% histograms
figure; hold
histogram(data_all.EM_prop)
plot([mean(data_all.EM_prop) mean(data_all.EM_prop)],[0 140],'r','LineWidth',2)
xlabel('Emulation propensity')
xlim([0 1])
ylabel('Count')
set(gca, 'box', 'off')

figure; hold
histogram(data_all.EM_prop_diff,-0.72:0.1:0.82)
plot([mean(data_all.EM_prop_diff) mean(data_all.EM_prop_diff)],[0 300],'r','LineWidth',2)
xlabel('Change in Emulation propensity')
ylabel('Count')
set(gca, 'box', 'off')


%% plot behavioral signatures by model group
%add plotSpread to path if not already
grp = data_all.best_model_group;
EM_prop = data_all.EM_prop;
mean_EM = [mean(EM_prop(grp==1)) mean(EM_prop(grp==2)) mean(EM_prop(grp==3)) ...
    mean(EM_prop(grp==4)) mean(EM_prop(grp==5))];
std_EM = [std(EM_prop(grp==1))/sqrt(sum(grp==1)) std(EM_prop(grp==2))/sqrt(sum(grp==2)) ...
    std(EM_prop(grp==3))/sqrt(sum(grp==3)) std(EM_prop(grp==4))/sqrt(sum(grp==4)) ...
    std(EM_prop(grp==5))/sqrt(sum(grp==5))];
figure; hold
bar(1:5,mean_EM,0.5,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k','LineWidth',1);
errorbar(1:5,mean_EM,std_EM,'.k','LineWidth',1.5);
errorbar(1:5,mean_EM,std_EM,'.k','LineWidth',1.5);
plotSpread(EM_prop,'distributionIdx',grp,'distributionColors',[0.4 0.4 0.4],'spreadWidth',0.5);
plot([0 6],[0.5 0.5],'r--')
xticks(1:5)
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
ylim([0 1])
xlabel('Group')
ylabel('Emulation Propensity')

arb = data_all.EM_prop_diff;
mean_arb = [mean(arb(grp==1)) mean(arb(grp==2)) mean(arb(grp==3)) ...
    mean(arb(grp==4)) mean(arb(grp==5))];
std_arb = [std(arb(grp==1))/sqrt(sum(grp==1)) std(arb(grp==2))/sqrt(sum(grp==2)) ...
    std(arb(grp==3))/sqrt(sum(grp==3)) std(arb(grp==4))/sqrt(sum(grp==4)) ...
    std(arb(grp==5))/sqrt(sum(grp==5))];
figure; hold
bar(1:5,mean_arb,0.5,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k','LineWidth',1);
errorbar(1:5,mean_arb,std_arb,'.k','LineWidth',1.5);
errorbar(1:5,mean_arb,std_arb,'.k','LineWidth',1.5);
plotSpread(arb,'distributionIdx',grp,'distributionColors',[0.4 0.4 0.4],'spreadWidth',0.5);
xticks(1:5)
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
% ylim([0 1])
xlabel('Group')
ylabel('Arbitration index')

wUnc = data_all.wUnc;
mean_wUnc = [mean(wUnc(grp==1)) mean(wUnc(grp==2)) mean(wUnc(grp==3)) ...
    mean(wUnc(grp==4)) mean(wUnc(grp==5))];
std_wUnc = [std(wUnc(grp==1))/sqrt(sum(grp==1)) std(wUnc(grp==2))/sqrt(sum(grp==2)) ...
    std(wUnc(grp==3))/sqrt(sum(grp==3)) std(wUnc(grp==4))/sqrt(sum(grp==4)) ...
    std(wUnc(grp==5))/sqrt(sum(grp==5))];
figure; hold
bar(1:5,mean_wUnc,0.5,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k','LineWidth',1);
errorbar(1:5,mean_wUnc,std_wUnc,'.k','LineWidth',1.5);
errorbar(1:5,mean_wUnc,std_wUnc,'.k','LineWidth',1.5);
plotSpread(wUnc,'distributionIdx',grp,'distributionColors',[0.4 0.4 0.4],'spreadWidth',0.5);
xticks(1:5)
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
% ylim([0 1])
xlabel('Group')
ylabel('Uncertainty weight parameter')

bias = data_all.bias;
mean_bias = [mean(bias(grp==1)) mean(bias(grp==2)) mean(bias(grp==3)) ...
    mean(bias(grp==4)) mean(bias(grp==5))];
std_bias = [std(bias(grp==1))/sqrt(sum(grp==1)) std(bias(grp==2))/sqrt(sum(grp==2)) ...
    std(bias(grp==3))/sqrt(sum(grp==3)) std(bias(grp==4))/sqrt(sum(grp==4)) ...
    std(bias(grp==5))/sqrt(sum(grp==5))];
figure; hold
bar(1:5,mean_bias,0.5,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k','LineWidth',1);
plotSpread(bias,'distributionIdx',grp,'distributionColors',[0.4 0.4 0.4],'spreadWidth',0.5);
errorbar(1:5,mean_bias,std_bias,'.k','LineWidth',1.5);
errorbar(1:5,mean_bias,std_bias,'.k','LineWidth',1.5);
xticks(1:5)
xticklabels({'Baseline','Imitation','Emulation','FixArb','DynArb'})
% ylim([0 1])
xlabel('Group')
ylabel('Emulation bias parameter')

%% Correlations
x = data_all.EM_prop_diff;
y = data_all.wUnc;
[p,S] = polyfit(x,y,1);
xv = linspace(min(x), max(x), 150);
[y_ext,delta] = polyconf(p,xv,S,'predopt','curve');
figure;
hold on
scatter(x, y, 15, [0.5 0.5 0.5], 'filled','MarkerFaceAlpha',0.7); 
plot(xv, y_ext, '-k', 'LineWidth', 1.2)
patch([xv fliplr(xv)], [(y_ext+delta) fliplr((y_ext-delta))], [0.7 0.7 0.7], 'FaceAlpha',0.6, 'EdgeColor','none')
set(gca, 'box', 'off')
xlim([-0.8 0.8])
ylim([-3 4.2])
xlabel("Arbitration index");
ylabel("Uncertainty weight parameter");
set(gca,'FontSize',16)
title(['R=' num2str(corr(x,y))])

for g=1:5
    x = data_all.EM_prop_diff(grp==g);
    y = data_all.wUnc(grp==g);
    [p,S] = polyfit(x,y,1);
    xv = linspace(min(x), max(x), 150);
    [y_ext,delta] = polyconf(p,xv,S,'predopt','curve');
    figure;
    hold on
    scatter(x, y, 15, [0.5 0.5 0.5], 'filled','MarkerFaceAlpha',0.7); 
    plot(xv, y_ext, '-k', 'LineWidth', 1.2)
    patch([xv fliplr(xv)], [(y_ext+delta) fliplr((y_ext-delta))], [0.7 0.7 0.7], 'FaceAlpha',0.6, 'EdgeColor','none')
    set(gca, 'box', 'off')
    xlim([-0.7 0.8])
    ylim([-3 5])
    xlabel("Arbitration index");
    ylabel("Uncertainty weight parameter");
%     set(gca,'FontSize',16)
    title(['Group ' num2str(g) ', R=' num2str(corr(x,y))])
end

%% plot glm results
load('model_free_analyses_Oct2020.mat')
allID_1 = allID;
glm_b_1 = PredBehavGLMs.Data.GLM1;

load('model_free_analyses_Prolific.mat')
allID_2 = allID;
glm_b_2 = PredBehavGLMs.Data.GLM1;

allID = [allID_1; allID_2];
glm_b = [glm_b_1; glm_b_2];

glm_b_fin = nan(height(data_all),2);
for s=1:height(data_all)
    sID = data_all.subid{s};
    inds = find(strcmp(allID,sID));
    glm_b_fin(s,:) = glm_b(inds,:);
end

figure; hold
bar(1:2,nanmean(glm_b_fin),0.5,'FaceColor',[0.4 0.4 0.4],'EdgeColor','k','LineWidth',1);
plotSpread(glm_b_fin,'distributionColors',[0.8 0.8 0.8],'spreadWidth',0.4);
errorbar(1:2,nanmean(glm_b_fin),nanstd(glm_b_fin)/sqrt(901),'.k','LineWidth',1.5);
xticks(1:2)
xticklabels({'PastAction','TokenInference'})
ylim([-1.5 3])
ylabel('GLM effect')