/*

+---------------------+
|                     |
|  		Part B    	  |
|                     |
+---------------------+

 **************************************************************************
* Run all code for Part B at the start of lab.                              *  
* Detailed information on what the code is doing are commented in the code. *
* TAs will also briefly discuss what the code is doing.                     *
 ***************************************************************************
*/


/*********


/*
Extra information about Libname:
In order for SAS to call in a data set you have to provide the location 
of the dataset by giving the file path in a 'Libname' statement.
Libname gives a nickname to the file path. 
FYI: The nickname must be eight or less characters and start with a letter
*/



/* 1.	Assign a LIBNAME and import the CHS03 dataset into SAS.*/

libname EPI3 '~/my_shared_file_links/u62250266' access=readonly;


/*
if using desktop SAS, the filepath is the location of the folder where you are storing your data 
locally. On a Mac with Windows Parallels, here is an example of a file path '\\Mac\Home\Desktop\'
notice that the slashes are opposite on a Mac (\ instead of /).
If using desktop SAS on a PC here is an example'F:Desktop\EPI_III_2017'
*/ 




/* 2.	Run PROC CONTENTS to see if the data sets loaded properly/if your 
		LIBNAME was successfully assigned.*/ 

proc contents data=Epi3.chs03;
run;

		/* What we are looking for:
			1. Correct number of observations
			2. Correct number of variables
			3. All variables in the variable list 
		*/


/* 3. 	Run PROC FORMAT so that the data displays formatted variables rather than the underlying
		numeric values.*/

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
	value colon
		1='<= 10 yrs'
		2='> 10 yrs';
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
run;



/* 4. Visualize key variables, including missing data */

proc freq data=epi3.chs03;
tables insurance familyhx colonoscopy10yr /list missing;
format insurance que. familyhx famhx. colonoscopy10yr colon.;
run;


/* 5. Prepare the variables for analysis.*/

/* Create a temporary data set from the permanent  chs03 data in our library.*/
data chs03;
set epi3.chs03;

/* Subset the data to retain those age >=50 years (those NOT missing the age50up variable)*/
if ^missing(age50up);

/* Assign formats for the variables you will create below*/
format insured insureyn.	   
       fambin fambinyn.;

/*re-coding insurance and familyhx variables to 1,0 for 2x2 table analysis*/

if insurance IN (1,2,3,4) then insured=1;/*YES*/
else if insurance=5 then insured=0;/*NO*/
if insurance=. then insured=.;

if familyhx IN (1,2) then fambin=1; /*Fam Hx of colon cancer*/
else if familyhx=3 then fambin=0;/*No family hx of colon cancer*/
else if familyhx=4 then fambin=.;

run;


/*6. Run 'Proc Freq` on the age50up variable in the original data set and, separately, the new
temporary set to ensure the correct observations were retained/removed.*/

/*original*/
Proc freq data=epi3.chs03;
tables age50up/list missing;
run;

/*temporary*/
Proc freq data=chs03;
tables age50up/list missing;
run;

				/* What we are looking for: 
					1. No missing data on this variable in the temporary data set
					2. Cell counts for non-missing levels being the same across data sets
				*/
  


/*7. Run ‘Proc Freq’ crosstabs on the old and new variables to ensure the new 
variables were created correctly.*/
  
proc freq data=chs03;
tables familyhx*fambin/list missing;
run;

proc freq data=chs03;
tables insurance*insured/list missing;
run;

			/* What we are looking for: Levels of old variable correspond to correct 
			   levels of the new variables*/


/*

+---------------------+
|                     |
|  		Part C    	  |
|                     |
+---------------------+

*/


/*********




/*Part C: Question 1: Examine the crude association between your exposure 
and outcome.*/
proc freq data=chs03 order=data;
tables insured*colonoscopy10yr / chisq relrisk;/*‘chisq’ gives the chi-square and ‘relrisk’ gives the OR (and RR)*/
run;

/*****************************








/*Part C: Question 3: Examine the association between family history of colorectal cancer and insurance 
status.*/
proc freq data=chs03 order=data;
tables fambin*insured/ chisq relrisk;
run;



/* Part C: Question 3.2: Among the unexposed only, examine the association between family history of 
colorectal cancer and timely colonoscopy.*/ 
proc freq data=chs03 order=data;
where insured=0;
table fambin*colonoscopy10yr/ chisq relrisk;
run;




/******************************



/*Part C: Question 4: Examine the association of insurance coverage with timely colonoscopy in strata of 
family history of colorectal cancer.

Also, examine the adjusted association using the Mantel-Haenszel method. (this code gives you all 3 ORs)*/
proc freq data=chs03 order=data;
table fambin*insured*colonoscopy10yr / relrisk chisq cmh;/*‘cmh’ gives the MH Summary OR*/
run;

