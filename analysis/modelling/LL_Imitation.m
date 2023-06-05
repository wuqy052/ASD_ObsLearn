function [f,vals] = LL_IM_expbeta(params,P)
%Imitation model

params(1) = exp(params(1)); % softmax beta [0 +Inf]

tr_nb = length(P(:,1));

%careful, the column indices may change
tr_type  = P(:,4); %obs(1)/play(2)
unav_act = P(:,7);
part_act = P(:,8); %partner's action (always = correct action)
choice   = P(:,13); %subject's choice (1: left, 0: right)
iscorr   = P(:,14); %is subject correct (1:yes, 0:no);

%initialize variables
val_diff = zeros(tr_nb,1);

P_left   = NaN(tr_nb,1);
LH       = NaN(tr_nb,1);
ll_corr  = NaN(tr_nb,1);

for t=1:tr_nb       
               
    if tr_type(t)==2 %play trial
        
        UA = unav_act(t); %unavailable action
        AVt = [0 0 0];
        
        %find most recent observe trial in current block where one of the two 
        %currently available actions was chosen
        l = find(P(:,1)==P(t,1) & P(:,3)<P(t,3) & tr_type==1 & part_act~=UA);
        if ~isempty(l)
            pred_choice = part_act(l(end));
            AVt(pred_choice) = 1;
        end
        
        AVt(UA)=[]; %isolate the probabilities of the 2 available actions
        val_diff(t) = AVt(1) - AVt(2); %always left minus right difference 
        
        P_left(t) = (1+exp(-params(1)*val_diff(t)))^-1;
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
vals = [LH P_left ll_corr val_diff];
end