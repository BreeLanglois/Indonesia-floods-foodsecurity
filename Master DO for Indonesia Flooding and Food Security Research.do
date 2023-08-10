
****************************************************************
* Recurrent flooding & household food access in Central Java ***
* Bree dissertation research (part of NSF IRES project) ********
* Indonesia Family Life Survey *********************************
* Master DO file ***********************************************
* Written by: BKL **********************************************
* breanne.langlois@tufts.edu ***********************************
****************************************************************

*** This DO file and associated contributing DO files contain all data preparation, 
	/// cleaning, variable construction, and analysis steps ***


	*SET GLOBAL DIRECTORIES 
global rootdir "R:\Indonesia Family Life Survey\Bree data files for thesis" 
global rawdata "${rootdir}\raw data"
global reviseddata "${rootdir}\revised data"
global working "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Working datasets"
global contributingsyntaxfiles "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Syntax files\contributing DO files"

		
*****************************************************************************


    *********       ****    *********  ****       
	**      ***    *    *       *     *    *      
	**      ***   ********      *    ********     
	*********    *        *     *   *        *   
	
	   ****     ****    **    ****     *      *   *    *******    **   *******
	  *    *    **  *   **   *    *    *       * *    ****        **  ****
	 ********   **   *  **  ********   *        *         *****   **      *****
	*        *  **    **** *        *  *****    *      *******    **   *******


	***** NOTES**********
//Look at distributions of district-level flood variables from household level. In the histograms, use a large number of bins to show the true distributions
//if the distribution is highly skewed to 0 - try zero inflated distribution model? If towards 1,try truncated distribution model
//for flood exposure: Elena agrees to look at sums of fractions showing increase (from change variable) and total sums of recurrence values ranging from 8-96
//Explore random forest model in addition to regressions 
	
//Questions for Elena:	
	//should I control for the number of years/months/ or days between surveys since not all consistent and flood var will be #floods since last survey

	
use "${working}\ifls_thesis_dataset.dta", clear


	**************************
	*** Descriptive Tables ***
	**************************

	
	*** Recode variables for partchart ***
do "${contributingsyntaxfiles}\partchart_recode.do" 	
	
		
	*** Create global variable lists ***
global hhchars ut00a1 ut011 ut07aa1 own_lpf edu_level2 hhsize sc05 krk06_2 kr031 kr111 krk08_wealthier krk09_wealthier krk10_wealthier kr13_improved kr17_2_improved kr20_improved kr21_improved kr221 hr01_ho1 hr01_othhb1 hr01_vh1 hr01_apl1 hr01_jw1 hr01_sv1 hr01_rcv1 know_borrow1 ever_borrow recvd_loan kr281 recvd_cash recvd_anyasstnce hhexp krk02g1 krk02f1 krk02e1 krk02d1 krk02c1 krk02b1 krk02a1 pc1 wealth_quintiles coastal_com1 water_obstruct1 water_stand1
global commvars coastal_com1 water_obstruct1 water_stand1   
global floodvars tot_days tot_floods ch_increase episodic_fld_tot
global outcomes hdds wfood


	*** Output descriptive tables to excel (using partchart) ***
do "${contributingsyntaxfiles}\partchart_tables.do" 	
	
	*** Assess missing data ***
sort ifls_wave
by ifls_wave: mdesc $hhchars $commvars
	mdesc $hhchars $commvars
by ifls_wave: mdesc $floodvars $outcomes
	mdesc $floodvars $outcomes
	//check education var, has a lot missing
	//a lot missing for community variables, I think because some communities did not have the survey done in later waves
	//exclude edu and comm vars from analysis, do multiple imputation for the rest of the vars
	//could explore missing data further to yield important information

	
	******************
	*** Histograms ***
	******************


do "${contributingsyntaxfiles}\histograms.do" 	

			//SUMMARY:
				//Do linear mixed model for both outcomes and check that model assumptions are met



	***********************************************************
	*** Scatter plots w/linear & quadratic regression lines ***
	***********************************************************


do "${contributingsyntaxfiles}\scatter_plots.do" 	

		//Notes:
			//HH food expenditure share
				//wfood tot_days_ordinal: Small increasing linear effect overall and by wave, small nonlinear effect varies by wave... most prominent in waves 1 (convex), 2 (concave), 5 (concave).
				//wfood tot_floods: Small increasing linear effect overall and by wave, small concave nonlinear effect by wave.
				//wfood ch_increase_ordinal: Small decreasing linear effect, with an increasing effect in wave 1 only. Small nonlinear effect in waves 2 (convex) and 4 (concave).
				//wfood episodic_fld_tot_ordinal: Small decreasing linear effect, with an increasing effect in wave 1 only. Small convex nonlinear effect in waves 1, 2, 3 and overall.
			//HH diet diversity
				//hdds tot_days_ordinal: Small increasing linear effect overall and by wave, w/horizontal line for wave 2 (this was economic crisis?). Small concave nonlinear effect overall and in waves 2 and 5. wave 1 has slight convex nonlinear effect. 	
				//hdds tot_floods: Small increasing linear effect overall and by wave. Small concave nonlinear effects overall and by wave, with slight convex nonlinear effect in wave 5. 
				//hdds ch_increase_ordinal: small increasing linear effect overall and by wave. Small nonlinear concave effect in waves 1 and 4. Small convex nonlinear effect in waves 2,3,5 and overall.
				//hdds episodic_fld_tot_ordinal: small increasing linear effect overall and by wave. Small convex nonlinear effect overall and by wave, with concave nonlinear effect in wave 1.
		
		
	
	*****************
	*** Modelling ***
	*****************


	//Model 1 - unadjusted relationship of flood and each of the outcomes
		//explore linear, quadratic, and cubic terms for flood variables
	//Model 2 - bivariate relationship of each of the confounding factors, u, and each of the outcomes
	//Model 3 - full model (including differential effects based on indicators of adaptive capacity)		
	
		
	***HOUSEHOLD FOOD EXPENDITURE SHARE ('WFOOD' VARIABLE)***

//MODEL 1
do "${contributingsyntaxfiles}\model1_wfood.do" 	
	
//MODEL 2
do "${contributingsyntaxfiles}\model2_wfood.do" 		
	
//MODEL 3 - FULL MODELS, COMPLETE CASE ANALYSIS, ALL WAVES
do "${contributingsyntaxfiles}\model3_wfood.do" 	
	
	//EXPLORE DIFFERENTIAL EFFECTS BASED ON INDICATORS OF ADAPTIVE CAPACITY (sub aim to aims 2 & 3)
		//NOTE: aside from wealth index, adaptive capacity variables are only available for waves 3-5. So these models only include waves 3-5.
		do "${contributingsyntaxfiles}\model3_wfood_adaptivecapacity_w3to5.do" 	

		
//RANDOM FOREST APPROACH		
do "${contributingsyntaxfiles}\randomforest_wfood.do" 	
		
		
	
	***HOUSEHOLD DIET DIVERSITY SCORE ('HDDS' VARIABLE)***
		//NOTE: tried modelling this outcome using linear mixed models, but transformations were needed that impacted interpretability (square root transformation of the outcome). Used ordinal logit regression instead.

		
	//cross tabulations for ordinal regression models
egen hdds_ordinal = cut(hdds), group(5) label //generate ordinal variable, try 5 level var
egen hdds_ordinal4l = cut(hdds), group(4) label	
egen hdds_ordinal3l = cut(hdds), group(3) label	


foreach v of varlist tot_days_ordinal ch_increase_ordinal ch_increase2 episodic_fld_tot_ordinal episodic_fld_tot2 ut01 own_lpf sc05 kr031 move_overall {
	tab `v' hdds_ordinal
}    //cell counts look good
	
	
	
//MODEL 1
do "${contributingsyntaxfiles}\model1_hdds.do" 	//linear mixed model approach
do "${contributingsyntaxfiles}\model1_hdds_meologit.do" //mixed ordinal logit model approach
	
//MODEL 2
do "${contributingsyntaxfiles}\model2_hdds.do" 	//linear mixed model approach
do "${contributingsyntaxfiles}\model2_hdds_meologit.do" //mixed ordinal logit model approach
		
//MODEL 3 - FULL MODELS, COMPLETE CASE ANALYSIS, ALL WAVES
do "${contributingsyntaxfiles}\model3_hdds.do" 	//linear mixed model approach
do "${contributingsyntaxfiles}\model3_hdds_meologit.do" //mixed ordinal logit model approach

	
	//EXPLORE DIFFERENTIAL EFFECTS BASED ON INDICATORS OF ADAPTIVE CAPACITY (sub aim to aims 2 & 3)
		//NOTE: aside from wealth index, adaptive capacity variables are only available for waves 3-5. So these models only include waves 3-5.
	do "${contributingsyntaxfiles}\model3_hdds_adaptivecapacity_w3to5.do" 	
	

	
//RANDOM FOREST APPROACH		
do "${contributingsyntaxfiles}\randomforest_hdds.do" 	
	
	
	
	

	
// TO DO BELOW	
	
	***************************
	*** Multiple Imputation ***
	***************************
	
	//Multiple imputation (ref: https://stats.oarc.ucla.edu/stata/seminars/mi_in_stata_pt1_new/)
	//NOTE: Upon choosing to impute one or many variables, one of the first decisions you will make is the type of distribution under which you want to impute your variable(s). One available method uses Markov Chain Monte Carlo (MCMC) procedures which assume that all the variables in the imputation model have a joint multivariate normal distribution. This is probably the most common parametric approach for multiple imputation. The specific algorithm used is called the data augmentation (DA) algorithm, which belongs to the family of MCMC procedures. The algorithm fills in missing data by drawing from a conditional distribution, in this case a multivariate normal, of the missing data given the observed data. In most cases, simulation studies have shown that assuming a MVN distribution leads to reliable estimates even when the normality assumption is violated given a sufficient sample size (Demirtas et al., 2008; KJ Lee, 2010). However, biased estimates have been observed when the sample size is relatively small and the fraction of missing information is high.
	
mi set wide	//tells Stata how the imputed data is to be stored once completed
mi misstable patterns wfood tot_days_ordinal ut01 own_lpf hhsize sc05 kr031 pc1 move_overall ifls_wave
	foreach v of varlist tot_days_ordinal ut01 sc05 move_overall ifls_wave {
		tab `v', gen(`v'_)
	}  //need to create dummy variables for nominal vars so the parameter estimates for each level can be interpreted
mi register imputed hhsize kr031 ut01_1 pc1 wfood move_overall_2 move_overall_3 move_overall_4 move_overall_5 move_overall_6 //identifies which variables in the imputation model have missing information
mi impute mvn hhsize kr031 ut01_1 pc1 wfood move_overall_2 move_overall_3 move_overall_4 move_overall_5 move_overall_6 = tot_days_ordinal_2 tot_days_ordinal_3 tot_days_ordinal_4 tot_days_ordinal_5 sc05_2 ifls_wave_2 ifls_wave_3 ifls_wave_4 ifls_wave_5, add(10) rseed(17577) //specifies the imputation model to be used and the number of imputed datasets to be created, vars on the left of the equal sign have missing information while those on the right have no missing information	, setting the random # seed is not required but allows you to reproduce the same results each time

mi estimate: mixed wfood tot_days_ordinal_2 tot_days_ordinal_3 tot_days_ordinal_4 tot_days_ordinal_5 ut01_1 own_lpf hhsize sc05_2 kr031 c.pc1##c.pc1 move_overall_2 move_overall_3 move_overall_4 move_overall_5 move_overall_6 ifls_wave_2 ifls_wave_3 ifls_wave_4 ifls_wave_5 || kec_numeric: || hhid:
	mi estimate, vartable dftable
   
 
	
	
	//forest plot for visualization of reg results, unadjusted and adjusted

	//EXPLORE MORE EFFECT OF TIME & FLOODS
 //peak timing, does impact of flood change nonlinearly over time (also try just flood*time see what that looks like... can only do with DFO vars)
mixed wfood i.tot_days_ordinal#c.ifls_wave i.tot_days_ordinal#c.ifls_wave#c.ifls_wave c.ifls_wave#c.ifls_wave || kec_numeric: || hhid:
	margins i.tot_days_ordinal, at(ifls_wave=(1(1)5)) atmeans
	marginsplot
	
mixed wfood c.tot_floods##c.tot_floods c.tot_floods#c.ifls_wave i.tot_days_ordinal#c.ifls_wave#c.ifls_wave c.ifls_wave#c.ifls_wave || kec_numeric: || hhid:
	margins i.tot_days_ordinal, at(ifls_wave=(1(1)5)) atmeans
	marginsplot
	
	//ALSO LOOK AT EFFECT OF GSW VARS ON WAVE 5 OUTCOMES or on changes in outcomes
	
	


	
	*ICN abstract analysis
	do "${contributingsyntaxfiles}\ICN_abstracts.do" 
	
	
	
	
*** BURKINA FASO EXAMPLE ***

*RE: choice of standard error, if residuals are pretty normal then leave as default option, if they look weird then use robust SE
*include age#study group interaction in order to show trends over time
*add age^squared#study group interaction due to the curvature
*study arm coefficients with interactions are what we want to interpret
	 *the interaction with age^squared tells us about the rate of change (is the curved portion of the curve different)
	 *the interaction with age tells us about the slope change (is the straight portion of the curve different)
	 *if they both are significant then it tells us that the programs behave differently
	 *do not need to interpret the betas


	***** LAZ (_zlen) *****	
	
//mixed _zlen i.studyarm_gen#c.age_round i.studyarm_gen#c.age_round#c.age_round c.age_round#c.age_round || id_enfant: 
		 
	// margins i.studyarm_gen, at(age_round=(6(1)23)) atmeans
	 //marginsplot
	 
	// margins i.studyarm_gen, at(age_round=(6(1)23)) atmeans
	 //marginsplot, noci

	
	
	
	
	
	
	
	
	
	
	
	
*****************************************************************************	
	
	
    *********       ****    *********  ****         ********   ******  ******  ******
	**      ***    *    *       *     *    *        **     **  *    *  *       **    * 
	**      ***   ********      *    ********       ********   *       ***     ******
	*********    *        *     *   *        *      **         *       *       **
	                                                **         *       ******  **
	
	
***********************************************************************
**** RESHAPE INDIVIDUAL MODULES, MERGE MODULES FROM EACH WAVE INTO ****
**** ONE DATASET, THEN CONCATENATE EACH OF THE WAVES ******************
***********************************************************************

	//NOTES FROM USER GUIDE:
		//Structure of modules may differ -- some are per household, some per individual, some per event
		//Wherever possible the data have been organized so that the level of observation is either household or individual
			//HHID14 uniquely identifies households
			//Both HHID14 and PID14 are required to uniquely identify a individuals, unless PIDLINK and AR01a are used
		//When the level of observation is something other than the household or individual, it is usually because the data were collected as part of a grid, in which a set of questions was repeated for a series of items or events.
		//The variable that defines the items or events is usually named XXXTYPE, where XXX identifies the associated module

*********************************		

	***************
	*** RESHAPE ***
	***************
	
	*reshape all module data files that contain multiple observations per household
		//household data
do "${contributingsyntaxfiles}\ifls_reshaping_hh_sept2021.do" 
	

	**************************
	*** VARIABLE CROSSWALK ***
	**************************

	//crosswalk among individual data files to compare variables between all waves before merging and appending
	//this procedure done in SAS, see SAS program "IFLS Longitudinal Variable Crosswalk - Sept2021.sas"
	//Stata files converted to SAS using 'savasas' prior to running crosswalks
	//crosswalk output to 'Data sources for thesis' excel book
	//reviewed crosswalk to identify variables of interest to keep for analysis
	
	
	******************************************************************
	*** CREATE REVISED DATA FILES CONTAINING VARIABLES FOR MERGING ***
	******************************************************************

		//household data
do "${contributingsyntaxfiles}\ifls_keepvars_hh_sept2021.do" 


	*************
	*** MERGE ***
	*************
	
		//household data
do "${contributingsyntaxfiles}\ifls_merging_hh_oct2021.do" 


	************************************
	*** CONCATENATE/APPEND ALL WAVES ***
	************************************

	** household dataset **
	
use "${rootdir}\working datasets\ifls_hhmerged_wave1.dta", clear	
append using "${rootdir}\working datasets\ifls_hhmerged_wave2.dta"
append using "${rootdir}\working datasets\ifls_hhmerged_wave3.dta"
append using "${rootdir}\working datasets\ifls_hhmerged_wave4.dta"
append using "${rootdir}\working datasets\ifls_hhmerged_wave5.dta"

order ifls_wave ifls_wave_year hhid* commid*, first

label data "IFLS longitudinal dataset - BKL thesis research Oct. 2021"		
save "${rootdir}\working datasets\ifls_long_oct2021.dta", replace
	dropmiss //drops vars with all obs missing
	save "${rootdir}\working datasets\ifls_long_oct2021.dta", replace
		//dataset contains 1303 vars, 54736 obs

codebookout "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\ifls_long_codebook.xls"

	//also save to working folder
	save "${working}\ifls_long_oct2021.dta", replace


	********************************************************
	*** Consumption & expenditure aggregates for Wave 5 ****
	********************************************************

	*these were provided for earlier waves of IFLS, but not for wave 5
	*construct for wave 5 by modifying the do file that IFLS provided for wave 4
	
	do "${contributingsyntaxfiles}\pce14_BKL.do"
	
	*merge wave 5 consumption & expenditure aggregates to working dataset
use "${working}\ifls_long_oct2021.dta", clear
keep if ifls_wave==5
save "${working}\wave5_merge_pce.dta"	

merge 1:1 hhid14 using "R:\Indonesia Family Life Survey\IFLS5\hh14_all_dta\pce14nom.dta", update
drop _merge
browse mstaple-pce

save "${working}\wave5_merge_pce.dta", replace	

use "${working}\ifls_long_oct2021.dta", clear
drop if ifls_wave==5
append using "${working}\wave5_merge_pce.dta"
save "${working}\ifls_long_oct2021.dta", replace
	//dataset now contains 1315 vars, 54736 obs

	*compare variable list with original data
cfvars "${working}\ifls_long_oct2021.dta" "${rootdir}\working datasets\ifls_long_oct2021.dta"
	//the following vars are new from the wave 5 PCE merge:	 
		// _outlierks04b _outlierks07a _outlierks10aa _outlierks10ab
		// _outlierks11aa _outlierks11ab _outlierks12aa _outlierks12ab _outlierks12bb
		// lnpce _outlierfood _outlier



	********************************************************
	*** Identify number of origin & offspring households ***
	********************************************************
//Note about household IDs from IFLS doc:
	// In IFLS5, HHID14 is a seven digit character variable whose digits carry the following meaning: In the last two digits, 00 designates an origin household. For a split-off household, the 6th digit is either 1, 2, 3, 4 or 5 depending on which wave the split-off first appeared. Split-offs from IFLS2 have their sixth digit equal to 1, while split-off households first appearing in IFLS2+ have a 2, split-offs from 2000, a 3, split-offs in 2007 have a 4 and new  split-offs from 2014 a 5. The 7th digit indicates whether it is the first, second, or other split-off (some multiple split-offs occurred) for that wave. The easiest method for merging household-level information is to use the variables HHID93, HHID97, HHID00, HHID07 together with HHID14. These are compatible in their construction and so one can safely merge at the household-level using these, after renaming them with the same name.

use "${working}\ifls_long_oct2021.dta"

	*create new hhid variable
gen hhid = hhid93 if ifls_wave==1
order hhid, first
replace hhid = hhid97 if ifls_wave==2
replace hhid = hhid00 if ifls_wave==3
replace hhid = hhid07 if ifls_wave==4
replace hhid = hhid14 if ifls_wave==5

gen origin_split = substr(hhid,6,2)
order origin_split, after(hhid)

label variable origin_split "Indicator of origin or split-off household"

save "${working}\ifls_long_oct2021.dta", replace
	//dataset now contains 1317 vars, 54736 obs


	*Wave 1: a total of 7,730 households were sampled to obtain a final sample size goal of 7,000 completed households. In fact, interviews were conducted with 7,224 households in IFLS1.
	*Wave 2: IFLS2 included 6,742 origin households, plus an additional 878 new split off households for a total of 7620 households.
	*Wave 3: 6,758 origin households, 1,031 split off households from IFLS 2 (751) and 2+ (280), 2,646 new split offs from IFLS 3, total 10,435 households
	*Wave 4: 6,429 origin households, 7,107 split off households from IFLS 2 (704) and 2+ (261) and 3 (2,109), 4,033 new split offs from IFLS 4, total 13,536 households
	*Wave 5: 6,044 origin households, 9,877 split off households from IFLS 2 (607) and 2+ (207) and 3 (1,787) and 4 (3,273), 4,003 new split offs from IFLS 5, total 15,921 households

	
	*****************************
	*** Compress dataset size ***
	*****************************
	
use "${working}\ifls_long_oct2021.dta", clear
	//current size is 443.08M, 576M memory
compress 
	//297,435,424 bytes saved
	
save "${working}\ifls_long_oct2021.dta", replace
	//size is 159.42M, 256M memory


	
	**************************************
	*** PARE DOWN DATASET FOR ANALYSIS ***
	**************************************	

use "${working}\ifls_long_oct2021.dta"

do "${contributingsyntaxfiles}\ifls_thesis_dataset.do" 

label data "IFLS longitudinal dataset for analysis - BKL thesis research June 2022"

save "${working}\ifls_thesis_dataset.dta"
	
	//NOTE: see 'Master crosswalk & codebook.xlsx' file for finalized version of codebook for analysis dataset
	

	********************************************
	*** MERGE FLOOD DATA w/IFLS*****************
	********************************************
	
	//NOTE FROM IFLS: In all waves of IFLS public release data, BPS province, kabupaten, and kecamatan geographic codes are provided for locations collected (e.g., current residences, migration histories). Because BPS geographic codes change over time, a cross-walk has been provided under IFLS5 documentation as Volume 14 for these three levels of geographic codes that cover codes across 1998, 1999, 2000, 2007 and 2014 (note this excludes 1993 codes).
	//NOTE: Could not obtain shapefile of admin boundaries using 2014 BPS codes, so DFO data contains boundaries from 2020. Linkage will be made using the names rather than codes, since I do not have a cross-walk of 2014/2020 codes.
	
	***** DFO ARCHIVE DATA *****
	
	*prep DFO data for merging
		//NOTE: DFO data are already subset to central java
do "${contributingsyntaxfiles}\dfo_prep4merge.do" 

	*link DFO districts names w/IFLS crosswalk file to identify the BPS codes corresponding to the names that match (the codes will then be used to link the names to IFLS)
use "${working}\dfo_link_subdistwave.dta", clear
keep nmprov nmkab nmkec
duplicates drop //now has 576 observations, these are the individual districts that dfo floods spanned
sort nmprov nmkab nmkec
gen keclink_id = _n //create a linking id
save "${working}\dfo_unique_kecs.dta"

use "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\IFLS Geographic Location Codes\bps_codes_long.dta", clear
drop if nmprov=="" | nmkab=="" | nmkec==""
duplicates report nmprov nmkab nmkec //many dups, these are the names that were consistent accross yrs, want to keep all possible districts and identify the corresponding codes (for most recent yr if there were duplicates) for linking purposes
gsort nmprov nmkab nmkec -year
by nmprov nmkab nmkec: gen most_recent = _n
keep if most_recent==1
duplicates report nmprov nmkab nmkec //now no dups
drop most_recent
save "${working}\bps_crosswalk_unique_kecs.dta"

merge 1:1 nmprov nmkab nmkec using "${working}\dfo_unique_kecs.dta" //all but 40 of the 576 dfo districts matched
drop if _merge==1
tab year if _merge==3 //all the matched districts were from the 2014 bps codes/names, can use the 2014 codes for merging the names into thesis dataset, and then for merging 
label define kecmerge 2 "DFO only" 3 "Matched"
label value _merge kecmerge
label variable year "BPS code year"
save "${working}\dfo_bps_kecs.dta"


	*link BPS names to IFLS using 2014 codes
			//each IFLS wave used a diff BPS code scheme, so need to get all waves into 2014 codes using the crosswalk using 98 bps codes (for waves 1 & 2), 2000 bps codes (for wave 3), 2007 bps codes (for wave 4), 2014 bps codes (for wave 5) 
	
	*create file containing hhid, wave, and kecid from IFLS htrack file
do "${contributingsyntaxfiles}\ifls_create_kecid.do" 

	*link IFLS kecid created above (with diff BPS code years) to 2014 BPS codes and names
do "${contributingsyntaxfiles}\bps_crosswalk_merge.do" 
		//NOTE: when linking to 2014 codes, duplicate observations emerge. Likely b/c new kecs/districts form year after year (could be as areas become more populated, or as they change, e.g. timor-leste became an independent state)
	
	*subset to central java
use "${working}\ifls_hhkecid_names_2014bps.dta", clear
	keep if nmprov=="JAWATENGAH"
	
	*identify and resolve the duplicate kecs
	duplicates report hhid ifls_wave //11 surplus observations
	duplicates tag hhid ifls_wave, gen(dup)
	tab ifls_wave if dup>0
	tab nmprov if dup>0 //only 22 from central java
	browse if dup>0 & nmprov=="JAWATENGAH" //all are from wave 2 and 3
		drop if hhid=="0861131" & kecid==3307031
		drop if hhid=="0961921" & kecid==3305111
		drop if hhid=="1000631" & kecid==3320110
		drop if hhid=="1680111" & kecid==3307051
		drop if hhid=="1791131" & kecid==3321090
		drop if hhid=="1801832" & kecid==3322031
		drop if hhid=="1802600" & kecid==3322151
		drop if hhid=="1841511" & kecid==3324080
		drop if hhid=="1842533" & kecid==3327011
		drop if hhid=="3012000" & kecid==3371011
			//reviewed manually, dropped the ones not consistent w/the other waves
	sort hhid ifls_wave
	save "${working}\ifls_hhkecid_names_2014bps.dta", replace

	
	*merge kec names to thesis dataset by hhid/wave
use "${working}\ifls_thesis_dataset.dta", clear //54736 observations
	sort hhid ifls_wave
merge 1:1 hhid ifls_wave using "${working}\ifls_hhkecid_names_2014bps.dta" //all but 1 from using merged
	keep if _merge==3
	drop _merge
	save "${working}\ifls_thesis_dataset.dta", replace //now subset to central java w/6743 observations
	
	*merge w/DFO using kec names and wave
use "${working}\ifls_thesis_dataset.dta", clear	
	sort nmprov nmkab nmkec ifls_wave
	duplicates report nmprov nmkab nmkec ifls_wave
merge m:1 nmprov nmkab nmkec ifls_wave using "${working}\dfo_link_subdistwave.dta" //most merged, manually reviewed ones that did not merge, need to rename some kab from DFO to remove 'kota'
	use "${working}\dfo_link_subdistwave.dta", clear
		replace nmkab="MAGELANG" if nmkab=="KOTAMAGELANG"
		replace nmkab="PEKALONGAN" if nmkab=="KOTAPEKALONGAN"
		replace nmkab="SALATIGA" if nmkab=="KOTASALATIGA"
		replace nmkab="SEMARANG" if nmkab=="KOTASEMARANG"
		replace nmkab="TEGAL" if nmkab=="KOTATEGAL"	
	sort nmprov nmkab nmkec ifls_wave
	save "${working}\dfo_link_subdistwave.dta", replace

use "${working}\ifls_thesis_dataset.dta", clear	
	sort nmprov nmkab nmkec ifls_wave
merge m:1 nmprov nmkab nmkec ifls_wave using "${working}\dfo_link_subdistwave.dta" 
	drop if _merge==2 //dataset now contains DFO data, 297 of the 308 districts in the IFLS had DFO data, 11 IFLS districts did not have DFO data
	foreach v of varlist tot_days-tot_extreme {
		replace `v' = 0 if _merge==1
	} //if didn't merge with DFO, means no flood was recorded, recode vars to 0
save "${working}\ifls_thesis_dataset.dta", replace 
	
	
	***** HIGH RESOLUTION GLOBAL SURFACE WATER EXPLORER DATA *****

	*prep gswe data for merging
do "${contributingsyntaxfiles}\gswe_data_prep.do" 
	
	*merge many to 1 by district
use "${working}\ifls_thesis_dataset.dta", clear	
	sort nmkab nmkec
	merge m:1 nmkab nmkec using "${working}\gswe_occurrence.dta"  //all merged
	drop if _merge==2
	drop _merge
	merge m:1 nmkab nmkec using "${working}\gswe_change.dta"  //all merged
	drop if _merge==2
	drop _merge
	merge m:1 nmkab nmkec using "${working}\gswe_recurrence.dta"  //all merged
	drop if _merge==2
	drop _merge
	
	browse pixel* //checking that pixel counts are consistent between the GSWE datasets
					//looks good
		drop pixel_count_*

save "${working}\ifls_thesis_dataset.dta", replace 
	
	
	
	
	********************************************
	*** CONSTRUCT NEW VARIABLES FOR ANALYSIS ***
	********************************************
	
use "${working}\ifls_thesis_dataset.dta"	

***** HOUSEHOLD VARIABLES *****

	//encode kec name for random effect variable for modelling
encode nmkec, gen(kec_numeric)
	order kec_numeric, after(nmkec)
		                                                                                   //indicators of having experienced any disaster and flooding	
gen any_disaster = 1 if nd01 != "W"
	replace any_disaster=0 if any_disaster==.
	replace any_disaster=. if nd01==""
gen splitat = strpos(nd01,"A")
	gen flood = 1 if splitat > 0
	replace flood=0 if flood==.
	replace flood=. if nd01==""
	replace flood=0 if nd01=="W"
	drop splitat
	order any_disaster flood, after(nd01)
	
	//household food expenditure variable ('wfood') for wave 1 using xfoodtot and hhexp, the calculation is xfoodtot/hhexp*100
	replace wfood = (xfoodtot/hhexp)*100 if ifls_wave==1
	
	//distance household moved since previous survey, create from mover* vars
gen move_ordinal=0 if ifls_wave==1
	replace move_ordinal=mover97+1 if ifls_wave==2
	replace move_ordinal=mover00+1 if ifls_wave==3
	replace move_ordinal=mover07+1 if ifls_wave==4
	replace move_ordinal=mover14+1 if ifls_wave==5
	label variable move_ordinal "Extent household moved since previous survey"
	label define move_ordinal 0 "Baseline (Wave 1)" 1 "Did not move" 2 "w/in same desa" 3 "w/in same kec" 4 "w/in same kab" 5 "w/in same prov" 6 "other IFLS prov" 
	label values move_ordinal move_ordinal
	drop mover*
	order move_ordinal, after(sc05)
	
	//overall extent moved during entire study period
egen move_overall = max(move_ordinal), by(hhid)
	label variable move_overall "Overall extent moved during entire study period"
	label values move_overall move_ordinal
	order move_overall, after(move_ordinal)
		tab move_overall
		replace move_overall=1 if move_overall==0 //3 still coded as 0 b/c they were only in the study for wave 1 
	
	
	//interviewer observation vars, harmonize wave 1
replace krk02a=krk2a if ifls_wave==1
replace krk02b=krk2b if ifls_wave==1
replace krk02c=krk2c if ifls_wave==1
replace krk02d=krk2d if ifls_wave==1
replace krk02e=krk2e if ifls_wave==1
replace krk02f=krk2f if ifls_wave==1
replace krk02g=krk2g if ifls_wave==1
drop krk2a krk2b krk2c krk2d krk2e krk2f krk2g

save "${working}\ifls_thesis_dataset.dta", replace	

	//access to credit variables - pull from raw data
		//NOTE: not included in wave 1, section PM variables in wave 2, section BH variables for waves 3-5
do "${contributingsyntaxfiles}\credit_access_variables.do" 

	//asset ownership for wealth index, from hr01 vars
do "${contributingsyntaxfiles}\asset_ownership.do" 
		
	//level of education - pull from raw data
do "${contributingsyntaxfiles}\edu_level_variables.do" 

	//received cash assistance variables section KSR ksr06, ksr17, ksr24a, ksr38, ksr47 - pull from raw data (waves 3-5 only)
do "${contributingsyntaxfiles}\assistance_variables.do" 

	//livestock ownership - create combined / harmonized variable accross waves from hr01 vars
gen own_lpf = 0 
	replace own_lpf=1 if hr01_p==1 | hr01_lpf==1 | hr01_lf==1
	label variable own_lpf "DO ANY HH MEMBERS OWN LIVEST/POULTRY/FISHPOND?"
	drop hr01_lpf hr01_p hr01_lf hr06_lpf hr06_p hr06_lf

	//ordinal flood severity variable, create from flood exposure variable (none/yes but not severe/yes severe)
tab nd02 flood, col

gen flood_ordinal = flood
replace flood_ordinal = 2 if flood==1 & nd02==1
replace flood_ordinal = 0 if any_disaster==0
order flood_ordinal, after(nd04_fld)

save "${working}\ifls_thesis_dataset.dta", replace	

	//Household diet diversity score - needs to be derived from b1_ks1 vars	
do "${contributingsyntaxfiles}\hdds_outcome.do" 
		
		
	//calculate GSW vars to use for analysis
egen ch_increase = rowtotal(frac_101_ch-frac_200_ch)	//increase in water occurrence
	order ch_increase, after(frac_254_ch)
gen ch_increase_rounded=ch_increase*100
replace ch_increase_rounded=round(ch_increase_rounded)
	order ch_increase_rounded, after(ch_increase)
	
	
	//sums of recurrence fractions
egen episodic_fld_1	= rowtotal(frac_8_rec-frac_25_rec)  //Sum of recurrence fractions between 1-25, note no pixels had fraction values between 1-7
egen episodic_fld_2	= rowtotal(frac_26_rec-frac_50_rec)   //Sum of recurrence fractions between 26-50
egen episodic_fld_3	= rowtotal(frac_51_rec-frac_75_rec)  //Sum of recurrence fractions between 51-75
egen episodic_fld_4	= rowtotal(frac_76_rec-frac_96_rec)  //Sum of recurrence fractions between 76-99, note no pixels had values of 97,98, or 99
egen episodic_fld_tot = rowtotal(frac_8_rec-frac_96_rec)	// Sum of recurrence fractions between 1-99
	order episodic_fld_1-episodic_fld_tot, after(frac_100_rec)
gen episodic_fld_tot_rounded=episodic_fld_tot*100
replace episodic_fld_tot_rounded=round(episodic_fld_tot_rounded)
	order episodic_fld_tot_rounded, after(episodic_fld_tot)

	
label variable ch_increase "Sum of change fractions showing increased water"
label variable ch_increase_rounded "Percent of district raster cells showing increased water"
label variable episodic_fld_1	"Sum of recurrence fractions between 1-25"
label variable episodic_fld_2	"Sum of recurrence fractions between 26-50"
label variable episodic_fld_3	"Sum of recurrence fractions between 51-75"
label variable episodic_fld_4	"Sum of recurrence fractions between 76-99"
label variable episodic_fld_tot "Sum of recurrence fractions between 1-99"
label variable episodic_fld_tot_rounded "Percent of district raster cells w/episodic flooding"

	
	//calculate indicator of first and last measures
sort hhid ifls_wave
	by hhid: gen first_wave = _n
	replace first_wave=. if first_wave > 1
gsort hhid -ifls_wave
	by hhid: gen last_wave = _n
	replace last_wave=. if last_wave > 1
sort hhid ifls_wave
browse hhid ifls_wave first_wave last_wave

save "${working}\ifls_thesis_dataset.dta", replace	

	//wealth index
do "${contributingsyntaxfiles}\pca_wealthindex.do" 		
	
	
***** COMMUNITY VARIABLES *****

do "${contributingsyntaxfiles}\community_variables.do" 

	//NOTE: Can get flood data for all waves from community data from section E in Book 1 (question E10, important events in village) and Section F in Book 1 (for waves 4 and 5), but the codebook seems to be missing from the documentation. Section F is also available for the Mini-CFS data.

	gen commid=commid93 if ifls_wave==1 //create common commid and coastal variable that is constant across waves
		replace commid=commid97 if ifls_wave==2
		replace commid=commid00 if ifls_wave==3
		replace commid=commid07 if ifls_wave==4
		replace commid=commid14 if ifls_wave==5
		destring commid, replace
		drop commid93-commid14
		order commid, after(ifls_wave_year)
	xfill coastal_com, i(commid)
	
	save "${working}\ifls_thesis_dataset.dta", replace	
	
	
*****************************************************************************
