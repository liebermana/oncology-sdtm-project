###Oncology SDTM Programming Portfolio  

#Programmer: Adam Lieberman
#Programming Language: SAS version 9.4
#Data Source: CDISC Dataset Generator https://cdiscdataset.com/
#Project Description: This project demonstrates the process of transforming simulated raw clinical-trial data into CDISC Study Data Tabulation 
Model (SDTM) domains using SAS. The project uses synthetic oncology clinical-trial data and is intended to demonstrate the programming 
and data-management concepts involved in an SDTM implementation: raw-data exploration, source-to-target mapping, controlled terminology, 
SAS data transformation, and quality-control review.


#Current Status: Development in progress

#Project Workflow: 
	1) Generate Synthetic Raw Data 	
	2) Raw Data Exploration 
	3) Identify Source Variables 
	4) Review SDTMIG Domain Specification 
	5) Determine Raw-to-SDTM Mapping
	6) Document Mapping in Metadata
	7) Develop SAS Transformation Programs
	8) Generate SDTM Domains
	9) Perform Quality Control
	10) Review Results Against Metadata

#Github Repository Structure:
oncology-sdtm-project/
-README.md
-raw_data/
-metadata/
	-SDTM_METADATA.xlsx
-sas/
	-explore.sas
	-dm.sas
	-ae.sas
	-cm.sas
	-ex.sas
	-lb.sas
-output/
	-SDTM datasets
-documentation/
	-mapping notes and supporting documentation

The repository structure may change as additional domains and QC programs are added.

#Source Data: 
	The data used in this project is synthetic data used to simulate a clinical trial. To create the datasets used in this project, 
	I used the CDISC Dataset Generator: https://cdiscdataset.com/. 

	The parameters I used to generate the data are as follows:
		Dataset Type: SDTM (Tabulation)
		Therapeutic Area: Oncology
		Domain: DM- Demographics, AE- Adverse Events, CM- Concomitant Medications, EX- Exposure, LB- Laboratory Tests 
		Output Format: CSV
		Number of Subjects: 200
		Treatment Arms: 1

	Because the data are synthetic, they do not represent actual clinical-trial participants or observations.
	Additional domains may be added as the project develops.

#Reference Standards and Resources
	The primary references used for SDTM mapping were:
	1) SDTMIG v3.4 
	2) Implementing CDISC Using SAS: An End-to-End Guide, Revised Second Edition by Chris Holland and Jack Shostak
		The project uses the SDTM_METADATA.xlsx framework provided with the book as a starting point for the metadata structure.
	3) CDISC Controlled Terminology- https://www.cdisc.org/standards/terminology/controlled-terminology
		CDISC Controlled Terminology was used to identify appropriate codelists and submission values.

#Mapping Workflow

For each SDTM variable:

1. Locate the variable in the applicable SDTMIG domain specification.
2. Review the variable’s Role.
3. Review the variable’s Core designation.
4. Enter the corresponding metadata values into SDTM_METADATA.xlsx.
5. Confirm that the resulting metadata are consistent with the domain specification.

#Raw to SDTM Mapping Approach
	Each source variable was evaluated to determine how it should be represented in the corresponding SDTM domain.
	Four general mapping categories were used: 
		1. Direct mapping
			A source variable corresponds directly to an SDTM variable.
		2. Assigned
			There is no corresponding source variable, so an SDTM value is assigned 
		3. Derived
			There is no single source variable that directly corresponds to the SDTM variable. The SDTM value is calculated or constructed using one or 			more source variables.
		4. Not applicable / not being produced
			The SDTMIG or metadata template contains a variable, but the source data do not provide the information needed to populate it and the 				project does not derive or assign a value.

Example Mapping: 
  Raw:  subject_id
  SDTM: STUDYID
  Method: Direct Mapping
  
  Raw: height_cm + weight_kg
  SDTM: BMI
  Method: Derived

#Role and Core /Mandatory Status
	The Role assigned to each SDTM variable was based on the Role column in the SDTM Implementation Guide.
	The Core status was based on the Core designation in the SDTM Implementation Guide (Mandatory Status column). 
	Core column in STDM IG terminology mapping: Req=Required, Exp=Expected, Perm=Permissible OR Req=Y, Exp=Y, Perm=N

#Controlled Terminology and Codelists

When an SDTM variable has associated controlled terminology, the CDISC Controlled Terminology resources are used 
to identify the appropriate codelist and submission values.

The general workflow was:

1. Identify the SDTM variable in the SDTMIG.
2. Determine whether the variable has an associated CDISC controlled terminology codelist.
3. Locate the corresponding codelist in the CDISC Controlled Terminology resource.
4. Document the appropriate codelist in the metadata.
5. Map source values to the appropriate CDISC submission values where applicable.

#Mapping Decisions and Source Variables Without Direct SDTM Equivalents
I found that not every source variable had a direct one-to-one equivalent in SDTM.

For example in the AE domain a few variables did not have an SDTM equivalent:
  - reporter
  - report_date
  - treatment_given
  - treatment_details
  
Mapping decisions were documented in mapping_decisions.xlsx
