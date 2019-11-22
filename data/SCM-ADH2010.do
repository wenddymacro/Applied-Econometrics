*Example Data: This panel dataset contains information for 39 US States for the years 1970-2000 
*(see Abadie, Diamond, and Hainmueller (2010) for details)

*Declare the dataset as panel:
tsset state year

*Example 1 - Construct synthetic control group:
synth cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989)

*In this example, the unit affected by the intervention is unit no 3 (California) in the year 1989.  The donor pool (since no counit() is specified) defaults to the control units 1,2,4,5,...,39 ( ie. the other 38 states in the dataset).  Since no xperiod() is provided, the predictor variables for which no variable specific time period is specified (retprice, lnincome, and age15to24) are averaged over the entire pre-intervention period up to the year of the intervention (1970,1981,...,1988).  The beer variable has the time period (1984(1)1988) specified, meaning that it is averaged for the periods 1984,1985,...,1988. The variable cigsale will be used three times as a predictor using the values from periods 1988, 1980, and 1975 respectively.  The MSPE is minimized over the entire pretreatment period, because mspeperiod() is not provided. By default, results are displayed for the period from 1970,1971,...,2000 period (the earliest and latest year in the dataset).

*Example 2 - Construct synthetic control group:
synth cigsale beer lnincome(1980&1985) retprice cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) fig

*This example is similar to example 1, but now beer is averaged over the entire pretreatment period while lnincome is only averaged over the periods 1980 and 1985.  Since no data
*is available for beer prior to 1984, synth will inform the user that there is missing data for this variable and that the missing values are ignored in the averaging. A results
*figure is also requested using the fig option.

*Example 3 - Construct synthetic control group:
synth cigsale retprice cigsale(1970) cigsale(1979) , trunit(33) counit(1(1)20) trperiod(1980) fig resultsperiod(1970(1)1990)

*In this example, the unit affected by the intervention is state no 33, and the donor pool of potential control units is restricted to states no 1,2,...,20.  The intervention
*occurs in 1980, and results are obtained for the 1970,1971,...,1990 period.

*Example 4 - Construct synthetic control group:
synth cigsale retprice cigsale(1970) cigsale(1979) , trunit(33) counit(1(1)20) trperiod(1980) resultsperiod(1970(1)1990) keep(resout)

*This example is similar to example 2 but keep(resout) is specified and thus synth will save a dataset named resout.dta in the current Stata working directory (type pwd to see the
*path of your working directory). This dataset contains the result from the current fit and can be used for further processing. Also to easily access results recall that synth
*routinely returns all result matrices. These can be displayed by typing ereturn list after synth has terminated.

*Example 5 - Construct synthetic control group:
synth cigsale beer lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975) , trunit(3) trperiod(1989) xperiod(1980(1)1988) nested

*This is again example 2, but the nested option is specified, which typically produces a better fit at the expense of additional computing time. Alternativley, the user can also
*specified the allopt option which can improve the fit even further and requires yet more computing time. Also, xperiod() is specified indicating that predictors are averaged for
*the 1980,1981,...,1988 period.

*Example 5 � Run placebo in space:
tempname resmat
        forvalues i = 1/4 {
        synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988)
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        }
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

*This is a code example to run placebo studies by iteratively reassigning the intervention in space to the first four states. To do so, we simply run a four loop each where the
*trunit() setting is incremented in each iteration. Thus, in the n of synth state number one is assigned to the intervention, in the second run state number two, etc, etc. In each
*run we store the RMSPE and display it in a matrix at the end.


*alternative to Placebo Tests for Synthetic Control Method

*The above code is probably not the most efficient solution, but it should work.

*The steps are as follows:

*1. Loop through all units and store the results of synth via the keep option.

*Code:
* load dataset

use smoking, clear

** tsset

tsset state year

** loop through units

forval i=1/39{

qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975), ///
xperiod(1980(1)1988) trunit(`i') trperiod(1989) keep(synth_`i', replace)
}
*

*2. Now I loop through all saved datasets and create the relevant variables (years and treatment effect). Furthermore, I drop missing observations.

*Code:
forval i=1/39{

use synth_`i', clear

rename _time years

gen tr_effect_`i' = _Y_treated - _Y_synthetic

keep years tr_effect_`i'

drop if missing(years)

save synth_`i', replace
}

*3. Now I load the first dataset and merge all the remaining datasets.

*Code:
use synth_1, clear

forval i=2/39{

qui merge 1:1 years using synth_`i', nogenerate
}

*4. Now the dataset should consist of 40 variables. One named "years" and 39 variables with the treatment effect of the respective unit. To plot these variables in one graph, I use a solution offered by Nicholas J. Cox (see http://www.stata.com/statalist/archi.../msg01370.html) to plot all the lines with one color. Then I add california (unit = 3) with a different color to the plot.

*Code:
local lp

forval i=1/39 {
   local lp `lp' line tr_effect_`i' years, lcolor(gs12) ||
}
*

* create plot

twoway `lp' || line tr_effect_3 years, ///
lcolor(orange) legend(off) xline(1989, lpattern(dash))
*You might consider dropping some of the extreme outliers or adjusting the range of the y-axis.



*References

*Abadie, A., Diamond, A., and J. Hainmueller. 2014. Comparative Politics and the Synthetic Control Method. American Journal of Political Science (Forthcoming 2014).

*Abadie, A., Diamond, A., and J. Hainmueller. 2010. Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program.  Journal of the American Statistical Association 105(490): 493-505.

*Abadie, A. and Gardeazabal, J. 2003. Economic Costs of Conflict:  A Case Study of the Basque Country. American Economic Review 93(1): 113-132.

*Vanderbei, R.J. 1999. LOQO: An interior point code for quadratic programming.  Optimization Methods and Software 11: 451-484.
