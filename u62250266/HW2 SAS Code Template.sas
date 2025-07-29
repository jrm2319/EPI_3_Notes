/*Libname specifying location of data.
If you are using desktop SAS, you need to specify your own library location*/
libname HW2 '~/my_shared_file_links/u62250266' access=readonly;

/*Formats for data set*/
Proc Format;
	value esteemLowHigh
	1 = "Low"
	0 = "High";

	value stressLE
	1 = "SLE +"
	0 = "SLE -";

	value depres
	1 = "MDD +"
	0 = "MDD -";

	value sle_esteem
	0 = "11" /*Has both exposure and modifier*/
	1 = "01" /*Doesn't have exposure but has modifier*/
	2 = "10" /*Has exposure but doesn't have modifier*/ 
	3 = "00"; /*Has neither the exposure or modifier*/
run;