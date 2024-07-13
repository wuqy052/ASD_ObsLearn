# ASD_ObsLearn

### Individual Differences in Autism-like Traits are Associated with Reduced Emulation in a Computational Model of Observational Learning
Qianying Wu, Sarah Oh, Reza Tadayonnejed, Jamie D. Feusner, Jeffrey Cockburn, John P. O'Doherty & Caroline J. Charpentier

Email: qwu@caltech.edu

![Advertise_figure](https://github.com/user-attachments/assets/841e0df2-8373-498a-87bf-c7a5aee10602)
Now published at Nature Mental Health: https://doi.org/10.1038/s44220-024-00287-1 

**Abstract**

The ability to infer the goals and intentions of others is crucial for social interactions, and such social capabilities are broadly distributed across individuals. Autism-like traits (that is, traits associated with autism spectrum disorder (ASD)) have been associated with reduced social inference, yet the underlying computational principles and social cognitive processes are not well characterized. Here we tackle this problem by investigating inference during social learning through computational modeling in two large cross-sectional samples of adult participants from the general population (N 1 = 943, N 2 = 352). Autism-like traits were extracted and isolated from other associated symptom dimensions through a factor analysis of the Social Responsiveness Scale. Participants completed an observational learning task to quantify the tradeoff between two social learning strategies: imitation (repeating the observed partner’s most recent action) and emulation (inferring the observed partner’s goal). Autism-like traits were associated with reduced observational learning specifically through reduced emulation (but not imitation), revealing difficulties in social goal inference (Pearson’s r = −0.124, P < 0.001). This association held, even when controlling for other model parameters (for example, decision noise, heuristics, F 1,925 = 15.352, P < 0.001), and was specifically related to social difficulties in autism-like traits (F 1,916 = 33.169, P < 0.001) but not social anxiety traits (F 1,916 = 0.005, P = 0.945). The findings, replicated in an additional sample, provide a powerfully specific mechanistic hypothesis for social learning challenges in ASD, employing a computational psychiatry approach that could be applied to other disorders.

### task folder
A demo of the task is available at the following URL: http://www.its.caltech.edu/~ccharpen/OL_demo.html.

The code and stimuli used in this demo are available in the /task/OL_task_demo_code/ folder. The demo only has 10 trials, but full trial lists used in the two studies are available in the /task/Study1/ and /task/Study2/ folders.

### data folder
Includes Study 1 and Study 2. In both of them, the following data files are included:
**OL_data_.mat:** For model-free analysis)

**data_modelfit_.mat:** For computational model fitting

**SRS_items_.csv:** Item-wise SRS data, raw data (several items are reverse-coded). Used for factor analysis

**AllVars_.csv:** Mainly for the correlation and regression analysis, also used in figure plottings.

Note that to keep the data anonymous, we removed the ID info from the shared spreadsheet. However, the order of the participant samples in all the data files are consistent.

In addition, there's a 'Conte' folder, including the SRS raw item scores (and total scores) obtained from the Caltech Conte Database.

### analysis folder
**model_free analysis:** Codes and outputs of the model-free analysis, including calculation of the accuracy and emulation propensity under each uncertainty condition.

**modelling:** Codes and outputs of the model fitting

- LL_NonLearn.m, LL_Imitation.m, LL_Emulation.m, LL_FixArb.m, LL_DynArb.m:  5 parsimoneous models (non-learning , imitation, emulation, fixed arbitraiton, dynamic arbitration) 
- LL_IntDynArb.m: 1 integrated full model.
- model_fitting_.m: codes to run model fitting (non-hierarchical and hierarchical) 
- data_driven_clustering_.m: codes to perform data-driven clustering on subjects.

**factor_analysis:** Codes and outputs of the factor analysis, including exploratory FA on the discovery sample aand confirmatory FA on the replication sample.

**simulations:** Simulate choices from different models based on pre-specified parameters. Used in the model recovery and parameter recovery analysis.

**regression:** codes for running the linear regression predicting autistic traits using emulation behaviors & predicting emulation behaviors using autistic traits.

### figures folder
Including a R markdown file (All_figures_R.Rmd) that has codes for all the figures using R, a source_data folder linking several figure source data, and an output folder saving figure outputs.
