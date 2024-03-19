/******************************

Name: Ngu Hui En
Name of program: Assignment 2.sas
Description: 

1. 	Data Pre-processing
	1.1 Data Cleaning
	1.2 Handling of Missing Values
	1.3 Handling Outliers

2. 	Exploratory Data Analysis
	2.1 Pearson Correlation
	2.2 Bivariate Analysis

3. 	Feature Engineering
	3.1 Label Encoding
	3.2 One Hot Encoding
	3.3 Binning

4. 	Hypothesis
	4.1 Hypothesis 1
	4.2 Hypothesis 2
	4.3 Hypothesis 3
	4.4 Hypothesis 4
	4.5 Hypothesis 5
	4.6 Hypothesis 6
	4.7 Hypothesis 7
	4.8 Hypothesis 8
	4.9 Hypothesis 9
	4.10 Hypothesis 10
	4.11 Hypothesis 11

Date first written: Sat, 10 June-2023
Date last updated: Sun, 25 June-2023

Project Folder name: NGUHE - Assignment

*******************************/

/* Read data from library */
DATA EMPLOYEE;
   SET NEW_LIB1.EMPLOYEE;
RUN;

/* Sampling */
PROC SURVEYSELECT data=EMPLOYEE out=sample
   method=srs /* simple random sampling*/
   sampsize=3500 /* sample size */
   seed=123;
   title1 'Employee Evaluation Promotion';
   title2 'Simple Random Sampling with Control Sorting';
RUN;

/* Explore data */
*Display the first 5 observations;
PROC PRINT data=sample (obs=5);
RUN;

*Display all observations;
PROC PRINT data=sample;
RUN;

/*Metadata*/
PROC CONTENTS data=sample;
title "Employee Promotion Evaluation Dataset";
RUN;


/*--------------------- 1. DATA PREPROCESSING -----------------*/
/* 1.1 Data Cleaning */
/* Check duplicates */
proc sql;
  create table duplicate_counts as
  select employee_id, count(*) as duplicate_count
  from sample
  group by employee_id 
  having count(*) > 1;
quit;

/* Display the table */
proc print data=duplicate_counts;
  title 'Duplicate Employee IDs and Count';
run;
/* Observation: Employee ID is unique for each employee. No duplicates. */

/* Check Consistency of Data Value in All Attribute*/
PROC FREQ data=sample;
run;

/* Num. Data */
PROC UNIVARIATE plot data=sample;
var employee_id age no_of_trainings previous_year_rating length_of_service 
awards_won avg_training_score is_promoted;
Title 'The Univariate Statistics of Data';
RUN;

/* Observations: No inconsistent value detected */

/* Char. data */
PROC FREQ data=sample;
tables department education gender recruitment_channel region;
TITLE 'The Frequency of Categorical Data in Employee Promotion Evaluation Dataset';
run;

/* Rename of values */
proc sql;
  update sample
  set department = 
    case
      when department = 'HR' then 'Human Resources'
      when department = 'R&D' then 'Research & Development'
      else department
    end;
quit;

/* 1.2 Handling of Missing value */
/* 1.2.1 Check Numerical Data */
PROC MEANS data=sample NMISS;
TITLE 'The Missing Value of Numerical Data in Employee Promotion Evaluation Dataset';
RUN;

/* previous_year_rating */
/* Replace missing values with mean */
proc stdize data=sample out=sample 
reponly missing=mean;
  var previous_year_rating;
run;
/* Round imputed values to integers */
data sample;
  set sample;
  previous_year_rating = round(previous_year_rating);
run;

/* avg_training_score */
/* Replace missing values with mean */
proc stdize data=sample out=sample
reponly missing=mean;
  var avg_training_score;
run;
/* Round imputed values to integers */
data sample;
  set sample;
  avg_training_score = round(avg_training_score);
run;


/* 1.2.2 Check Categorical Data */
proc sql;
  select count(*) as total_count,
         sum(missing(department)) as department_missing_count,
         sum(missing(education)) as education_missing_count,
         sum(missing(gender)) as gender_missing_count,
         sum(missing(recruitment_channel)) as recruitment_missing_count,
         sum(missing(region)) as region_missing_count
  from sample;
quit;

/* education */
/* Replace missing values with mode */
/* Calculate mode using PROC FREQ */
proc freq data=sample;
  tables education / noprint out=mode_table(rename=(education=mode_education count=mode_count));
run;
/* Observation: Bachelor's is the mode */

proc sql;
update sample
set education="Bachelor's"
where education IS MISSING;
quit;

/* 1.2.3 Check Missing Value */
/* Check again Missing value AFTER Imputation */
proc format;
	value _nmissprint low-high="Non-missing";
	value $_cmissprint " "=" " other="Non-missing";
run;
proc freq data=sample;
	title3 "Missing Data Frequencies";
	format employee_id no_of_trainings age previous_year_rating length_of_service 
		awards_won avg_training_score is_promoted _nmissprint.;
	format department region education gender recruitment_channel $_cmissprint.;
	tables department region education gender recruitment_channel employee_id 
		no_of_trainings age previous_year_rating length_of_service awards_won 
		avg_training_score is_promoted / missing nocum;
run;
proc freq data=sample noprint;
	table department * region * education * gender * recruitment_channel * 
		employee_id * no_of_trainings * age * previous_year_rating * 
		length_of_service * awards_won * avg_training_score * is_promoted / missing 
		out=Work._MissingData_;
	format employee_id no_of_trainings age previous_year_rating length_of_service 
		awards_won avg_training_score is_promoted _nmissprint.;
	format department region education gender recruitment_channel $_cmissprint.;
run;

/* 1.3 Outlier Treatment */
/* Refer to Univariate Analysis */

proc sgplot data=sample;
	vbox age /;
	yaxis grid;
	title 'Distribution of Age';
run;
proc sgplot data=sample;
	histogram age /;
	yaxis grid;
	title 'Distribution of Age';
run;

proc sgplot data=sample;
	vbox length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;
proc sgplot data=sample;
	histogram length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;

proc sgplot data=sample;
	vbox avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;
proc sgplot data=sample;
	histogram avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;

/* Outlier treatment with log */
data work.transform;
	set work.sample;
	log_age = log(age);
	log_length_of_service=log(length_of_service);
	log_avg_training_score=log(avg_training_score);
run;

/* Log transformation graph */
proc sgplot data=transform;
	vbox log_age /;
	yaxis grid;
	title 'Distribution of Age';
run;
proc sgplot data=transform;
	histogram log_age /;
	yaxis grid;
	title 'Distribution of Age';
run;

proc sgplot data=transform;
	vbox log_length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;
proc sgplot data=transform;
	histogram log_length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;

proc sgplot data=transform;
	vbox log_avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;
proc sgplot data=transform;
	histogram log_avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;


/* Outlier treatment with SQRT */
data work.transform;
	set transform;
	sqrt_age=sqrt(age);
	sqrt_length_of_service=sqrt(length_of_service);
	sqrt_avg_training_score = sqrt(avg_training_score);
run;

/* SQRT graph */
proc sgplot data=transform;
	vbox sqrt_age /;
	yaxis grid;
	title 'Distribution of Age';
run;
proc sgplot data=transform;
	histogram sqrt_age /;
	yaxis grid;
	title 'Distribution of Age';
run;

proc sgplot data=transform;
	vbox sqrt_length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;
proc sgplot data=transform;
	histogram sqrt_length_of_service /;
	yaxis grid;
	title 'Distribution of Service Length';
run;

proc sgplot data=transform;
	vbox sqrt_avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;
proc sgplot data=transform;
	histogram sqrt_avg_training_score /;
	yaxis grid;
	title 'Distribution of Average Training Score';
run;

/* Drop column of SQRT as LOG perform better */
data work.transform;
   set transform(drop=sqrt_age sqrt_length_of_service sqrt_avg_training_score);
run;

/*--------------------- 2. Exploratory Data Analysis (EDA) -----------------*/
/* promotion status */

proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=is_promoted / stat=pct;
		endlayout;
		endgraph;
	end;
run;

proc sgrender template=SASStudio.Pie data=WORK.TRANSFORM;
run;

/* 2.1 Pearson Correlation */
proc corr data=transform;
var employee_id no_of_trainings log_age
previous_year_rating log_length_of_service
awards_won log_avg_training_score;
title 'The Pearson Correlation Coefficient Among the Input Variables';
run;

proc corr data=transform pearson nosimple plots=matrix;
	var employee_id no_of_trainings log_age 
	previous_year_rating log_length_of_service 
		awards_won log_avg_training_score;
	with is_promoted;
	TITLE 'The Pearson Correlation Coefficient of the Input Variable and Output Variable';
run;

/* Drop column of Employee ID as it has no contribution */
data work.transform;
   set transform(drop=employee_id);
run;

/* 2.2 Bivariate Analysis */

/* Promotion Status by Department */
proc freq data=transform;
   tables department * is_promoted;
   title "Department by Promotion Status";
run;
proc sgplot data=transform;
	vbar department / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Department by Promotion Status";
	xaxis label='Department';
	yaxis label='Frequency';
run;

/* Promotion Status by Region */
proc freq data=transform;
   tables region * is_promoted;
   title "Region by Promotion Status";
run;
proc sgplot data=transform;
	vbar region / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Region by Promotion Status";
	xaxis label='Region';
	yaxis label='Frequency';
run;

/* Promotion Status by Education */
proc freq data=transform;
   tables education * is_promoted;
   title "Education Level by Promotion Status";
run;
proc sgplot data=transform;
	vbar education / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Education Level by Promotion Status";
	xaxis label='Education level';
	yaxis label='Frequency';
run;

/* Promotion Status by Gender */
proc freq data=transform;
   tables gender * is_promoted;
   title "Gender by Promotion Status";
run;
proc sgplot data=transform;
	vbar gender / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Gender by Promotion Status";
	xaxis label='Gender';
	yaxis label='Frequency';
run;

/* Promotion Status by Recruitment Channel */
proc freq data=transform;
   tables recruitment_channel * is_promoted;
   title "Recruitment Channel by Promotion Status";
run;
proc sgplot data=transform;
	vbar recruitment_channel / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Recruitment Channel by Promotion Status";
	xaxis label='Recruitment Channel';
	yaxis label='Frequency';
run;

/* Promotion Status by Training Numbers */
proc freq data=transform;
   tables no_of_trainings * is_promoted;
   title "Training Numbers by Promotion Status";
run;
proc sgplot data=transform;
	vbar no_of_trainings / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Training Numbers by Promotion Status";
	xaxis label='Training Numbers';
	yaxis label='Frequency';
run;

/* Promotion Status by Age */
proc freq data=transform;
   tables log_age * is_promoted;
   title "Log Age by Promotion Status";
run;
PROC SGPLOT data=transform;
	vbox log_age/ GROUP=is_promoted;
	yaxis grid;
	title "Log Age by Promotion Status";
	xaxis label='Log Age';
	yaxis label='Frequency';
RUN;

/* Promotion Status by Previous Year Ratings */
proc freq data=transform;
   tables previous_year_rating * is_promoted;
   title "Previous Year Rating by Promotion Status";
run;
proc sgplot data=transform;
	vbar previous_year_rating / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Previous Year Rating by Promotion Status";
	xaxis label='Previous Year Rating';
	yaxis label='Frequency';
RUN;

/* Promotion Status by Service Length*/
proc freq data=transform;
   tables log_length_of_service * is_promoted;
   title "Log Service Length by Promotion Status";
run;
proc sgplot data=transform;
	vbox log_length_of_service / group=is_promoted;
	yaxis grid;
	title "Log Service Length by Promotion Status";
	xaxis label='Log Service Length';
	yaxis label='Frequency';
RUN;

/* Promotion Status by Awards Won */
proc freq data=transform;
   tables awards_won * is_promoted;
   title "Awards Won by Promotion Status";
run;
proc sgplot data=transform;
	vbar awards_won / group=is_promoted groupdisplay=stack;
	yaxis grid;
	title "Awards Won by Promotion Status";
	xaxis label='Awards Won';
	yaxis label='Frequency';
run;

/* Promotion Status by Average Training Score*/
proc freq data=transform;
   tables log_avg_training_score * is_promoted;
   title "Log Average Training Score by Promotion Status";
run;
proc sgplot data=transform;
	vbox log_avg_training_score / group=is_promoted;
	yaxis grid;
	title "Log Average Training Score by Promotion Status";
	xaxis label='Log Average Training Score';
	yaxis label='Frequency';
RUN;


/* Awards won by education */;
proc freq data=transform;
   tables awards_won * education;
   title "Awards Won by Education";
run;
PROC SGPLOT data=transform;
vbar awards_won/ GROUP=education datalabel;
title "Awards Won by Education";
xaxis label='Awards Won';
yaxis label='Frequency';
RUN;

/* Average Training Score by Education */
PROC SGPLOT data=transform;
vbox log_avg_training_score/ GROUP=education;
title "Log Average Training Score by Education";
xaxis label='Log Average Training Score';
yaxis label='Frequency';
RUN;

/* Previous Year Rating by Age and Length of Service  */
PROC SGPLOT data=transform;
  scatter x=sqrt_age y=length_of_service / group=previous_year_rating;
  reg x=sqrt_age y=length_of_service / group=previous_year_rating;
  title "Age and Length of Service by Previous Year Rating";
  xaxis label='Age';
  yaxis label='Length of Service';
run;

/* Promotion Status by Length of Service and Previous Year Ratings*/
PROC SGPLOT DATA=transform;
    Vbox length_of_service / CATEGORY=previous_year_rating GROUP=is_promoted;
    WHERE is_promoted = 1;
    TITLE "Length of Service and Previous Year Ratings by Promoted Status";
    xaxis label='Previous Year Rating (1-5)';
    yaxis label='Length of Service (year)';
RUN;

/*--------------------- 3. Feature Engineering -----------------*/
/* 3.1 Label Encoding*/
/* Education */
proc sql;
  alter table transform
    add education_encoding int;
quit;
data transform;
  set transform;
  if education = "Below Secondary" then education_encoding = 0;
  else if education = "Bachelor's" then education_encoding = 1;
  else if education = "Master's & above" then education_encoding = 2;
run;

/* Gender */
proc sql;
  alter table transform
    add gender_encoding int;
quit;
data transform;
  set transform;
  if gender = "m" then gender_encoding = 0;
  else if gender = "f" then gender_encoding = 1;
run;


/* 3.2 One Hot Encoding */
/* Department */
proc sql;
  alter table transform
    add department_analytics int,
        department_finance int,
        department_hr int,
        department_legal int,
        department_operations int,
        department_procurement int,
        department_rnd int,
        department_snm int,
        department_tech int;
quit;
data transform;
  set transform;
  department_analytics = (department = "Analytics") * 1;
  department_finance = (department = "Finance") * 1;
  department_hr = (department = "Human Resources") * 1;
  department_legal = (department = "Legal") * 1;
  department_operations = (department = "Operations") * 1;
  department_procurement = (department = "Procurement") * 1;
  department_rnd = (department = "Research & Development") * 1;
  department_snm = (department = "Sales & Management") * 1;
  department_tech = (department = "Technology") * 1;
run;

/* Recruitment channel */
proc sql;
  alter table transform
    add recruitment_other int,
        recruitment_referred int,
        recruitment_sourcing int;
quit;
data transform;
  set transform;
  recruitment_other = (recruitment_channel = "other") * 1;
  recruitment_referred = (recruitment_channel = "referred") * 1;
  recruitment_sourcing = (recruitment_channel = "sourcing") * 1;
run;


/* Region*/
proc sql;
  alter table transform
    add region_1 int,
    	region_2 int,
    	region_3 int,
    	region_4 int,
    	region_5 int,
    	region_6 int,
    	region_7 int,
    	region_8 int,
    	region_9 int,
    	region_10 int,
    	region_11 int,
    	region_12 int,
    	region_13 int,
    	region_14 int,
    	region_15 int,
    	region_16 int,
    	region_17 int,
    	region_18 int,
    	region_19 int,
    	region_20 int,
    	region_21 int,
    	region_22 int,
    	region_23 int,
    	region_24 int,
    	region_25 int,
    	region_26 int,
    	region_27 int,
    	region_28 int,
    	region_29 int,
    	region_30 int,
    	region_31 int,
    	region_32 int,
    	region_33 int,
    	region_34 int;
quit;
data transform;
set transform;
region_1 = (region = "region_1") * 1;
region_2 = (region = "region_2") * 1;
region_3 = (region = "region_3") * 1;
region_4 = (region = "region_4") * 1;
region_5 = (region = "region_5") * 1;
region_6 = (region = "region_6") * 1;
region_7 = (region = "region_7") * 1;
region_8 = (region = "region_8") * 1;
region_9 = (region = "region_9") * 1;
region_10 = (region = "region_10") * 1;
region_11 = (region = "region_11") * 1;
region_12 = (region = "region_12") * 1;
region_13 = (region = "region_13") * 1;
region_14 = (region = "region_14") * 1;
region_15 = (region = "region_15") * 1;
region_16 = (region = "region_16") * 1;
region_17 = (region = "region_17") * 1;
region_18 = (region = "region_18") * 1;
region_19 = (region = "region_19") * 1;
region_20 = (region = "region_20") * 1;
region_21 = (region = "region_21") * 1;
region_22 = (region = "region_22") * 1;
region_23 = (region = "region_23") * 1;
region_24 = (region = "region_24") * 1;
region_25 = (region = "region_25") * 1;
region_26 = (region = "region_26") * 1;
region_27 = (region = "region_27") * 1;
region_28 = (region = "region_28") * 1;
region_29 = (region = "region_29") * 1;
region_30 = (region = "region_30") * 1;
region_31 = (region = "region_31") * 1;
region_32 = (region = "region_32") * 1;
region_33 = (region = "region_33") * 1;
region_34 = (region = "region_34") * 1;
run;

*Display the first 5 observations;
PROC PRINT data=transform (obs=5);
RUN;

/* 3.3 Binning */
/* Binning Age variable */
proc hpbin data=transform out=bin_age;
   input age / numbin=4;
run;
/* Merge bin_age into transform */
data transform;
   merge transform bin_age;
run;
/* Create Histogram */
proc sgplot data=transform;
   vbar bin_age / DATALABEL; 
   xaxis grid;
   yaxis grid;
   title 'Age Range Distribution';
run;


/* Binning Service length variable */
proc hpbin data=transform out=bin_length_of_service;
   input length_of_service / numbin=4;
run;
/* Merge bin_length_of_service into transform */
data transform;
   merge transform bin_length_of_service;
run;
/* Create Histogram */
proc sgplot data=transform;
   vbar bin_length_of_service / DATALABEL; 
   xaxis grid;
   yaxis grid;
   title 'Service Length Range Distribution';
run;


/* Binning Average Training Score variable */
proc hpbin data=transform out=bin_avg_training_score;
   input avg_training_score / numbin=4;
run;
/* Merge bin_length_of_service into transform */
data transform;
   merge transform bin_avg_training_score;
run;
/* Create Histogram */
proc sgplot data=transform;
   vbar bin_avg_training_score / DATALABEL; 
   xaxis grid;
   yaxis grid;
   title 'Average Training Score Range Distribution';
run;

/* Check the results*/
proc print data=transform;
run;


/*--------------------- 4. Hypothesis -----------------*/
/* 4.1 Hypothesis 1 */
/*
H0: There is no significant difference in the promotion rates between employees in different departments.
H1: There is a significant difference in the promotion rates between employees in different departments.
*/
proc freq data=transform;
  tables department*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Departments';
proc glm data=WORK.TRANSFORM;
	class department;
	model is_promoted=department;
	means department / hovtest=levene welch plots=none;
	lsmeans department / adjust=tukey pdiff alpha=.05;
	run;
quit;


/* 4.2 Hypothesis 2 */
/*
H0: There is no relationship between the recruitment channel and employee promotions.
H1: There is a relationship between the recruitment channel and employee promotions.
*/
proc freq data=transform;
  tables recruitment_channel*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Recruitment Channel';
proc glm data=WORK.TRANSFORM;
	class recruitment_channel;
	model is_promoted=recruitment_channel;
	means recruitment_channel / hovtest=levene welch plots=none;
	lsmeans recruitment_channel / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.3 Hypothesis 3 */
/* 
H0: There is no significant difference in the promotion rates between male and female employees.
H1: There is a significant difference in the promotion rates between male and female employees.
*/
proc freq data=transform;
  tables gender*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Gender';
proc glm data=WORK.TRANSFORM;
	class gender;
	model is_promoted=gender;
	means gender / hovtest=levene welch plots=none;
	lsmeans gender / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.4 Hypothesis 4 */
/* 
H0: Age does not have a significant impact on the likelihood of promotion.
H1: Employees with higher age are more likely to be promoted.
*/
proc ttest data=transform;
  class is_promoted;
  var log_age;
run;
title 'ANOVA: Difference in Promotion Rates Between Age';
proc glm data=WORK.TRANSFORM;
	class bin_age;
	model is_promoted=bin_age;
	means bin_age / hovtest=levene welch plots=none;
	lsmeans bin_age / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.5 Hypothesis 5 */
/* 
H0: The length of service does not have a significant impact on the likelihood of promotion.
H1: Employees with longer length of service are more likely to be promoted.
*/
proc ttest data=transform;
  class is_promoted;
  var log_length_of_service;
run;
title 'ANOVA: Difference in Promotion Rates Between Service Length';
proc glm data=WORK.TRANSFORM;
	class bin_length_of_service;
	model is_promoted=bin_length_of_service;
	means bin_length_of_service / hovtest=levene welch plots=none;
	lsmeans bin_length_of_service / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.6 Hypothesis 6 */
/* 
H0: There is no significant difference in promotion rates between employees with different previous year ratings.
H1: Employees with higher previous year ratings are more likely to be promoted.
*/
proc freq data=transform;
  tables previous_year_rating*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Previous Year Ratings';
proc glm data=WORK.TRANSFORM;
	class previous_year_rating;
	model is_promoted=previous_year_rating;
	means previous_year_rating / hovtest=levene welch plots=none;
	lsmeans previous_year_rating / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.7 Hypothesis 7 */
/* 
H0: The awards won does not have a significant impact on the likelihood of promotion.
H1: Employees with awards won are more likely to be promoted.
*/
proc freq data=transform;
  tables awards_won*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Awards Won';
proc glm data=WORK.TRANSFORM;
	class awards_won;
	model is_promoted=awards_won;
	means awards_won / hovtest=levene welch plots=none;
	lsmeans awards_won / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.8 Hypothesis 8 */
/* 
H0: There is no significant difference in promotion rates between employees with higher and lower average training scores.
H1: Employees with higher average training scores are more likely to be promoted.
*/
proc ttest data=transform;
  class is_promoted;
  var log_avg_training_score;
run;
title 'ANOVA: Difference in Promotion Rates Between Average Training Score';
proc glm data=WORK.TRANSFORM;
	class bin_avg_training_score;
	model is_promoted=bin_avg_training_score;
	means bin_avg_training_score / hovtest=levene welch plots=none;
	lsmeans bin_avg_training_score / adjust=tukey pdiff alpha=.05;
	run;
quit;


/* 4.9 Hypothesis 9 */
/* 
H0: There is no association between the education level of employees and their promotion status.
H1: There is an association between the education level of employees and their promotion status.
*/
proc freq data=transform;
  tables education*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Education Level';
proc glm data=WORK.TRANSFORM;
	class education;
	model is_promoted=education;
	means education / hovtest=levene welch plots=none;
	lsmeans education / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.10 Hypothesis 10 */
/* 
H0: The number of trainings does not have a significant impact on the likelihood of promotion.
H1: Employees with a higher number of trainings are more likely to be promoted.
*/
proc freq data=transform;
  tables no_of_trainings*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Training Number';
proc glm data=WORK.TRANSFORM;
	class no_of_trainings;
	model is_promoted=no_of_trainings;
	means no_of_trainings / hovtest=levene welch plots=none;
	lsmeans no_of_trainings / adjust=tukey pdiff alpha=.05;
	run;
quit;

/* 4.11 Hypothesis 11 */
/* 
H0: There is no association between the region of employees and their promotion status.
H1: There is an association between the region of employees and their promotion status.
*/
proc freq data=transform;
  tables region*is_promoted / chisq;
run;
title 'ANOVA: Difference in Promotion Rates Between Region';
proc glm data=WORK.TRANSFORM;
	class region;
	model is_promoted=region;
	means region / hovtest=levene welch plots=none;
	lsmeans region / adjust=tukey pdiff alpha=.05;
	run;
quit;