********************************************************************************
*** GSS 2018 Data Preparation for Discordant Benovolence Analyses
*** Author: Stuart Perrett
*** Last Ran: 10/01/2021
*** Input: .dta file of 2018 General Social Survey
*** Output: .dta file containing original, re-coded and new variables
********************************************************************************

clear all

version 15

********************************************************************************
*** Import data
********************************************************************************

*** Add your directory

cd ""

use "Raw_Data/GSS2018.dta"

********************************************************************************
*** Generating new variables -- Demographics from Mike Hout
********************************************************************************

***************************************
*** Race4 and Xrel  
***************************************

*** Combine weights for black oversamples (1983 & 1987)
*** and non-response (2004+)
gen Compwt=oversamp*wtssnr
svyset [weight=Compwt], strata (vstrat) psu(vpsu) singleunit(scaled)
lab var Compwt "Oversamples of non-respondents (2004+) & blacks (1983-87)"
lab var year Year

***************************************
***  Racial & Ethnic categories
***************************************
gen Ethnicx = ethnic if ethnic<.
replace Ethnicx = eth1 if Ethnicx>=.
replace Ethnicx = eth2 if Ethnicx>=.
replace Ethnicx = eth3 if Ethnicx>=.

recode Ethnicx 8=1 14=2 2 11 27=3 15=4 21=5 24=6 7 9 26 19=7 3 10=8 6 13 34 35=9 18 36=10 23 33=11 12 32=12 4 97=13 30=14 17 22 25 38=16 5 16 20 31 40=17  *=97

gen Latino = ethnic==17
replace Latino = 1 if ethnic==22
replace Latino = 1 if ethnic==25
replace Latino = 1 if ethnic==28
replace Latino = 1 if ethnic==38
replace Latino = 1 if eth1==17
replace Latino = 1 if eth1==22
replace Latino = 1 if eth1==25
replace Latino = 1 if eth1==28
replace Latino = 1 if eth1==38
replace Latino = 1 if eth2==17
replace Latino = 1 if eth2==22
replace Latino = 1 if eth2==25
replace Latino = 1 if eth2==28
replace Latino = 1 if eth2==38
replace Latino = 1 if eth3==17
replace Latino = 1 if eth3==22
replace Latino = 1 if eth3==25
replace Latino = 1 if eth3==28
replace Latino = 1 if eth3==38
lab var Latino "Hispanic Heritage"
lab def Latino 0 "Other" 1 "Latino"
lab val Latino Latino

***  Amalgamate race and ancestry into Race4
gen Race4=2 if race==2
replace Race4=3 if hispanic>1 & hispanic<.
replace Race4=3 if Latino==1 & hispanic>=.
replace Race4=1 if race==1 & Race4>=.
replace Race4=4 if Race4>=.
lab var Race4 "Race and/or ancestry"
lab def Race4 1 "White" 2 "Black" 3 "Hispanic or Latino/a" 4 "All other"
lab val Race4 Race4
gen Black=Race4==2
lab var Black "African American"
lab def Black 0 Other 1 Black
lab val Black Black

***************************************
***  Religious categories
***************************************
gen Xaffil = 0 
replace Xaffil = 3 if relig==1
replace Xaffil = 4 if relig==2
replace Xaffil = 5 if relig==3
replace Xaffil = 9 if relig==4
replace Xaffil = 6 if ((relig>4 & relig<11) | relig==12)

***  Separate conservative and mainline Protestants.
replace Xaffil = 1 if relig==1 & fund==1

***  Put "Christian" and "Inter-denominational" into conservative Protestant.
replace Xaffil = 1 if relig==11 | relig==13

label var Xaffil "Current Religion"
label def Xaffil 1 "Conservative Protestant" 2 "AfAm Protestant" 3 "Mainline Protestant" 4 "Catholic" 5 "Jewish" 6 "Other religion" 9 "No religion", modify
label val Xaffil Xaffil

*** Break down religious groups by evangelicals, Black Protestants,
*** mainline, liberal & conservative nontraditional Protestants,
*** and Protestant nondemonination/no denomination.

*** Following are Black sectarians.
recode other 7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133=1 *=0, gen(Xbp)

*** Following are historically Black churches.
replace Xbp=1 if denom==12
replace Xbp=1 if denom==13
replace Xbp=1 if denom==20
replace Xbp=1 if denom==21

*** Following are Black methodists.
replace Xbp=1 if (denom==23 | denom==28) & race==2

*** Following are Black baptists.
replace Xbp=1 if (denom==10 | denom==11 | denom==14 | denom==15 | denom==18) & race==2
replace Xbp=1 if other==93 & race==2

replace Xaffil = 2 if Xbp==1

*** Following two commands put sectarians into evangelical.
recode other 1 2 3 5 6 9 10 12 13 16 18 19 20 22 23 24 26 27 28 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 134 135 138 139 140 146=1 *=0, gen(Xev)

*** Put conserv methodists into evangelical
replace Xev=1 if denom==23 & race~=2

*** Put conservative lutherans into evangelical.
replace Xev=1 if denom==32 | denom==33 | denom==34

*** Put conserv presbyterians into evangelical.
replace Xev=1 if denom==42

*** Put white Baptists into evangelical.
replace Xev=1 if (denom ==10 | denom ==14 | denom ==15 | denom ==18 | other==93) & race~=2

*** Mainline Protestants
recode other 8 25 40 44 46 48 49 50 54 70 71 72 73 81 96 99       ///
	105 119 148=1 *=0, gen(Xml)
replace Xml=1 if (denom==11 | denom==22 | denom==30 | denom==31 | ///
	denom==35 | denom==38 | denom==40 | denom==41 | denom==43 |   ///
	denom==48 | denom==50) & Xbp<1

*** Non-Black generic Methodists into Mainline.
replace Xml=1 if denom==28 & race~=2

*** Catholics
gen Xcath = (Xaffil==4)
replace Xcath=1 if other==123

*** Jewish
gen Xjew = (Xaffil==5)

*** Adherents of other religions
gen Xother = (Xaffil==6 & Xev~=1)

*** Conservative and liberal nontraditionals into other.
recode other 11 17 29 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 130 136 141 145=1 *=0, gen(Xoth2)
replace Xother=1 if Xoth2==1

*** NO DENOM / NONDENOM PROTESTANTS.
gen Xprotdk = (denom==70)

* Get rid of no denoms/nondenoms who attend less than once a month
* and puts those who attend in evangelical.
replace Xev=1 if (attend>3 & attend<9) & Xprotdk==1

* Generate None
gen None=relig==4   if relig<.

* Generate reltrad & label categories
gen Reltrad = Xev + 2*Xml + 3*Xbp + 4*Xcath + 5*Xjew + 6*Xother + 7*None
replace Reltrad=. if Reltrad==0

label def Reltrad 1 "Evangelical" 2 "Mainline" 3 "Black Protestant" 4 "Catholic" 5 "Jewish" 6 "Other faith" 7 "Nonaffiliated", modify

label val Reltrad Reltrad
label var Reltrad "Religious Tradition - Current"

***   Repeat for reltrad16
gen Xaffil16 = 0 
replace Xaffil16 = 3 if relig16==1
replace Xaffil16 = 4 if relig16==2
replace Xaffil16 = 5 if relig16==3
replace Xaffil16 = 9 if relig16==4
replace Xaffil16 = 6 if ((relig16>4 & relig16<11) | relig16==12)
*Separate conservative and mainline Protestants.
replace Xaffil16 = 1 if relig16==1 & fund16==1
*Put "Christian" and "Inter-denominational" into conservative Protestant.
replace Xaffil16 = 1 if relig16==11 | relig16==13

label var Xaffil16 "Religious Origin"
label val Xaffil16 Xrel

* Break down religious groups by evangelicals, AfroAm Protestants
* mainline, liberal & conservative nontraditional Protestants,
* and Protestant nondemonination/no denomination.

* Black sectarians.
recode oth16 7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133=1 *=0, gen(Xbp16)

* Historically black churches.
replace Xbp16=1 if denom16==12
replace Xbp16=1 if denom16==13
replace Xbp16=1 if denom16==20
replace Xbp16=1 if denom16==21
* Black methodists - could be AME, for instance.
replace Xbp16=1 if (denom16==23 | denom16==28) & race==2
* Black baptists.
replace Xbp16=1 if (denom16==10 | denom16==11 | denom16==14 | denom16==15 | denom16==18) & race==2
replace Xbp16=1 if oth16==93 & race==2

replace Xaffil16 = 2 if Xbp16==1

* Put sectarians into evangelical.
recode oth16 1 2 3 5 6 9 10 12 13 16 18 19 20 22 23 24 26 27 28 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 134 135 138 139 140 146=1 *=0, gen(Xev16)

* Put conserv methodists into evangelical
replace Xev16=1 if denom16==23 & race~=2

* Put conservative lutherans into evangelical.
replace Xev16=1 if denom16==32 | denom16==33 | denom16==34

* Puts conserv presbyterians into evangelical.
replace Xev16=1 if denom16==42

* Put nonblack Baptists into evangelical.
replace Xev16=1 if (denom16 ==10 | denom16 ==14 | denom16 ==15 | denom16 ==18 | oth16==93) & race~=2

*  Mainline Protestants
recode oth16 8 25 40 44 46 48 49 50 54 70 71 72 73 81 96 99 105 119 148=1 *=0, gen(Xml16)
replace Xml16=1 if (denom16==11 | denom16==22 | denom16==30 | denom16==31 | denom16==35 | denom16==38 | denom16==40 | denom16==41 | denom16==43 | denom16==48 | denom16==50) & Xbp16<1

* Put nonblack generic methodists into mainline.
replace Xml16=1 if denom16==28 & race~=2

* Catholics
gen Xcath16 = (Xaffil16==4)
replace Xcath16=1 if oth16==123

* Jewish
gen Xjew16 = (Xaffil16==5)

* Adherents of other religions
gen Xoth16 = (Xaffil16==6 & Xev16~=1)

* Puts conservative & liberal nontraditionals into other.
recode oth16 11 17 29 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 130 136 141 145=1 *=0, gen(Xoth26)
replace Xoth16=1 if Xoth26==1

* NO DENOM & NONDENOM PROTESTANTS.
gen Xprotdk16 = (denom16==70)

* Get rid of no denoms/nondenoms who attend less than once a month
* and put those who attend in evangelical.
replace Xev16=1 if (attend>3 & attend~=9) & Xprotdk16==1

*  Generate None16
gen None16=relig16==4 if relig16<.

*  Generate Reltrad16 and label variable and categories
gen Reltrad16 = Xev16 + 2*Xml16 + 3*Xbp16 + 4*Xcath16 + 5*Xjew16 + 6*Xoth16 + 7*None16
replace Reltrad16=. if Reltrad16==0

label val Reltrad16 Reltrad
label var Reltrad16 "Religious Tradition - Origin"

drop Xaffil Xbp Xev Xml Xcath Xjew Xother Xoth2 Xprotdk Xaffil16 Xbp16 Xev16 Xml16 Xcath16 Xjew16 Xoth16 Xoth26 Xprotdk16

*** Repeat for spouse
gen Xspaffil = 0 
replace Xspaffil = 3 if sprel==1
replace Xspaffil = 4 if sprel==2
replace Xspaffil = 5 if sprel==3
replace Xspaffil = 9 if sprel==4
replace Xspaffil = 6 if ((sprel>4 & sprel<11) | sprel==12)

*** Separate conservative and mainline Protestants.
replace Xspaffil = 1 if sprel==1 & spfund==1

*** Put "Christian" and "Inter-denominational" into conservative Protestant.
replace Xspaffil = 1 if sprel==11 | sprel==13

label var Xspaffil "Spouse's Religion"
label val Xspaffil Xrel

*** Following are black sectarians.
recode spother 7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133=1 *=0, gen(Xspbp)

*** Following are historically Black churches.
replace Xspbp=1 if spden==12
replace Xspbp=1 if spden==13
replace Xspbp=1 if spden==20
replace Xspbp=1 if spden==21
*Following are black methodists - could be AME, for instance.
replace Xspbp=1 if (spden==23 | spden==28) & race==2
*Following are black baptists.
replace Xspbp=1 if (spden==10 | spden==11 | spden==14 | spden==15 | spden==18) & race==2
replace Xspbp=1 if spother==93 & race==2

replace Xspaffil = 2 if Xspbp==1

* Following two commands put sectarians into evangelical.
recode spother 1 2 3 5 6 9 10 12 13 16 18 19 20 22 23 24 26 27 28 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 134 135 138 139 140 146=1 *=0, gen(Xspev)

*Following puts conserv methodists into evangelical
replace Xspev=1 if spden==23 & race~=2

*Following puts conservative lutherans into evangelical.
replace Xspev=1 if spden==32 | spden==33 | spden==34

*Following puts conserv presbyterians into evangelical.
replace Xspev=1 if spden==42

*Following puts white Baptists into evangelical.
replace Xspev=1 if (spden ==10 | spden ==14 | spden ==15 | spden ==18 | spother==93) & race~=2

*A few black protestants overlapped with evangelical. So we excised them from evangelical.
***replace Xev16=0 if Xbp16==1    ***I removed this.  -MH

*Mainline Protestants
recode spother 8 25 40 44 46 48 49 50 54 70 71 72 73 81 96 99 105 119 148=1 *=0, gen(Xspml)
replace Xspml=1 if (spden==11 | spden==22 | spden==30 | spden==31 | spden==35 | spden==38 | spden==40 | spden==41 | spden==43 | spden==48 | spden==50) & Xspbp<1

* Following are white generic methodists into mainline.
replace Xspml=1 if spden==28 & race~=2

*Catholics
gen Xspcath = (Xspaffil==4)
replace Xspcath=1 if spother==123

*Jewish
gen Xspjew = (Xspaffil==5)

*Adherents of other religions
gen Xspoth = (Xspaffil==6 & Xspev~=1)

* Following puts conservative and liberal nontraditionals into other.
recode spother 11 17 29 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 130 136 141 145=1 *=0, gen(Xspoth2)
replace Xspoth=1 if Xspoth2==1

* NOTE: THE FOLLOWING DEALS WITH NO DENOM & NONDENOM PROTESTANTS.
gen Xspprotdk = (spden==70)

* Following gets rid of no denoms/nondenoms who attend less than once a month
* and puts those who attend in evangelical.
* replace Xspev=1 if (attend>3 & attend~=9) & Xprotdk16==1

*  Generate Spnone
gen Spnone=sprel==4 if sprel<.

*Following does Reltrad16.
gen Spreltrad = Xspev + 2*Xspml + 3*Xspbp + 4*Xspcath + 5*Xspjew + 6*Xspoth + 7*Spnone
replace Spreltrad=. if Spreltrad==0

label val Spreltrad Reltrad
label var Spreltrad "Spouse's Religious Tradition"

drop Xspaffil Xspbp Xspev Xspml Xspcath Xspjew Xspoth Xspoth2 Xspprotdk

gen Xrel=0
replace Xrel=1 if (relig==1 & fund==1) | relig==11 | relig==13
replace Xrel=2 if Reltrad==3 & denom~=14
replace Xrel=3 if relig==1 & (fund~=1 & Reltrad~=3)
replace Xrel=4 if relig==2
replace Xrel=5 if relig==3
replace Xrel=6 if relig>4 & relig<=10
replace Xrel=6 if relig==12
replace Xrel=7 if relig==4
replace Xrel=. if relig==. | Xrel==0

lab var Xrel "Current Religion"
lab def Xrel 1 "Conservative P" 2 "AfroAm P" 3 "Mainline P" 4 "Catholic" 5 "Jewish" 6 "Other religion" 7 "No religion"
lab val Xrel Xrel

***************************************
*** Combining Conservative and African American Protestant categories
***************************************	

gen Xrel6=.
	replace Xrel6=1 if Xrel==1 | Xrel==2
	replace Xrel6=2 if Xrel==3
	replace Xrel6=3 if Xrel==4
	replace Xrel6=4 if Xrel==5
	replace Xrel6=5 if Xrel==6
	replace Xrel6=6 if Xrel==7
	lab var Xrel6 "Current Religion (6 categories)"
	lab def Xrel6 1 "Conservative Protestant" 2 "Mainline Protestant" 3 "Catholic" ///
	4 "Jewish" 5 "Other Religion" 6 "No religion"
	lab val Xrel6 Xrel6

***************************************
***  Religious attendence
***************************************

gen Attendance = .
	replace Attendance = 0 if attend >= 0 & attend < 7 & !missing(attend)
	replace Attendance = 1 if attend >= 7 & attend < 9 & !missing(attend)
	label define Attendance 1 "Weekly Attendance" 0 "Non-Weekly Attendance" 
	label var Attendance "Religious Attendance"
	label val Attendance Attendance

***************************************
***  Education categories
***************************************

gen Educ5 = degree
	replace Educ5 = 2 if degree==1 & educ>12 & educ<.
	lab def Educ5 0 "No credentials" 1 "High school diploma" 2 "Some college" 3 "College degree" 4 "Advanced degree"
	lab var Educ5 "Education"
	lab val Educ5 Educ5

gen Educ4 = Educ5
	replace Educ4 = 1 if Educ5==0
	replace Educ4 = 2 if Educ5==1
	replace Educ4 = 3 if Educ5==2
	replace Educ4 = 4 if Educ5==3 | Educ5==4
	lab def Educ4 1 "No HS Diploma" 2 "HS Graduate" 3 "Some College" 4 "BA or Above"
	lab var Educ4 "Education"
	lab val Educ4 Educ4
	
***************************************
*** Female
***************************************

recode sex (2=1) (1=0) (.=.), gen(Female)
	lab var Female "Female"
	lab def Female 0 "Male" 1 "Female"
	lab val Female Female
	
***************************************
*** Age
***************************************

*** Re-labelling age

lab var age "Age"	
	
***************************************
*** Age categories
***************************************		
	
gen Age_Cats=.
	replace Age_Cats=1 if age<=25 & !missing(age)
	replace Age_Cats=2 if age>=26 & age<36 & !missing(age)
	replace Age_Cats=3 if age>=36 & age<46 & !missing(age)
	replace Age_Cats=4 if age>=46 & !missing(age)
	lab var Age_Cats "Age Categories"	
	lab def Age_Cats 1 "18-25" 2 "26-35" 3 "36-45" 4 "46+"
	lab val Age_Cats Age_Cats		
	
***************************************	
*** Party ID to three categories (this drops the 77 'Other party' responses)
***************************************

gen Partyid3=.
	replace Partyid3=1 if partyid==0 | partyid==1 
	replace Partyid3=2 if partyid==2 | partyid==3 | partyid==4
	replace Partyid3=3 if partyid==5 | partyid==6
	lab var Partyid3 "Political party affiliation (3 categories)"
	lab def Partyid3 1 "Democrat" 2 "Independent" 3 "Republican"
	lab val Partyid3 Partyid3
	
***************************************	
*** Party ID as 7 point scale (this drops the 77 'Other party' responses)
***************************************	

gen Partyid7=partyid
	replace Partyid7=. if partyid==7
	lab var Partyid7 "Political party affiliation (7 point scale)"
	lab def Partyid7 0 "Strong Democrat" 1 "Democrat" 2 "Independent, near Democrat" /// 
	3 "Independent" 4 "Independent, near Republican" 5 "Republican" 6 "Strong Republican"
	lab val Partyid7 Partyid7

***************************************	
*** Polviews to five categories 
***************************************	

gen Ideology=.
	replace Ideology=1 if polviews==1 | polviews==2 
	replace Ideology=2 if  polviews==3
	replace Ideology=3 if polviews==4
	replace Ideology=4 if polviews==5
	replace Ideology=5 if polviews==6 | polviews==7
	lab var Ideology "Political views (5 categories)"
	lab def Ideology 1 "Liberal" 2 "Slightly Liberal" 3 "Moderate" ///
	4 "Slightly Conservative" 5 "Conservative"
	lab val Ideology Ideology		
	
***************************************	
*** Income binaries
***************************************

gen Income_50K=income16
	replace Income_50K=0 if income16<=18 & !missing(income16)
	replace Income_50K=1 if income16>=19 & !missing(income16)
	lab var Income_50K "Total family income (2 categories)"
	lab def Income_50K 0 "Below $50,000" 1 "$50,000 and above"
	lab val Income_50K Income_50K
	
gen Income_90K=income16
	replace Income_90K=0 if income16<=21 & !missing(income16)
	replace Income_90K=1 if income16>=22 & !missing(income16)
	lab var Income_90K "Income (\$90000 and above)"
	lab def Income_90K 0 "Below $90000" 1 "$90000 and above"
	lab val Income_90K Income_90K	
		
***************************************	
*** reg16 binary
***************************************	

gen USat16=.
	replace USat16=0 if reg16==0 & !missing(reg16)
	replace USat16=1 if reg16>0 & !missing(reg16)
	lab var USat16 "U.S. Residency at 16"
	lab def USat16 0 "Foreign" 1 "U.S."
	lab val USat16 USat16	

***************************************	
*** Generating vote choice binaries
***************************************	

gen Clinton=.
	replace Clinton=0 if pres16==2
	replace Clinton=1 if pres16==1
	lab var Clinton "2016 Presidential Election Vote Choice"
	lab def Clinton 1 "Voted for Clinton" 0 "Voted for Trump"
	lab val Clinton Clinton		
	
***************************************	
*** Generating voted binary
***************************************	

gen Voted=.
	replace Voted=1 if vote16==1
	replace Voted=0 if vote16==2
	lab var Voted "Whether Voted in 2016 Presidential Election"
	lab def Voted 0 "Did not vote" 1 "Voted"
	lab val Voted Voted	
	
*** Included in missing for Voted are those respondents who were 'ineligible'.	

***************************************	
*** Re-naming partvol
***************************************	

gen Partvol = partvol
lab def Partvol 1 "Once a week" 2 "One to three times a month" 3 "Several times a year" 4 "Once a year" 5 "Never"
lab var Partvol "Volunteering"
lab val Partvol Partvol

***************************************	
*** Generating non-kin social network control
***************************************	

gen NonKinNet=.
	replace NonKinNet=0 if !missing(hlpadvce) | !missing(hlpdown) | !missing(hlphome) | !missing(hlpsick)
	replace NonKinNet=1 if hlpadvce==3 | hlpdown==3 | hlphome==3 | hlpsick==3
	lab var NonKinNet "Non-kin social network"
	lab def NonKinNet 0 "No non-kin network" 1 "Non-kin network"
	lab val NonKinNet NonKinNet	

***************************************	
*** Generating metro area binary
***************************************	

gen Metro = srcbelt
replace Metro=1 if srcbelt==1 |srcbelt==3 
replace Metro=0 if srcbelt==2 |srcbelt==4 | srcbelt==5 | srcbelt==6
lab def Metro 0 "Non-Metro Area" 1 "Metro Area"
lab var Metro "Region Type"
lab val Metro Metro	

***************************************	
*** Generating 4-category region control
***************************************	

gen Region = .
replace Region=1 if region==1 |region==2 
replace Region=2 if region==3 | region==4
replace Region=3 if region==5 | region==6 | region==7
replace Region=4 if region==8 | region==9
lab def Region 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
lab var Region "Region"
lab val Region Region	

***************************************	
*** Generating Marital
***************************************	

gen Marital = marital
lab def Marital 1 "Married" 2 "Widowed" 3 "Divorced" 4 "Separated" 5 "Never married"
lab var Marital "Marital Status"
lab val Marital Marital	

***************************************	
*** Generating Workstat
***************************************	

gen Workstat = wrkstat
replace Workstat=1 if wrkstat==1
replace Workstat=2 if wrkstat==2
replace Workstat=3 if wrkstat==3 | wrkstat==4
replace Workstat=4 if wrkstat==5
replace Workstat=5 if wrkstat==7
replace Workstat=6 if wrkstat==6 | wrkstat==8
lab def Workstat 1 "Full-time" 2 "Part-time" 3 "Unemployed" 4 "Retired" ///
				 5 "Keeping House" 6 "School or Other"
lab var Workstat "Employment Status"
lab val Workstat Workstat	

********************************************************************************
*** Generating new variables -- Recoding Old and New Abortion Items
********************************************************************************	

***************************************
*** Combining genders for ablegal question
***************************************

gen Ablegal=abfelegl==1 if abfelegl<.
	replace Ablegal=1 if abmelegl==1
	replace Ablegal=2 if abfelegl==3
	replace Ablegal=2 if abmelegl==3
	replace Ablegal=3 if abfelegl==2
	replace Ablegal=3 if abmelegl==2
	lab var Ablegal "Abortion should be legal"
	lab def Ablegal 1 "Should be" 2 "It depends" 3 "Should not be"
	lab val Ablegal Ablegal

***************************************
*** Recoding Ablegal (-1, 0, 1)
***************************************		

recode Ablegal (1=1) (2=0) (3=-1) (.=.), gen(Legal)
	lab var Legal "Legality"
	lab def Legal -1 "Should not be" 0 "It depends" 1 "Should be"
	lab val Legal Legal	
	
***************************************
*** Recoding abmoral (-1, 0, 1)
***************************************	

recode abmoral (1=1) (2=3) (3=2) (.=.), gen(Abmoral)
	lab var Abmoral "Moral Opposition"
	lab def Abmoral 1 "Morally opposed" 2 "It depends" 3 "Not morally opposed"
	lab val Abmoral Abmoral		
	
recode abmoral (1=-1) (2=1) (3=0) (.=.), gen(Moral)
	lab var Moral "Moral Opposition"
	lab def Moral -1 "Morally opposed" 0 "It depends" 1 "Not morally opposed"
	lab val Moral Moral		
	
***************************************		
*** Generating abstate1 with DK as a response category
***************************************	

gen Abstate1=abstate1
	replace Abstate1=6 if abstate1==.d
	lab var Abstate1 "abstate1 with DK category"
	lab def Abstate1 1 "Very Easy" 2 "Easy" 3 "Neither" 4 "Hard" 5 "Very Hard" 6 "DK" 
	lab val Abstate1 Abstate1
	
***************************************
*** Generating abstate1 (3 categories)
***************************************

gen Abdiff=abstate1
	replace Abdiff=1 if abstate1==1 | abstate1==2
	replace Abdiff=2 if abstate1==3
	replace Abdiff=3 if abstate1==4 | abstate1==5
	lab var Abdiff "Access"
	lab def Abdiff 1 "Very Easy & Easy" 2 "Neither easy nor hard" 3 "Very Hard & Hard"
	lab val Abdiff Abdiff	
	
***************************************
*** Generating abstate1 (4 categories)
***************************************

gen AbdiffDK=abstate1
	replace AbdiffDK=1 if abstate1==1 | abstate1==2
	replace AbdiffDK=2 if abstate1==3
	replace AbdiffDK=3 if abstate1==4 | abstate1==5
	replace AbdiffDK=4 if abstate1==.d
	lab var AbdiffDK "Access"
	lab def AbdiffDK 1 "Very Easy & Easy" 2 "Neither easy nor hard" 3 "Very Hard & Hard" 4 "Don't Know"
	lab val AbdiffDK AbdiffDK		
		
***************************************
*** Recoding abstate2 (-1, 0, 1)
***************************************	

recode abstate2 (1=1) (2=-1) (3=0) (.=.), gen(Ablaws)
	lab var Ablaws "Access Reform"
	lab def Ablaws 1 "Easier" 0 "Stay the same" -1 "Harder"
	lab val Ablaws Ablaws	
	
***************************************		
*** Generating bstate2 with DK as a response category
***************************************	
	
gen AblawsDK=Ablaws
	replace AblawsDK=2 if abstate2==.d
	lab var AblawsDK "Access Reform"
	lab def AblawsDK 1 "Easier" 0 "Stay the same" -1 "Harder" 2 "Don't Know"
	lab val AblawsDK AblawsDK

***************************************
*** Recoding the four help variables into 0/1
***************************************

recode abhelp1 (2=0) (1=1) (.=.), gen(HelpArrange)
	lab var HelpArrange "Help Arrange"
	
recode abhelp2 (2=0) (1=1) (.=.), gen(HelpPayAb)
	lab var HelpPayAb "Help Pay for Abortion"

recode abhelp3 (2=0) (1=1) (.=.), gen(HelpOthCost)
	lab var HelpOthCost "Help Pay for Other Costs"

recode abhelp4 (2=0) (1=1) (.=.), gen(HelpEmotion)
	lab var HelpEmotion "Help Emotionally" 

*** Creating a local for the four help variables to label recoded values
local helps "HelpArrange HelpPayAb HelpOthCost HelpEmotion"

foreach var in `helps'{
	lab def `var' 0 "No" 1 "Yes"
	lab val `var' `var'
}

***************************************
*** Creating a help index (0-4)
***************************************

gen Abhelpindx=HelpArrange+HelpPayAb+HelpOthCost+HelpEmotion
	lab var Abhelpindx "Helping Index 0-4"
	lab val Abhelpindx Abhelpindx
	
***************************************
*** Creating a help index (1-4)
***************************************

gen HelpIndex=Abhelpindx
	replace HelpIndex=. if Abhelpindx==0
	lab var HelpIndex "Helping Index (1-4)"
	lab val HelpIndex HelpIndex	
	
***************************************		
*** Creating help once or more vs never help binary variable
***************************************
gen Abhelp=Abhelpindx
	replace Abhelp=0 if Abhelpindx==0
	replace Abhelp=1 if Abhelpindx>0
	replace Abhelp=. if Abhelpindx==.
	lab var Abhelp "Would give any help"
	lab def Abhelp 0 "Would not give any help" 1 "Would give one or more forms of help"  
	lab val Abhelp Abhelp
		
***************************************
*** Recoding abinspay into 0/1
***************************************
	
recode abinspay (2=0) (1=1) (.=.), gen(Abinspay)
	lab def Abinspay 0 "People should not be able" 1 "People should be able"
	lab var Abinspay "Insurance"
	lab val Abinspay Abinspay	
	
***************************************
*** Generating the Rossi Scale (0-6)
***************************************	
	
*** Recoding the constituent abortion items into 1/0

recode abdefect (2=0) (1=1) (.=.), gen(Abdefect)
recode abnomore (2=0) (1=1) (.=.), gen(Abnomore)
recode abhlth (2=0) (1=1) (.=.), gen(Abhlth)
recode abpoor (2=0) (1=1) (.=.), gen(Abpoor)
recode abrape (2=0) (1=1) (.=.), gen(Abrape)
recode absingle (2=0) (1=1) (.=.), gen(Absingle)

*** Creating a local for the four help variables to label recoded values

local Rossi "Abdefect Abnomore Abhlth Abpoor Abrape Absingle"

foreach var in `Rossi'{
	lab def `var' 0 "No" 1 "Yes"
	lab val `var' `var'
}

*** Generating the Rossi Scale (0-6)

gen Rossi=Abdefect+Abnomore+Abhlth+Abpoor+Abrape+Absingle
	lab var Rossi "Rossi Scale"
	lab val Rossi Rossi
	
***************************************
*** Standardizing the Rossi Scale (0-6)
***************************************	
	
egen zRossi = std(Rossi)	

lab var zRossi "Rossi Scale"
	
***************************************
*** Recoding abany into 0/1
***************************************	

recode abany (2=0) (1=1) (.=.), gen(Abany)
	lab def Abany 0 "No" 1 "Yes"
	lab var Abany "Any Reason"
	lab val Abany Abany		
	
***************************************
*** Generating the Rossi Scale (0-7)
***************************************		
	
gen Rossi7=Abdefect+Abnomore+Abhlth+Abpoor+Abrape+Absingle+Abany
	lab var Rossi7 "Rossi Scale with Abany"
	lab val Rossi7 Rossi7		

***************************************
*** Rossi module as a treatment
***************************************		
	
gen AskedRossi=.
	replace AskedRossi=1 if ballot==1 | ballot==3
	replace AskedRossi=0 if ballot==2
	lab var AskedRossi "Was respondent asked Rossi questions"
	lab def AskedRossi 1 "Asked about Rossi" 0 "Not asked about Rossi"
	lab val AskedRossi AskedRossi	
		
***************************************
*** Pro Choice binary
***************************************		
	
gen ProChoice=.
	replace ProChoice=0 if !missing(Legal) & !missing(Moral) &!missing(Abinspay)
	replace ProChoice=1 if Legal==1 & Moral==1 & Abinspay==1
	lab var ProChoice "Abortion should be/is legal, moral, and insured"
	lab def ProChoice 1 "Yes" 0 "No"
	lab val ProChoice ProChoice		
	
***************************************
*** Didn't answer helping questions
***************************************	
	
gen AnsweredHelp1=.
	replace AnsweredHelp1=1 if Abhelpindx==0 | Abhelpindx==1 | Abhelpindx==2 | Abhelpindx==3 | Abhelpindx==4
	replace AnsweredHelp1=0 if Abhelpindx==.
	lab var AnsweredHelp1 "Was respondent included in Help Index"
	lab def AnsweredHelp1 1 "Answered Help Index" 0 "Not included in Help Index"
	lab val AnsweredHelp1 AnsweredHelp1		
	
********************************************************************************
*** Saving output
********************************************************************************	
	
save "Data/GSS2018SP.dta", replace	
