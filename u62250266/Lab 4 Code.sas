**************** EPI III Lab 4 **************;

/* We will continue to use the CHS03 SAS dataset from the past two weeks.*/

******* Upload data & format ********; 

libname Epi3 '~/my_shared_file_links/u62250266'; /*remember to change your path*/

proc format;
	value sex
		1 = 'Male'
		2 = 'Female';
	value famhx 
		1 = 'First degree relative' 
		2 = 'Second degree relative'
		3 = 'No relatives with col. cancer' 
		4 = 'Don''t Know';
	value que
		1 = 'Private'
		2 = 'Medicare'
		3 = 'Medicaid'
		4 = 'Other'
		5 = 'Uninsured';
	value educat
		1 = 'Less than high school'
		2 = 'High school graduate'
		3 = 'Some college/technical school'
		4 = 'College graduate';
	value age50up
		1 = '50 - 64'
		2 = '65+';	
	value income
		1 = '< $25,000'
		2 = '$25,000 - < $50,000'
		3 = '$50,000 - < $75,000'
		4 = '>= $75,000'
		5 = 'Dont know';	
	value insureyn
		1= 'insured'
		0= 'uninsured';
	value fambinyn
		1='family hx'
		0='no family hx';
	value rothman
		0= 'famhx, insured'
		1= 'famhx, uninsured'
		2= 'no famhx, insured'
		3= 'no famhx, uninsured';
	value colon
		1='<= 10 yrs'
		2='> 10 yrs';
run;

******** Re-code Variables ********;

/* We will now re-code the following variables. As we noted in Lab 2, CHS03 data includes people 
18+ years old; however, the colonoscopy question was only asked to those 50+ years old. When we 
run logistic regression the colon variable will limit the analysis to those 50+ years old. 

/* For the logistic regression procedure, we will create a new variable “colon” 
by recoding the outcome variable colonoscopy10yrs (coded 1= Yes: received timely 
colonoscopy screening, 0= No: did not receive timely colonoscopy screening). */

/* We will use the “insured” exposure variable as described in Lab 2 (coded 1=insured, 0=uninsured). */

/* We will also create new variables “fambin” (coded 1=yes, 0=no) and “income” 
(coded 1=high income, 0=low income) from the variables familyhx and incomegroup as shown below. */


data chs03;
set Epi3.chs03;

if colonoscopy10yr=1 then colon=1;/*Had a timely colonoscopy screening*/
else if colonoscopy10yr=2 then colon=0;	/*Have NOT had a timely colonoscopy screening*/
if colonoscopy10yr=. then colon=.; 

if insurance IN (1,2,3,4) then insured=1;/*YES*/
else if insurance=5 then insured=0;/*NO*/
if insurance=. then insured=.;

if familyhx IN (1,2) then fambin=1; /*Fam Hx*/
else if familyhx=3 then fambin=0;/*No family hx*/
else if familyhx=4 then fambin=.;

if incomegroup in (2,3,4) then income=1; /*high income*/
else if incomegroup in (1) then income=0;/*low income*/
else if incomegroup=5 then income=.;

run;

*/

+---------------------+
|                     |
|  		Part A    	  |
|                     |
+---------------------+

*/

****** Q2 ****; 

* Let's create a new cross-product term to represent the interaction between
insurance status and income.;

data chs03new; set chs03; 
ins_inc_Int=insured*income; 
run;

* Run the code below to further understand the interaction variable (ins_inc_Int);

proc freq data=chs03new;
where age50up IN (1,2);
table ins_inc_Int*insured*income/list missing;
run;

* Note: We are restricting this analysis to our study group (those who are 50 year and older);

***** Q3 ****;

* Using the cross-product method, determine if there is an interaction between
insurance status and income.;

proc logistic data=chs03new descending; 
model colon= insured income ins_inc_Int; 
run;

/*

+---------------------+
|                     |
|  		Part B  	  |
|                     |
+---------------------+

*/ 

/* Let us now create the indicator variables to test for interaction in the model */

data chs03new2;
set chs03new;

/* to create four groups for binary insured and income*/
if insured=0 and income=0 then insured_income_int=3; /*uninsured, low income-00*/
if insured=1 and income=0 then insured_income_int=2; /*insured, low income-10*/
if insured=0 and income=1 then insured_income_int=1; /*uninsured, high income-01*/
if insured=1 and income=1 then insured_income_int=0; /*insured, high income-11*/

/*to create indicator variables*/

insinc1=.; /*insured, low income (10)*/
if insured_income_int IN (0,1,3) then insinc1=0;
if insured_income_int=2 then insinc1=1;

insinc2=.; /*uninsured, high income (01)*/
if insured_income_int IN (0,2,3) then insinc2=0;
if insured_income_int=1 then insinc2=1;

insinc3=.; /*insured, high income (11)*/
if insured_income_int IN (1,2,3) then insinc3=0;
if insured_income_int=0 then insinc3=1;

if insured_income_int=. then do;
insinc1=.;
insinc2=.; 
insinc3=.; end;
run;

/* Note: Uninsured, low income (00) is the referent category so we did not create a new indicator variable for it*/

****** Q2 ****;

* Using the indicator method, determine if there is an interaction between
insurance status and income.;

proc logistic data=chs03new2 descending; 
model colon=insinc1 insinc2 insinc3; 
run;

/*

+---------------------+
|                     |
|  		Part C  	  |
|                     |
+---------------------+

*/ 

****** Q2 ****;

* Compare this model with no interaction term...;
proc logistic data=chs03new descending;
model colon=insured income; 
run;

* To this model with an interaction term;
proc logistic data=chs03new2 descending; 
model colon=insinc1 insinc2 insinc3; 
run;

* Which statistical test can we use to determine the presence of interaction?

****** Q3 ****;

* Compare this model that uses the cross-product variables...;
proc logistic data=chs03new descending; 
model colon= insured income ins_inc_Int; 
run;

* To this model that uses the indicator variables...;
proc logistic data=chs03new2 descending; 
model colon=insinc1 insinc2 insinc3; 
run;

* Are our final conclusions different whether we use the cross-product method
verus the indicator method?;

/*

+---------------------+
|                     |
|  		Appendix A 	  |
|                     |
+---------------------+

*/ 

****** Q1 ****;

* We will now use the Likelihood Ratio Test to determine if the interaction term is 
statistically significant;

* Compare this model with no interaction term...;
proc logistic data=chs03new descending;
model colon=insured income; 
run;

* To this model with an interaction term;
proc logistic data=chs03new descending; 
model colon= insured income ins_inc_Int; 
run;

/*

+---------------------+
|                     |
|  		Appendix B 	  |
|                     |
+---------------------+

*/ 

****** Q1 ****;

* We will use the following outputs from the cross-product model to hand 
calculate the confidence interval;

proc logistic data=chs03new descending;
model colon= insured income ins_inc_Int/covb rl;
run;

* If the covb option is used then in the output SAS will provide the 
covariance matrix for insured and income. We use the specified variance (var) 
and covariance (cov) values in the formula below to hand calculate the CIs;
