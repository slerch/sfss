# Objective: Evaluate NWP output and statistically postprocess the forecasts

# ----  [Sebastian: Introduction to data (slides) + loading data sets into R] -----

# Data

## load data
load("~/GitHub/sfss/postproc_example/data/HDwind.Rdata")
load("/home/sebastian/Dropbox/ERC SummerSchool/GitHub_repo/postproc_example/data/new/HDwind.Rdata")

## contents data
ls()
str(dates)
range(dates)
str(obs)
str(ensfc)

# ----  [Alexander: Absolute verification of ensemble forecasts] -----

## split data
training_ind <- which(dates < "2016-12-30")
training_ensfc <- ensfc[training_ind, ]

## absolute verification of training data

### scatter plot
plot(ensfc, rep(obs, 50))
abline(a = 0, b = 1)

boxplot(t(head(ensfc, 30)))
lines(head(obs, 30), col = "red", type = "o")

### rank histogram
rank_hist

# ----  [Sebastian: Implementation of simple post-processing model (slides + code)] -----

# Modeling

## (slide EMOS)

## training

### objective function


### optimization


## forecasting

### calculate out-of-sample parameters

# ----  [Alexander: Verification of post-processed forecasts] -----

# Evaluation

## absolute verification of test data

### compare rank (ensemble) and PIT (EMOS) histograms

### compare scores

# ----  [Alexander/Sebastian: Exercise: DIY] -----

#
# do it yourself, mix it up, change things
#
