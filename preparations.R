## check installed R version
R.Version()$version.string
if(R.Version()$major < 3){
  print("please install R version >= 3.0.0")
}
# In case you are using Linux, please note that the official software repositories 
# often only provide an older version of R, e.g. R 2.15 in Ubuntu. To install the latest 
# R version, see, e.g., https://cran.r-project.org/bin/linux/ubuntu/README.html

## install required packages (required dependencies will be installed automatically)
install.packages("scoringRules")
install.packages("rmarkdown")
install.packages("xtable")

library(scoringRules)
library(rmarkdown)
library(xtable)

## check if data can be loaded
load("/path/to/data/HDwind.Rdata") 
load("/path/to/data/USgdp.Rdata") 

ls()
# there should be objects "ensfc", "dates", "obs", "gdp_fc" and "gdp_obs" in the workspace