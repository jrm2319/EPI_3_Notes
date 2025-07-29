*********** EPI III Lab 3 *********;

/*

+---------------------+
|                     |
|  		Part I    	  |
|                     |
+---------------------+

 **************************************************************************
* Run all code for Part I at the start of lab.                              *  
* Detailed information on what the code is doing are commented in the code. *
* TAs will also briefly discuss what the code is doing.                     *
 ***************************************************************************
*/


******** Q3-Q5 ***********;

*FIRST FORMAT AND RECODE THE DATA;

*You will need to run proc format for all the variables before SAS will be 
able to do any other data manipulation or run any procedures.;

*Set Values;

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
    value colon
		1='<= 10 yrs'
		2='> 10 yrs';
	value insureyn
		1= 'insured'
		0= 'uninsured';
	value fambinyn
		1='family hx'
		0='no family hx';
	value hilo
		1= 'high'
		0= 'low';
	value rothman
		0= 'insured, high income'
		1= 'uninsured, high income'
		2= 'insured, low income'
		3= 'uninsured, low income';
run;

* Upload data; 

libname Epi3 '~/my_shared_file_links/u62250266'; /*remember to change your path*/

data chs03;
	set Epi3.chs03;
	format insured insureyn.	
 		   income hilo.;	
 
 /*re-code variables to 1,2 for 2x2 table analysis*/
	if insurance in (1,2,3,4) then insured=1;/*YES*/
	else if insurance=5 then insured=0;/*NO*/
	if insurance=. then insured=.;

	if incomegroup in (2,3,4) then income=1; /*high income*/
	else if incomegroup in (1) then income=0;/*low income*/
	else if incomegroup=5 then income=.;
run;

*create a new variable with 4 categories to represent each level of insurance and income;

data lab3;
	set chs03;
	where age50up ge 1; /*we use code here to exclude people who are <50 yrs old*/
	
/*to create four groups for binary insurance and income*/;
if insured=0 and income=0 then insured_income_int=3; /*uninsured, low income-00*/
if insured=1 and income=0 then insured_income_int=2; /*insured, low income-10*/
if insured=0 and income=1 then insured_income_int=1; /*uninsured, high income-01*/
if insured=1 and income=1 then insured_income_int=0; /*insured, high income-11*/
run;

* Remember: Always check your recodes; 

proc freq data=lab3;
	where insured ne .;
	table insured_income_int*insured*income/list missing;
	format insured_income_int rothman.;
run;

* Generate 2x2 table on SAS;

proc freq data=lab3;
where insured ne .;
tables insured_income_int*colonoscopy10yr/list nocol norow nopercent;
format insured_income_int rothman.;
run;




************ Q6 *************;

* Use the following SAS commands to estimate these risk ratios 
R11/R00, R10/R00, R01/R00 and risk differences R11-R01, R10-R00
to check your hand calculations from before;

/*R11/R00*/
proc freq data=lab3;
where insured_income_int=0 or insured_income_int=3;
tables insured_income_int*colonoscopy10yr/nocol norow nopercent chisq relrisk;
format insured_income_int rothman.;
run;

/*R01/R00*/
proc freq data=lab3;
where insured_income_int=1 or insured_income_int=3;
tables insured_income_int*colonoscopy10yr/nocol norow nopercent chisq relrisk;
format insured_income_int rothman.;
run;

/*R10/R00*/
proc freq data=lab3;
where insured_income_int=2 or insured_income_int=3;
tables insured_income_int*colonoscopy10yr/nocol norow nopercent chisq relrisk;
format insured_income_int rothman.;
run;

/*R11-R01*/
proc freq data=lab3;
where insured_income_int=0 or insured_income_int=1;
tables insured_income_int*colonoscopy10yr/nocol norow nopercent chisq riskdiff;
format insured_income_int rothman.;
run;

/*R10-R00*/
proc freq data=lab3;
where insured_income_int=2 or insured_income_int=3;
tables insured_income_int*colonoscopy10yr/nocol norow nopercent chisq riskdiff;
format insured_income_int rothman.;
run;
