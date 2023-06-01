clear all
close all

%this is to generate data on both the trial list from the original dataset
%and the replication dataset to check whether any differences in model
%performance arise because of the differences in design between the two
%studies
fs = filesep;
or_tl_path = ['original' fs 'trial_lists'];
rep_tl_path = ['replication' fs 'trial_lists'];
addpath('generate_choice_functions')
ntl = 10; 

%extract and read trial lists in cell
tl_list_s1 = cell(ntl,1);
tl_list_s2 = cell(ntl,1);
for t=1:ntl
    tl_list_s1{t} = readtable([or_tl_path fs 'trial_list_v' num2str(t) '.csv']);
    tl_list_s2{t} = readtable([rep_tl_path fs 'trial_list_v' num2str(t) '.csv']);
end

beta_list = linspace(0.5,30,50);
w_list = linspace(0.01,0.99,50);
eta_list = linspace(-2,3,50); 
bias_list = linspace(-3,3,50);




mean_corr_ArbF_s1 = nan(50,50,50);



mean_corr_ArbF_s2 = nan(50,50,50);

%% generate choice with imitation model
mean_corr_IM_s1 = nan(50,1);
mean_corr_IM_s2 = nan(50,1);

for b=1:50
    param = beta_list(b);
    mean_corr_s1 = nan(ntl,1);
    mean_corr_s2 = nan(ntl,1);
    for t=1:ntl
        %run simulations for original trial lists
        tl = tl_list_s1{t};
        pred_vals = gc_IM_expbeta(param,tl);
        mean_corr_s1(t) = nanmean(pred_vals(:,4));
        %run simulations for replication trial lists
        tl = tl_list_s2{t};
        pred_vals = gc_IM_expbeta(param,tl);
        mean_corr_s2(t) = nanmean(pred_vals(:,4));
    end
    mean_corr_IM_s1(b,1) = mean(mean_corr_s1);
    mean_corr_IM_s2(b,1) = mean(mean_corr_s2);
end

figure;
plot(beta_list',mean_corr_IM_s1,'-g','LineWidth',1.5); hold
plot(beta_list',mean_corr_IM_s2,'-m','LineWidth',1.5);
xlabel('Softmax beta parameter value')
ylabel('Model performance')
ylim([0.5 0.75])
title('IMITATION model')
h = legend({'original','replication'});
title(h,'trial lists')
set(gca,'box','off')


%% generate choice with emulation model
mean_corr_EM_s1 = nan(50,1);
mean_corr_EM_s2 = nan(50,1);

for b=1:50
    param = beta_list(b);
    mean_corr_s1 = nan(ntl,1);
    mean_corr_s2 = nan(ntl,1);
    for t=1:ntl
        %run simulations for original trial lists
        tl = tl_list_s1{t};
        pred_vals = gc_EM_expbeta(param,tl);
        mean_corr_s1(t) = nanmean(pred_vals(:,4));
        %run simulations for replication trial lists
        tl = tl_list_s2{t};
        pred_vals = gc_EM_expbeta(param,tl);
        mean_corr_s2(t) = nanmean(pred_vals(:,4));
    end
    mean_corr_EM_s1(b,1) = mean(mean_corr_s1);
    mean_corr_EM_s2(b,1) = mean(mean_corr_s2);
end

figure;
plot(beta_list',mean_corr_EM_s1,'-g','LineWidth',1.5); hold
plot(beta_list',mean_corr_EM_s2,'-m','LineWidth',1.5);
xlabel('Softmax beta parameter value')
ylabel('Model performance')
title('EMULATION model')
h = legend({'original','replication'});
title(h,'trial lists')
set(gca,'box','off')



%% generate choice with hybrid model
mean_corr_Hyb_b1_s1 = nan(50,1);
mean_corr_Hyb_b1_s2 = nan(50,1);
mean_corr_Hyb_b5_s1 = nan(50,1);
mean_corr_Hyb_b5_s2 = nan(50,1);
mean_corr_Hyb_b10_s1 = nan(50,1);
mean_corr_Hyb_b10_s2 = nan(50,1);
mean_corr_Hyb_b20_s1 = nan(50,1);
mean_corr_Hyb_b20_s2 = nan(50,1);

for b=1:50
    wp = w_list(b);
    mean_corr_b1_s1 = nan(ntl,1);
    mean_corr_b1_s2 = nan(ntl,1);
    mean_corr_b5_s1 = nan(ntl,1);
    mean_corr_b5_s2 = nan(ntl,1);
    mean_corr_b10_s1 = nan(ntl,1);
    mean_corr_b10_s2 = nan(ntl,1);
    mean_corr_b20_s1 = nan(ntl,1);
    mean_corr_b20_s2 = nan(ntl,1);
    for t=1:ntl
        %run simulations for original trial lists
        tl = tl_list_s1{t};
        %beta=1
        pred_vals = gc_Hyb_AV_expbeta([1 wp],tl);
        mean_corr_b1_s1(t) = nanmean(pred_vals(:,4));
        %beta=5
        pred_vals = gc_Hyb_AV_expbeta([5 wp],tl);
        mean_corr_b5_s1(t) = nanmean(pred_vals(:,4));
        %beta=10
        pred_vals = gc_Hyb_AV_expbeta([10 wp],tl);
        mean_corr_b10_s1(t) = nanmean(pred_vals(:,4));
        %beta=20
        pred_vals = gc_Hyb_AV_expbeta([20 wp],tl);
        mean_corr_b20_s1(t) = nanmean(pred_vals(:,4));
        
        %run simulations for replication trial lists
        tl = tl_list_s2{t};
        %beta=1
        pred_vals = gc_Hyb_AV_expbeta([1 wp],tl);
        mean_corr_b1_s2(t) = nanmean(pred_vals(:,4));
        %beta=5
        pred_vals = gc_Hyb_AV_expbeta([5 wp],tl);
        mean_corr_b5_s2(t) = nanmean(pred_vals(:,4));
        %beta=10
        pred_vals = gc_Hyb_AV_expbeta([10 wp],tl);
        mean_corr_b10_s2(t) = nanmean(pred_vals(:,4));
        %beta=20
        pred_vals = gc_Hyb_AV_expbeta([20 wp],tl);
        mean_corr_b20_s2(t) = nanmean(pred_vals(:,4));
    end
    mean_corr_Hyb_b1_s1(b,1) = mean(mean_corr_b1_s1);
    mean_corr_Hyb_b1_s2(b,1) = mean(mean_corr_b1_s2);
    mean_corr_Hyb_b5_s1(b,1) = mean(mean_corr_b5_s1);
    mean_corr_Hyb_b5_s2(b,1) = mean(mean_corr_b5_s2);
    mean_corr_Hyb_b10_s1(b,1) = mean(mean_corr_b10_s1);
    mean_corr_Hyb_b10_s2(b,1) = mean(mean_corr_b10_s2);
    mean_corr_Hyb_b20_s1(b,1) = mean(mean_corr_b20_s1);
    mean_corr_Hyb_b20_s2(b,1) = mean(mean_corr_b20_s2);
end

figure;
subplot(2,2,1); hold on
plot(w_list',mean_corr_Hyb_b1_s1,'-g','LineWidth',1.5); 
plot(w_list',mean_corr_Hyb_b1_s2,'-m','LineWidth',1.5);
xlabel('Weight (EM>IM) parameter value')
ylabel('Model performance')
ylim([0.5 0.75])
title('HYBRID model (softmax beta = 1)')
subplot(2,2,2); hold on
plot(w_list',mean_corr_Hyb_b5_s1,'-g','LineWidth',1.5); 
plot(w_list',mean_corr_Hyb_b5_s2,'-m','LineWidth',1.5);
xlabel('Weight (EM>IM) parameter value')
ylabel('Model performance')
ylim([0.5 0.75])
title('HYBRID model (softmax beta = 5)')
subplot(2,2,3); hold on
plot(w_list',mean_corr_Hyb_b10_s1,'-g','LineWidth',1.5); 
plot(w_list',mean_corr_Hyb_b10_s2,'-m','LineWidth',1.5);
xlabel('Weight (EM>IM) parameter value')
ylabel('Model performance')
ylim([0.5 0.75])
title('HYBRID model (softmax beta = 10)')
subplot(2,2,4); hold on
plot(w_list',mean_corr_Hyb_b20_s1,'-g','LineWidth',1.5); 
plot(w_list',mean_corr_Hyb_b20_s2,'-m','LineWidth',1.5);
xlabel('Weight (EM>IM) parameter value')
ylabel('Model performance')
ylim([0.5 0.75])
title('HYBRID model (softmax beta = 20)')
h = legend({'original','replication'});
title(h,'trial lists')



%% generate choice with dyn arb model
mean_corr_ArbF_b1_s1 = nan(50,50);
mean_corr_ArbF_b1_s2 = nan(50,50);
mean_corr_ArbF_b5_s1 = nan(50,50);
mean_corr_ArbF_b5_s2 = nan(50,50);
mean_corr_ArbF_b10_s1 = nan(50,50);
mean_corr_ArbF_b10_s2 = nan(50,50);
mean_corr_ArbF_b20_s1 = nan(50,50);
mean_corr_ArbF_b20_s2 = nan(50,50);

for e=1:50
    e
    eta = eta_list(e);
    for b=1:50
        bias = bias_list(b);
        mean_corr_b1_s1 = nan(ntl,1);
        mean_corr_b1_s2 = nan(ntl,1);
        mean_corr_b5_s1 = nan(ntl,1);
        mean_corr_b5_s2 = nan(ntl,1);
        mean_corr_b10_s1 = nan(ntl,1);
        mean_corr_b10_s2 = nan(ntl,1);
        mean_corr_b20_s1 = nan(ntl,1);
        mean_corr_b20_s2 = nan(ntl,1);
        for t=1:ntl
            %run simulations for original trial lists
            tl = tl_list_s1{t};
            %beta=1
            pred_vals = gc_ArbF_AV_expbeta([1 eta bias],tl);
            mean_corr_b1_s1(t) = nanmean(pred_vals(:,4));
            %beta=5
            pred_vals = gc_ArbF_AV_expbeta([5 eta bias],tl);
            mean_corr_b5_s1(t) = nanmean(pred_vals(:,4));
            %beta=10
            pred_vals = gc_ArbF_AV_expbeta([10 eta bias],tl);
            mean_corr_b10_s1(t) = nanmean(pred_vals(:,4));
            %beta=20
            pred_vals = gc_ArbF_AV_expbeta([20 eta bias],tl);
            mean_corr_b20_s1(t) = nanmean(pred_vals(:,4));

            %run simulations for replication trial lists
            tl = tl_list_s2{t};
            %beta=1
            pred_vals = gc_ArbF_AV_expbeta([1 eta bias],tl);
            mean_corr_b1_s2(t) = nanmean(pred_vals(:,4));
            %beta=5
            pred_vals = gc_ArbF_AV_expbeta([5 eta bias],tl);
            mean_corr_b5_s2(t) = nanmean(pred_vals(:,4));
            %beta=10
            pred_vals = gc_ArbF_AV_expbeta([10 eta bias],tl);
            mean_corr_b10_s2(t) = nanmean(pred_vals(:,4));
            %beta=20
            pred_vals = gc_ArbF_AV_expbeta([20 eta bias],tl);
            mean_corr_b20_s2(t) = nanmean(pred_vals(:,4));
        end
        mean_corr_ArbF_b1_s1(e,b) = mean(mean_corr_b1_s1);
        mean_corr_ArbF_b1_s2(e,b) = mean(mean_corr_b1_s2);
        mean_corr_ArbF_b5_s1(e,b) = mean(mean_corr_b5_s1);
        mean_corr_ArbF_b5_s2(e,b) = mean(mean_corr_b5_s2);
        mean_corr_ArbF_b10_s1(e,b) = mean(mean_corr_b10_s1);
        mean_corr_ArbF_b10_s2(e,b) = mean(mean_corr_b10_s2);
        mean_corr_ArbF_b20_s1(e,b) = mean(mean_corr_b20_s1);
        mean_corr_ArbF_b20_s2(e,b) = mean(mean_corr_b20_s2);
    end
end

clims = [0.5 0.75];
figure;
subplot(2,4,1); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b1_s1,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, original, beta=1')
subplot(2,4,2); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b5_s1,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, original, beta=5')
subplot(2,4,3); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b10_s1,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, original, beta=10')
subplot(2,4,4); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b20_s1,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, original, beta=20')
subplot(2,4,5); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b1_s2,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, replication, beta=1')
subplot(2,4,6); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b5_s2,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, replication, beta=5')
subplot(2,4,7); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b10_s2,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, replication, beta=10')
subplot(2,4,8); hold on
imagesc(bias_list,eta_list,mean_corr_ArbF_b20_s2,clims); colorbar
xlabel('bias (EM>IM)'); ylabel('eta parameter'); xlim([-3 3]); ylim([-2 3]); 
title('DYN ARB model, replication, beta=20')

%% compare Fix vs Dyn Arb
mean_corr_b1 = nan(50,6);
mean_corr_b10 = nan(50,6);

for b=1:50
    b
    bias = bias_list(b);
    wp = w_list(b);
    corr_b1 = nan(ntl,6);
    corr_b10 = nan(ntl,6);

    for t=1:ntl
        %run simulations for original trial lists
        tl = tl_list_s1{t};
        %beta=1, FixArb
        pred_vals = gc_Hyb_AV_expbeta([1 wp],tl);
        corr_b1(t,1) = nanmean(pred_vals(:,4));
        %beta=1, eta=-1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([1 -1.5 bias],tl);
        corr_b1(t,2) = nanmean(pred_vals(:,4));
        %beta=1, eta=1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([1 1.5 bias],tl);
        corr_b1(t,3) = nanmean(pred_vals(:,4));
        %beta=10, FixArb
        pred_vals = gc_Hyb_AV_expbeta([10 wp],tl);
        corr_b10(t,1) = nanmean(pred_vals(:,4));
        %beta=10, eta=-1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([10 -1.5 bias],tl);
        corr_b10(t,2) = nanmean(pred_vals(:,4));
        %beta=10, eta=1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([10 1.5 bias],tl);
        corr_b10(t,3) = nanmean(pred_vals(:,4));

        %run simulations for replication trial lists
        tl = tl_list_s2{t};
        %beta=1, FixArb
        pred_vals = gc_Hyb_AV_expbeta([1 wp],tl);
        corr_b1(t,4) = nanmean(pred_vals(:,4));
        %beta=1, eta=-1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([1 -1.5 bias],tl);
        corr_b1(t,5) = nanmean(pred_vals(:,4));
        %beta=1, eta=1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([1 1.5 bias],tl);
        corr_b1(t,6) = nanmean(pred_vals(:,4));
        %beta=10, FixArb
        pred_vals = gc_Hyb_AV_expbeta([10 wp],tl);
        corr_b10(t,4) = nanmean(pred_vals(:,4));
        %beta=10, eta=-1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([10 -1.5 bias],tl);
        corr_b10(t,5) = nanmean(pred_vals(:,4));
        %beta=10, eta=1.5, DynArb
        pred_vals = gc_ArbF_AV_expbeta([10 1.5 bias],tl);
        corr_b10(t,6) = nanmean(pred_vals(:,4));
    end
    mean_corr_b1(b,:) = mean(corr_b1);
    mean_corr_b10(b,:) = mean(corr_b10);
end

figure;
subplot(2,2,1); hold on
plot(w_list',mean_corr_b1(:,1),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b1(:,2),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b1(:,3),'-','LineWidth',1.5); 
xlabel('Weight/Bias towards Emulation')
ylabel('Model performance')
ylim([0.5 0.75])
title('Original (softmax beta = 1)')
subplot(2,2,2); hold on
plot(w_list',mean_corr_b10(:,1),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b10(:,2),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b10(:,3),'-','LineWidth',1.5); 
xlabel('Weight/Bias towards Emulation')
ylabel('Model performance')
ylim([0.5 0.75])
title('Original (softmax beta = 10)')
subplot(2,2,3); hold on
plot(w_list',mean_corr_b1(:,4),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b1(:,5),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b1(:,6),'-','LineWidth',1.5); 
xlabel('Weight/Bias towards Emulation')
ylabel('Model performance')
ylim([0.5 0.75])
title('Replication (softmax beta = 1)')
subplot(2,2,4); hold on
plot(w_list',mean_corr_b10(:,4),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b10(:,5),'-','LineWidth',1.5); 
plot(w_list',mean_corr_b10(:,6),'-','LineWidth',1.5); 
xlabel('Weight/Bias towards Emulation')
ylabel('Model performance')
ylim([0.5 0.75])
title('Replication (softmax beta = 10)')
h = legend({'FixArb','DynArb (eta=-1.5)','DynArb (eta=1.5)'});
title(h,'model')
    


%for more informative simulations, probably easier to plots continuous
%graphs/heatmap of how accuracy changes with parameter values, averaged
%across all trial lists from one study