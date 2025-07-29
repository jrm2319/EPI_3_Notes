/***************************
*      Epi III Lab 7       *
*   Survival Analysis II   *
*        Fall 2024         *
***************************/

/* load in data */
libname epi3 '~/my_shared_file_links/u62250266';

/* As we import the data, we need to recreate the person-time 
	variables we used in Lab 6. */

data hivhcv;
set epi3.hivhcv;
*among those who died;
if death = 1 then days = death_date - cohort_date;
*among those who did not die;
else if death = 0 then days = last_alive_date - cohort_date;
pyears = days / 365.25;  *gives time-to-event in years;
run;


/*** Part I: Univariable Cox Regression ***/

/* Question 3: What is the hazard of death for a man living with HIV with a history of 
	IV drug use compared to a man living with HIV without a history of IV drug use? */

proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse / ties = efron rl; 
run;


	/* In the model statement, we cross the person-time variable (pyears)
		with the event variable (death) and specify that the censoring 
		value for the event variable is 0 (and therefore an event = 1). 
		
		The "ties" command tells the model how to handle tied failure times, 
		and there are 4 options: exact, Breslow, discrete, and Efron. Breslow 
		is the default in SAS, though other courses recommend using Efron ties,
		particularly for model exploration. When there are no failure time ties 
		in the dataset, all four options produce identical results. See the lab
		answer key for more information if you are curious.
		
		The "rl" command gives us 95% confidence intervals (Risk Limits) for the 
		HR estimates. */


/*** Part II: Testing for Confounding and Interaction ***/


/* Question 2: Check for confounding by ART initiation. */

proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse ART_init / ties = efron rl; 
run;

/* Question 3: Test whether the interaction between IV drug use and MSM is significant. */

proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse msm IVdruguse * msm / ties = efron rl; 
run;

	/* Note that the hazard ratios are not displayed. This is because the hazard for the
	interaction term is not interpretable on its own, and therefore the "main effect"
	HRs are also not interpretable. But, we can calculate them by hand. */


/*** Part III: Plotting the hazard curve and assessing the proportional hazards assumption ***/

/* Question 2: Check PH assumption graphically, using log-log plots. */

proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse / ties = efron; 
strata IVdruguse;
baseline out = c loglogs = lls survival = s;
run;

proc sgplot data = c;
series x = pyears y = lls / group = IVdruguse;
xaxis values = (0 to 30 by 5);
yaxis values = (-6 to 1 by 1);
title 'Proportional Hazards Assumption for Variable IVdruguse';
run;


/* Question 3: Check the PH assumption statistically, using the cross-product term. */

data survival;
set hivhcv;
ln_py = log(pyears);
run;

proc phreg data = survival;
model pyears * death(0) = IVdruguse ln_py * IVdruguse / ties = efron;
run;

/* Question 4: Check the PH assumption using cumulative sums of martingale-based residuals. */

proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse / ties = efron; 
assess ph / resample seed = 40262001;
run; 

	/* The command 'assess ph' requests that SAS test the proportional hazards assumption 
	for the covariates in the model. The 'resample' option allows us to get the p-value for 
	the proportional hazards test. Since the assessment of the proportional hazards assumption 
	is done using simulations, we use the 'seed' option to set a specific value for generating 
	random numbers (this ensures that with each run of the code we will obtain the same results 
	instead of slightly different results). 
	
	An advantage of this approach is that it easily assesses the proportional hazards assumption 
	for all variables in model at once. 
	
	Note: the p-value of 0.013 for IVdruguse means that among the 1000 simulated paths (only 20 
	shown in the graph), only 1.3% of them have extreme points that exceeded the most extreme 
	point of the observed path; in other words, our actual/observed path deviated appreciably 
	or had significantly more ‘extreme’ points than all but 3.4% of the paths simulated under 
	the PH assumption. */


/* Question 5: Check the PH assumption for the Cox model including IV drug use and HIV
	diagnosis before 1996. */

*** Graphical approach: ***;
proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse / ties = efron; 
strata hiv_diag_1996;
baseline out = p loglogs = lls survival = s;
run;

proc sgplot data = p;
series x = pyears y = lls / group = hiv_diag_1996;
xaxis values = (0 to 30 by 5);
yaxis values = (-6 to 1 by 1);
title 'Proportional Hazards Assumption for Variable hiv_diag_1996';
run;

*** Statistical approach: ***;
proc phreg data = survival;
model pyears * death(0) = IVdruguse hiv_diag_1996 ln_py * hiv_diag_1996 / ties = efron;
run;

*** Martingale residual approach: ***;
proc phreg data = hivhcv;
model pyears * death(0) = IVdruguse hiv_diag_1996 / ties = efron;
asses ph / resample seed = 40262001;
run;

