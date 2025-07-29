*** EPI III Lab I ***;

/*

+---------------------+
|                     |
|  		Part A    	  |
|                     |
+---------------------+

*/


/*********

Question 1: Run the format and data statement below to input the data. Run the print procedure to verify that the data were loaded correctly.

*********/

/* PROC FORMAT allows us to label the values of a variable--the values themselves do not change, but the way they're displayed does. Formats can help make our output
easier to interpret. This format, which we've called "yn", makes a value of 1 appear as "Yes" and a value of 0 appear as "No". */

proc format;
  value yn  1='Yes'
            0='No';
run;

/* There are two main ways of bringing raw data into SAS:

- PROC IMPORT (good for reading well-organized Excel, csv, or tab-delimited files)
- DATA step (good for reading files with unusual structures, controlling the way variables are read, or writing data directly
			into our code, like below!)

*/

data CVD; *Name of the dataset we're creating;
input ID 1-3 CVD 4-5 FAMHX 6-7 OBESE 8-9 STATIN 10-11; *Define variables. These are numeric by default.
														The number ranges tell SAS where the data will
														be for a given variable (e.g. 1-3 means start
														at position 1, read until position 3.);

/* The DATALINES command tells SAS to read the following lines as data values. Each line
will be a row in our dataset. */
datalines;
1  0 1 1 1
2  0 0 0 0
3  1 1 0 0
4  1 1 1 1
5  1 0 1 0
6  0 0 0 1
7  1 1 0 0
8  1 0 0 1
9  0 0 0 1
10 1 1 1 0
11 0 1 1 1
12 0 0 0 0
13 1 1 0 0
14 1 1 1 1
15 1 0 1 0
16 0 0 0 1
17 1 1 0 0
18 1 0 0 1
19 0 0 0 1
20 1 1 1 0
;
run;

proc print data=CVD; *Look at the dataset we just created;
run;

/*********

Question 2: Create a 2x2 table of Family History and CVD status.

*********/

/* In PROC FREQ, the first variable listed will be on the rows of the 2x2 table, the second on the columns.
Traditionally, we put exposure (FAMHX) on the rows and outcome (CVD) on the columns.
Notice that the values are listed in ASCENDING order from top to down and left to right (0, then 1.) */

proc freq data=CVD;
	table FAMHX*CVD;
run;

/*********

Question 3: Flip the table so that cell 'a' is exposed/diseased. Next, use the format statement at the top
of the program to label the exposure/disease values.

*********/

/* Exposed = 1 and diseased = 1 in our data. We can flip the order by sorting the data with PROC SORT.
The DESCENDING command sorts biggest to smallest (1 to 0). */

proc sort data=CVD;
	by descending FAMHX descending CVD;
run;

proc freq data=CVD order=data; *ORDER=data tells FREQ to use the sort order of these variables in the dataset;
	table FAMHX*CVD;
run;

/* Now apply the format to our exposure and outcome variables to make them easier to read. */

proc freq data=CVD order=data;
	table FAMHX*CVD;
	format FAMHX yn. CVD yn.;
run;

/*********

Question 5: Calculate the crude OR and RR for the associations between Family History,
Statin Use, Obesity and CVD.

*********/


proc freq data=CVD order=data;
	table FAMHX*CVD / chisq relrisk; *RELRISK requests the OR and RR and their 95% CI's. You want
									  RELRISK Column 1 ("Yes"). CHISQ provides a quick measure of
									  association;
	format FAMHX yn. CVD yn.;
run;

proc sort data=CVD;
	by descending STATIN descending OBESE; *Get the other variables in the correct order;
run;

proc freq data=CVD order=data;
	table STATIN*CVD / chisq relrisk;
	format STATIN yn. CVD yn.;
run;

proc freq data=CVD order=data;
	table OBESE*CVD / chisq relrisk;
	format OBESE yn. CVD yn.;
run;

/*********

Question 8: Run the larger dataset below (CVD_2) which maintains the same proportions of exposure
and disease status as the smaller dataset CVD.

*********/

data CVD_2; *Create dataset CVD_2;
input ID 1-3 CVD 4-5 FAMHX 6-7 OBESE 8-9 STATIN 10-11;
datalines;
1  0 1 1 1
2  0 0 0 0
3  1 1 0 0
4  1 1 1 1
5  1 0 1 0
6  0 0 0 1
7  1 1 0 0
8  1 0 0 1
9  0 0 0 1
10 1 1 1 0
11 0 1 1 1
12 0 0 0 0
13 1 1 0 0
14 1 1 1 1
15 1 0 1 0
16 0 0 0 1
17 1 1 0 0
18 1 0 0 1
19 0 0 0 1
20 1 1 1 0
21 0 1 1 1
22 0 0 0 0
23 1 1 0 0
24 1 1 1 1
25 1 0 1 0
26 0 0 0 1
27 1 1 0 0
28 1 0 0 1
29 0 0 0 1
30 1 1 1 0
31 0 1 1 1
32 0 0 0 0
33 1 1 0 0
34 1 1 1 1
35 1 0 1 0
36 0 0 0 1
37 1 1 0 0
38 1 0 0 1
39 0 0 0 1
40 1 1 1 0
41 0 1 1 1
42 0 0 0 0
43 1 1 0 0
44 1 1 1 1
45 1 0 1 0
46 0 0 0 1
47 1 1 0 0
48 1 0 0 1
49 0 0 0 1
50 1 1 1 0
;
run;

/*********

Question 9: Calculate the new crude OR and RR for the associations between Family History, Statin Use,
Obesity and CVD.

*********/

proc sort data=CVD_2;
	by descending FAMHX descending STATIN descending OBESE descending CVD;
run;

proc freq data=CVD_2 order=data;
	table FAMHX*CVD / chisq relrisk;
	format FAMHX yn. CVD yn.;
run;

proc freq data=CVD_2 order=data;
	table STATIN*CVD / chisq relrisk;
	format STATIN yn. CVD yn.;
run;

proc freq data=CVD_2 order=data;
	table OBESE*CVD / chisq relrisk;
	format OBESE yn. CVD yn.;
run;

/*

+---------------------+
|                     |
|  		Part B    	  |
|                     |
+---------------------+

*/


/* Odds ratio and risk ratio

RR = Risk ratio
OR = Odds ratio
PDe = Prevalence of the disease among the unexposed

The loops below increment the prevalence among the unexposed and the risk ratio by units of 0.5.
The risk ratio relates to the odds ratio through the formula:

OR = [RR - (RR*P(D|e))] / [1 - (RR*P(D|e))]

*/

data lab1grapha; 
	do PDe = 0.01, 0.05 to 0.35 by 0.05; 
		do RR = 1.0 to 2.5 by 0.5; 
		OR = (RR - (RR*PDe)) / (1 - (RR*PDe));  
		output; 
		end; 
	end; 
run; 

/* This plot puts on the OR on the y axis, the RR on the x axis, and the lines represent different
prevalences among the unexposed. Look at what happens to the relationship between these two measures
as the prevalence among the unexposed goes up. */

proc sgplot data=lab1grapha; 
	SERIES X=RR Y=OR/GROUP=pde LINEATTRS = (THICKNESS = 4); 
	YAXIS VALUES=(1 to 14 by 1); 
	title 'Lab 1: Graph of Odds Ratio versus Risk Ratio'; 
run;


/* Incidence rate and risk ratio

RR = Risk ratio
IR = Incidence rate ratio
PDe = Prevalence of the disease among the unexposed

The risk ratio relates to the incidence rate ratio through the formula:

RR=1-exp(-IR*t)

If we assume one unit of observation time, then we can rearrange that to:

IR = log(1-RR*PDe)/log(1-PDe)

*/

data lab1graphb; 
	do PDe = 0.01, 0.05 to 0.35 by 0.05; 
		do RR = 1.0 to 2.5 by 0.5; 
		IR = log(1-RR*PDe)/log(1-PDe);  
		output; 
		end; 
	end; 
run; 

/* This plot puts on the IR on the y axis, the RR on the x axis, and the lines represent different
prevalences among the unexposed. Look at what happens to the relationship between these two measures
as the prevalence among the unexposed goes up. */

proc sgplot data=lab1graphb; 
	SERIES X=RR Y=IR/GROUP=pde LINEATTRS = (THICKNESS = 3); 
	XAXIS VALUES=(1.0 to 2.5 by 0.1);
	YAXIS VALUES=(1 to 14 by 1); 
	title 'Lab 1: Graph of Incidence Rate Ratio versus Risk Ratio'; 
run;

