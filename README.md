# ASD_ObsLearn

### task folder
A demo of the task is available at the following URL: http://www.its.caltech.edu/~ccharpen/OL_demo.html.

The code and stimuli used in this demo are available in the /task/OL_task_demo_code/ folder. The demo only has 10 trials, but full trial lists used in the two studies are available in the /task/Study1/ and /task/Study2/ folders.

### data folder
OL task data: OL_data_.mat (for model-free analysis), data_modelfit_.mat (for model fitting)
SRS questionnaire data: SRS_items_.csv (for factor analysis)
Summary of all variables: AllVars_.csv (for the linear regression)

### analysis folder
model_free analysis: codes and outputs of the model-free analysis, including calculation of the accuracy and emulation propensity under each uncertainty condition.
modelling: codes and outputs of the model fitting
    - LL_NonLearn.m, LL_Imitation.m, LL_Emulation.m, LL_FixArb.m, LL_DynArb.m:  5 parsimoneous models (non-learning , imitation, emulation, fixed arbitraiton, dynamic arbitration) 
    - LL_IntDynArb.m: 1 integrated full model.
    - model_fitting_.m: codes to run model fitting (non-hierarchical and hierarchical)
    - data_driven_clustering_.m: codes to perform data-driven clustering on subjects.
factor_analysis: codes and outputs of the factor analysis, including exploratory FA on the discovery sample aand confirmatory FA on the replication sample.
simulations: choice generation functions.
regression: codes for running the linear regression predicting autistic traits using emulation behaviors & predicting emulation behaviors using autistic traits.
