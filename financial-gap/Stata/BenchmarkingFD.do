
****************************
*/* YAHOO Finance DATA */  *
****************************

stockquote ^KSE, fm(1) fd(2) fy(2000) lm(03) ld(4) ly(2008) frequency(d)
stockquote HBL, fm(1) fd(2) fy(2000) lm(03) ld(4) ly(2015) frequency(w)
stockquote HSBC, fm(1) fd(2) fy(2000) lm(03) ld(4) ly(2015) frequency(w)

**********************
*/* WB OPEN DATA */  *
**********************

adoupdate wbopendata, update

%//https://www.wto.org/english/res_e/reser_e/ersd201207_e.pdf // page-5 reference radarplot


//The Radar Graph tool creates graphs that compare sets of values at given points in time or in particular categories, and is displayed in a circular format. This type of graph is also called a web graph.
//It is also called spiderchart or a star chart
//findit radar // see parplot as well
// ISO country Codes for SAARC Countries// 

CHN   // China
BGD   // Bangladesh
BTN   // Bhutan
IND   // India
LKA   // Sri Lanka
MDV   // Maldives
NPL   // Nepal
PAK   // Pakistan

wbopendata, country(chn;bgd;btn;ind;lka;mdv;npl;pak;) indicator(SI.POV.2DAY;SI.POV.NAHC;SP.POP.TOTL;EN.POP.DNST;SP.POP.DPND;SP.POP.DPND.OL;SP.POP.DPND.YG;IS.ROD.DNST.K2;NY.GDP.PCAP.KD;FP.CPI.TOTL;FP.CPI.TOTL.ZG;NY.GDP.TOTL.RT.ZS;GC.DOD.TOTL.GD.ZS;DP.DOD.DECD.CR.CG.Z1;GFDD.EI.04;GFDD.OI.02;GFDD.EI.02;GFDD.EI.05;GFDD.EI.06;GFDD.EI.07 ;GFDD.EI.09;GFDD.EI.10;GFDD.EM.01;GFDD.EI.01 ;GFDD.DI.05 ;GFDD.DI.14 ;GFDD.DM.01 ;GFDD.DM.02;IC.CRD.INFO.XQ ;IC.CRD.PUBL.ZS ;IQ.CPA.PROP.XQ ;IC.PRP.COST.PROP.ZS ;IC.PRP.DURS ;IC.PRP.PROC ;FB.CBK.BRCH.K2 ;FB.CBK.BRCH.P5 ;FB.ATM.TOTL.K2 ;FB.ATM.TOTL.P5 ;GFDD.EI.03 ;EG.USE.ELEC.KH.PC    ;ACCESS.ELECTRICITY.TOT ;TOTAL.FINAL.ENERGY.CONSUM ;UIS.E.1.Guk ;IN.POV.INF.MORTRATE ;IN.POV.INF.MORTRATE.UNDR5  ;IT.MOB.COV.ZS;IT.NET.USER.P2;IT.CEL.SETS ;IT.CEL.SETS.P2;IT.CELL.3MIN.CD.OP ;IT.CELL.3MIN.CD.PK ;IT.CELL.3MIN.CN.OP  ;IT.CELL.3MIN.CN.PK ;IT.CELL.PO.CONN.CD;IT.CELL.PO.CONN.CN  ;IT.CELL.PR.CONN.CD  ;IT.CELL.PR.CONN.CN ;IT.CMP.PCMP.P2      ;IT.MLT.3MIN.CD.OP ;IT.MLT.3MIN.CD.PK;IT.MLT.3MIN.CD.US ;IT.MLT.3MIN.CN.OP ;IT.MLT.3MIN.CN.PK ) year(1980:2014) clear long
wbopendata, country(chn;bgd;btn;ind;lka;mdv;npl;pak) indicator(NY.GDP.PCAP.PP.KD;SI.POV.2DAY;SP.POP.TOTL;EN.POP.DNST;SP.POP.DPND.YG;SP.POP.DPND.OL;GFDD.OI.02;GFDD.DI.05;GFDD.DI.14)  year(2000:2014) clear long

**********************
*/* Offshore Dummy */  
**********************
gen offsh = 0 
replace offsh = 1 if countrycode == "IND"
replace offsh = 1 if countrycode == "MDV"


**********************
*/* Fuel Exp Dummy */  
**********************

gen fexp = 0 
replace fexp = 1 if countrycode == "CHN"


***********************
*/* Landlocked Dummy */  
***********************

gen landlock = 0 
replace landlock = 1 if countrycode == "BTN"
replace landlock = 1 if countrycode == "NPL"

*****************************
*/* Transition Econ Dummy */  
*****************************

gen trans = 0 
replace trans = 1 if countrycode == "CHN"


*****************************
*/* Rename Variables */  
*****************************

ren ny_gdp_pcap_pp_kd gdp
ren si_pov_2day pov
ren sp_pop_totl pop
ren en_pop_dnst popden
ren sp_pop_dpnd_yg ageyoung
ren  sp_pop_dpnd_ol ageold
ren gfdd_oi_02 dep
ren gfdd_di_05 ll
ren gfdd_di_14 credit

// loop to take log of all variables

foreach var of varlist  gdp- credit {

g l`var' = log(`var')

}

*****************************
*/* Analysis */  
*****************************

encode countrycode, gen(cty)
xtset cty year
gen sqrgdp = gdp^2
gen lsqrgdp = ln(sqrgdp)

*****************************
*/* Linear Interpolation */  
*****************************

tabulate lpov year if lpov == ., missing
by cty: ipolate lpov year, gen(ilpov)
pwcorr lpov ilpov


qreg lcredit lgdp limrt lsqrgdp  lpop lpopden lageyoung lageold offsh fexp landlock trans
predict ehat, resid
predict yhat, xb
xtline yhat lcredit
qreg lll lgdp limrt lsqrgdp  lpop lpopden lageyoung lageold offsh fexp landlock trans
predict yhat2, xb
xtline yhat2 lll

gen gap=(yhat/lcredit)


*****************************
*/* Line and Bar Charts */  
*****************************

graph bar (mean) gap, over(cty)
radar cty gap yhat lcredit if sets==1
radar ctyy ldep lll lcredit limrt if sets==1, title(Comparative Graph)

radar ctyy ldep lll lcredit limrt if sets==1, title(Nice Radar graph) lc(red blue green orange) lp(dash dot dash_dot)


#delimit ;
graph bar (mean) lower higher, over( year ) over( cty, descending ) 
legend( label(1 "lower") label(1 "higher"))
title( "International Comparision: Microfinance Profitability",
span pos(11) ) subtitle(" Weighted Avg. ROE & ROA") note("Source: MIX/Authors' calculations", span);
#delimit cr

**************************************************
*Observed and Benchmark Financial Development
*************************************************
*FILE FGap
twoway bar lcredit year || line yhat year
twoway bar lcredit year || line yhat year if cty==1
**presented in the paper
twoway bar lcredit year || line yhat year, by(cty)
twoway bar lcredit year || line yhat year, by(cname)
twoway bar lll year || line yhat2 year, by(cty)
twoway bar lcredit year || line medyhat year if cty==1



*****************************
*/* Mean/Median Scatter plot*/  
*****************************

bysort cty : egen mlcredit=mean(lcredit)
bysort cty : egen mlimrt=mean(limrt)
scatter mlimrt mlcredit, mlabel(cty)
bysort cty : egen medlcredit=median(lcredit)
bysort cty : egen medlimrt=median(limrt)
bysort cty : egen medyhat=median(yhat)
scatter medlimrt medlcredit, mlabel(cty)
scatter limrt lcredit, mlabel(cty)

*****************************
*/* Averages*/  
*****************************

g mean_temp = 1 if year >= 2009 & year <=2014
collapse (mean)  gdp - gap , by(cname  mean_temp) 
drop if  mean_temp == .

















// Inidactors Required for Financial Development Gap

SI.POV.2DAY          //             Poverty headcount ratio at $2 a day (PPP) (% of population)
SI.POV.25DAY         //             Poverty headcount ratio at $2.5 a day (PPP) (%of population)
SI.POV.NAHC        //               Poverty headcount ratio at national poverty lines (% of population)
SP.POP.TOTL        //               Population, total
EN.POP.DNST       //                Population density (people per sq. km of landarea)
SP.POP.DPND       //                Age dependency ratio (% of working-agepopulation)
SP.POP.DPND.OL   //                 Age dependency ratio, old (% of working-age population)
SP.POP.DPND.YG   //                 Age dependency ratio, young (% of working-agepopulation)
IS.ROD.DNST.K2    //                Road density (km of road per 100 sq. km of landarea)
NY.GDP.PCAP.KD     //               GDP per capita (constant 2005 US$)
NY.GDP.PCAP.KD.ZG   //              GDP per capita growth (annual %)
NY.GDP.PCAP.PP.KD    //             GDP per capita, PPP (constant 2011 international $)
FP.CPI.TOTL          //             Consumer price index (2010 = 100)
FP.CPI.TOTL.ZG         //           Inflation, consumer prices (annual %)
NY.GDP.TOTL.RT.ZS        //         Total natural resources rents (% of GDP)
GC.DOD.TOTL.GD.ZS      //           Central government debt, total (% of GDP)
DP.DOD.DECD.CR.CG.Z1   //           508.Central Govt. Public Sector Debt, Domestic creditors(% of GDP)
GFDD.EI.04           //             Bank overhead costs to total assets (%)
GFDD.OI.02           //             Bank deposits to GDP (%)} //the first indicator of financial development 
GFDD.EI.02           //             Bank lending-deposit spread
GFDD.EI.05           //             Bank return on assets (%, after tax)
GFDD.EI.06           //             Bank return on equity (%, after tax)
GFDD.EI.07          //              Bank cost to income ratio (%)
GFDD.EI.09          //              Bank return on assets (%, before tax)
GFDD.EI.10          //              Bank return on equity (%, before tax)
GFDD.EM.01          //              Stock market turnover ratio (%)
GFDD.EI.01          //              Bank net interest margin (%)
GFDD.DI.05          //              Liquid liabilities to GDP (%)
GFDD.DI.14          //              Domestic credit to private sector (% of GDP)} // the second indi of financial developmen t. from the both sides of balance sheets
GFDD.DM.01          //              Stock market capitalization to GDP (%)
GFDD.DM.02          //              Stock market total value traded to GDP (%)
GE.EST              //              Government Effectiveness: Estimate
GV.RULE.LW.ES       //              Rule of Law (estimate)
GV.REGL.LA.ES       //              Regulatory Quality (estimate)
GV.POLI.ST.ES        //             Political Stability/No Violence (estimate)
GV.TI.SCOR.IDX       //             Corruption Perceptions Index (score)
IC.CRD.INFO.XQ    //                Depth of credit information index (0=low to 8=high)
IC.CRD.PUBL.ZS     //               Public credit registry coverage (% of adults)
IQ.CPA.PROP.XQ     //               CPIA property rights and rule-based governance rating (1=low to 6=high)
IC.PRP.COST.PROP.ZS //              Cost of registering property (% of property value)
IC.PRP.DURS      //                 Time required to register property (days)
IC.PRP.PROC      //                 Procedures to register property (number)
FB.CBK.BRCH.K2    //                Commercial bank branches (per 1000 sq km)
FB.CBK.BRCH.P5    //                Commercial bank branches (per 100,000 adults)
FB.ATM.TOTL.K2     //               Automated teller machines (ATMs) (per 1,000 sq km)
FB.ATM.TOTL.P5      //              Automated teller machines (ATMs) (per 100,000 adults)
GFDD.EI.03           //             Bank noninterest income to total income (%)
EG.USE.ELEC.KH.PC    //             Electric power consumption (kWh per capita)
ACCESS.ELECTRICITY.TOT   //         Access to electricity (% of total population)
TOTAL.FINAL.ENERGY.CONSUM  //       Total final energy consumption (TFEC)
UIS.E.1.Guk      //                 Enrolment in primary education, Grade unspecified, both sexes (number)
IN.POV.INF.MORTRATE  //             Infant Mortality Rate (per 1,000)
IN.POV.INF.MORTRATE.UNDR5  //       Under 5 Mortality Rate (Per 1,000)
IT.MOB.COV.ZS       //              Population coverage of mobile cellular telephony (%)
IT.NET.USER.P2      //              Internet users (per 100 people)
IT.CEL.SETS        //               Mobile cellular subscriptions
IT.CEL.SETS.P2       //             Mobile cellular subscriptions (per 100 people)
IT.CELL.3MIN.CD.OP    //            Mobile cellular - price of 3-minute local call(off-peak rate - current US$)
IT.CELL.3MIN.CD.PK    //            Mobile cellular - price of 3-minute local call(peak rate - current US$)
IT.CELL.3MIN.CN.OP     //           Mobile cellular - price of 3-minute local call (off-peak rate - current LCU)
IT.CELL.3MIN.CN.PK   //             Mobile cellular - price of 3-minute local call(peak rate - current LCU)
IT.CELL.PO.CONN.CD  //              Mobile cellular postpaid connection charge(current US$)
IT.CELL.PO.CONN.CN   //             Mobile cellular postpaid connection charge (current LCU)
IT.CELL.PR.CONN.CD  //              Mobile cellular prepaid connection charge(current US$)
IT.CELL.PR.CONN.CN   //             Mobile cellular prepaid connection charge (current LCU)
IT.CMP.PCMP.P2       //             Personal computers (per 100 people)
IT.MLT.3MIN.CD.OP    //             Price of a 3-minute fixed telephone local call (off-peak rate - current US$)
IT.MLT.3MIN.CD.PK    //             Price of a 3-minute fixed telephone local call (peak rate - current US$)
IT.MLT.3MIN.CD.US     //            Telephone average cost of call to US (US$ per three minutes)
IT.MLT.3MIN.CN.OP      //           Price of a 3-minute fixed telephone local call (off-peak rate - current LCU)
IT.MLT.3MIN.CN.PK      //           Price of a 3-minute fixed telephone local call(peak rate - current LCU)























