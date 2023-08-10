
*****************************************************
**** PCA analysis for socioeconomic status **********
*****************************************************

*References: "Constructing socio-economic status indices: how to use principal components analysis" Seema Vyas and Lilani Kumaranayak & WFP guide (https://docs.wfp.org/api/documents/WFP-0000022418/download/)
 
 **STEPS:
	// 1. Select variables (common vars are: asset ownership, access to utilities 
							// and infrastructure, e.g. sanitation facility and source of water, 
							// housing characteristics, e.g. number of rooms for sleeping and building material,
							// literacy or education level or occupation of head of hh)
	// 2. Descriptive analysis for all variables:
							// PCA works best when vars are correlated, but also when the
							// distribution varies accross hhs
							// Vars with low SDs would carry a low weight from the PCA
							// Ensure the range of asset vars included is broad enough to avoid
							// problems of 'clumping' (i.e. hhs being grouped together in small
							// number of distinct clusters (if there is clumping, 1 solution is to 
							// add more variables to the analysis... other studies have used between
							// 10 to 30)
	// 3. Re-code qualitative categorical variables into binary 1/0 variables
	// 4. Assess missing data (either exclude or replace missing with the mean)
	
********************************************************
	
	
use "${working}\ifls_thesis_dataset.dta"	
	
	*view the variables that will go into the pca analysis (asset ownership, access to electricity, water source, toilet type, type of sewage disposal, type of garbage disposal, number of rooms, type of roof, floor, wall material, status of house (moderate size yard, well kept yard, adequate ventillation, stable under or next to house, house surrounded by puddles or trash or human animal waste near the house))
	
codebook hr01_ho hr01_othhb hr01_fl hr01_vh hr01_apl hr01_sv hr01_stk hr01_rcv hr01_jw hr01_oth hr01_fu hr01_nfl hr01_hsp kr03 kr11 kr13 kr14 kr15 kr16 kr17 kr18 kr19 kr20 kr21 kr22 krk06 krk08 krk09 krk10 krk02g krk02f krk02e krk02d krk02c krk02b krk02a

	//remove hr01_hsp, hr01_nfl, hr01_fu, hr01_fl, hr01_oth, hr01_stk (stocks) -- mostly missing
	//remove kr14, kr15, kr18, kr19 (location and distance of water sources) -- mostly missing likely due to skip logic

	//recode variable for bath water source, replace if same as main water source
	clonevar kr17_2=kr17
	replace kr17_2=kr13 if kr16==1
	
	//create vars for improved/unimproved water sources (from UNICEF/WHO table)
	gen kr13_improved=1 if inlist(kr13,1,2,3,4,5)
		replace kr13_improved=0 if inlist(kr13,6,7,8,10,95)
	gen kr17_2_improved=1 if inlist(kr17_2,1,2,3,4,5)
		replace kr17_2_improved=0 if inlist(kr17_2,6,7,8,10,95)	
	
	//create vars for improved/unimproved sanitation facility (from UNICEF/WHO table)
	gen kr20_improved=1 if inlist(kr20,1,2)
		replace kr20_improved=0 if inlist(kr20,3,4,5,6,7,9,10,11,95)
	gen kr21_improved=1 if inlist(kr21,1,2,3)
		replace kr21_improved=0 if inlist(kr21,4,5,7,8,9,11,95)
	
	//create vars for wealthier housing materials (from UNICEF/WHO table)
	gen krk08_wealthier=1 if inlist(krk08,1,2,3,4)
		replace krk08_wealthier=0 if inlist(krk08,5,6,95,98,99)
	gen krk09_wealthier=1 if inlist(krk09,1,2)
		replace krk09_wealthier=0 if inlist(krk09,3,95,99)
	gen krk10_wealthier=1 if inlist(krk10,1,4)
		replace krk10_wealthier=0 if inlist(krk10,2,3,5,6,95,99)
	
	*create binary indicator variables from categorical vars (coded as 1/0)
foreach v of varlist hr01_ho hr01_othhb hr01_vh hr01_apl hr01_sv hr01_rcv hr01_jw kr03 kr11 kr22 krk02g krk02f krk02e krk02d krk02c krk02b krk02a {
	tab `v', gen(`v')
}	
	
	//drop extraneous variables ('no' indicators, and indicators of categories with few n / little variation)
drop hr01_ho2 hr01_othhb2 hr01_vh2 hr01_apl2 hr01_jw2 hr01_sv2 hr01_rcv2 kr032 kr033 kr034 kr112 kr222 kr223 kr224 kr225 kr226 kr227 kr228 kr229 krk02g2 krk02g3 krk02f2 krk02f3 krk02e2 krk02e3 krk02d2 krk02d3 krk02c2 krk02c3 krk02b2 krk02b3 krk02a2 krk02a3

 //recode 99 in krk06 
clonevar krk06_2=krk06
	replace krk06_2=. if inlist(krk06_2,98,99)

 
	*view new variables that will go into PCA
browse hr01_ho1 hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr031 kr111 kr13_improved kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 krk02d1 krk02c1 krk02b1 krk02a1


**** Create SES var obtained through PCA*************


	//check assumptions for PCA 
		//Bartlett's test for sphericity and the Kaiser-Meyer-Olkin Measure of Sampling Adequacy
factortest hr01_ho1 hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr031 kr111 kr13_improved kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 krk02d1 krk02c1 krk02b1 krk02a1 
	//Bartlett's test looks good, KMO value is .74
	//can improve KMO value by removing variables with low factor loadings (less than .o5)
	
	//run PCA 
pca hr01_ho1 hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr031 kr111 kr13_improved kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 krk02d1 krk02c1 krk02b1 krk02a1
	screeplot
	estat summarize
	estat loadings
		//variables w/low factor loadings (<.05): kr13_improved
		//variables related in the opposite direction: hr01_ho1, kr031, kr13_improved, krk02a1, krk02b1, krk02c1, krk02d1 
	
		//factor test w/ low factor loadings (kr13_improved) removed
factortest hr01_ho1 hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr031 kr111 kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 krk02d1 krk02c1 krk02b1 krk02a1
			//KMO value improves to .754

		//factor test w/variables in the opposite direction removed 
factortest hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr111 kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 
			////KMO value improves to .816
			
			
	*PCA w/vars w/low loadings and those related in the opposite direction removed (same variables as above factor test)
pca hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr111 kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1 
	screeplot
	estat summarize
	estat loadings

	predict pc1, score //save principal component 1 as a variable

	
	*create wealth quintiles from principal component 1
xtile wealth_quintiles=pc1, nq (5)
	label define wealth 1 "Lowest" 2 "Mid-Low" 3 "Medium" 4 "Mid-High" 5 "Highest"
	label values wealth_quintiles wealth 
	
	
	*view the new SES variables
	sort pc1
	browse pc1 wealth_quintiles hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr111 kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1
	
	tabstat hr01_othhb1 hr01_vh1 hr01_apl1 hr01_sv1 hr01_rcv1 hr01_jw1 kr111 kr17_2_improved kr20_improved kr21_improved kr221 krk06_2 krk08_wealthier krk09_wealthier krk10_wealthier krk02g1 krk02f1 krk02e1, by(wealth_quintiles) stat(mean)


sort hhid ifls_wave
order pc1 wealth_quintiles, after(hhsize)

save "${working}\ifls_thesis_dataset.dta", replace	
