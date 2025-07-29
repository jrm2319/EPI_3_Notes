/**************************
*      Epi III Lab 6      *
*   Survival Analysis I   *
*        Fall 2024        *
**************************/

/* load in data */
libname epi3 '~/my_shared_file_links/u62250266';

data hivhcv;
set epi3.hivhcv;
run;


/*** Part I: Exploring the dataset ***/


/* Question 1: How many observations are in the dataset? */

proc contents data = hivhcv;
run;

/* Question 2: How many of the participants are positive for HCV? */

proc freq data = hivhcv;
table hcv;
run;

/* Question 4: Is this an open or a closed cohort? How would we examine
	the data to determine this? */
	
proc freq data = hivhcv;
table cohort_date * last_alive_date / list;
where death = 0;
run;

/* Question 5: Calculate person-time for each participant in the cohort. */

data hivhcv2;
set hivhcv;
*among those who died;
if death = 1 then days = death_date - cohort_date;
*among those who did not die;
else if death = 0 then days = last_alive_date - cohort_date;
pyears = days / 365.25;  *gives time-to-event in years;
run;

/* Check your work */

proc freq data = hivhcv2;
table death_date * cohort_date * pyears / list missing nocum nofreq nopercent;
run;
 
proc freq data = hivhcv2;
table last_alive_date * cohort_date * pyears / list missing nocum nofreq nopercent;
run;
 
proc freq data = hivhcv2;
table pyears;
run;

 
/*** Part II: Plotting the survival curve ***/


/* Question 1-4: Plot the survival curve. */

proc lifetest data = hivhcv2 method = km plots = (s) graphics;
time pyears * death(0);
run;
	
/* Question 5: Compare the survival curve for patients with a diagnosis of 
	Hepatitis C versus those without a diagnosis of Hepatitis C. What are the 
	median survival proportions for each group? */
	
proc lifetest data = hivhcv2 method = km plots = (s) graphics;
time pyears * death(0);
strata hcv;
run;


