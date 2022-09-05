# HLW with constant policy rate

This repo contains Holston Laubach and Williams (HLWs) R Code obtained from https://www.newyorkfed.org/medialibrary/media/research/economists/williams/data/HLW_Code.zip. 
This code was modified to show the fact that estimates of the real natural rate $r^{\ast}_t$ from HLWs model are mechanically determined by the nominal policy rate $i_t$ which is set by the federal reserve. To illustrate this, I simply fix the policy rate to be constant from 2008:Q1 onwards and re-estimate the model parameters as well as the natural rate that comes out.

**NOTE:** All files are in their original format as obtained from the above link's 
[HLW_Code.zip](https://www.newyorkfed.org/medialibrary/media/research/economists/williams/data/HLW_Code.zip) file.

Only the [run.HLW.R](run.HLW.R) file is modified to read in the US data that is stored in the folder [./inputData](inputData) on line 92 and the line that generates the fixed interest rate scenarios on line 105:
```{r}
us.data[T0:TT,"interest"] <- fixedinterest
```
Some small changes related to displaying and saving the results have also been made throughout the [run.HLW.R](run.HLW.R) (check the changes/diffs on github).

Daniel Buncic, Stockholm 05.09.2022.