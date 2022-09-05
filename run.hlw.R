#------------------------------------------------------------------------------#
# File:        run.hlw.R
#
# Description: This the main file for HLW, which does the following:
#              (1) Prepares data to be used in estimation
#              (2) Runs the three-stage HLW estimation for each economy
#              (3) Saves output.
#------------------------------------------------------------------------------#
rm(list=ls())
cat("\014"); gc(); 
#------------------------------------------------------------------------------#
# Prepare data to be used in estimation.
#
# Output will be saved in the inputData folder.
#
# Set the data start and end dates manually in each prepare.rstar.data file
#------------------------------------------------------------------------------#
# source("prepare.rstar.data.us.R")
# source("prepare.rstar.data.ca.R")
# source("prepare.rstar.data.ea.R")
# source("prepare.rstar.data.uk.R")


#------------------------------------------------------------------------------#
# Load required packages and source all programs to be used in HLW estimation.
#------------------------------------------------------------------------------#
if (!require("tis")) {install.packages("tis"); library("tis")} # Time series package
if (!require("mFilter")) {install.packages("mFilter"); library("mFilter")} # HP filter
if (!require("nloptr")) {install.packages("nloptr"); library("nloptr")} # Optimization
if (!require("tictoc")) {install.packages("tictoc"); library("tictoc")} # for simple timing

# Source all R programs; see code guide for details of each
source("calculate.covariance.R")
source("format.output.R")
source("kalman.log.likelihood.R")
source("kalman.standard.errors.R")
source("kalman.states.R")
source("kalman.states.wrapper.R")
source("log.likelihood.wrapper.R")
source("median.unbiased.estimator.stage1.R") 
source("median.unbiased.estimator.stage2.R")
source("rstar.stage1.R")
source("rstar.stage2.R")
source("rstar.stage3.R")
source("run.hlw.estimation.R") 
source("unpack.parameters.stage1.R") 
source("unpack.parameters.stage2.R") 
source("unpack.parameters.stage3.R") 
source("utilities.R")


#------------------------------------------------------------------------------#
# Define variables
#------------------------------------------------------------------------------#
# Upper bound on a_3 parameter (slope of the IS curve)
a3.constraint <- -0.0025

# Lower bound on b_2 parameter (slope of the Phillips curve)
b2.constraint <- 0.025

# Set the start and end dates of the estimation sample (format is c(year,quarter))
sample.start <- c(1961,1) 
sample.end   <- c(2019,4)

# Set the estimation sample start date for the Euro Area 
ea.sample.start <- c(1972,1)

# The estimation process uses data beginning 4 quarters prior to the sample start
data.start    <- shiftQuarter(sample.start,-4)
ea.data.start <- shiftQuarter(ea.sample.start,-4)

# Set start index for y
g.pot.start.index <- 1 + ti(shiftQuarter(sample.start,-3),'quarterly')-ti(data.start,'quarterly')

# Set column names for CSV output
output.col.names <- c("Date","rstar","g","z","output gap","","All results are output from the Stage 3 model.",rep("",8),"Standard Errors","Date","y*","r*","g","","rrgap")

# Set number of iterations for Monte Carlo standard error procedure
niter <- 1

# Because the MC standard error procedure is time consuming, we include a run switch
# Set run.se to TRUE to run the procedure
run.se <- FALSE

#------------------------------------------------------------------------------#
# United States: Read in data, run estimation, and save output
#------------------------------------------------------------------------------#
# make data input folder if it does not exist
if (!dir.exists("inputData")) {dir.create("inputData")}

# Read in output of prepare.rstar.data.us.R
us.data <- read.table("inputData/US.data.csv",sep = ',', na.strings = ".", header=TRUE, stringsAsFactors=FALSE)

TT = length(us.data$Date)
# set date from when to fix it. 
T0 = which("01.01.2008" == us.data$Date)

# for (fixedinterest in -2:5){
for (fixedinterest in 2.5){
  # data
  us.log.output             <- us.data$gdp.log
  us.inflation              <- us.data$inflation
  us.inflation.expectations <- us.data$inflation.expectations
  # this fixes the interest rate to be constant from T0 onwards to the end of the sample
  us.data[T0:TT,"interest"] <- fixedinterest
  us.nominal.interest.rate  <- us.data$interest
  us.real.interest.rate     <- us.nominal.interest.rate - us.inflation.expectations
  
  # Run HLW estimation for the US ------
  tic("Run all")
  us.estimation <- run.hlw.estimation(us.log.output, us.inflation, us.real.interest.rate, us.nominal.interest.rate,
                                      a3.constraint = a3.constraint, b2.constraint = b2.constraint, run.se = FALSE)
  print("Done")
  toc()
  # create output parameters names etc.
  para.names = c( "a_y1","a_y2","a_r","b_pi","b_y","sigma_y~","sigma_pi","sigma_y*","Log-Likelihood","Lambda.g","Lambda.z")
  
  est3 = cbind(c( us.estimation$out.stage3$theta,
                  us.estimation$out.stage3$log.likelihood,
                  us.estimation$lambda.g,
                  us.estimation$lambda.z))
  rownames(est3) = para.names
  colnames(est3) = "Stage 3 estimates"
  print(est3)
  
  # One-sided (filtered) estimates--------
  one.sided.est.us <- cbind(us.estimation$out.stage3$rstar.filtered,
                            us.estimation$out.stage3$trend.filtered,
                            us.estimation$out.stage3$z.filtered,
                            us.estimation$out.stage3$output.gap.filtered)
  # add row and column names
  colnames(one.sided.est.us) = c("rstar","g","z","output gap")
  rownames(one.sided.est.us) = us.data$Date[5:length(us.data$Date)]
  
  # Two-sided (smoothed) estimates
  two.sided.est.us <- cbind(us.estimation$out.stage3$rstar.smoothed,
                            us.estimation$out.stage3$trend.smoothed,
                            us.estimation$out.stage3$z.smoothed,
                            us.estimation$out.stage3$output.gap.smoothed)
  # add row and column names
  colnames(two.sided.est.us) = c("rstar","g","z","output gap")
  rownames(two.sided.est.us) = us.data$Date[5:length(us.data$Date)]
  
  # SAVE OUTPUT ----
  if (!dir.exists("output")) {dir.create("output")}
  # Save one and two sided estimates to CSV
  write.table(one.sided.est.us, paste0('output/one.sided.HLW', fixedinterest, '.csv'), quote = FALSE, sep = ',', na = ".")
  write.table(two.sided.est.us, paste0('output/two.sided.HLW', fixedinterest, '.csv'), quote = FALSE, sep = ',', na = ".")
  
  # Save output to CSV
  output.us <- format.output(us.estimation, one.sided.est.us, us.real.interest.rate, sample.start, sample.end, run.se = run.se)
  write.table(output.us, paste0('output/output.HLW', fixedinterest, '.csv'), col.names = output.col.names, quote=FALSE, row.names=FALSE, sep = ',', na = '')
}



#EOF


