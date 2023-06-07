function [f,vals] = LL_IntDynArb(params,P)
%Dynamic reliability-driven arbitration model, with flexible weight of
%uncertainty, allowing for weight assigned to a strategy to increase when
%uncertainty is high
% Action value based, first integrate AV_em and AV_im then do softmax
% plus all baseline
% params: beta (only 1!), eta, bias, w_hand, w_rb, w_g, w_stickyact, w_stickycol

%transform parameters to make sure they are constrained between values that
%make sense, for ex
params(1) = exp(params(1)); % [0, inf] 
% params(2): weight of uncertainty on emulation probability, no transformation 
% params(3): bias, no transformation 
w_hand = params(4); % hand bias weight, no need to transform
w_rb = params(5); % color bias (red vs blue), no need to transform
w_g = params(6); % color bias (green), no need to transform
val_g = 1/(1+exp(-w_g)); % value of green token, bounded between 0 ~ 1
val_rb =2/(1+exp(-w_rb)) -1;% value of red-blue, bounded between -1 ~ 1
val_r = 0.5 * (1 - val_g + val_rb); % value of red
val_b = 0.5 * (1 - val_g - val_rb); % value of blue
colvals = [val_g, val_r, val_b];
w_stickyact = params(7); % sticky stimulus weight, no need to transform
d_stickycol = 0;
w_stickycol = params(8); % sticky stimulus color, no need to transform
d_stickyact  = 0;


lambda = 0.99999;
tr_nb = length(P(:,1));

%initialize variables
prior_V  = zeros(tr_nb,3); %prior token values for BI (each row=trial, each column=token)
V        = zeros(tr_nb,3); %posterior token values for BI (each row=trial, each column=token)
AVbi     = zeros(tr_nb,3); %available action values for BI (each row=trial, each column=action)
w       = zeros(tr_nb,1); %arbitration weight (each row=trial)
entropy = zeros(tr_nb,1); %entropy (each row=trial)
min_ent = zeros(tr_nb,1); %keep track of minimum entropy (each row=trial)
max_ent = zeros(tr_nb,1); %keep track of maximum entropy (each row=trial)
xBI     = zeros(tr_nb,1); %unreliability of BI (each row=trial)
val_diff_all = zeros(tr_nb,1); % joint action value differences
AVbi_diff = zeros(tr_nb,1); % action value difference of emulation
AVim_diff = zeros(tr_nb,1); % action value difference of imitation
stickycol  = zeros(3,1);% sticky color, [green, red, blue]
stickycol_all = zeros(tr_nb,3); % to visualise the sticky stim across time
AVbl = zeros(tr_nb,2); % save the sticky color action value
AVbl_diff = zeros(tr_nb, 1); % stcky color action value difference
choice_col = zeros(tr_nb,1); % the chosen color in each trial
stickyact = [0 0];

%contingencies of the slot machine (each row=token, each column=action)
SM_struct = cell(2,3);
SM_struct{1,1} = [0.75 0.05 0.2; 0.2 0.75 0.05; 0.05 0.2 0.75]; %probability distribution of EASY slot machine (low BU, horizOrd 1)
SM_struct{1,2} = [0.05 0.2 0.75; 0.75 0.05 0.2; 0.2 0.75 0.05]; %probability distribution of EASY slot machine (low BU, horizOrd 2)
SM_struct{1,3} = [0.2 0.75 0.05; 0.05 0.2 0.75; 0.75 0.05 0.2]; %probability distribution of EASY slot machine (low BU, horizOrd 3)
SM_struct{2,1} = [0.5 0.2 0.3; 0.3 0.5 0.2; 0.2 0.3 0.5]; %probability distribution of HARD slot machine (high BU, horizOrd 1)
SM_struct{2,2} = [0.2 0.3 0.5; 0.5 0.2 0.3; 0.3 0.5 0.2]; %probability distribution of HARD slot machine (high BU, horizOrd 2)
SM_struct{2,3} = [0.3 0.5 0.2; 0.2 0.3 0.5; 0.5 0.2 0.3]; %probability distribution of HARD slot machine (high BU, horizOrd 3)
% turn the probability into simple color code
SM_color = cell(2,3);
for i=1:2
    for j=1:3
        for c = 1:3
            [~, SM_color{i,j}(c)] = max(SM_struct{i,j}(:,c));
        end
    end
end

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

%extract relevant columns from P matrix
tr_type  = P(:,4); %obs(1)/play(2)
tr_bu    = P(:,6); %low BU(1)/high BU(2)
unav_act = P(:,7);
part_act = P(:,8); %partner's action (always = correct action)
choice   = P(:,13); %subject's choice (left 1/right 0)
choice_act   = P(:,13); %subject's choice (1: left, 0: right)
choice_stim = P(:, 12); % the chosen stim {1, 2, 3}
iscorr   = P(:,14); %is subject correct (1:yes, 0:no);
hord     = P(:,11); %horizontal order
ismiss = P(:,17);

P_left   = NaN(tr_nb,1);
LH       = NaN(tr_nb,1);
ll_corr  = NaN(tr_nb,1);

for t=1:tr_nb
    
    UA = unav_act(t); %unavailable action #1
    PA = part_act(t); %partner's action
    HO = hord(t); %horizontal order 
    UnchA = [1 2 3];
    UnchA([UA PA]) = []; %unchosen action
    
    if tr_type(t)==1 %observe
        
        %Calculate likelihood of partner's action given slot machine and
        %valuable token
        P_PA_V = P_PA_Tok{UA,HO}(:,PA)'; %each row=token
        
        if P(t,3)==1 %initialize prior on first trial of each block     
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
        %params(2) is the weight of uncertainty on the propensity to emulate
       	%params(3) is the bias towards one strategy over the other
        
    elseif tr_type(t)==2 && (ismiss(t) == 0)%play
        
        %values under bayesian inference model
        prior_V(t,:) = V(t-1,:);
        V(t,:) = prior_V(t,:);

        min_ent(t) = min_ent(t-1);
        max_ent(t) = max_ent(t-1);

        xBI(t) = xBI(t-1);
        w(t) = w(t-1);
                                
        %PART I: EMUL - calculate value of each action by multipyling matrix of slot machine
        %contingencies (token to action mapping) by token values
        AVbi(t,:) = V(t,:)*SM_struct{tr_bu(t),HO};
        AVbi(t,UA)=0; %isolate the probabilities of the 2 available actions
        sca = sum(AVbi(t,:)); 
        if sca == 0
            sca = eps; % eps added to make sure scaling is never 0, otherwise scaled values become NaNs
        end
        AVbi(t,:) = AVbi(t,:)/sca;
        
         % modification:  keep AV but delete AVdiff and Pleft
        AVbi_c = AVbi(t,:);
        AVbi_c(UA) = [];
        AVbi_diff(t) = AVbi_c(1) - AVbi_c(2); % store the AVdiff of emulation
        
        %PART II: IMIT action values
        %find most recent observe trial in current block where one of the two 
        %currently available actions was chosen
        AVim = [0 0 0];
        
        l = find(P(:,1)==P(t,1) & P(:,3)<P(t,3) & tr_type==1 & part_act~=UA);
        if ~isempty(l)
            pred_choice = part_act(l(end));
            AVim(pred_choice) = 1;
        end

       % modification:  keep AV but delete AVdiff and Pleft
        AVim(UA)=[]; %isolate the probabilities of the 2 available actions
        AVim_diff(t) = AVim(1) - AVim(2); % store the AVdiff of imitation
        
        % PART III: baseline sticky color and color bias
        AVbl_t = [0 0 0];
        BU = tr_bu(t); % uncertainty type
        cols = SM_color{BU,HO}; % maximun color for 3 slot machines
        choice_col(t) =cols(choice_stim(t));
        % extract the color stickyness
        stickycol_all(t,:)    = stickycol;
       % update the utility according to sticky color
        for i = 1:3
            AVbl_t(i) =  w_stickycol * stickycol(cols(i)) + colvals(cols(i));
        end
         % decay unchosen color, and update chosen
        stickycol = d_stickycol .*  stickycol;
        stickycol(choice_col(t))= 1;
        
        % PART IV: baseline sticky action and hand bias
        AVbl_t(UA)=[]; %isolate the probabilities of the 2 available actions
        AVbl_t = AVbl_t + w_stickyact * stickyact; % sticky action
       % decay unchosen action, and update chosen
        stickyact = d_stickyact .*  stickyact;
        stickyact(2-choice_act(t))= 1; % if left, th the 1st element updates, if right, the 2nd updates
       % hand bias
        AVbl_t(1) = AVbl_t(1) + w_hand; % left = 1;
        AVbl(t,:) = AVbl_t;
        AVbl_diff(t) = AVbl_t(1) - AVbl_t(2);
        
        % modification: calculate joint AV and P_left
        val_diff_all(t) = AVbi_diff(t) * w(t) + AVim_diff(t) * (1-w(t)) + AVbl_diff(t);
        P_left(t) = (1+exp(-params(1)*val_diff_all(t)))^-1;
        
         %if choice value is 1, use one part of likelihood contribution.
        if choice(t) == 1
            LH(t) = P_left(t);   
            if iscorr(t) == 1
                ll_corr(t) = P_left(t);
            else
                ll_corr(t) = 1 - P_left(t);
            end
        %if choice value is 0, use other part of likelihood contribution    
        elseif choice(t) == 0
            LH(t) = 1-P_left(t);
            if iscorr(t) == 1
                ll_corr(t) = 1 - P_left(t);
            else
                ll_corr(t) = P_left(t);
            end
        end 
        
    end 
end
f = nansum(log(LH + eps)); %negative value of loglikelihood
vals = [LH P_left ll_corr prior_V V AVbi AVbi_diff AVim_diff AVbl_diff val_diff_all xBI w];
end