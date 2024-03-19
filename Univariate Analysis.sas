/******************************

Name: Ngu Hui En
Name of program: Assignment.sas
Description: Initial Data Exploration of Employee Promotion Evaluation Dataset
Date first written: Sat, 12-May-2023
Date last updated: Sat, 6-June-2023

Project Folder name: NGUHE - LAB

*******************************/

/*Read data*/
DATA EMPLOYEE;
SET NEW_LIB1.EMPLOYEE;
RUN;


/* Sampling */ 
PROC SURVEYSELECT data=EMPLOYEE out=sample
	 method=srs   /* simple random sample */
	 n=3500	 /* sample size */
	 seed=123;
RUN;

/* Duplicate the sample */
DATA sample1;
set sample;
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

/* Missing value */
/* Numerical data */
PROC MEANS DATA=SAMPLE NMISS;
TITLE 'The Missing Value of Numerical Data in Employee Promotion Evaluation Dataset';
RUN;

/* Char. data */
PROC FREQ data=SAMPLE;
tables department education gender recruitment_channel region;
TITLE 'The Frequency of Categorical Data in Employee Promotion Evaluation Dataset';
run;

/* Frequency of all attribute */
PROC FREQ data=SAMPLE;
run;

/*Summary statistics for numerical data*/
PROC MEANS DATA=SAMPLE N MEAN STD VAR SUM MODE MEDIAN P1 P5 P10 P90 P95 P99;
	VAR no_of_trainings age previous_year_rating 
	length_of_service awards_won avg_training_score is_promoted;
	TITLE "Summary Statistics for Numerical Data";
RUN;

PROC MEANS DATA=SAMPLE MIN MAX RANGE Q1 Q3 QRANGE;
	VAR no_of_trainings age previous_year_rating 
	length_of_service awards_won avg_training_score is_promoted;
	TITLE 'The Range and Interquatile Range of Data';
RUN;

/* Univariate statistics*/
PROC UNIVARIATE plot data=SAMPLE;
var employee_id age no_of_trainings previous_year_rating length_of_service 
awards_won avg_training_score is_promoted;
Title 'The Univariate Statistics of Data';
RUN;

/* Univariate plot */
/* employee id */
proc sgplot data=SAMPLE;
	histogram employee_id;
	title 'Distribution of Employee ID';
	xaxis label='Employee ID';
	yaxis label='Percentage (%)';
run;

/* age */
proc sgplot data=SAMPLE;
	histogram age;
	title 'Age Distribution of Employee';
	xaxis label='Age';
	yaxis label='Percentage (%)';
run;

/* length of service */
proc sgplot data=SAMPLE;
	histogram length_of_service;
	title 'Length of Service by Employee';
	xaxis label='Length of Service (year)';
	yaxis label='Percentage (%)';
run;

/* average training score */
proc sgplot data=SAMPLE;
	histogram avg_training_score;
	title 'Average Training Score by Employee';
	xaxis label='Average Training Score (%)';
	yaxis label='Percentage (%)';
run;

/* number of training */
proc sgplot data=SAMPLE;
   	vbar no_of_trainings/ DATALABEL ;
   	title "Number of Trainings by Employee";
   	xaxis label='Number of Training';
	yaxis label='Frequency';
run;

/* previous year rating */
proc sgplot data=SAMPLE;
   	vbar previous_year_rating/ DATALABEL;
  	title "Previous Year Rating by Employee";
	xaxis label='Previous Year Rating (1-5)';
	yaxis label='Frequency';
run;

/* awards won */
proc sgplot data=SAMPLE;
   	vbar awards_won/ DATALABEL;
   	title "Awards Won by Employee";
   	xaxis label='Awards Won';
	yaxis label='Frequency';
run;

/* department */
PROC SGPLOT DATA=SAMPLE;
	vbar department/ DATALABEL;
	title "Department Distribution of Employee";
	xaxis label='Types of Department';
	yaxis label='Frequency';
RUN;

/* region */
PROC SGPLOT DATA=SAMPLE;
	vbar region/ DATALABEL;
	title "Region Distribution of Employee";
	xaxis label='Region';
	yaxis label='Frequency';
RUN;

/* education */
PROC SGPLOT DATA=SAMPLE;
	vbar education/ DATALABEL;
	title "Education level of Employee";
	xaxis label='Education level';
	yaxis label='Frequency';
RUN;

/* gender */;
PROC SGPLOT data=SAMPLE;
	vbar gender/ STAT=PERCENT DATALABEL;
	title "Gender Distribution of Employee";
	xaxis label='Gender';
	yaxis label='Frequency';
RUN;

/* recruitment channel */
PROC SGPLOT data=SAMPLE;
	vbar recruitment_channel/ DATALABEL;
	title "Recruitment Channel Distribution of Employee";
	xaxis label='Types of Recruitment Channel';
	yaxis label='Frequency';
RUN;

/* is_promoted */
proc sgplot data=SAMPLE;
   	vbar is_promoted/ STAT=PERCENT DATALABEL;
   	title "Distribution of Promotion Status";
   	xaxis label='Promotion Status';
	yaxis label='Percentage (%)';
run;
PROC TEMPLATE;
   DEFINE STATGRAPH pie;
      BEGINGRAPH;
         LAYOUT REGION;
            PIECHART CATEGORY = is_promoted /
            DATALABELLOCATION = OUTSIDE
            CATEGORYDIRECTION = CLOCKWISE
            START = 180 NAME = 'pie';
            DISCRETELEGEND 'pie' /
            TITLE = 'Promotion Status';
         ENDLAYOUT;
      ENDGRAPH;
   END;
RUN;
PROC SGRENDER DATA = SAMPLE
            TEMPLATE = pie;
RUN;