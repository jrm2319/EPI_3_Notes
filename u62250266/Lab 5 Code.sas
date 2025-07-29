**************** EPI III Lab 5 **************;

* Upload data & format;

/* We will using in this lab the dataset name adult_BMI.sas7bdat found in the in the dataset folder in files*/


**** Question 1 ****;

libname epi3 '~/my_shared_file_links/u62250266'; 

data adult_bmi; /*Here we are creating a new temporary dataset “adult_bmi” from the source dataset “adult_BMI.sas7bdat"*/
set epi3.adult_bmi;
binbmi=.;
if bmi <25 then binbmi=0;	
if bmi >=25 then binbmi=1;
run;


**** Question 2 ****;

proc logistic data=adult_bmi descending;
model binbmi=weight7/clodds=wald; /*Wald Confidence Intervals for Odds Ratio*/
run;

/* or */

proc genmod data=adult_bmi descending;
model binbmi=weight7/link=logit dist=bin;
estimate 'weight7' weight7 1/exp; /*The “1” in the estimate statement requests an exponentiated beta estimate for a 1-unit increase in weight7*/
run;


**** Question 3 ****;

proc logistic data=adult_bmi descending;
model binbmi=weight7/clodds=wald; /*Wald Confidence Intervals for Odds Ratio*/
units weight7=5; /*Your beta estimates will reflect the change in the log odds of the outcome associated with a 5-unit increase in the exposure*/
run;

/* or */

proc genmod data=adult_bmi descending;
model binbmi=weight7/link=logit dist=bin;
estimate 'weight7' weight7 5/exp; /*The “5” in the estimate statement requests an exponentiated beta estimate for a 5-unit increase in weight7*/
run;


**** Question 5 ****;

proc freq data=adult_bmi;
table binbmi;
run;

**** Question 6 ****;

proc genmod data=adult_bmi descending;
class id;
model binbmi=weight7/link=log dist=poisson;	
repeated subject=id/type=ind;
estimate 'weight7' weight7 1/exp; /*The “1” in the estimate statement requests an exponentiated beta estimate for a 1-unit increase in weight7*/
run;


**** Question 7 ****;

proc genmod data=adult_bmi descending;
class id;
model binbmi=weight7/link=log dist=poisson;	
repeated subject=id/type=ind;
estimate 'weight7' weight7 5/exp; /*The “5” in the estimate statement requests an exponentiated beta estimate for a 5-unit increase in weight7*/
run;


**** APPENDIX **********************************************************************;

/* Prepare data for weight7 to be categorized into 5 equally-spaced groups */

data adult_bmi2;
set adult_bmi;

/* using weight <20 kg as the reference group*/
wt7_1=0;
wt7_2=0;
wt7_3=0;
wt7_4=0;
if 20<=weight7<=23 then wt7_1=1;
if 23<weight7<=27 then wt7_2=1;
if 27<weight7<=31 then wt7_3=1;
if weight7>31 then wt7_4=1;
if weight7=. then do;
wt7_1=.;
wt7_2=.;
wt7_3=.;
wt7_4=.;
end;
run;

**** Question A1 ****; 

proc freq data=adult_bmi2;
tables weight7*wt7_1*wt7_2*wt7_3*wt7_4/list missing;
run;

proc freq data=adult_bmi2;
tables wt7_1*wt7_2*wt7_3*wt7_4/list missing;
run;

**** Question A2 ****; 

proc logistic data=adult_bmi2 desc;
model binbmi=wt7_1 wt7_2 wt7_3 wt7_4;
run;

**** Question A3 ****;

data plot1;
input beta wt7; /*The data for the cards statement (the part in yellow) comes from the output generated in the previous step. The first row is for the reference group.*/
cards; 
 0.0000 0
-0.8426 1
 1.7600 2
 2.3354 3
 3.8859 4
run;

PROC SGPLOT DATA=plot1;
SERIES x=wt7 y=beta/LINEATTRS=(pattern=1 thickness=5 color=turquoise);
YAXIS values=(-4 to 4 by 0.5);
run;

**** Question A5 ****; 

/* Categorize BMI at 20*/

data adult_bmi3;
set adult_bmi2;
if bmi = . then bmi3 = .;
else if bmi < 25 then bmi3 = 1;
else if bmi < 30 then bmi3 = 2;	
else bmi3 = 3;
run;

proc logistic data=adult_bmi3;
class bmi3 (ref="1");
model bmi3 = weight7/link=glogit; /*PROC LOGISTIC fits an ordinal model by default (specifically, a cumulative logit model) when the response has more than two levels. Therefore, to run an unordered polytomous logistic regression model we must specify link=glogit (glogit means ‘generalized’ logit model which is the unordered model).*/
run;

/* To obtain Group 3 vs Group 2? */

proc logistic data=adult_bmi3;
class bmi3 (ref="2");
model bmi3 = weight7/link=glogit;
run;





          


