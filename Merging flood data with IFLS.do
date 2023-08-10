
	********************************************
	*** MERGE FLOOD DATA w/IFLS*****************
	********************************************
	
	//NOTE FROM IFLS: In all waves of IFLS public release data, BPS province, kabupaten, and kecamatan geographic codes are provided for locations collected (e.g., current residences, migration histories). Because BPS geographic codes change over time, a cross-walk has been provided under IFLS5 documentation as Volume 14 for these three levels of geographic codes that cover codes across 1998, 1999, 2000, 2007 and 2014 (note this excludes 1993 codes).
	//NOTE: Could not obtain shapefile of admin boundaries using 2014 BPS codes, so DFO data contains boundaries from 2020. Linkage will be made using the names rather than codes, since I do not have a cross-walk of 2014/2020 codes.
	
	***** DFO ARCHIVE DATA *****
	
	*prep DFO data for merging
		//NOTE: DFO data are already subset to central java
do "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Syntax files\contributing DO files\dfo_prep4merge.do" 

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
do "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Syntax files\contributing DO files\ifls_create_kecid.do" 

	*link IFLS kecid created above (with diff BPS code years) to 2014 BPS codes and names
do "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Syntax files\contributing DO files\bps_crosswalk_merge.do" 
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
do "C:\Users\BLANGL01\Box\School - NEDS PhD\Dissertation Research - Working Folder\Data\Syntax files\contributing DO files\gswe_data_prep.do" 
	
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
	
