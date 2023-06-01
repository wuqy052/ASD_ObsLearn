library(psych)
library(dplyr)
library(nFactors)
library(corrplot)
library(ggplot2)
library(stringr)
library(gridExtra)
library(paran)
library(EFA.dimensions)
library(reshape2)

rm(list = ls())

# set working directory
setwd('C:/Users/Caroline/Box/Post-doc Projects/OL_EL_arbitration/analyses_for_paper_Oct2022/pooled_analyses/factor_analyses')

# define a function for plotting factor loadings
plot_factor <- function(df_loadings, x, y, title) {
  p_f <- ggplot(df_loadings) +
    geom_bar(aes(x = x, y = y, fill=Questionnaire), colour="black", size=0.1, stat="identity") +
    geom_hline(yintercept = 0) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.key.size = unit(.6, "lines"),
          axis.line.x = element_blank(), 
          axis.ticks.x = element_blank(),
          axis.title.x = element_blank(),
          axis.text.x.bottom =element_blank(),
          panel.grid = element_blank()) +
    ggtitle(title) +
    ylab("Loading Strength") +
    scale_fill_brewer(palette="Pastel1")
  return(p_f)
}

plot_factor_nolegend <- function(df_loadings, x, y, title) {
  p_f <- ggplot(df_loadings) +
    geom_bar(aes(x = x, y = y, fill=Questionnaire), colour="black", size=0.1, stat="identity", show.legend = FALSE) +
    geom_hline(yintercept = 0) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.position = "none",
          axis.line.x = element_blank(), 
          axis.ticks.x = element_blank(),
          axis.title.x = element_blank(),
          axis.text.x.bottom =element_blank(),
          panel.grid = element_blank()) +
    ggtitle(title) +
    ylab("Loading Strength") +
    scale_fill_brewer(palette="Pastel1")
  return(p_f)
}

#function for calculating p-values of correlation matrix
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}


# load the data
csv_fname = 'total_items.csv'
all_data = read.csv(csv_fname)

# exclusion
exclusion = read.csv('Careless_Exclusion.csv')
exc = exclusion[c("subID_prolific","excluded2")]
all_data = merge(all_data, exc, by="subID_prolific")

data = all_data[all_data$excluded2==FALSE,]
id_list = data$subID_prolific
rownames(data) <- data$subID_prolific
data$subID_prolific <- NULL
data$batch <- NULL
data$excluded2 <- NULL

# correlation matrix & eigenvalues for factor analysis
corr_mat = cor(data, use="pairwise")
scree(corr_mat)
eigens = eigen(corr_mat)

# factor selection: Cattell-Nelson-Gorsuch (CNG) test
nfactors = nCng(eigens$values)

# initialize data frame for comparing models with different number of factors
df_mod_comp <- as.data.frame(matrix(nrow=20,ncol=13))
colnames(df_mod_comp) <- c("nFactors","rms","crms","TLI","RMSEA","Fit","FitOff","BIC","chi2","df","chi2-diff","df-diff","sig_threshold_001")
for (nf in 1:20) {
  print(nf)
  fa_model_wls = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')
  if (nf==1) {
    df_mod_comp[nf,] = c(nf, fa_model_wls$rms, fa_model_wls$crms, fa_model_wls$TLI, as.numeric(fa_model_wls$RMSEA[1]), fa_model_wls$fit, fa_model_wls$fit.off,
                         fa_model_wls$BIC, fa_model_wls$chi, fa_model_wls$dof, NA, NA, NA)
  } else {
    df_mod_comp[nf,] = c(nf, fa_model_wls$rms, fa_model_wls$crms, fa_model_wls$TLI, as.numeric(fa_model_wls$RMSEA[1]), fa_model_wls$fit, fa_model_wls$fit.off,
                         fa_model_wls$BIC, fa_model_wls$chi, fa_model_wls$dof, chi_prev-fa_model_wls$chi, df_prev-fa_model_wls$dof, qchisq(0.001,df_prev-fa_model_wls$dof,lower.tail=FALSE))
  }
  chi_prev = fa_model_wls$chi
  df_prev = fa_model_wls$dof
}
write.csv(x=df_mod_comp, file='FA_model_comparison_wls.csv')
#TLI: Tucker Lewis fit index, typically reported in SEM. Generally want > .9
#RMSEA: Root mean square error of approximation. Also reported is the so-called 'test of close fit'
#FitOff: Fit based upon off diagonal values: you can think of it as 1 - resid^2 / cor^2, or a kind of R2 applied to a correlation matrix instead of raw data
#BIC: Useful for model comparison purposes only.
#SABIC: sample-size corrected BIC


# run from nF=2 to nF=8 and save results

# factor analysis (nfactors = 2)
nf=2
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")

png(filename = 'loading_strength_excl_2F.png', width = 1000, height = 800, res = 200)
grid.arrange(p_f1, p_f2)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_2F.csv')

# factor analysis (nfactors = 3)
nf=3
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")

png(filename = 'loading_strength_excl_3F.png', width = 1000, height = 1000, res = 200)
grid.arrange(p_f1, p_f2, p_f3)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_3F.csv')

### Repeat with 4 factors
nf=4
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS4, "Factor 4")

png(filename = 'loading_strength_excl_4F.png', width = 1000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, ncol=1)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_4F.csv')

### Repeat with 5 factors
nf=5
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS5, "Factor 5")

png(filename = 'loading_strength_excl_5F.png', width = 1000, height = 1400, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, ncol=1)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_5F.csv')


### Repeat with 6 factors
nf=6
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS6, "Factor 6")

png(filename = 'loading_strength_excl_6F.png', width = 2000, height = 1000, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, ncol=2)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_6F.csv')


### Repeat with 7 factors
nf=7
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS6, "Factor 6")
p_f7 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS7, "Factor 7")

png(filename = 'loading_strength_excl_7F.png', width = 2000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, p_f7, ncol=2)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_7F.csv')


### Repeat with 8 factors
nf=8
fa_model = fa(data, nfactors = nf, fm='wls', rotate = 'oblimin')

df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))
write.csv(x=df_loadings, file='factor_loadings_8F.csv')

p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS6, "Factor 6")
p_f7 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS7, "Factor 7")
p_f8 <- plot_factor(df_loadings, df_loadings$q, df_loadings$WLS8, "Factor 8")

png(filename = 'loading_strength_excl_8F.png', width = 2000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, p_f7, p_f8, ncol=2)
dev.off()

indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
indiv_scores$subID_prolific = id_list
write.csv(x=indiv_scores, file='factor_scores_excl_8F.csv')

corrplot(cor(df_loadings[,1:8]),method='number',type='upper',tl.col="black", tl.srt=45)

#correlation matrix of loadings across items
M <- cor(df_loadings[,1:nf])
p.mat <- cor.mtest(df_loadings[,1:nf])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45,
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)
#correlation matrix of scores across subjects
M <- cor(indiv_scores[,1:nf])
p.mat <- cor.mtest(indiv_scores[,1:nf])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45,
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)














#try model comparison with other fit methods
df_mod_comp <- as.data.frame(matrix(nrow=20,ncol=13))
colnames(df_mod_comp) <- c("nFactors","rms","crms","TLI","RMSEA","Fit","FitOff","BIC","chi2","df","chi2-diff","df-diff","sig_threshold_001")
for (nf in 1:20) {
  print(nf)
  fa_model = fa(data, nfactors = nf, fm='ml', rotate = 'oblimin')
  if (nf==1) {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, NA, NA, NA)
  } else {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, chi_prev-fa_model$chi, df_prev-fa_model$dof, qchisq(0.001,df_prev-fa_model$dof,lower.tail=FALSE))
  }
  chi_prev = fa_model$chi
  df_prev = fa_model$dof
}
write.csv(x=df_mod_comp, file='FA_model_comparison_ml.csv')

df_mod_comp <- as.data.frame(matrix(nrow=20,ncol=13))
colnames(df_mod_comp) <- c("nFactors","rms","crms","TLI","RMSEA","Fit","FitOff","BIC","chi2","df","chi2-diff","df-diff","sig_threshold_001")
for (nf in 1:20) {
  print(nf)
  fa_model = fa(data, nfactors = nf, fm='pa', rotate = 'oblimin')
  if (nf==1) {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, NA, NA, NA)
  } else {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, chi_prev-fa_model$chi, df_prev-fa_model$dof, qchisq(0.001,df_prev-fa_model$dof,lower.tail=FALSE))
  }
  chi_prev = fa_model$chi
  df_prev = fa_model$dof
}
write.csv(x=df_mod_comp, file='FA_model_comparison_pa.csv')

df_mod_comp <- as.data.frame(matrix(nrow=20,ncol=13))
colnames(df_mod_comp) <- c("nFactors","rms","crms","TLI","RMSEA","Fit","FitOff","BIC","chi2","df","chi2-diff","df-diff","sig_threshold_001")
for (nf in 1:20) {
  print(nf)
  fa_model = fa(data, nfactors = nf, fm='minres', rotate = 'oblimin')
  if (nf==1) {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, NA, NA, NA)
  } else {
    df_mod_comp[nf,] = c(nf, fa_model$rms, fa_model$crms, fa_model$TLI, as.numeric(fa_model$RMSEA[1]), fa_model$fit, fa_model$fit.off,
                         fa_model$BIC, fa_model$chi, fa_model$dof, chi_prev-fa_model$chi, df_prev-fa_model$dof, qchisq(0.001,df_prev-fa_model$dof,lower.tail=FALSE))
  }
  chi_prev = fa_model$chi
  df_prev = fa_model$dof
}
write.csv(x=df_mod_comp, file='FA_model_comparison_minres.csv')

## FOR N=8 factors, any differences in loadings across methods?
nf=8

fa_model = fa(data, nfactors = nf, fm='ml', rotate = 'oblimin')
df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))
p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML6, "Factor 6")
p_f7 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML7, "Factor 7")
p_f8 <- plot_factor(df_loadings, df_loadings$q, df_loadings$ML8, "Factor 8")
png(filename = 'loading_strength_excl_8F_ml.png', width = 2000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, p_f7, p_f8, ncol=2)
dev.off()
#correlation matrix of loadings across items
M <- cor(df_loadings[,c(1,7,4,2,5,6,8,3)])
p.mat <- cor.mtest(df_loadings[,c(1,7,4,2,5,6,8,3)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)
#correlation matrix of scores across subjects
indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
M <- cor(indiv_scores[,c(1,7,4,2,5,6,8,3)])
p.mat <- cor.mtest(indiv_scores[,c(1,7,4,2,5,6,8,3)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)


fa_model = fa(data, nfactors = nf, fm='pa', rotate = 'oblimin')
df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))
p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA6, "Factor 6")
p_f7 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA7, "Factor 7")
p_f8 <- plot_factor(df_loadings, df_loadings$q, df_loadings$PA8, "Factor 8")
png(filename = 'loading_strength_excl_8F_pa.png', width = 2000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, p_f7, p_f8, ncol=2)
dev.off()
#correlation matrix of loadings across items
M <- cor(df_loadings[,c(1,8,3,4,5,6,7,2)])
p.mat <- cor.mtest(df_loadings[,c(1,8,3,4,5,6,7,2)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)
#correlation matrix of scores across subjects
indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
M <- cor(indiv_scores[,c(1,8,3,4,5,6,7,2)])
p.mat <- cor.mtest(indiv_scores[,c(1,8,3,4,5,6,7,2)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)

fa_model = fa(data, nfactors = nf, fm='minres', rotate = 'oblimin')
df_loadings = data.frame(fa_model$loadings[,1:nf])
df_loadings <- df_loadings[,order(names(df_loadings))]
df_loadings$ q = 1:174
df_loadings$Questionnaire = factor(c(rep("BDI",21),rep("STAI-S",20),rep("STAI-T",20),rep("SRS",65),rep("LSAS",48)))
p_f1 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR1, "Factor 1")
p_f2 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR2, "Factor 2")
p_f3 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR3, "Factor 3")
p_f4 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR4, "Factor 4")
p_f5 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR5, "Factor 5")
p_f6 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR6, "Factor 6")
p_f7 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR7, "Factor 7")
p_f8 <- plot_factor(df_loadings, df_loadings$q, df_loadings$MR8, "Factor 8")
png(filename = 'loading_strength_excl_8F_minres.png', width = 2000, height = 1200, res = 200)
grid.arrange(p_f1, p_f2, p_f3, p_f4, p_f5, p_f6, p_f7, p_f8, ncol=2)
dev.off()
#correlation matrix of loadings across items
M <- cor(df_loadings[,c(1,8,3,4,5,6,7,2)])
p.mat <- cor.mtest(df_loadings[,c(1,8,3,4,5,6,7,2)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)
#correlation matrix of scores across subjects
indiv_scores = data.frame(fa_model$scores)
indiv_scores <- indiv_scores[,order(names(indiv_scores))]
M <- cor(indiv_scores[,c(1,8,3,4,5,6,7,2)])
p.mat <- cor.mtest(indiv_scores[,c(1,8,3,4,5,6,7,2)])
corrplot(M, method="color", type="upper", addCoef.col = "black", tl.col="black", tl.srt=45, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag=FALSE)





## OLD STUFF BELOW
#plot
fa_model = fa(data, nfactors = 12, fm='pa', rotate = 'oblimin')
fx <- as.data.frame(unclass(fa_model$loadings))
fx <- cbind(item = rownames(fx), fx)
#fxl <- melt(fx, id="item", measure=c("WLS1","WLS2","WLS3","WLS4","WLS5","WLS6","WLS7","WLS8","WLS9","WLS10","WLS11","WLS12"), 
#            variable.name="Factor", value.name="Loading")
#fxl <- melt(fx, id="item", measure=c("MR1","MR2","MR3","MR4","MR5","MR6","MR7","MR8","MR9","MR10","MR11","MR12"), 
#            variable.name="Factor", value.name="Loading")
#fxl <- melt(fx, id="item", measure=c("ML1","ML2","ML3","ML4","ML5","ML6","ML7","ML8","ML9","ML10","ML11","ML12"), 
#            variable.name="Factor", value.name="Loading")
fxl <- melt(fx, id="item", measure=c("PA1","PA2","PA3","PA4","PA5","PA6","PA7","PA8","PA9","PA10","PA11","PA12"), 
            variable.name="Factor", value.name="Loading")
ggplot(fxl, aes(item, abs(Loading), fill=Loading)) + 
  facet_wrap(~ Factor, nrow=1) + #place the factors in separate facets
  geom_bar(stat="identity") + #make the bars
  coord_flip() + #flip the axes so the test names can be horizontal  
  #define the fill color gradient: blue=positive, red=negative
  scale_fill_gradient2(name = "Loading", 
                       high = "blue", mid = "white", low = "red", 
                       midpoint=0, guide="none") +
  ylab("Loading Strength") + #improve y-axis label
  theme_bw(base_size=10) #use a black-and0white theme with set font size



# plot: scree plot of eigenvalues
df_scree = data.frame(Eigenvalue = eigens$values,
                      Factor = 1:174,
                      Selection = factor(c(rep(1,3),
                                           rep(0,171))))

p_scree<- ggplot(df_scree[1:15,]) +
  geom_bar(aes(x = Factor, y = Eigenvalue),colour="black", stat="identity") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid = element_blank()) +
  scale_x_continuous(expand = c(0.01,0)) +
  scale_y_continuous(expand = c(0,0,0,2)) +
  xlab("Factor Number") +
  ylab("Eigenvalue") +
  scale_fill_brewer(palette="Set2")

png(filename = 'eigenvalues_excl.png',width = 1200, height = 1200, res = 200)
p_scree
dev.off()

# correlation plot
png(filename = 'correlation_matrix_excl_3F.png', width = 1200, height = 1200, res = 150)
corrplot(corr_mat, method = "color", tl.pos='n') 
corrRect(c(21,40,65,48))
dev.off()

