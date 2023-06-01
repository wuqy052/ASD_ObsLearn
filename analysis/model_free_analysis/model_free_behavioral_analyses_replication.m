% model free analysis of behaviors, output are accuracy, emulation
% propensity, decomposed by high/low uncertainty, switch/nonswitch
% for replication data

%% load data
clear all
close all
fs = filesep;
% this step load all the replication data (without any exclusion)
load(['..',fs,'..',fs,'data',fs,'Study2',fs,'OL_data_all_subs_raw_rep.mat']);

%% perform analysis
%trial definitions (this is set by design)
tr_em_corr = [1 3; 1 6; 2 3; 2 7; 3 9; 4 9]; %trials where emulation is correct and imitation is wrong
tr_im_corr = [1 10; 2 10; 3 5; 3 12; 4 5; 4 12]; %trials where imitation is correct and emulation is wrong
tr_catch = [1 12; 3 3]; %catch trial (repeat partner's action)
tr_both_corr = [2 12; 4 2]; %trial where both strategies would lead to the correct choice

%identify play trials after a switch vs no switch
tr_switch = [1 6; 1 10; 2 7; 2 10; 3 5; 3 9; 3 12; 4 5; 4 9; 4 12];
tr_no_switch = [1 3; 1 12; 2 3; 2 12; 3 3; 4 2];

%contingencies of the slot machine (each row=token, each column=action)
SM_struct = cell(2,3);
SM_struct{1,1} = [0.75 0.05 0.2; 0.2 0.75 0.05; 0.05 0.2 0.75]; %probability distribution of EASY slot machine (low BU, horizOrd 1)
SM_struct{1,2} = [0.05 0.2 0.75; 0.75 0.05 0.2; 0.2 0.75 0.05]; %probability distribution of EASY slot machine (low BU, horizOrd 2)
SM_struct{1,3} = [0.2 0.75 0.05; 0.05 0.2 0.75; 0.75 0.05 0.2]; %probability distribution of EASY slot machine (low BU, horizOrd 3)
SM_struct{2,1} = [0.5 0.2 0.3; 0.3 0.5 0.2; 0.2 0.3 0.5]; %probability distribution of HARD slot machine (high BU, horizOrd 1)
SM_struct{2,2} = [0.2 0.3 0.5; 0.5 0.2 0.3; 0.3 0.5 0.2]; %probability distribution of HARD slot machine (high BU, horizOrd 2)
SM_struct{2,3} = [0.3 0.5 0.2; 0.2 0.3 0.5; 0.5 0.2 0.3]; %probability distribution of HARD slot machine (high BU, horizOrd 3)

%task structure matrices
P_PA_Tok{1,1} = [0 0 1;0 1 0;0 0 1]; %ua 1, horizOrd 1
P_PA_Tok{1,2} = [0 0 1;0 0 1;0 1 0]; %ua 1, horizOrd 2
P_PA_Tok{1,3} = [0 1 0;0 0 1;0 0 1]; %ua 1, horizOrd 3
P_PA_Tok{2,1} = [1 0 0;1 0 0;0 0 1]; %ua 2, horizOrd 1
P_PA_Tok{2,2} = [0 0 1;1 0 0;1 0 0]; %ua 2, horizOrd 2
P_PA_Tok{2,3} = [1 0 0;0 0 1;1 0 0]; %ua 2, horizOrd 3
P_PA_Tok{3,1} = [1 0 0;0 1 0;0 1 0]; %ua 3, horizOrd 1
P_PA_Tok{3,2} = [0 1 0;1 0 0;0 1 0]; %ua 3, horizOrd 2
P_PA_Tok{3,3} = [0 1 0;0 1 0;1 0 0]; %ua 3, horizOrd 3
%here we detail the structure of probability of each partner's action given
%set of available actions and given goal token
%each row of the cell structure {1}, {2}, or {3} represents the unavailable action.
%each column of the cell structure {1}, {2}, or {3} represents the horizontal order.
%within each cell, each column represents the action performed by the partner
%and each row represents the conditional goal token (1:green, 2:red, 3:blue)

n_all = length(ol_task_data);
nt = 96;

Accuracy = nan(n_all,3);
Acc_switch = nan(n_all,2);
RT = nan(n_all,3);
missed = nan(n_all,1);
EM_prop = nan(n_all,3);
acc_catch = nan(n_all,4);
acc_both = nan(n_all,4);
for s=1:n_all
    subID = ol_task_data(s).subID;
    recap_ol.ID_list{s} = subID;
    if ~isempty(ol_task_data(s).mainTask) 
        designNo = ol_task_data(s).designNo;
        tr_list = readmatrix(['..',fs,'..',fs,'task',fs,'Study2',fs,'trial_lists',fs,'trial_list_v' num2str(designNo) '.csv']);
        practice_data = ol_task_data(s).practice;
        main_data = ol_task_data(s).mainTask;
        data = main_data;
        data.runID = [tr_list(:,2)];
        data.choiceLR = nan(nt,1);
        
        i_m = data.blockID~=0;
        i_lu = data.uncertainty==1;
        i_play = strcmp(data.trialType, 'play');
        
        Accuracy(s,:) = [nanmean(data.isCorr(i_m)) nanmean(data.isCorr(i_lu & i_m)) nanmean(data.isCorr(~i_lu & i_m))];
        RT(s,:) = [nanmean(data.rt(i_m)) nanmean(data.rt(i_lu & i_m)) nanmean(data.rt(~i_lu & i_m))];
        missed(s) = nansum(data.miss);
        
        V_tok = NaN(nt,5);
        V_act = [data.corrAct data.unavAct NaN(nt,2)];
        c=0;
        b=0;
        em_ch = nan(nt,1); %build vector of choices consistent with emulation
        acc_switch = nan(nt,2);
        for t=1:nt
            if ismember([data.runID(t) data.trID(t)],tr_switch,'rows') %first play trial after a switch
                acc_switch(t,1)=data.isCorr(t);
            elseif ismember([data.runID(t) data.trID(t)],tr_no_switch,'rows') %no switch
                acc_switch(t,2)=data.isCorr(t);
            end
            if ismember([data.runID(t) data.trID(t)],tr_em_corr,'rows') %emulation-correct trial
                if data.isCorr(t)==1 %subject correct
                    em_ch(t) = 1;
                elseif data.isCorr(t)==0 %subject incorrect
                    em_ch(t) = 0;
                end
            elseif ismember([data.runID(t) data.trID(t)],tr_im_corr,'rows') %imitation-correct trial
                if data.isCorr(t)==1 %subject correct
                    em_ch(t) = 0;
                elseif data.isCorr(t)==0 %subject incorrect
                    em_ch(t) = 1;
                end
            elseif ismember([data.runID(t) data.trID(t)],tr_catch,'rows')
                c=c+1;
                if data.isCorr(t)==1 %subject correct
                    acc_catch(s,c) = 1;
                elseif data.isCorr(t)==0 %subject incorrect
                    acc_catch(s,c) = 0;
                end
            elseif ismember([data.runID(t) data.trID(t)],tr_both_corr,'rows')
                b=b+1;
                if data.isCorr(t)==1 %subject correct
                    acc_both(s,b)=1;
                elseif data.isCorr(t)==0 %subject incorrect
                    acc_both(s,b)=0;
                end
            end  
        end
        Acc_switch(s,:) = nanmean(acc_switch);
        EM_prop(s,:) = [nanmean(em_ch) nanmean(em_ch(i_lu)) nanmean(em_ch(~i_lu))];
        
        id_cell = repmat({subID},sum(i_play),1);
        
    end
end

allID = {ol_task_data.subID}';
model_free_measures = [Accuracy,RT,missed,EM_prop,Acc_switch];

%% apply subject exclusion, generate the final results
load(['..',fs','..',fs,'data',fs,'Study2',fs,'SubList_final_replication.mat']);
[C,~,incl] = intersect(sublist_rep,allID);
model_free_measures = model_free_measures(incl,:);

save('model_free_analyses_replication.mat', 'model_free_measures','C');


