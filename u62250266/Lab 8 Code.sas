/***************************
*      Epi III Lab 8       *
*   Matching/Conditional   *
*		 Regression        *
*                          *
*        Fall 2024         *
***************************/

/* load in data */
libname epi3 '~/my_shared_file_links/u62250266';

/*************************************** Part I: Exploring the Data + Data Management ************************************/

*Always important to check data structure after loading in data; 
proc contents data=epi3.crp_angina;
run;

*Sort on group ID and case vs. control status to visualize matching;
proc sort data=epi3.crp_angina;
by descending group_id descending casecont;
run;

*After sorting, view the data by group number/case vs. control status;
proc freq data=epi3.crp_angina order=data; 
tables group_id*casecont*hscrp*angina/list; *list option displays multiway table in a single table, instead of separate two-way tables for each stratum;
run;

/* Question 2 */ 
*Create a dichotomous variable for CRP (hsCRP level above 1.0 can indicate a clinically active level of inflammation);
data crp_angina_grp; set epi3.crp_angina; 
crp_grp=.;
if 0< hscrp <= 1 then crp_grp=0;
else if hscrp >1 then crp_grp=1;
run;

*Always check your work; 
proc freq data=crp_angina_grp;
title 'check that binary CRP correctly created';
tables hscrp*crp_grp /list missing; 
run;


/************************************************* Part I: Exploring the Data **********************************************/

/* Question 3: Was matching successful? */

*Check that matching worked for age by comparing mean age by case vs. control; 
proc means data= crp_angina_grp;
title ''; *clears previous title; 
class casecont;
var age_yr;
run;

*Check that matching worked for smoking status; 
proc sort data= crp_angina_grp;
by descending smoke casecont;
run;

proc freq data= crp_angina_grp order=data;
table smoke*casecont;
run;

/* Question 4: Conditional logistic regression (crude) */ 

proc logistic data= crp_angina_grp;	
title 'Crude (unadjusted) conditional logistic regression of CRP on angina'; *adds title to output; 
strata group_id; *STRATA statement names variables that define strata or matched sets to use in stratified logistic regression of binary response data;
model casecont(event = '1') = crp_grp; *Note: You can use the event= option in the model statement instead of using the descending option;
run;

/* Question 5: Conditional logistic regression (adjusted for alcohol use) */ 

proc logistic data=crp_angina_grp;
title 'Conditional logistic regression of CRP on angina, adjusting for alcohol use';
strata group_id; 
model casecont(event = '1') = crp_grp alc_high; 
run;

/* Question 7: Interaction */ 

*Question 7.a) Create BMI variable; 

data crp_angina_bmi;
set crp_angina_grp;
bmi= wt_kg/(ht_cm/100)**2;
bmi30=.;
if 0 < bmi <= 30 then bmi30=0;
else if bmi >30 then bmi30=1;
run;

*Check your work;
proc freq data=crp_angina_bmi;
table bmi*bmi30/list missing; 
run;

*Question 7.b) Examine relationship between BMI and angina; 

proc logistic data=crp_angina_bmi;
strata group_id; 
model casecont(event = '1') = bmi30; 
run;

*Question 7.c) Examine interaction between BMI and hr-CRP; 

proc logistic data=crp_angina_bmi;
strata group_id;
class crp_grp(ref='0') bmi30(ref='0') / param=ref;  
model casecont(event = '1') = crp_grp bmi30 crp_grp*bmi30 ; *the crp_grp*bmi30 is the same as manually creating a cross-product term in a data step;
run;  

*Question 9. Comparing conditional logistic regression w standard logistic regression; 

proc logistic data=crp_angina_bmi;
title 'Conditional logistic regression of hr-CRP on angina'; 
strata group_id; 
model casecont(event = '1') = crp_grp; 
run;

proc logistic data=crp_angina_bmi;
title 'Standard logistic regression of hr-CRP on angina, not matched on smoking/age'; 
model casecont=crp_grp smoke age_yr;
run;


/******************************************** Extra Practice ****************************************/
** We recommend you try to figure out the code on your own first!; 

*Extra Practice Question 1: Crude conditional logistic regression model of hsCRP (continuous) on angina; 

proc logistic data=crp_angina_bmi;	
strata group_id; 
model casecont(event = '1') = hscrp; 
run;

*Extra Practice Question 4: Interaction of BMI on the additive scale; 

data crp_angina_bmi;
set crp_angina_bmi;
if crp_grp = 0 and bmi30 = 0 then crpbmi = 0;
if crp_grp = 0 and bmi30 = 1 then crpbmi = 1;
if crp_grp = 1 and bmi30 = 0 then crpbmi = 2;
if crp_grp = 1 and bmi30 = 1 then crpbmi = 3;
if crp_grp = . or bmi30 = . then crpbmi = .;
crpbmi1 = .;
if crpbmi in (0,2,3) then crpbmi1=0;
if crpbmi=1 then crpbmi1=1;
crpbmi2=.;
if crpbmi IN (0,1,3) then crpbmi2=0;
if crpbmi=2 then crpbmi2=1;
crpbmi3=.;
if crpbmi IN (0,1,2) then crpbmi3=0;
if crpbmi=3 then crpbmi3=1;
if crpbmi=. then do;
crpbmi1=.; crpbmi2=.; crpbmi3=.; 
end;
run;

proc logistic data=crp_angina_bmi;
strata group_id; 
model casecont(event = '1') = crpbmi1 crpbmi2 crpbmi3 / covb; 
run;




                                       

                                   
