% miscellaneous analyses

clear all
fs = filesep;
data_discovery = readtable(['..',fs,'..',fs,'data',fs,'Study1',fs,'AllVars_discovery.csv']);
data_replication = readtable(['..',fs,'..',fs,'data',fs,'Study2',fs,'AllVars_replication.csv']);

%% Supplementary Fig. S9, Table S5
% comparison across OL strategy subgroups
% cluster proportion
[grpname, grpnumber_dis] = grpstats(ones(943,1),data_discovery.cluster_group,["gname","numel"]);
[grpname, grpnumber_rep] = grpstats(ones(352,1),data_replication.cluster_group,["gname","numel"]);

% Task performance (ACC) diff by clusters
% discovery sample
[p.acc_cluster_dis,~,stats.acc_cluster_dis] = anova1(data_discovery.ACC,data_discovery.cluster_group);
title('Accuracy - discovery sample');
[c.acc_cluster_dis,~,~,gnames] = multcompare(stats.acc_cluster_dis);
tbl.acc_cluster_dis = array2table(c.acc_cluster_dis,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.acc_cluster_dis.("Group 1") = gnames(tbl.acc_cluster_dis.("Group 1"));
tbl.acc_cluster_dis.("Group 2") = gnames(tbl.acc_cluster_dis.("Group 2"));
% replication sample
[p.acc_cluster_rep,~,stats.acc_cluster_rep] = anova1(data_replication.ACC,data_replication.cluster_group);
title('Accuracy - replication sample');
[c.acc_cluster_rep,~,~,gnames] = multcompare(stats.acc_cluster_rep);
tbl.acc_cluster_rep = array2table(c.acc_cluster_rep,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.acc_cluster_rep.("Group 1") = gnames(tbl.acc_cluster_rep.("Group 1"));
tbl.acc_cluster_rep.("Group 2") = gnames(tbl.acc_cluster_rep.("Group 2"));


% Emulation propensity
% discovery sample
[p.emprop_cluster_dis,~,stats.emprop_cluster_dis] = anova1(data_discovery.EM_prop,data_discovery.cluster_group);
title('Emulation propensity - discovery sample');
[c.emprop_cluster_dis,~,~,gnames] = multcompare(stats.emprop_cluster_dis);
tbl.emprop_cluster_dis = array2table(c.emprop_cluster_dis,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.emprop_cluster_dis.("Group 1") = gnames(tbl.emprop_cluster_dis.("Group 1"));
tbl.emprop_cluster_dis.("Group 2") = gnames(tbl.emprop_cluster_dis.("Group 2"));
% replication sample
[p.emprop_cluster_rep,~,stats.emprop_cluster_rep] = anova1(data_replication.EM_prop,data_replication.cluster_group);
title('Emulation propensity - discovery sample');
[c.emprop_cluster_rep,~,~,gnames] = multcompare(stats.emprop_cluster_rep);
tbl.emprop_cluster_rep = array2table(c.emprop_cluster_rep,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.emprop_cluster_rep.("Group 1") = gnames(tbl.emprop_cluster_rep.("Group 1"));
tbl.emprop_cluster_rep.("Group 2") = gnames(tbl.emprop_cluster_rep.("Group 2"));

% age
% discovery sample
[p.age_cluster_dis,~,stats.age_cluster_dis] = anova1(data_discovery.Age,data_discovery.cluster_group);
title('Age - discovery sample');
[c.age_cluster_dis,~,~,gnames] = multcompare(stats.age_cluster_dis);
tbl.age_cluster_dis = array2table(c.age_cluster_dis,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.age_cluster_dis.("Group 1") = gnames(tbl.age_cluster_dis.("Group 1"));
tbl.age_cluster_dis.("Group 2") = gnames(tbl.age_cluster_dis.("Group 2"));
% replication sample
[p.age_cluster_rep,~,stats.age_cluster_rep] = anova1(data_replication.Age,data_replication.cluster_group);
title('Age - replication sample');
[c.age_cluster_rep,~,~,gnames] = multcompare(stats.age_cluster_rep);
tbl.age_cluster_rep = array2table(c.age_cluster_rep,"VariableNames", ...
    ["Group 1","Group 2","Lower Limit","A-B","Upper Limit","P-value"])
tbl.age_cluster_rep.("Group 1") = gnames(tbl.age_cluster_rep.("Group 1"));
tbl.age_cluster_rep.("Group 2") = gnames(tbl.age_cluster_rep.("Group 2"));

% gender
% discovery sample
data_nonan_dis = data_discovery(~strcmp(data_discovery.Gender,'NaN'),:);
[conttbl_dis,chi2_dis,p.gender_cluster_dis,~] = crosstab(data_nonan_dis.Gender,data_nonan_dis.cluster_group);
heatmap(data_nonan_dis,'Gender','cluster_group')
title('Gender - discovery sample');
% replication sample
[conttbl_rep,chi2_rep,p.gender_cluster_rep,~] = crosstab(data_replication.Gender,data_replication.cluster_group)
heatmap(data_replication,'Gender','cluster_group')

%% Supplementary Fig S3 
% a,b: SRS and F1 correlate with other questionnaires
Quesnames = {'BDI','OCI_R','Barratt_Impulsiveness','STAI_T','LSAS'};
corr_srsf1_ori = [];
p_srsf1_ori = [];
for q=1:5
    [corr_srsf1_ori(1,q),p_srsf1_ori(1,q)] = corr(data_discovery.SRS,data_discovery.(Quesnames{q}),'rows','complete');
    [corr_srsf1_ori(2,q),p_srsf1_ori(2,q)] = corr(data_discovery.SRS_F1,data_discovery.(Quesnames{q}),'rows','complete');
end
corr_srsf1_rep = [];
p_srsf1_rep = [];
for q=1:5
    [corr_srsf1_rep(1,q),p_srsf1_rep(1,q)] = corr(data_replication.SRS,data_replication.(Quesnames{q}),'rows','complete');
    [corr_srsf1_rep(2,q),p_srsf1_rep(2,q)] = corr(data_replication.SRS_F1,data_replication.(Quesnames{q}),'rows','complete');
end

xnames = {'BDI-II','OCI-R','BIS-11','STAI-T','LSAS'};
figure;
subplot(2,2,1)
hm1 = heatmap(corr_srsf1_ori(1,:),'XData',xnames,'YData',{'SRS'},'ColorLimits',[-1 1]);
hm1.CellLabelFormat = '%.3g';
caxis([-1 1]);
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colorbar; 
colormap(J);
subplot(2,2,3)
hm2 = heatmap(corr_srsf1_ori(2,:),'XData',xnames,'YData',{'Factor 1'},'ColorLimits',[-1 1]);
hm2.CellLabelFormat = '%.3g';
caxis([-1 1]);
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colorbar; 
colormap(J);
subplot(2,2,2)
hm3 = heatmap(corr_srsf1_rep(1,:),'XData',xnames,'YData',{'SRS'},'ColorLimits',[-1 1]);
hm3.CellLabelFormat = '%.3g';
caxis([-1 1]);
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colormap(J);
subplot(2,2,4)
hm4 = heatmap(round(corr_srsf1_rep(2,:),3),'XData',xnames,'YData',{'Factor 1'},'ColorLimits',[-1 1]);
hm4.CellLabelFormat = '%.3g';
caxis([-1 1]);
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colormap(J);


% c: how these other questionnaire correlate with themselves
corr_ques_ori = [];
corr_ques_rep = [];
for q1=1:5
    for q2=1:5
        [corr_ques_ori(q1,q2),~] = corr(data_discovery.(Quesnames{q1}),data_discovery.(Quesnames{q2}),'rows','complete');
        [corr_ques_rep(q1,q2),~] = corr(data_replication.(Quesnames{q1}),data_replication.(Quesnames{q2}),'rows','complete');
    end
end
figure;
hm5 = heatmap(corr_ques_ori,'XData',xnames,'YData',xnames,'ColorLimits',[-1 1]);
hm5.CellLabelFormat = '%.3g';
caxis([-1 1]);
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colormap(J);
figure;
hm6 = heatmap(corr_ques_rep,'XData',xnames,'YData',xnames,'ColorLimits',[0 1]);
hm6.CellLabelFormat = '%.3g';
caxis([0 1]);
J = customcolormap([0 1], {'#e66aac','#ffffff'});
colormap(J);

