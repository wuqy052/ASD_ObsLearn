% clustering in a high dimensional space
%% Clustering
% load data
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/5models_recap_original.mat');
fitcriteria = fitRecap.pseudoR2;
% select a set of parameters
clustervars = table;
clustervars.R2_Baseline = fitcriteria(:,1);
clustervars.R2_Imitation = fitcriteria(:,2);
clustervars.R2_Emulation = fitcriteria(:,3);
clustervars.R2_fix_bestSin = fitcriteria(:,4) - max(fitcriteria(:,2:3)')';
clustervars.R2_dyn_fix = fitcriteria(:,5) - fitcriteria(:,4);
varnames = {'R_2Baseline','R_2Imitation','R_2Emulation','R_2Fix-bestSin','R_2Dyn-Fix'};
input = table2array(clustervars);


%% if use BIC
fitcriteria = fitRecap.BIC;
norm_BIC = 1 - rescale(fitcriteria,"InputMin",min(fitcriteria,[],2),"InputMax",max(fitcriteria,[],2));
input = norm_BIC(:,1:3);
input(:,4) = norm_BIC(:,4) - max(norm_BIC(:,2:3)')';
input(:,5) = norm_BIC(:,5) - norm_BIC(:,4);
%% check variable properties
% correlations among predictors
figure;
heatmap(varnames,varnames,corr(table2array(clustervars)),'CellLabelFormat', '%.3f');
colormap(redbluecmap);
caxis([-1,1]);
% plot the histogram of each variable
figure
for i=1:5
    subplot(2,3,i)
    histogram(table2array(clustervars(:,i)));
end
% visualize the AIC based grouping
colorpal = {'#ff6666','#ffb266','#ffff66','#66ff66','#66ffff'};
% plot 1, scatter plot 2D
idx_AIC = fitRecap.best_model(:,3);
figure;
k=1;
for i=1:4
    for j=i+1:5
        subplot(4,3,k)
        hold on;
        for c = 1:max(idx_AIC)
            scatter(input(find(idx_AIC==c),i),input(find(idx_AIC==c),j),'filled','MarkerFaceColor',colorpal{c},'MarkerFaceAlpha',0.3);
        end
        xlabel(varnames{i});
        ylabel(varnames{j});
        k=k+1;
    end
end
legend;

%% k means clustering - cosine distance
distmeasure = 'cosine';
eva = evalclusters(input,'kmeans','silhouette','Distance',distmeasure,'KList',[2:10]);
disp(eva.OptimalK);
opts = statset('Display','final');
% visualize the silhouette score
for k = 2:10
    clust = kmeans(input,k,'Distance',distmeasure,...
    'Replicates',5);
    figure;
    hold on
    [s{k},h{k}] = silhouette(input,clust,'cosine');
    s_mean(k-1) = mean(s{k});
    s_neg(k-1) = sum(s{k} < 0);
    xline(mean(s{k}));
end
% plot silhouette score 
figure;
plot([2:10],s_mean);
xlabel('Number of clusters');
ylabel('Silhouette score');
figure;
plot([2:10],s_neg);
xlabel('Number of clusters');
ylabel('# misclustered points');

[idx,C] = kmeans(input,4,'Distance',distmeasure,...
    'Replicates',5,'Options',opts);

% makingplots
% match the cluster to group names
for c=1:max(idx)
    cluster_varmean(c,:) = mean(input(find(idx==c),:),1);
    cluster_prop(c) = mean(idx == c);
end
[~, idxcluster] = max(cluster_varmean,[],1);
cluster_name{idxcluster(1)} = 'Baseline';
cluster_name{idxcluster(2)} = 'Imitation';
cluster_name{idxcluster(3)} = 'Emulation';
cluster_name{10-sum(idxcluster(1:3))} = 'Arbitration';
    

% define a 4-color palette
colorpal = struct();
colorpal.Baseline = '#f7db4a';
colorpal.Imitation = '#00cc66';
colorpal.Emulation = '#ff007f';
colorpal.Arbitration = '#6f88eb';

% plot 1, scatter plot 2D
figure;
k=1;
for i=1:4
    for j=i+1:5
        subplot(4,3,k)
        hold on;
        for c = 1:max(idx)
            scatter(input(find(idx==c),i),input(find(idx==c),j),'filled','MarkerFaceColor',colorpal.(cluster_name{c}),'MarkerFaceAlpha',0.3);
        end
        xlabel(varnames{i});
        ylabel(varnames{j});
        k=k+1;
    end
end
legend(cluster_name);
% plot 2, alluvial/sankey plot
CreateSankeyPlot([fitRecap.best_model(:,3) idx])
% plot 3, group stats
% match the order to a fixed template
[~,c_reorder] = ismember(cluster_name,{'Baseline','Imitation','Emulation','Arbitration'});
figure;
for c=1:max(idx)
    subplot(1,4,c_reorder(c))
    hold on
    bar(cluster_varmean(c,:),'FaceColor',colorpal.(cluster_name{c}));
    errorbar(cluster_varmean(c,:),...
        std(input(find(idx==c),:),[],1)./sqrt(sum(idx==c)),...
        "LineStyle","none",'Color','k');
    title({cluster_name{c},[num2str(round(cluster_prop(c),3)*100),'%']});
    xticks([1:6]);
    xticklabels(varnames);
    xtickangle(45);
    ylim([-0.1,0.5]);
end
% plot 4, proportion in each group
figure;
[~,c_reorder2] = ismember({'Baseline','Imitation','Emulation','Arbitration'},cluster_name);
b = barh(1,cluster_prop(c_reorder2),'stacked');
for c=1:max(idx)
    b(c).FaceColor = colorpal.(cluster_name{c_reorder2(c)});
end
yticklabels('Strategy');
xlabel('Proportions');

%% association between new clusters vs. SRS/F1
SRS_factors = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_8_factor_promax_original.csv');
% the order of subID in the FA score data is different from that in the
% final list
% align with the final list
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat');
[~,~,faid] = intersect(sublist,SRS_factors.subIDs_inc);
factors_final = SRS_factors(faid,:);
factors_final.subIDs_inc = [];

% factor 1, along the emulation dimension
[grpdata.F1_mean,grpdata.F1_se] = grpstats(factors_final.Factor1,idx,["mean","sem"]);
figure;
hold on
for c=1:max(idx)
    bar(c_reorder(c),grpdata.F1_mean(c),'FaceColor',colorpal.(cluster_name{c}));
end
errorbar(c_reorder(1:max(idx)),grpdata.F1_mean,grpdata.F1_se,"LineStyle","none",'Color','k');
xlabel('group');
ylabel('F1');
xticks([1:4]);
xticklabels({'Baseline','Imitation','Emulation','Arbitration'});
xtickangle(45);
[p,tbl,stats] = anova1(factors_final.Factor1,idx);
[c,~,~,gnames] = multcompare(stats);
tbl = array2table(c,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Group A") = gnames(tbl.("Group A"));
tbl.("Group B") = gnames(tbl.("Group B"))
%% cross-validation, calculate the rand index - no normalization
for r = 1:100
    c = cvpartition(size(input,1),'KFold',5);
    for k=1:5
        dist_c =[];
        idxTrain = training(c,k);
        idxTest = test(c,k);
        % train a clustering
        [idx_cluster_train,C_train] = kmeans(input(idxTrain,:),4,'Distance','cosine',...
            'Replicates',10);
        % apply the trained cluster to test data
        %[~,idx_train_on_test] = pdist2(C_train,input(idxTest,:),'cosine','Smallest',1);
        % match each test data to the cluster, to which the mean distance (across
        % all train data) is the smallest
        dist = pdist2(input(idxTrain,:),input(idxTest,:),'cosine');
        for clust = 1:4
            dist_c(:,clust) = mean(dist(idx_cluster_train == clust,:),1);
        end
        [~,idx_train_on_test] = max(dist_c == min(dist_c,[],2),[],2);
        % do the clustering on test only
        [idx_cluster_test,C_test] = kmeans(input(idxTest,:),4,'Distance','cosine',...
            'Replicates',10);
        % match 2 partitions
        [~,cluster_match] = pdist2(C_train,C_test,'cosine','Smallest',1);
        if length(unique(cluster_match))<size(cluster_match,1)
            disp('Not a good match!');
        end
        % reorder
        idx_cluster_text_reorder = [];
        for i=1:length(idx_cluster_test)
            idx_cluster_text_reorder(i,1) = cluster_match(idx_cluster_test(i));
        end
        [AR(k,r),RI(k,r),~,~]=RandIndex(idx_cluster_text_reorder,idx_train_on_test);
    end
end
mean_AR = mean(AR(:));
mean_RI = mean(RI(:));


