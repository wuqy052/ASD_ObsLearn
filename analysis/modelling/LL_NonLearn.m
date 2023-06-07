function [f,vals] = LL_NonLearn(params,P)
% The baseline OL model
% only consider 1) left/right bias; 2) color bias 3rd version; 3) sticky action no decay 4) sticky color no decay
% params = [w_hand, w_redvsblue,w_green, w_stickyact, w_stickycol]
% hand bias, color bias (2 parameters), sticky action and sticky color .
% edit 9/21/2022 - remove softmax beta (non-identifiable wrt other 5 parameters)

% Step 1. transform parameters
w_hand = params(1); % hand bias weight, no need to transform
w_rb = params(2); % color bias (red vs blue), no need to transform
w_g = params(3); % color bias (green), no need to transform
val_g = 1/(1+exp(-w_g)); % value of green token, bounded between 0 ~ 1
val_rb =2/(1+exp(-w_rb)) -1;% value of red-blue, bounded between -1 ~ 1
val_r = 0.5 * (1 - val_g + val_rb); % value of red
val_b = 0.5 * (1 - val_g - val_rb); % value of blue
colvals = [val_g, val_r, val_b];
w_stickyact = params(4); % sticky stimulus weight, no need to transform
d_stickycol = 0;
w_stickycol = params(5); % sticky stimulus color, no need to transform
d_stickyact  = 0;

% Step 2. extract important task specifications
tr_nb = length(P(:,1)); % total number of trials, usually 84
%careful, the column indices may change
tr_type  = P(:,4); % trial type, obs(1)/play(2)
tr_bu    = P(:,6); %low BU(1)/high BU(2)
unav_act = P(:,7); % unavailable action, {1, 2, 3}
hord     = P(:,11); %horizontal order
choice_act   = P(:,13); %subject's choice (1: left, 0: right)
choice_stim = P(:, 12); % the chosen stim {1, 2, 3}
iscorr   = P(:,14); %is subject correct (1:yes, 0:no);
ismiss = P(:,17);

% slot machine structure, to extract the color of greatest prob
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

% Step 3. initialize variables
val_diff = zeros(tr_nb,1); % val(left) - val(right)
P_left   = NaN(tr_nb,1); % probability of choosing the left one
LH       = NaN(tr_nb,1); % likelihood
ll_corr  = NaN(tr_nb,1); % likelihood of choosing the correct one
stickycol  = zeros(3,1);% sticky color, [green, red, blue]
stickycol_all = zeros(tr_nb,3); % to visualise the sticky stim across time
AVt_all = zeros(tr_nb,2); % save the action value
choice_col = zeros(tr_nb,1); % the chosen color in each trial
stickyact = [0 0];

% Step 4. Calculate the likelihood trial by trial
for t=1:tr_nb
    %play trial
    if (tr_type(t)==2) && (ismiss(t) == 0)
        %initialize stickystim on first play trial of each block
        
        % Step 4.1 Initialize utility (action value)
        UA = unav_act(t); %unavailable action
        AVt = [0 0 0]; % stimulus utility
        
        % Step 4.2 Sticky color and color bias
        BU = tr_bu(t); % uncertainty type
        HO = hord(t); % horrizontal order
        cols = SM_color{BU,HO}; % maximun color for 3 slot machines
        choice_col(t) =cols(choice_stim(t));
        % extract the color stickyness
        stickycol_all(t,:)    = stickycol;
       % update the utility according to sticky color
        for i = 1:3
            AVt(i) = AVt(i) + w_stickycol * stickycol(cols(i)) +  colvals(cols(i));
        end
         % decay unchosen color, and update chosen
        stickycol = d_stickycol *  stickycol;
        stickycol(choice_col(t))= 1;
        
        % Step 4.3 Calculate final action value
        % add in the hand bias and sticky action
        AVt(UA)=[]; %isolate the probabilities of the 2 available actions
        AVt = AVt + w_stickyact * stickyact; % sticky action
        AVt(1) = AVt(1) + w_hand;% left = 1;
        AVt_all(t,:) = AVt';
         % decay unchosen action, and update chosen
        stickyact = d_stickyact .*  stickyact;
        stickyact(2-choice_act(t))= 1; % if left, th the 1st element updates, if right, the 2nd updates
 
        % Step 4.4 Calculate softmax probability
        % calculate the value difference (between 2 actions)
        val_diff(t) = AVt(1) - AVt(2); %always left minus right difference      
        P_left(t) = (1+exp(-val_diff(t)))^-1;
        % choice likelihood + correct likelihood
        %if choice value is 1, use one part of likelihood contribution.
        if choice_act(t) == 1
            LH(t) = P_left(t);
            if iscorr(t) == 1 % if choose correctly
                ll_corr(t) = P_left(t); % the likelihood of correct choice = the left choice
            else
                ll_corr(t) = 1 - P_left(t);
            end
            %if choice value is 0, use other part of likelihood contribution
        elseif choice_act(t) == 0
            LH(t) = 1-P_left(t);
            if iscorr(t) == 1
                ll_corr(t) = 1 - P_left(t);
            else
                ll_corr(t) = P_left(t);
            end
        end
    end
end

% Step 5. Aggregate the likelihood and outputs
f = nansum(log(LH + eps)); %negative value of loglikelihood
vals = [LH P_left ll_corr val_diff];
end