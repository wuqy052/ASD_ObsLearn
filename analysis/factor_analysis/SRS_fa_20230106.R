# SRS questionnaire factor analysis
# data includes mturk + prolific 

library(stats)
library(tidyverse)
library(psych)
library(GPArotation)
library(lavaan)
library(parameters)

# load single question data
SRS_all <- read_csv("/Users/wuqy0214/Documents/psy/OLab/SRS/SRS score/SRS_nonreversed_updated_noNA.csv")
SRS_all$X1 <- NULL
subIDs <- SRS_all$subID

# load final subject inclusion list
inc_list <- read_csv('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.csv')
SRS_final <- subset(SRS_all, SRS_all$subID %in% inc_list$ID)
subIDs_inc <- SRS_final$subID
SRS_final$subID <- NULL
SRS_final$...1 <- NULL

# factor analysis
# parallel analysis
res_parallel <- fa.parallel(SRS_final, fm='minres', fa='fa')
# parallel analysis suggests num_factor  = 8
# promax
SRS.promax <- factanal(SRS_final, factors = 8, rotation = "promax",fm='ml')
# save factor loadings
loading_ori_promax = data.frame(matrix(as.numeric(SRS.promax$loadings), 
                                       attributes(SRS.promax$loadings)$dim, 
                                       dimnames=attributes(SRS.promax$loadings)$dimnames))

print(SRS.promax, digits=3, cutoff = 0.3, sort=TRUE)
print(apply(SRS.promax$loadings^2,1,sum))
# oblimin
SRS.oblimin <- factanal(SRS_final, factors = 8, rotation = "oblimin")
print(SRS.oblimin, digits=3, cutoff = 0.3, sort=TRUE)
print(apply(SRS.oblimin$loadings^2,1,sum))

# factor scores
SRS.promax.scores <- factor.scores(SRS_final, SRS.promax, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
SRS_score_promax <- SRS.promax.scores$scores
SRS_score_promax <- cbind(subIDs_inc, SRS_score_promax)
write.csv(SRS_score_promax, "/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_8_factor_promax_original.csv", row.names=F)

#---------------------------------------------------------------#
# 2023.1.19 Apply the dataset 1 FA scores to the replication data
#---------------------------------------------------------------#
SRS_replicate <- read_csv("/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/questionnaires/SRS_sarah_format.csv")
inc_list_rep <- read_csv('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/sublist_replication.csv')
SRS_rep_final <- subset(SRS_replicate, SRS_replicate$subID %in% inc_list_rep$ID)
subIDs_rep_inc <- SRS_rep_final$subID
SRS_rep_final$subID <- NULL
# apply the transformation
SRS_rep.scores <- factor.scores(SRS_rep_final, SRS.promax, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
SRS_rep_score <- SRS_rep.scores$scores
SRS_rep_score <- cbind(subIDs_rep_inc, SRS_rep_score)
write.csv(SRS_rep_score, "/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_8_ofactor_promax_rep.csv", row.names=F)

# using CFA to assess the model fitting
cfa_mdl <- 'f1 =~ SRS.A_10 + SRS.A_14 + SRS.A_16 + SRS.A_19 + SRS.A_2 + SRS.A_20 + SRS.A_24 + 
SRS.A_28 + SRS.A_30 + SRS.A_31 + SRS.A_39 + SRS.A_4 + SRS.A_41 + SRS.A_42 + 
SRS.A_44 + SRS.A_47 + SRS.A_49 + SRS.A_5 + SRS.A_50 + SRS.A_51 + 
SRS.A_52 + SRS.A_53 + SRS.A_54 + SRS.A_55 + SRS.A_56 + SRS.A_58  + SRS.A_61 +
SRS.A_62 + SRS.A_63 + SRS.A_65 + SRS.A_8 + SRS.A_9
        f2 =~ SRS.A_1 + SRS.A_23 + SRS.A_27 + SRS.A_34 + SRS.A_37 + SRS.A_43 + SRS.A_57 + SRS.A_6 + SRS.A_64
        f3 =~ SRS.A_15 + SRS.A_17 + SRS.A_21 + SRS.A_22 + SRS.A_26 + SRS.A_38 + SRS.A_45 + SRS.A_48 + SRS.A_7
        f4 =~ SRS.A_11 + SRS.A_12 + + SRS.A_3
        f5 =~ SRS.A_13 + SRS.A_18 + SRS.A_33 + SRS.A_35
        f7 =~ SRS.A_25 + SRS.A_29 + SRS.A_40
        f8 =~  SRS.A_46 + SRS.A_59 + SRS.A_60' 
cfa_ori_on_ori = cfa(cfa_mdl,data=SRS_final)
fitmeasures(cfa_ori_on_ori,fit.measures="all",output = "text")
cfa_ori_on_rep = cfa(cfa_mdl,data=SRS_rep_final)
fitmeasures(cfa_ori_on_rep,fit.measures="all",output = "text")
#---------------------------------------------------------------#
# 2023.1.5 Run a new factor analysis using the replication data
#---------------------------------------------------------------#
fa.parallel(SRS_rep_final, fm='minres', fa='fa')
# parallel analysis suggests 6 factors
# promax
SRS_rep.promax <- factanal(SRS_rep_final, factors = 8, rotation = "promax")
print(SRS_rep.promax, digits=3, cutoff = 0.3, sort=TRUE)
print(apply(SRS_rep.promax$loadings^2,1,sum))
# calculate factor score
SRS_rep.ownscores <- factor.scores(SRS_rep_final, SRS_rep.promax, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
SRS_rep_ownscores <- cbind(subIDs_rep_inc, SRS_rep.ownscores$scores)
write.csv(SRS_rep_ownscores, "/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_rep_score_rep_20230106.csv", row.names=F)
# save factor loadings
loading_rep_promax = data.frame(matrix(as.numeric(SRS_rep.promax$loadings), 
                                       attributes(SRS_rep.promax$loadings)$dim, 
                                       dimnames=attributes(SRS_rep.promax$loadings)$dimnames))
#---------------------------------------------------------------#
# 2023.1.6 Compare the factor scores by 2 factor analyses
#---------------------------------------------------------------#
# calculate the correlation between 2 score matrices on the replication data
corr_fas = cor(SRS_rep.scores$scores, SRS_rep.ownscores$scores)
heatmap(corr_fas[order(nrow(corr_fas):1),],Colv = NA, Rowv = NA, scale="column",col = cm.colors(256))
# calculate the correlation between factnal and fa outputs 
i=1
corr_methods = cor(SRS.promax.scores$scores[,i], SRS_promax.scores$scores[,i])
heatmap(corr_methods[order(nrow(corr_methods):1),],Colv = NA, Rowv = NA, scale="column",col = cm.colors(256))

#---------------------------------------------------------------#
# 2023.3.14 iteratively run factor analysis
#---------------------------------------------------------------#

rotation_method = "promax"
rotation_method = "oblimin"
# do factor analysis and simplification until converge
step = 0
input_iter <- SRS_final
items_survive_old <- colnames(SRS_final)
items_survive <- colnames(SRS_final[,1:64])
while (length(items_survive) < length(items_survive_old)) {
  step = step + 1
  items_survive_old <- items_survive
  res_parallel_iter <- fa.parallel(input_iter, fm='minres', fa='fa')
  fa_iter <- factanal(input_iter, factors = res_parallel_iter$nfact, rotation = rotation_method)
  loading_iter = data.frame(matrix(as.numeric(fa_iter$loadings), 
                                   attributes(fa_iter$loadings)$dim, 
                                   dimnames=attributes(fa_iter$loadings)$dimnames))
  # simpify factors
  # 1. identify potential factor for each item based on maximun loading
  factor_assign_initial <- apply(abs(loading_iter), 1, which.max)
  # 2. exclusion criteria: one and only one factor loading (abs) > 0.3
  # 2 cases: 1) none of them >0.3, 2) more than one >0.3
  criteria_split <- apply(abs(loading_iter),1,function(x) sum(x > 0.3)) ==1 
  # 3. intermediate factor assignment
  factor_assign_med <- factor_assign_initial * criteria_split
  # 4. delete those factors with items <= 2
  factor_count <- as.tibble(table(factor_assign_med))
  minor_item <- as.integer(c(0,factor_count$factor_assign_med[c(which (factor_count$n <=2))]))
  # 5. delete all redundant items and factors
  criteria_minor <- !(factor_assign_med %in% minor_item)
  criteria_all <- criteria_split *criteria_minor
  items_survive <- rownames(loading_iter[which(criteria_all==1),])
  input_iter <-  select(SRS_final, items_survive)
}

final_factor_scores <- factor.scores(input_iter, fa_iter, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
write.csv(cbind(subIDs_inc, final_factor_scores$scores), "/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_6_iterfactor_oblimin_original.csv", row.names=F)

# using CFA to assess the model fitting - promax result
cfa_mdl <- 'f1 =~ SRS.A_10 + SRS.A_16 + SRS.A_28 + SRS.A_39 + SRS.A_4 + SRS.A_41 + SRS.A_42 + 
SRS.A_47 + SRS.A_49 + SRS.A_5 + SRS.A_50 + SRS.A_51 + 
SRS.A_52 + SRS.A_58  + SRS.A_61 + SRS.A_62 + SRS.A_9
        f2 =~ SRS.A_1 + SRS.A_23 + SRS.A_27 + SRS.A_57 + SRS.A_6 + SRS.A_64
        f3 =~ SRS.A_15 + SRS.A_17 + SRS.A_21 + SRS.A_22 + SRS.A_26 + SRS.A_38 + SRS.A_45 + SRS.A_48 + SRS.A_7'
cfa_simp = cfa(cfa_mdl,data=SRS_final)
fitmeasures(cfa_simp,fit.measures="all",output = "text")
cfa_ori_on_rep = cfa(cfa_simp,data=SRS_rep_final)
fitmeasures(cfa_ori_on_rep,fit.measures="all",output = "text")

# using CFA to assess the model fitting - oblimin result
cfa_mdl <- 'f1 =~ SRS.A_1 + SRS.A_23 + SRS.A_27 + SRS.A_57 + SRS.A_6 + SRS.A_64
        f2 =~ SRS.A_43 + SRS.A_44 + SRS.A_53 + SRS.A_54 + SRS.A_55 + SRS.A_56 + SRS.A_63 + SRS.A_9
        f3 =~ SRS.A_15 + SRS.A_17 + SRS.A_21 + SRS.A_22 + SRS.A_26 + SRS.A_32 + SRS.A_38 + SRS.A_45 + SRS.A_48 + SRS.A_7
        f4 =~ SRS.A_24 + SRS.A_28 + SRS.A_30 + SRS.A_31 + SRS.A_4 + SRS.A_42 + SRS.A_58 + SRS.A_61
        f5 =~ SRS.A_25 + SRS.A_29 + SRS.A_8 
        f6 =~ SRS.A_13 + SRS.A_14 + SRS.A_19 + SRS.A_35'
cfa_simp = cfa(cfa_mdl,data=SRS_final)
fitmeasures(cfa_simp,fit.measures="all",output = "text")
cfa_ori_on_rep = cfa(cfa_simp,data=SRS_rep_final)
fitmeasures(cfa_ori_on_rep,fit.measures="all",output = "text")