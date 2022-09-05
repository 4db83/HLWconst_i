# HLW with constant policy rate $i$






This repo contains Holston Laubach and Williams (HLWs) R Code obtained from https://www.newyorkfed.org/medialibrary/media/research/economists/williams/data/HLW_Code.zip. 
This code was modified to show the fact that estimates of the real natural rate $r^{\ast}_t$ from HLWs model are mechanically determined by the nominal policy rate $i_t$ which is set by the federal reserve. To illustrate this, I simply fix the policy rate to be constant from 2008:Q1 onwards and re-estimate the model parameters as well as the natural rate that comes out.

**NOTE:** All files are in their original format as obtained from the above link's 
[HLW_Code.zip](https://www.newyorkfed.org/medialibrary/media/research/economists/williams/data/HLW_Code.zip) file.

Only the "run.hwl.R" file is modified to read in the US data that I have stored in the folder "inputData" and to fix the policy rate 

incorporate the constant interest rate counterfactual.


## R Users
If you are an **R** user, go to the **R.code** directory and familiarize yourself with the file [fit.HLW.R](R.code/fit.HLW.R). This is the main file for estimation in R. The estimation results are stored in various **'data/R.HLW.results/'** files for each country of interest and most results are also printed to screen. 
