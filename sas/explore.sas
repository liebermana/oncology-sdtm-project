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
	* 3. Review data distribution and missingness (categorical distribution, numeric distribution,
			relationships between variables within domains)
	* 4. Identify dates and study timelines
	* 5. Identify duplicate records
	* 6. Assess relationships across datasets
*---------------------------------------------------------------*;


options ls=100 ps=65 mlogic mprint symbolgen spool;

proc printto log="/home/u47160755/explore.log" new;
run;

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
* 3. Review data distribution and internal consistency ;
*---------------------------------------------------------------*;

/* DM */
proc freq data=dm;
	tables site_number gender race_category country_code medical_history smoking_status alcohol_use/missing;
run;


/* AE */
proc freq data=ae;
	tables ae_number event_term ongoing severity serious relationship_to_study_drug
			action_taken outcome hospitalization life_threatening disability death
			congenital_anomaly medically_important treatment_given treatment_details/missing;
run;


* Cross-tab analysis:;
proc freq data=ae ;
	tables event_term*relationship_to_study_drug 
			severity*action_taken
			severity*outcome
			action_taken*treatment_given*outcome
			/missing nocol nopercent ;
run;

/* CM */
proc freq data=cm;
	tables medication_number*medication_name ongoing dose_unit dose_unit*medication_name frequency route 
			medication_name*route indication/missing;
run;
* Cross-tab analysis:;
proc freq data=cm;
	tables medication_number*medication_name dose_unit*medication_name 
			medication_name*route medication_name*indication/missing;
run;

proc means data=cm n nmiss mean stddev min max;
	var dose;
	class dose_unit;
run;

/* EX */
proc freq data=ex;
	tables visit_name study_drug_name dose_unit route_of_administration formulation
			missed_doses dose_modification/missing;
run;

* Cross-tab analysis:;
proc freq data=ex;
	tables visit_name*missed_doses dose_modification*missed_doses/missing;
run;

proc means data=ex ;
	var dose_administered compliance_percent;
run;

/* LB */
proc freq data=lb;
	tables visit_name specimen_type fasting_status lab_name/missing;
run;

proc means data=lb n nmiss mean stddev min max;
	var ALBUMIN ALP ALT AST BILI BUN CALCIUM CHLORIDE CREAT GLUC HCT HGB PLT
		POTASSIUM RBC SODIUM TOTAL_PROTEIN WBC;
run;

/* TU */
proc freq data=tu;
	tables visit_name lesion_id lesion_type lesion_location measurement_method
			lesion_present target_lesion evaluable response_assessment scan_type/missing;
run;

* Cross-tab analysis:;
proc freq data=tu;
	tables scan_type*lesion_location;
run;

proc means data=tu n nmiss mean stddev min max;
	var longest_diameter_mm perpendicular_diameter_mm;
run;

/* VS */
proc freq data=vs;
	tables visit_name position_during_measurement measurement_location comments/missing;
run;

proc means data=vs n nmiss mean stddev min max;
	var diastolic_bp_mmhg oxygen_saturation_percent pulse_rate_bpm 
		respiratory_rate_breaths_per_min systolic_bp_mmhg temperature_celsius;
run;
	
/* RS */
proc freq data=rs;
	tables overall_response/missing;
run;

*---------------------------------------------------------------*;
* 4. Identify dates and study timelines ;
*---------------------------------------------------------------*;

/* DM */
proc means data=dm noprint;
    var enrollment_date informed_consent_date;
    output out=dm_dates
        min=enrollment_min consent_min
        max=enrollment_max consent_max;
run;

data _null_;
    set dm_dates;
    put "Enrollment Date: "
        enrollment_min mmddyy10. " - "
        enrollment_max mmddyy10.;
    put "Informed Consent Date: "
        consent_min mmddyy10. " - "
        consent_max mmddyy10.;
run;

* Flag if enrollment date is before consent date;
proc print data=dm;
	var study_id enrollment_date informed_consent_date;
	where enrollment_date<informed_consent_date;
run;

/* AE */
proc means data=ae noprint;
    var start_date end_date report_date;
    output out=ae_dates
        min=start_min end_min report_min
        max=start_max end_max report_max;
run;

data _null_;
    set ae_dates;
    put "AE Start Date: "
        start_min mmddyy10. " - "
        start_max mmddyy10.;
    put "AE End Date: "
        end_min mmddyy10. " - "
        end_max mmddyy10.;
    put "AE Report Date: "
        report_min mmddyy10. " - "
        report_max mmddyy10.;
run;

* Flag if start date is after end date OR start date is after report date;
proc print data=ae;
	var study_id start_date end_date report_date;
	where (start_date>end_date or start_date>report_date) and end_date ne .;
run;

/* CM */
proc means data=cm noprint;
    var start_date end_date;
    output out=cm_dates
        min=start_min end_min report_min
        max=start_max end_max report_max;
run;

data _null_;
    set cm_dates;
    put "CM Start Date: "
        start_min mmddyy10. " - "
        start_max mmddyy10.;
    put "CM End Date: "
        end_min mmddyy10. " - "
        end_max mmddyy10.;
run;

* Flag if start date is after end date;
proc print data=cm;
	var study_id start_date end_date;
	where (start_date>end_date) and end_date ne .;
run;

/* EX */
proc means data=ex noprint;
    var administration_date;
    output out=ex_dates
        min=administration_min 
        max=administration_max;
run;

data _null_;
    set ex_dates;
    put "EX Administration Date: "
        administration_min mmddyy10. " - "
        administration_max mmddyy10.;
run;

proc freq data=ex;
	tables administration_date*Visit_name / norow nocol nopercent;
run;

/* LB */
proc means data=lb noprint;
    var collection_date;
    output out=lb_dates
        min=collection_min 
        max=collection_max;
run;

data _null_;
    set lb_dates;
    put "LB Collection Date: "
        collection_min mmddyy10. " - "
        collection_max mmddyy10.;
run;

proc freq data=lb;
	tables collection_date*Visit_name / norow nocol nopercent;
run;


/* TU */
proc means data=tu noprint;
    var assessment_date scan_date;
    output out=tu_dates
        min=assessment_min scan_min
        max=assessment_max scan_max;
run;

data _null_;
    set tu_dates;
    put "TU Assessment Date: "
        assessment_min mmddyy10. " - "
        assessment_max mmddyy10.;
    put  "TU Scan Date: "
    	scan_min mmddyy10. " - "
        scan_max mmddyy10.;
run;
* Flag if assessment date is after scan date;
proc print data=tu;
	var study_id assessment_date scan_date;
	where (assessment_date>scan_date);
run;

proc freq data=tu;
	tables assessment_date*Visit_name 
			scan_date*visit_name/ norow nocol nopercent;
run;

/* VS */
proc means data=vs noprint;
    var assessment_date;
    output out=vs_dates
        min=assessment_min
        max=assessment_max;
run;

data _null_;
    set vs_dates;
    put "VS Assessment Date: "
        assessment_min mmddyy10. " - "
        assessment_max mmddyy10.;
run;

proc freq data=vs;
	tables assessment_date*Visit_name / norow nocol nopercent;
run;

/* RS- no date variables */

*---------------------------------------------------------------*;
* 5. Identify duplicate records ;
*---------------------------------------------------------------*;

proc sort data=dm; by subject_id;
data dm_dupes_check;
	set dm;
	if not (first.subject_id and last.subject_id);
	by subject_id;
run;

%macro dupes_check(dsn,by1,by2);
proc sort data=&dsn.; by &by1. &by2.; run;
data &dsn._dupes_check;
	set &dsn.;
	by &by1. &by2.;
	if not (first.&by2. and last.&by2.);
run;
%mend dupes_check;

%dupes_check(ae,subject_id, ae_number);
%dupes_check(cm,subject_id, medication_number);
%dupes_check(ex,subject_id, visit_name);
%dupes_check(lb,subject_id, visit_name);
%dupes_check(vs,subject_id, visit_name);

proc sort data=tu; by subject_id visit_name lesion_id;
data tu_dupes_check;
	set tu;
	by subject_id visit_name lesion_id;
	if not (first.lesion_id and last.lesion_id);
run;

/* RS- 3 observations */

*---------------------------------------------------------------*;
* 6. Assess relationships across datasets ;
*---------------------------------------------------------------*;

* Compare subject_id across domains;
%macro compare_id(domain);
proc sort data=&domain.(keep=subject_id) out=&domain._subj nodupkey;
	by subject_id;
run;

data &domain._subj;
	set &domain._subj;
	&domain.=1;
run;
%mend compare_id;

%compare_id(DM);
%compare_id(AE);
%compare_id(CM);
%compare_id(EX);
%compare_id(LB);
%compare_id(RS);
%compare_id(TU);
%compare_id(VS);

* Subject Matrix;
data subject_matrix;
	merge dm_subj (in=a) ae_subj (in=b) cm_subj (in=c) ex_subj (in=d) lb_subj (in=e)
			rs_subj (in=f) tu_subj (in=g) vs_subj (in=h);
	by subject_id;
	if a or b or c or d or e or f or g or h;
	
	array domains DM AE CM EX LB TU VS RS;
	
	do i=1 to dim(domains);
		if missing(domains[i]) then domains[i]=0;
	end;
	
	drop i;
run;

* Does every subject in AE/CM/EX/LB/TU/VS/RS exist in DM? - Yes;
proc print data=subject_matrix;
    where DM=0;
    var subject_id AE CM EX LB TU VS RS;
run;

* Do treatment exposures and adverse events have plausible temporal relationships?;
proc sql;
	create table ex_administration_dates as
	select subject_id,
			min(administration_date) as first_administration,
			max(administration_date) as last_administration
	from ex
	group by subject_id;
quit;
data ex_administration_dates;
	set ex_administration_dates;
	format first_administration last_administration mmddyy10.;
run;

data ae_timing;
	merge ex_administration_dates(in=a) ae (in=b);
	by subject_id;
	if b;
	
	days_from_first_exposure=start_date-first_administration;
	days_from_last_exposure=start_date-last_administration;
run;



data ae_timing;
	set ae_timing;	
/* 1. AE starts before first exposure and ends before first exposure */
	if start_date < first_administration and end_date < first_administration
		then ae_before_exposure=1;
		else ae_before_exposure=0;

/* 2. AE starts before first exposure and continues into exposure */
	if start_date < first_administration and end_date >= first_administration then
  	  ae_preexisting_at_exposure=1;
	else ae_preexisting_at_exposure=0;

	
/* 3. AE starts during exposure */
	if first_administration <= start_date and start_date <= last_administration then
    ae_during_exposure = 1;
    else ae_during_exposure=0;
    
/* 4. AE starts after final exposure */
	if start_date > last_administration then ae_after_exposure = 1;
	else ae_after_exposure=0;
   
/* 5. AE end date before start date */
	if not missing(end_date) and end_date < start_date then FLAG=1;
	else FLAG=0;
run;

proc freq data=ae_timing;
	tables ae_before_exposure ae_preexisting_at_exposure ae_during_exposure ae_after_exposure FLAG;
run;


* Are there potentially relevant temporal relationships between medication use and adverse events?;

proc sql;
    create table cm_timing as
    select
        ae.subject_id,
        ae.ae_number,
        ae.event_term,
        ae.start_date as ae_start_date,
        ae.end_date as ae_end_date,
        
        cm.medication_number,
        cm.medication_name,
        cm.start_date as med_start_date,
        cm.end_date as med_end_date,
        cm.indication
    from ae as ae
    inner join cm as cm
        on ae.subject_id = cm.subject_id;
quit;


data cm_timing;
    set cm_timing;
/* 1. Medication started before AE */
    if med_start_date < ae_start_date then cm_before_ae=1;
    else cm_before_ae=0;

/* 2. Medication active when AE started */
	if med_start_date <= ae_start_date and
	(med_end_date >= ae_start_date or missing(med_end_date)) then
	cm_active_at_ae_start=1;
    else cm_active_at_ae_start=0;

/* 3. Medication initiated during AE */
	if med_start_date >= ae_start_date and med_start_date <= ae_end_date then
	cm_started_during_ae=1;
	else cm_started_during_ae=0;

/* 4. Medication in between adverse event start and end date */
	if med_start_date <= ae_end_date and
    (med_end_date >= ae_start_date or missing(med_end_date)) then
    cm_overlap_ae=1;
	else cm_overlap_ae=0;
	
/* 5. Medication started after AE ended */
	if med_start_date > ae_end_date then
	cm_after_ae=1;
	else cm_after_ae=0;
run;


proc freq data=cm_timing;
	tables cm_before_ae cm_active_at_ae_start cm_started_during_ae cm_overlap_ae cm_after_ae
		/missing;
run;

* Are there clinically relevant observations that correspond to AE records?;

/* LB observations during AE */
proc sql;
    create table lb_ae_timing as
    select
        ae.subject_id,
        ae.ae_number,
        ae.event_term,
        ae.start_date as ae_start_date,
        ae.end_date as ae_end_date,
        
        lb.visit_name,
        lb.collection_date,
        lb.lab_name,
        lb.ALBUMIN,
        lb.ALT,
        lb.AST,
        lb.BILI,
        lb.CREAT,
        lb.HGB,
        lb.WBC
    from ae as ae
    inner join lb as lb
        on ae.subject_id = lb.subject_id
       and lb.collection_date between ae.start_date and ae.end_date;
quit;

/* VS observations during AE */
proc sql;
    create table vs_ae_timing as
    select
        ae.subject_id,
        ae.ae_number,
        ae.event_term,
        ae.start_date as ae_start_date,
        ae.end_date as ae_end_date,

        vs.assessment_date,
        vs.systolic_bp_mmhg,
        vs.diastolic_bp_mmhg,
        vs.pulse_rate_bpm,
        vs.temperature_celsius,
        vs.oxygen_saturation_percent
    from ae as ae
    inner join vs as vs
        on ae.subject_id = vs.subject_id
       and vs.assessment_date between ae.start_date and ae.end_date;
quit;

proc print data=lb_ae_timing (obs=10); run;
proc print data=vs_ae_timing (obs=10); run;


*---------------------------------------------------------------*;
* Print log and output;
*---------------------------------------------------------------*;
proc printto;
run;
