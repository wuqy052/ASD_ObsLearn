function pred_vals = gc_NonLearn(params,tl)
% The baseline OL model
% only consider 1) left/right bias; 2) color bias ; 3) sticky action no decay 4) sticky color no decay
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
w_stickyact = params(4); % sticky action weight, no need to transform
w_stickycol = params(5); % sticky stimulus color, no need to transform

tr_nb = height(tl);

%initialize variables
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

%extract relevant columns from tl matrix
tr_type  = tl.trType; %obs(1)/play(2)
tr_bu    = tl.uncertainty; %low BU(1)/high BU(2)
unav_act = tl.unavAct;
part_act = tl.corrAct; %partner's action (always = correct action)
hord     = tl.horizOrd; %horizontal order

P_left   = NaN(tr_nb,1);
pred_ch  = NaN(tr_nb,1); % the choice left/right (1/0)
pred_act = NaN(tr_nb,1); % the chosen slot machine: [left, midle, right] (1/2/3)
ll_corr  = NaN(tr_nb,1);
is_corr  = NaN(tr_nb,1);

for t=1:tr_nb
    
    UA = unav_act(t); %unavailable action
    PA = part_act(t); %partner's action/correct action
    HO = hord(t); %horizontal order 
    
    if tr_type(t)==2 %play
        
        % PART I: baseline sticky color and color bias
        AVbl_t = [0 0 0];
        BU = tr_bu(t); % uncertainty type
        cols = SM_color{BU,HO}; % maximun color for 3 slot machines
        % extract the color stickyness
        stickycol_all(t,:) = stickycol;
       % update the utility according to sticky color
        for i = 1:3
            AVbl_t(i) =  w_stickycol * stickycol(cols(i)) + colvals(cols(i));
        end

        % PART II: baseline sticky action and hand bias
        AVbl_t(UA)=[]; %isolate the probabilities of the 2 available actions
        AVbl_t = AVbl_t + w_stickyact * stickyact; % sticky action
       % hand bias
        AVbl_t(1) = AVbl_t(1) + w_hand; % left = 1;
     
        AVbl(t,:) = AVbl_t;
        AVbl_diff(t) = AVbl_t(1) - AVbl_t(2);
        
        % calculate P_left
        P_left(t) = (1+exp(-AVbl_diff(t)))^-1;
        
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
        
        % update the sticky action (left = 0, right = 1)
        % decay unchosen action, and update chosen
        stickyact = [0 0];
        stickyact(2-pred_ch(t))= 1; % if left, th the 1st element updates, if right, the 2nd updates

        % update the sticky color
        % decay unchosen color, and update chosen
        choice_col(t) =cols(pred_act(t));
        stickycol = [0 0 0];
        stickycol(choice_col(t))= 1;

    end 
end
pred_vals = [P_left pred_ch pred_act ll_corr is_corr AVbl_diff choice_col];
end