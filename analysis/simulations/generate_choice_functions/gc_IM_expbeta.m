function pred_vals = gc_IM_expbeta(params,tl)
%Imitation model

% params(1): softmax beta [0 +Inf]

tr_nb = height(tl);

%careful, the column indices may change
tr_type  = tl.trType; %obs(1)/play(2)
unav_act = tl.unavAct;
part_act = tl.corrAct; %partner's action (always = correct action)

%initialize variables
val_diff = zeros(tr_nb,1);

P_left   = NaN(tr_nb,1);
pred_ch  = NaN(tr_nb,1);
pred_act = NaN(tr_nb,1);
ll_corr  = NaN(tr_nb,1);
is_corr  = NaN(tr_nb,1);


for t=1:tr_nb       
               
    if tr_type(t)==2 %play trial
        
        UA = unav_act(t); %unavailable action
        PA = part_act(t); %correct action
        AVt = [0 0 0];
        
        %find most recent observe trial in current block where one of the two 
        %currently available actions was chosen
        l = find(tl.runNb==tl.runNb(t) & tl.trialNb<tl.trialNb(t) & tr_type==1 & part_act~=UA);
        if ~isempty(l)
            pred_choice = part_act(l(end));
            AVt(pred_choice) = 1;
        end
        
        AVt(UA)=[]; %isolate the probabilities of the 2 available actions
        val_diff(t) = AVt(1) - AVt(2); %always left minus right difference 
        
        P_left(t) = (1+exp(-params(1)*val_diff(t)))^-1;
        
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
pred_vals = [P_left pred_ch pred_act ll_corr is_corr val_diff];
end