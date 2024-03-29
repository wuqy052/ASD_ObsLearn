function pred_vals = gc_DynArb(params,tl)
%Dynamic reliabilit-driven arbitration model, with flexible weight of
%uncertainty, allowing for weight assigned to a strategy to increase when
%uncertainty is high
%this model arbitrates between action values instead of arbitrating between
%choice probabilities, therefore it only includes 1 beta parameter.

%transform parameters to make sure they are constrained between values that
%make sense, for ex
% params(1): decision softmax beta [0 +Inf]
% params(2): weight of uncertainty on emulation probability, no transformation 
% params(3): bias, no transformation 

lambda = 0.99999;
tr_nb = height(tl);

%initialize variables
prior_V  = zeros(tr_nb,3); %prior token values for emulation (each row=trial, each column=token)
V        = zeros(tr_nb,3); %posterior token values for emulation (each row=trial, each column=token)
AVbi     = zeros(tr_nb,3); %action values for emulation (each row=trial, each column=action)
AVim     = zeros(tr_nb,3); %action values for imitation (each row=trial, each column=action)
AV       = zeros(tr_nb,3); %integrated action values
w       = zeros(tr_nb,1); %arbitration weight (each row=trial)
entropy = zeros(tr_nb,1); %entropy (each row=trial)
min_ent = zeros(tr_nb,1); %keep track of minimum entropy (each row=trial)
max_ent = zeros(tr_nb,1); %keep track of maximum entropy (each row=trial)
xBI     = zeros(tr_nb,1); %unreliability of emulation (each row=trial)

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

%extract relevant columns from tl matrix
tr_type  = tl.trType; %obs(1)/play(2)
tr_bu    = tl.uncertainty; %low BU(1)/high BU(2)
unav_act = tl.unavAct;
part_act = tl.corrAct; %partner's action (always = correct action)
hord     = tl.horizOrd; %horizontal order

P_left   = NaN(tr_nb,1);
pred_ch  = NaN(tr_nb,1);
pred_act = NaN(tr_nb,1);
ll_corr  = NaN(tr_nb,1);
is_corr  = NaN(tr_nb,1);

for t=1:tr_nb
    
    UA = unav_act(t); %unavailable action
    PA = part_act(t); %partner's action/correct action
    HO = hord(t); %horizontal order 
    UnchA = [1 2 3];
    UnchA([UA PA]) = []; %unchosen action
    
    if tr_type(t)==1 %observe
        
        %Calculate likelihood of partner's action given slot machine and
        %valuable token
        P_PA_V = P_PA_Tok{UA,HO}(:,PA)'; %each row=token
        
        if tl.trialNb(t)==1 %initialize prior on first trial of each block     
            prior_V(t,:) = [1/3 1/3 1/3];
        else %no switch possible on first trial
            prior_V(t,1) = lambda*V(t-1,1) + (1-lambda)*(1/2)*(V(t-1,2) + V(t-1,3));
            prior_V(t,2) = lambda*V(t-1,2) + (1-lambda)*(1/2)*(V(t-1,1) + V(t-1,3));
            prior_V(t,3) = lambda*V(t-1,3) + (1-lambda)*(1/2)*(V(t-1,1) + V(t-1,2));
        end

        %baysian update prior * likelihood
        V(t,:) = prior_V(t,:).*P_PA_V;

        %scale probas such that Vg(t) + Vr(t) + Vb(t) = 1
        scaling = sum(V(t,:)); 
        if scaling == 0
            scaling = eps; % eps added to make sure scaling is never 0, otherwise scaled values become NaNs
        end
        V(t,:) = V(t,:)/scaling;
        
        %BI - calculate value of each action by multipyling matrix of slot machine
        %contingencies (token to action mapping) by token values
        AVbi(t,:) = V(t,:)*SM_struct{tr_bu(t),HO};
        AVbi(t,UA)=0; %isolate the probabilities of the 2 available actions
        sca = sum(AVbi(t,:)); 
        if sca == 0
            sca = eps; % eps added to make sure scaling is never 0, otherwise scaled values become NaNs
        end
        AVbi(t,:) = AVbi(t,:)/sca;
                        
        %Calculate unreliability of Bayesian model
        %first calculate entropy
        if sum(AVbi(t,[PA UnchA]))~=0
            entropy(t) = -(sum(AVbi(t,[PA UnchA]).*log2(AVbi(t,[PA UnchA]))));
        else
            entropy(t) = 0;
        end

        %unreliability based on min/max normalized entropy
        if t==1
            min_ent(t) = 0.5;
            max_ent(t) = 0.8; 
            if entropy(t)<min_ent(t)
                min_ent(t) = entropy(t);
            elseif entropy(t)>max_ent(t)
                max_ent(t) = entropy(t);
            end
        else
            if entropy(t)<min_ent(t-1) %if entropy is smaller than previous min_ent then it becomes the new min
                min_ent(t) = entropy(t);
            else
                min_ent(t) = min_ent(t-1);
            end
            if entropy(t)>max_ent(t-1) %if ent is larger than previous max_ent then it becomes the new max
                max_ent(t) = entropy(t);
            else
                max_ent(t) = max_ent(t-1);
            end
        end
        if max_ent(t)>min_ent(t)
            xBI(t) = (entropy(t)-min_ent(t))/(max_ent(t)-min_ent(t));
        else
            xBI(t) = 0;
        end
        
        %Calculate arbitration weight (p(BI))
        %Difference in reliability pushed through a sigmoid to bound  the value between 0-->1
        uEM = 2*xBI(t)-1; %transform uncertainty so that it ranges between -1 and 1.
        w(t) = (1+exp(-(params(2)*uEM + params(3))))^-1; 
        %params(3) is the weight of uncertainty on the propensity to emulate
       	%params(4) is the bias towards one strategy over the other
        
    elseif tr_type(t)==2 %play
        
        %values under bayesian inference model
        prior_V(t,:) = V(t-1,:);
        V(t,:) = prior_V(t,:);

        min_ent(t) = min_ent(t-1);
        max_ent(t) = max_ent(t-1);

        xBI(t) = xBI(t-1);
        w(t) = w(t-1);
                                
        %EMUL - calculate value of each action by multipyling matrix of slot machine
        %contingencies (token to action mapping) by token values
        AVbi(t,:) = V(t,:)*SM_struct{tr_bu(t),HO};
        AVbi(t,UA)=0; %isolate the probabilities of the 2 available actions
        sca = sum(AVbi(t,:)); 
        if sca == 0
            sca = eps; % eps added to make sure scaling is never 0, otherwise scaled values become NaNs
        end
        AVbi(t,:) = AVbi(t,:)/sca;
        
        %IMIT action values
        %find most recent observe trial in current block where one of the two 
        %currently available actions was chosen
        l = find(tl.runNb==tl.runNb(t) & tl.trialNb<tl.trialNb(t) & tr_type==1 & part_act~=UA);
        if ~isempty(l)
            pred_choice = part_act(l(end));
            AVim(t,pred_choice) = 1;
        end
        
        AV(t,:) = w(t)*AVbi(t,:) + (1-w(t))*AVim(t,:);
        AVf = AV(t,:);
        AVf(UA) = []; %isolate the 2 available actions
        P_left(t) = (1+exp(-params(1)*(AVf(1) - AVf(2))))^-1;
        
        %generate choice
        n=rand();
        if n<=P_left(t)
            pred_ch(t) = 1; %left
            if UA==1
                pred_act(t) = 2;
            else
                pred_act(t) = 1;
            end
        else
            pred_ch(t) = 0; %right
            if UA==3
                pred_act(t) = 2;
            else
                pred_act(t) = 3;
            end
        end
        if pred_act(t) == PA
            is_corr(t) = 1;
            if pred_ch(t) == 1
                ll_corr(t) = P_left(t);
            elseif pred_ch(t) == 0
                ll_corr(t) = 1-P_left(t);
            end  
        else
            is_corr(t) = 0;
            if pred_ch(t) == 1
                ll_corr(t) = 1-P_left(t);
            elseif pred_ch(t) == 0
                ll_corr(t) = P_left(t);
            end  
        end       
    end 
end
pred_vals = [P_left pred_ch pred_act ll_corr is_corr prior_V V AVbi AVim AV xBI w];
end