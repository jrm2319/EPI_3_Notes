/*********************************
*         Epi III Lab 9          *
*   GEE AND POISSON REGRESSION   *
*		    Regression           *
*                                *
*           Fall 2024            *
**********************************/

* Load in the dataset;
libname epi3 '~/my_shared_file_links/u62250266';

/******* Part 1: GEE Models *********/

/* Question 1.1 */ 

* Let's assess the degree of correlation among residents of
the same zip code. We will use the following function to help
us obtain the ICC;
proc mixed data=epi3.lab9_gee cl covtest noclprint noitprint;
	class zip_code;
	model bmi = /solution ddfm=BW;
	random intercept/subject=zip_code;
run;

/* Question 1.4 */ 

* Let's run a normal regression model without addressing the clustering
in our data. proc genmod will allow us to run all types of generalized
linear models and is powerful because we can specify the link function
and the distribution of the data. In this case, we'll do a simple
linear regression, which uses the identify link function and the
normal distribution;

proc genmod data=epi3.lab9_gee;
	class sex race income  (ref='1');
	model bmi = income age_yrs race sex race*sex /link=identity dist=normal;
run;

/* Question 1.5 */ 

* Let's run a regression model that does address the clustering in the
data. To take clustering into account/to run a model using GEE, we 
add the ‘repeated’ statement  to our syntax and include our 
cluster level id variable (zip_code) in the subject= option. 
Remember, whatever identifier is included in the repeated 
subject= statement needs to also be included in the CLASS statement;

proc genmod data=epi3.lab9_gee;
	class zip_code sex race  income (ref='1');
	model bmi = income age_yrs race sex race*sex/link=identity dist=normal;
	repeated subject=zip_code;
run;

/******* Part 2: Poisson Regression *********/

/* Question 2.2 */

* Let's run a Poisson regression to determine the effect of arsenic
levels on respiratory death;

proc genmod data=epi3.lab9_poisson order=data;
	class arsenic / PARAM=REFERENCE REF=FIRST ;
	model rescadth = arsenic /dist=poisson link=log offset=lpyrs ;
	estimate 'arsenic 2 vs 1' arsenic 1 0 0 / exp ; 
	estimate 'arsenic 3 vs 1' arsenic 0 1 0 / exp ; 
	estimate 'arsenic 4 vs 1' arsenic 0 0 1 / exp ; 
run;

/* Question 2.3 */

* Let's run a Poisson regression to determine the effect of arsenic
levels on respiratory death, now adjusting for age;

proc genmod data=epi3.lab9_poisson order=data;
	class arsenic agegrp / PARAM=REFERENCE REF=FIRST;
	model rescadth = arsenic agegrp /dist=poisson link=log offset=lpyrs ;
	estimate 'arsenic 2 vs 1' arsenic 1 0 0 / exp ; 
	estimate 'arsenic 3 vs 1' arsenic 0 1 0 / exp ; 
	estimate 'arsenic 4 vs 1' arsenic 0 0 1 / exp ; 
run;

/* Question 2.4 */

* Let us determine if period of hire acts as an effect measure modifier
for the association between arsenic and respiratory death;

* First, we will create a new variable for the cross-product interaction
term;

data epi3.lab9_poisson; 
	set epi3.lab9_poisson; 
	interaction = arsenic*hire; 
run;

* Next, let us run a model without the interaction term and calculate the 
log likelihood value;

proc genmod data=epi3.lab9_poisson order=data;
	class arsenic agegrp hire / PARAM=REFERENCE REF=FIRST;
	model rescadth = arsenic agegrp hire /dist=poisson link=log offset=lpyrs ;
run;

* Next, let us run a model with the interaction term and calculate the 
log likelihood value;

proc genmod data=epi3.lab9_poisson order=data;
	class arsenic agegrp hire interaction / PARAM=REFERENCE REF=FIRST;
	model rescadth = arsenic agegrp hire interaction /dist=poisson link=log offset=lpyrs ;
run;

/******* Appendix: Mixed Effect Models *********/

/* Question 1.5 */ 

* Let's run a regression model that does address the clustering in the
data. This time, we use a mixed effect model to address the
correlated data;

proc mixed data=epi3.lab9_gee cl covtest noclprint noitprint;
	class zip_code sex race income (ref='1');
	model bmi = income age_yrs race sex race*sex / solution ddfm = BW;
	random intercept/subject=zip_code;
run;
