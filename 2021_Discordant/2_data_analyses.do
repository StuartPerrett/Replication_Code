********************************************************************************
*** GSS 2018 Data Analyses for Discordant Benovolence
*** Author: Stuart Perrett
*** Last Ran: 10/01/2021
*** Input: .dta file containing original, re-coded and new variables
*** Output: .csv for regression tables, .gph for visualizations
********************************************************************************

clear all

version 15

*** If necessary: 
*** ssc install combomarginsplot

********************************************************************************
*** Data -- 2018 GSS
********************************************************************************

*** Add your directory

cd ""

use "Data/GSS2018SP.dta", replace	

********************************************************************************
*** Figure 1 -- Helping Bar Graphs
********************************************************************************

recode Abhelp (0=0) (1=1) (.=.), gen(Help)
	lab def Help 0 "No" 1 "Yes"

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion Help"

foreach var in `helps'{
	label values `var' yesLabel
}

collapse (mean) `helps' [aweight=wtssall] 

xpose, clear varname

set scheme plotplain

graph bar v1, over(_varname, sort(v1) label(labsize(vsmall)) gap(*2)) ///
	plotregion(fcolor(white)) yline(0(.2)1, lcolor(gs14)) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ytitle("Percent") ///
	b1title("Helping Items")

graph save HelpItems, replace

*** Clear this new dataset and replace with GSS 2018 dataset with transformed vars

clear all

use  "Data/GSS2018SP.dta" 

graph bar [aweight=wtssall], over(Abhelpindx, label(labsize(vsmall)) gap(*3)) ///
	plotregion(fcolor(white)) yscale(range(0 100)) ylabel(0 20 40 60 80 100) yline(0 20 40 60 80 100, lcolor(gs14)) b1title("Help Index")
	
graph save Abhelpindx, replace

graph combine HelpItems.gph Abhelpindx.gph

********************************************************************************
*** New Figure 2: Help x Morality
********************************************************************************

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion"

foreach var in `helps'{

	logit `var' Moral [pweight=wtssall]
	
	margins, at(Moral=(-1 0 1)) saving(file`var')
	
	est store model`var'
}

set scheme plotplainblind	

combomarginsplot fileHelpEmotion fileHelpArrange fileHelpOthCost fileHelpPayAb, ///
	labels("Emotion" "Arrange" "Other Costs" "Help Pay") ///
	file1opts(lcolor("black")) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
	xlab(-1 `""Morally" "opposed""' 0 "It depends" 1 `""Not morally    " "opposed""') ///
	ytitle(Would offer help (%)) xtitle("Moral Opposition") title("") aspectratio(.86)	
	
********************************************************************************
*** Figure 3: Predicted Values for Morality
********************************************************************************

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion"

local abortion "zRossi Moral Abinspay"

local demographics "Female age i.Race4 i.Marital i.Workstat i.Xrel6 Attendance i.Educ4 Income_90K i.Region USat16"

foreach var in `helps'{

	logit `var' `demographics'  i.Ideology `abortion' [pweight=wtssall]
	
	margins, at(Moral=(-1 0 1))
	
	marginsplot, xlab(-1 `""Morally" "opposed""' 0 "It depends" 1 `""Not morally    " "opposed""') ///
	title(`var') yscale(range(.1 1)) ytitle(Would Offer Help (%)) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") xtitle("")
	
	graph save `var'Plot, replace
}

set scheme plotplainblind	

graph combine HelpEmotionPlot.gph HelpArrangePlot.gph  HelpOthCostPlot.gph  HelpPayAbPlot.gph	

********************************************************************************
*** Defining set of locals
********************************************************************************

local helps "HelpEmotion HelpArrange HelpOthCost HelpPayAb"

local abortion "zRossi Moral Abinspay"

local demographics "Female age i.Race4 i.Marital i.Workstat i.Xrel6 Attendance i.Educ4 Income_90K i.Region USat16"


********************************************************************************
*** Table A2 -- 'Included' binary for Helping items
********************************************************************************

logit AnsweredHelp1 `demographics' [pweight=wtssall], or

eststo AnsweredHelp1

logit AnsweredHelp1 `demographics' i.Ideology [pweight=wtssall], or

eststo AnsweredHelp2

logit AnsweredHelp1 `demographics' i.Ideology `abortion' [pweight=wtssall], or

eststo AnsweredHelp3

esttab AnsweredHelp1 AnsweredHelp2 AnsweredHelp3 using "Output/Answered.csv", ///
eform b(2) se(2) replace nogap wide pr2(2) noomit star label con

********************************************************************************
*** Table A3 -- Predicting each helping item
********************************************************************************

local helps "HelpEmotion HelpArrange HelpOthCost HelpPayAb"

local abortion "zRossi Moral Abinspay"

local demographics "Female age i.Race4 i.Marital i.Workstat i.Xrel6 Attendance i.Educ4 Income_90K i.Region USat16"


foreach var in `helps'{

	logit `var' `demographics' i.Ideology `abortion' [pweight=wtssall], or
	
	eststo Logit_`var'
}

esttab Logit_HelpEmotion Logit_HelpArrange Logit_HelpOthCost Logit_HelpPayAb using "Output/Logit_Helping_Items.csv", eform b(2) se(2) replace nogap wide pr2(2) star label
	
********************************************************************************
*** Figure A1 -- Helping by Rossi with CIs
********************************************************************************

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion Help"

foreach var in `helps'{

	logit `var' Rossi [pweight=wtssall]
	
	margins, at(Rossi=(0 1 2 3 4 5 6)) saving(file`var')
	
	est store model`var'
}

combomarginsplot fileHelpEmotion fileHelpArrange fileHelpOthCost fileHelpPayAb, ///
	labels("Emotion" "Arrange" "Other Costs" "Help Pay") ///
	file1opts(lcolor("black")) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") xlab(0 `" "0"  "Most pro-life" "' 1 2 3 4 5 6 `" "6"  "Most pro-choice" "') ///
	ytitle(Would offer help (%)) xtitle("Rossi scale") title("") ///
	aspectratio(.86) xline(0(1)6, lcolor(gs14))
	
********************************************************************************
*** Figure A2 -- Helping by Ideology with CIs
********************************************************************************

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion Help"

foreach var in `helps'{

	logit `var' polviews [pweight=wtssall]
	
	margins, at(polviews=(1 2 3 4 5 6 7)) saving(file`var'2)
	
	est store model`var'2
}

combomarginsplot fileHelpEmotion2 fileHelpArrange2 fileHelpOthCost2 fileHelpPayAb2, ///
	labels("Emotion" "Arrange" "Other Costs" "Help Pay") ///
	file1opts(lcolor("black")) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") xlab(1 `" "1"  "Most liberal" "' 2 "2" 3 "3"  4 `" "4"  "Moderate" "' 5 "5" 6 "6" 7 `" "7"  "Most conservative" "') ///
	xtitle(Political View) ytitle(Would offer help (%)) title("") aspectratio(.86)
	
********************************************************************************
*** Figure A3 -- Helping by Party ID with CIs
********************************************************************************

local helps "HelpPayAb HelpOthCost HelpArrange HelpEmotion"

foreach var in `helps'{

	logit `var' Partyid7 [pweight=wtssall]
	
	margins, at(Partyid7=(0 1 2 3 4 5 6)) saving(file`var'2)
	
	est store model`var'2
}

combomarginsplot fileHelpEmotion2 fileHelpArrange2 fileHelpOthCost2 fileHelpPayAb2, ///
	labels("Emotion" "Arrange" "Other Costs" "Help Pay") ///
	file1opts(lcolor("black")) recast(line) ciopt(color(%20)) recastci(rarea) ///
	ylab(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") xlab(0 `" "Strong"  "Democrat" "' 1 "Democrat" 2 `" "Near"  "Democrat" "' 3 "Independent" 4 `" "Near"  "Republican" "' 5 "Republican" 6 `" "Strong"  "Republican" "') ///
	xtitle("") ytitle(Would offer help (%)) title("") aspectratio(.8)
