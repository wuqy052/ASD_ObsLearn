# SRS questionnaire factor analysis
# data includes mturk + prolific 
library(stats)
library(tidyverse)
library(psych)
library(GPArotation)
library(lavaan)
library(parameters)

# load SRS item data - discovery sample
setwd("~/Documents/GitHub/ASD_ObsLearn/analysis/factor_analysis") # set your own working directory
SRS_discovery <- read_csv("../../data/Study1/SRS_items_discovery.csv")

# factor analysis
# parallel analysis
res_parallel <- fa.parallel(SRS_discovery, fm='minres', fa='fa')
# parallel analysis suggests num_factor  = 8
# promax
SRS.promax <- factanal(SRS_discovery, factors = 8, rotation = "promax",fm='ml')
# extract factor loadings
loading_ori_promax = data.frame(matrix(as.numeric(SRS.promax$loadings), 
                                       attributes(SRS.promax$loadings)$dim, 
                                       dimnames=attributes(SRS.promax$loadings)$dimnames))

print(SRS.promax, digits=3, cutoff = 0.3, sort=TRUE)
print(apply(SRS.promax$loadings^2,1,sum))

# factor scores
SRS.promax.scores <- factor.scores(SRS_discovery, SRS.promax, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
SRS_score_promax <- SRS.promax.scores$scores
write.csv(SRS_score_promax, "SRS_fa_score_8_factor_promax_discovery.csv", row.names=F)
write.csv(loading_ori_promax,"SRS_fa_loading_8_factor_promax.csv")
#---------------------------------------------------------------#
# Apply the dataset 1 FA scores to the replication data
#---------------------------------------------------------------#
SRS_replication <- read_csv("../../data/Study2/SRS_items_replication.csv")

# apply the transformation
SRS_rep.scores <- factor.scores(SRS_replication, SRS.promax, Phi = NULL, method = c("Thurstone"),rho=NULL,impute="none")
SRS_rep_score <- SRS_rep.scores$scores
write.csv(SRS_rep_score, "SRS_fa_score_8_factor_promax_replication.csv", row.names=F)

#---------------------------------------------------------------#
# using CFA to assess the model fitting
#---------------------------------------------------------------#

cfa_mdl <- 'f1 =~ SRS.A_10 + SRS.A_14 + SRS.A_16 + SRS.A_19 + SRS.A_2 + SRS.A_20 + SRS.A_24 + 
SRS.A_28 + SRS.A_30 + SRS.A_31 + SRS.A_39 + SRS.A_4 + SRS.A_41 + SRS.A_42 + 
SRS.A_44 + SRS.A_47 + SRS.A_49 + SRS.A_5 + SRS.A_50 + SRS.A_51 + 
SRS.A_52 + SRS.A_53 + SRS.A_54 + SRS.A_55 + SRS.A_56 + SRS.A_58  + SRS.A_61 +
SRS.A_62 + SRS.A_63 + SRS.A_65 + SRS.A_8 + SRS.A_9
        f2 =~ SRS.A_1 + SRS.A_23 + SRS.A_27 + SRS.A_34 + SRS.A_37 + SRS.A_43 + SRS.A_57 + SRS.A_6 + SRS.A_64
        f3 =~ SRS.A_15 + SRS.A_17 + SRS.A_21 + SRS.A_22 + SRS.A_26 + SRS.A_38 + SRS.A_45 + SRS.A_48 + SRS.A_7
        f4 =~ SRS.A_11 + SRS.A_12 + + SRS.A_3
        f5 =~ SRS.A_13 + SRS.A_18 + SRS.A_33 + SRS.A_35
        f7 =~ SRS.A_25 + SRS.A_29
        f8 =~  SRS.A_46 + SRS.A_59 + SRS.A_60' 
cfa_dis_on_dis = cfa(cfa_mdl,data=SRS_discovery)
fitmeasures(cfa_dis_on_dis,fit.measures="all",output = "text")
cfa_dis_on_rep = cfa(cfa_mdl,data=SRS_replication)
fitmeasures(cfa_dis_on_rep,fit.measures="all",output = "text")

