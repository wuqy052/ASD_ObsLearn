% model free analysis of behaviors, output are accuracy, emulation
% propensity, decomposed by high/low uncertainty, switch/nonswitch
% for discovery data

%% load data
clear all
close all
fs = filesep;
% this step load all the discovery data (without any exclusion)
load(['..',fs,'..',fs,'data',fs,'Study1',fs,'OL_data_discovery.mat']);

%% perform analysis
nsub = length(data);

Accuracy = zeros(nsub,3);
Acc_switch = zeros(nsub,2);
RT = zeros(nsub,3);
missed = zeros(nsub,1);
EM_prop = zeros(nsub,3);
acc_catch = zeros(nsub,2);
acc_both = zeros(nsub,2);

tr_em_corr = [1 3; 1 6; 2 10; 3 11; 4 3; 4 5]; %trials where emulation is correct and imitation is wrong
tr_im_corr = [1 10; 2 6; 3 6; 4 11]; %trials where imitation is correct and emulation is wrong
tr_catch = [3 8]; %catch trial (repeat partner's action)
tr_both_corr = [2 3; 3 3; 4 8]; %trial where both strategies would lead to the correct choice
%note: for trials 2-3 and 3-3 it's unclear whether they pertain to
%'imitation correct and emulation wrong' or to 'both strategies correct'?

nt = 84;

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

%identify play trials after a switch vs no switch
tr_switch = [1 6;1 10;2 6;2 10;3 6;3 11;4 6;4 11];
tr_no_switch = [1 3;2 3;3 3;3 8;4 3;4 8];


for s = 1:nsub   
    
    P = table2array(data(s).data);
    %add data for left-right choice to P
    P(P(:,12)==1,13)=1;
    P(P(:,12)==3,13)=0;
    P(P(:,12)==2 & P(:,7)==1,13)=1;
    P(P(:,12)==2 & P(:,7)==3,13)=0;
    %col 1: run order
    %col 2: run ID
    %col 3: trial number
    %col 4: Observe (1), Play (2)
    %col 5: goal token
    %col 6: low uncertainty (1), high uncertainty (2)
    %col 7: unavailable action
    %col 8: correct action (also partner's action)
    %col 9: best action
    %col 10: vertOrd (1:G/R/B, 2: R/B/G, 3: B/G/R)
    %col 11: horizOrd (1: G-R-B, 2: R-B-G, 3: B-G-R)
    %col 12: subject choice (1,2,3)
    %col 13: subject choice (coded as 1 for left and 0 for right)
    %col 14: accuracy (subject correct (1) or not (0))
    %col 15: reaction time
    %col 16: token shown
    %col 17: missed trial (1)
    
    i_lu = P(:,6)==1;
    i_play = P(:,4)==2;
    
    V_tok = [NaN(nt,3) P(:,4) NaN(nt,2)];
    V_act = [P(:,8) P(:,7) P(:,4) NaN(nt,2)];
    
    Accuracy(s,:) = [nanmean(P(:,14)) nanmean(P(i_lu,14)) nanmean(P(~i_lu,14))];
    RT(s,:) = [nanmean(P(:,15)) nanmean(P(i_lu,15)) nanmean(P(~i_lu,15))];
    missed(s) = nansum(P(:,17));
    
    c=0;
    b=0;
    em_ch = nan(nt,1); %build vector of choices consistent with emulation
    acc_switch=nan(nt,2);
    for t=1:nt
        if ismember([P(t,2) P(t,3)],tr_switch,'rows') %first play trial after a switch
            acc_switch(t,1)=P(t,14);
        elseif ismember([P(t,2) P(t,3)],tr_no_switch,'rows') %no switch
            acc_switch(t,2)=P(t,14);
        end
        if ismember([P(t,2) P(t,3)],tr_em_corr,'rows') %emulation-correct trial
            if P(t,14)==1 %subject correct
                em_ch(t) = 1;
            elseif P(t,14)==0 %subject incorrect
                em_ch(t) = 0;
            end
        elseif ismember([P(t,2) P(t,3)],tr_im_corr,'rows') %imitation-correct trial
            if P(t,14)==1 %subject correct
                em_ch(t) = 0;
            elseif P(t,14)==0 %subject incorrect
                em_ch(t) = 1;
            end
        elseif ismember([P(t,2) P(t,3)],tr_catch,'rows')
            c=c+1;
            if P(t,14)==1 %subject correct
                acc_catch(s,c) = 1;
            elseif P(t,14)==0 %subject incorrect
                acc_catch(s,c) = 0;
            end
        elseif ismember([P(t,2) P(t,3)],tr_both_corr,'rows')
            b=b+1;
            if P(t,14)==1 %subject correct
                acc_both(s,b)=1;
            elseif P(t,14)==0 %subject incorrect
                acc_both(s,b)=0;
            end
        end    
   

    end
    Acc_switch(s,:) = nanmean(acc_switch);
    EM_prop(s,:) = [nanmean(em_ch) nanmean(em_ch(i_lu)) nanmean(em_ch(~i_lu))];
        
    
end

model_free_measures = [Accuracy,RT,missed,EM_prop,Acc_switch];

save('model_free_analyses_discovery.mat', 'model_free_measures');
