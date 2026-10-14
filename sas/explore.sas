*---------------------------------------------------------------*;
* Program: explore.sas
* Author: Adam Lieberman
* Purpose: Perform an initial review of simulated clinical trial
	raw data to assess data structure, variable characteristics
	data completeness, and potential data quality issues prior to
	SDTM mapping
* Process:
	* 1. Import raw data files
	* 2. Review the contents of data files
	* 3. Review data distribution (frequency tables for categorical
			data, means for numeric data)
	* 4. Identify missingness
	* 5. Identify values requiring review
	* 6. Identify dates and study timelines
	* 7. Identify duplicate records
	* 8. Assess relationships across datasets
*---------------------------------------------------------------*;

options ls=100 ps=65 mlogic mprint symbolgen spool;

* Create library reference;
* libname raw "/home/u47160755/raw_data";

*---------------------------------------------------------------*;
* 1. Import data;
*---------------------------------------------------------------*;
%macro import(datafile,out);
proc import datafile="/home/u47160755/raw_data//&datafile."
	out=&out.
	dbms=csv
	replace;
	guessingrows=max;
	getnames=yes;
run;
%mend import;

%import(dm_raw_20260812_032533.csv,dm);
%import(ae_raw_20260812_032533.csv,ae);
%import(cm_raw_20260812_032533.csv,cm);
%import(ex_raw_20260812_032533.csv,ex);
%import(lbw_raw_20260812_032533.csv,lb);
%import(rawtu1_raw_20260812_032533.csv,tu);
%import(rawvs1_raw_20260812_032533.csv,vs);
%import(rs_raw_20260812_032533.csv,rs);

*---------------------------------------------------------------*;
* 2. Review the contents of data files;
*---------------------------------------------------------------*;
* demographics;
	* one record per subject;
proc contents data=dm; run;

* adverse events;
	* one record per adverse event;
proc contents data=ae; run;

* concominant medications ;
	* one record per medication;
proc contents data=cm; run;

* exposure to trial treatment ;
	* one record per exposure interval;
proc contents data=ex; run;

* lab test results ;
	* one record per subject-test-timepoint;
proc contents data=lb; run;

* tumor/lesion identification ;
	* one record per tumor/lesion assessment;
proc contents data=tu; run;

* vital signs ;
	* one record per vital-sign measurement;
proc contents data=vs; run;

* disease response ;
	* one record per response assessment;
proc contents data=rs; run;

*---------------------------------------------------------------*;
* 3. Review data distribution ;
*---------------------------------------------------------------*;

proc freq data=dm;
	tables sex race ethnic/missing;
run;

proc freq data=ae;
	tables aesev aeser aeout/missing;
run;


*---------------------------------------------------------------*;
* 4. Identify missingness ;
*---------------------------------------------------------------*;

*---------------------------------------------------------------*;
* 5. Identify values requiring review ;
*---------------------------------------------------------------*;

proc means data=vs n nmiss min p25 median p75 max;
run;

*---------------------------------------------------------------*;
* 6. Identify dates and study timelines ;
*---------------------------------------------------------------*;

*---------------------------------------------------------------*;
* 7. Identify duplicate records ;
*---------------------------------------------------------------*;

*---------------------------------------------------------------*;
* 8. Assess relationships across datasets ;
*---------------------------------------------------------------*;

* Assess the relational structure of your clinical trial data before mapping;
* Is the data in DM in all of the other domain datasets?;