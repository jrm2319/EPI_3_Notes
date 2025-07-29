/*********************************
*         Epi III Lab 10         *
*   REVIEWING THE LITERATURE.    *
*   		Fall 2024 			 *
*	This lab is experimental.    *
*	Code developed with help     *
*		   from ChatGTP.         *
**********************************/


**************************************************************************************************************************************************************************************;
*Data Preparations;														
**************************************************************************************************************************************************************************************;

/* Data set:

Create data set that contains effect estimates from studies we 
are including in our meta-analysis. We include the OR, and bounds
of the 95% confidence limit as well as a variable indicating the study.
These data can also be found in the metaanalysis.xls spreadsheet.
*/
Data meta_data;
	length Study $12.;
	input Study $ OR CI_Lower CI_Upper;
	datalines;
	Auvinen 1.3 0.9 1.8
	Christensen 0.73 0.59 0.9
	Hepworth 0.94 0.78 1.13
	Inskip 0.9 0.7 1.1
	Lonn04 1 0.6 1.5
	Lonn05 0.83 0.69 0.99
	Muscat 0.8 0.6 1.2
	Schoemaker 0.9 0.7 1.1
	Schuz 0.91 0.75 1.09
	;
run;

/* Checking data set contents:

Running proc contents to ensure everything loaded in properly;
'Varnum' is used so that the output is ordered by variable number.
The default is ordering the output by alphabet. Also, running Proc Print
*/
Proc contents data=meta_data varnum;
Proc print data=meta_data; run;




/* Preparing data set for meta-analysis:

First, we transform data from the odds ratio scale to the log odds scale.
Second, we use the log odds to calculate standard errors. Standard errors are needed
for us to pool the estimates.
Finally, we calculate the inverse variance weight. We weight studies in our 
meta-analysis based on their variance (Standard error squared). Larger standard
errors will have lower weights (be less influential) than smaller standard errors
in our pooled estimate.
*/
Data meta_data_random meta_data_fixed; *output 2 separate data sets;
set meta_data;
	*First;
	logOR = log(OR); /*OR to log odds*/
	logLL = log(ci_lower); /*lower bound of CI (OR scale) to log odds*/
	logUL = log(ci_upper); /*upper bound of CI (OR scale) to log odds*/

	*Second: Standard errors for each study;
	SE = (logUL - logLL)/(2*1.96); 
/*Note: We use 1.96 b/c it is the Z-score for the 95% confidence level*/

	*Third: Inverse variance weight (recall that variance is just the square of standard errors;
	iv_weight = 1/(SE**2);
run;

**************************************************************************************************************************************************************************************;
*Question 7;														
**************************************************************************************************************************************************************************************;

* Perform random-effects meta-analysis using PROC MIXED;
proc mixed data=meta_data_random  method=reml; *Restricted maximum likelihood estimation for heterogeneity variance;
    class Study; *Treat study as a categorical variable;
    model logOR = / solution; /* Fixed effect to generate intercept[pooled log(OR)] */
    random Study/subject=study; /* Random effect for study-level variability */
    weight iv_weight; /* Apply the inverse variance weights */
	Estimate "Intecept" intercept 1; 
	ods output Estimates = random_coefs; *Outputting our model outputs;
run;
* The beta estimate for the intercept is our pooled estimate on the log odds scale;

/*Question 7a*/
* Printing our intercept beta and standard error with extra digits for precision;
Proc print data=random_coefs; var estimate stderr; format estimate stderr 10.8; run;




/*Question 7b: Calculating the OR and 95% CIs*/
Data random_coefs;
set random_coefs;
OR = exp(estimate);
LL = exp(estimate - 1.96*stderr);
UL = exp(estimate + 1.96*stderr);
run;
Proc print data=random_coefs; var OR LL UL; run;




/*Question: 7c (run through the Proc Print)*/
*Generating Q;
data qstat_ran;
	set meta_data_random;
	unsummed_q = ((logOR - -0.1230)**2)*iv_weight;
/*Q is a summation of products from multiplying the inverse variance weight by the 
  differences between each study's estimate and the pooled estimate. Here we generate
  the products. We use SQL below to obtain the sum*/ 
run;
*Obtaining Q;
Proc sql;
	select sum(unsummed_q) as Q
	from qstat_ran;
quit;
/*Generating the p-value for Q and the I-squared value:
We use the chi-square distribution to determine Q's p-value 1-probchi(Q, DF),
where Q is the value of Q from the SQL above and DF is the number of studies - 1 .
I-squared can be calculated using the following formula:
(Q-(k-1))*100/Q; where Q is Q and k is the number of studies;
*/
Data isquare_ran;
	set meta_data_random;
	p_value = 1-probchi(9.542558, 8); 
	I_square = (9.542558 - 8)*100/9.542558;
	/*Note: I-squared must be positive, if k-1 is < Q then
	  I-squared = 0 should be set to 0*/ 
run;
Proc print data=isquare_ran; var p_value I_square; run; 
/* 
Note: The p-value and I-square is the same for everyone.
*/




/* Question 7d:
Now we are ready to generate a forest plot that displays the log odds for all the studies and
the pooled estimate. We will first insert the pooled estimate into our original data set*/ 
Proc SQL;
	insert into meta_data_random
	set study="Overall",
		logOR = -0.12295543,
		logLL = -0.12295543 - (1.96*0.04255887), /*Calculating the lower limit of the 95% CI*/
		logUL = -0.12295543 + (1.96*0.04255887); /*Calculating the upper limit of the 95% CI*/
quit; 

* Plotting the ORs;
title 'Random Effects Forest Plot';
proc sgplot data=meta_data_random;
    scatter x=LogOR y=Study / 	xerrorlower=logLL
							xerrorupper=logUL	
							markerattrs= (symbol=DiamondFilled size=8);
    refline 0 / axis=x;
    xaxis label = "Log Odds and 95% CI" min= -1 max=1;
	yaxis label  = "Study";
run;
Title;

**************************************************************************************************************************************************************************************;
*Question 8;														
**************************************************************************************************************************************************************************************;

* Perform fixed-effects meta-analysis using PROC MIXED;
proc mixed data=meta_data_fixed  method=ml; *Maximum likelihood estimation instead of REML;
    class Study; *Treat study as a categorical variable;
    model logOR = / solution E; /* Fixed effect to generate intercept[pooled log(OR)] */
    /* No RANDOM statement*/
    weight iv_weight; /* Apply the inverse variance weights */
	Estimate "Intecept" intercept 1; 
	ods output Estimates = fixed_coefs; *Outputting our model outputs;
run;
* The beta estimate for the intercept is our pooled estimate on the log odds scale;

/*Question 8a*/
* Printing our intercept beta and standard error with extra digits for precision;
Proc print data=fixed_coefs; var estimate stderr; format estimate stderr 10.8; run;




/*Question 8b: Calculating the OR and 95% CIs*/
Data fixed_coefs;
set fixed_coefs;
OR = exp(estimate);
LL = exp(estimate - 1.96*stderr);
UL = exp(estimate + 1.96*stderr);
run;
Proc print data=fixed_coefs; var OR LL UL; run;




/*Question: 8c (run through the Proc Print)*/
*Generating Q;
data qstat_fix;
	set meta_data_fixed;
	unsummed_q = ((logOR - -0.12295543)**2)*iv_weight;
/*Q is a summation of products from multiplying the inverse variance weight by the 
  differences between each study's estimate and the pooled estiamte. Here we generate
  the products. We use SQL below to obtain the sum*/ 
run;

*Obtaining Q;
Proc sql;
	select sum(unsummed_q) as Q
	from qstat_fix;
quit;

/*Generating the p-value for Q and the I-squared value:
We use the chi-square distribution to determine Q's p-value 1-probchi(Q, DF),
where Q is the value of Q from the SQL above and DF is the number of studies - 1 .
I-squared can be calculated using the following formula:
(Q-(k-1))*100/Q; where Q is Q and k is the number of studies;
*/
Data isquare_fix;
	set meta_data_fixed;
	p_value = 1-probchi(9.542557, 8);
	I_square = (9.542557 - 8)*100/9.542557;
	/*Note: I-squared must be positive, if k-1 is < Q then
	  I-squared = 0 should be set to 0*/ 
run;
Proc print data=isquare_fix; var p_value I_square; run; 

/* 
Note: I-square is the same for everyone.
*/




/* Question 8d:
Now we are ready to generate a forest plot that displays the log odds for all the studies and
the pooled estimate. We will first insert the pooled estimate into our original data set*/ 
Proc SQL;
	insert into meta_data_fixed
	set study="Overall", /*Note: 10 corresponds to 'Overall' format*/
		logOR = -0.12295543, /*exponentating the beta estimate from the output*/
		logLL = -0.12295543 - (1.96*0.04012488), /*Calculating the lower limit of the 95% CI*/
		logUL = -0.12295543 + (1.96*0.04012488); /*Calculating the upper limit of the 95% CI*/
quit; 

title 'Fixed effects forest plot';
proc sgplot data=meta_data_fixed;
    scatter x=logOR y=Study / 	xerrorlower=logll
							xerrorupper=logul	
							markerattrs= (symbol=DiamondFilled size=8);
    refline 0 / axis=x;
    xaxis label = "Log Odds and 95% CI" min= -1 max=1;
	yaxis label  = "Study";
run;
title;
