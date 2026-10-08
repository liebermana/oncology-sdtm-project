# Oncology SDTM Programming Portfolio

**Programmer:** Adam Lieberman  
**Programming Language:** SAS version 9.4  
**Data Source:** [CDISC Dataset Generator](https://cdiscdataset.com/)

## Project Description

This project demonstrates the process of transforming simulated raw clinical-trial data into CDISC Study Data Tabulation Model (SDTM) domains using SAS. The project uses synthetic oncology clinical-trial data and is intended to demonstrate the programming and data-management concepts involved in an SDTM implementation, including:

- Raw-data exploration
- Source-to-target mapping
- Controlled terminology
- SAS data transformation
- Quality-control review

**Current Status:** Development in progress

## Project Workflow

1. Generate synthetic raw data
2. Perform raw data exploration
3. Identify source variables
4. Review SDTMIG domain specification
5. Determine raw-to-SDTM mapping
6. Document mapping in metadata
7. Develop SAS transformation programs
8. Generate SDTM domains
9. Perform quality control
10. Review results against metadata

## GitHub Repository Structure

```text
oncology-sdtm-project/
├── README.md
├── raw_data/
├── metadata/
│   └── SDTM_METADATA.xlsx
├── sas/
│   ├── explore.sas
│   ├── dm.sas
│   ├── ae.sas
│   ├── cm.sas
│   ├── ex.sas
│   └── lb.sas
├── output/
│   └── SDTM datasets
└── documentation/
    └── mapping notes and supporting documentation
```

The repository structure may change as additional domains and QC programs are added.

## Source Data

The data used in this project are synthetic and were generated to simulate a clinical trial using the [CDISC Dataset Generator](https://cdiscdataset.com/).

The parameters used to generate the data are as follows:

- **Dataset Type:** SDTM (Tabulation)
- **Therapeutic Area:** Oncology
- **Domains:** DM (Demographics), AE (Adverse Events), CM (Concomitant Medications), EX (Exposure), LB (Laboratory Tests)
- **Output Format:** CSV
- **Number of Subjects:** 200
- **Treatment Arms:** 1

Because the data are synthetic, they do not represent actual clinical-trial participants or observations. Additional domains may be added as the project develops.

## Reference Standards and Resources

The primary references used for SDTM mapping were:

1. **SDTMIG v3.4**
2. **Implementing CDISC Using SAS: An End-to-End Guide, Revised Second Edition** by Chris Holland and Jack Shostak
   - The project uses the SDTM_METADATA.xlsx framework provided with the book as a starting point for the metadata structure.
3. **[CDISC Controlled Terminology](https://www.cdisc.org/standards/terminology/controlled-terminology)**
   - Used to identify appropriate codelists and submission values.

## Mapping Workflow

For each SDTM variable:

1. Locate the variable in the applicable SDTMIG domain specification.
2. Review the variable's Role.
3. Review the variable's Core designation.
4. Enter the corresponding metadata values into `SDTM_METADATA.xlsx`.
5. Confirm that the resulting metadata are consistent with the domain specification.

## Raw-to-SDTM Mapping Approach

Each source variable was evaluated to determine how it should be represented in the corresponding SDTM domain. Four general mapping categories were used:

1. **Direct mapping**
   - A source variable corresponds directly to an SDTM variable.
2. **Assigned**
   - There is no corresponding source variable, so an SDTM value is assigned.
3. **Derived**
   - There is no single source variable that directly corresponds to the SDTM variable. The SDTM value is calculated or constructed using one or more source variables.
4. **Not applicable / not being produced**
   - The SDTMIG or metadata template contains a variable, but the source data do not provide the information needed to populate it, and the project does not derive or assign a value.

### Example Mapping

- **Raw:** `subject_id`  
  **SDTM:** `STUDYID`  
  **Method:** Direct Mapping

- **Raw:** `height_cm + weight_kg`  
  **SDTM:** `BMI`  
  **Method:** Derived

## Role and Core / Mandatory Status

The Role assigned to each SDTM variable was based on the Role column in the SDTM Implementation Guide. The Core status was based on the Core designation in the SDTM Implementation Guide (Mandatory Status column).

**Core column terminology mapping:**

- `Req` = Required
- `Exp` = Expected
- `Perm` = Permissible
- `Req`/`Exp`/`Perm` may also be represented as `Y`/`N` in some metadata frameworks

## Controlled Terminology and Codelists

When an SDTM variable has associated controlled terminology, the CDISC Controlled Terminology resources are used to identify the appropriate codelist and submission values.

The general workflow was:

1. Identify the SDTM variable in the SDTMIG.
2. Determine whether the variable has an associated CDISC controlled terminology codelist.
3. Locate the corresponding codelist in the CDISC Controlled Terminology resource.
4. Document the appropriate codelist in the metadata.
5. Map source values to the appropriate CDISC submission values where applicable.

## Mapping Decisions and Source Variables Without Direct SDTM Equivalents

Not every source variable has a direct one-to-one equivalent in SDTM.

For example, in the AE domain, several variables did not have an SDTM equivalent:

- `reporter`
- `report_date`
- `treatment_given`
- `treatment_details`

Mapping decisions were documented in `mapping_decisions.xlsx`.
