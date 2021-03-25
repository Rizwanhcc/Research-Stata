**************************************************************
               ///Stock Indices////
**************************************************************

//Creating a date variable 
gen date2 =date(date, "DMY")
format %tdMon_DD,_CCYY date2
tsset date2,daily
 
//deleting duplicates
sort date2
duplicates drop date2, force

//Computing daily stock returns
**we can compute daily stock returns by ln(pt/pt-1)


**************************************************************
//Overview of the Economy of Pakistan//
**************************************************************


wbopendata, country(pak) indicator(BX.KLT.DINV.WD.GD.ZS;NY.GDP.MKTP.KD.ZG;NE.TRD.GNFS.ZS;GFDD.DM.01;GFDD.DI.14;GFDD.OI.02) year(1972:2015) clear long

//Macro
BX.KLT.DINV.WD.GD.ZS // Foreign direct investment, net inflows (% of GDP)
NY.GDP.MKTP.KD.ZG     // GDP growth (annual %)
UNDP.HDI.XD           // Human development index (HDI)
NE.TRD.GNFS.ZS        // Trade (% of GDP)
NE.TRM.TRAD.XN        // Terms of trade index (2000=100)
//Financial
GFDD.DM.01        // Stock market capitalization to GDP (%)
GFDD.DI.14        //  Domestic credit to private sector (% of GDP)
GFDD.DI.05        //  Liquid liabilities to GDP (%)
GFDD.DM.01        // Stock market capitalization to GDP (%)
GFDD.EI.01       //Bank net interest margin (%)
GFDD.OI.01       //    Bank concentration (%)
GFDD.OI.02       ///   Bank deposits to GDP (%)
//Tourism
ST.INT.ARVL    // International tourism, number of arrivals
ST.INT.DPRT     //  International tourism, number of departures
ST.INT.RCPT.CD    //  International tourism, receipts (current US$)
ST.INT.RCPT.XP.ZS  //  International tourism, receipts (% of total exports)
ST.INT.TRNR.CD // International tourism, receipts for passenger transport items (current US$)
ST.INT.TRNX.CD //   International tourism, expenditures for passenger transport items (current US$)
ST.INT.TVLR.CD //   International tourism, receipts for travel items (current US$)
ST.INT.TVLX.CD //  International tourism, expenditures for travel items (current US$)
ST.INT.XPND.CD    //  International tourism, expenditures (current US$)
ST.INT.XPND.MP.ZS  //   International tourism, expenditures (% of total imports)

wbopendata, country(pak) indicator(ST.INT.ARVL;ST.INT.RCPT.CD) year(1972:2015) clear long



//renaming vars


ren bx_klt_dinv_wd_gd_zs fdi
ren ny_gdp_mktp_kd_zg gdpg
ren ne_trd_gnfs_zs top
ren gfdd_dm_01 mcap
ren gfdd_di_14 fd
ren gfdd_oi_02 depgdp


//Arch GARCH Models
**http://www.learneconometrics.com/class/5263/notes/arch.pdf
**http://www.ssc.wisc.edu/~bhansen/390/390Lecture24.pdf

///1
use byd, clear 

///2

gen time = _n
tsset time 
///3
tsline lrbnk, name(g1, replace) 
histogram r, normal name(nas, replace) 

//make and combine graphs
qui tsline lrkse, name(kse, replace) 
qui tsline lrbnk, name(bnk, replace) 
qui tsline lrins, name(ins, replace) 
graph combine kse bnk ins , cols(3) name(all1, replace) 

**histogram
qui histogram lrkse, normal name(kse, replace) 
qui histogram lrbnk, normal name(bnk, replace) 
qui histogram lrins, normal name(ins, replace) 
graph combine kse bnk ins , cols(3) name(all2, replace) 


label variable lrkse "Karachi Stock Exchange Returns"
label variable lrbnk "Banking Sector Returns"
label variable lrins "Insurance Sector Returns"


///4

regress r
predict ehat, residual
gen ehat2 = ehat * ehat 

///5

regress ehat2 L.ehat2 

//6

scalar TR2 = e(N)*e(r2)
scalar pvalue = chi2tail(1,TR2)
scalar crit = invchi2tail(1,.05) 
scalar list TR2 pvalue crit 

//7
regress r 

//8
estat archlm, lags(1) 

//9
arch r, arch(1) 

//10//
predict htarch, variance 
tsline htarch, name(g2, replace) 

//GARCH graphs after 7 days dummy
predict htgarchkse, variance 
tsline htgarch, name(kse, replace) 

predict htgarchbnk, variance 
tsline htgarchbnk, name(bnk, replace) 

predict htgarchins, variance 
tsline htgarchins, name(ins, replace) 

graph combine kse bnk ins , cols(3) name(all2, replace) 


//ARCH GARCH
**http://fmwww.bc.edu/EC-C/S2014/823/EC823.S2014.nn09.slides.pdf

reg lrkse d3
estat archlm, lags(4)

arch lrkse d3, arch(1) garch(1)  nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1

reg lrkse d7
estat archlm, lags(4)

arch lrkse d7, arch(1) garch(1)  nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1


reg lrbnk d3
estat archlm, lags(4)

arch lrbnk d3, arch(1) garch(1)  nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1


reg lrbnk d7
estat archlm, lags(4)

arch lrbnk d7, arch(1) garch(1)  nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1


reg lrins d7
estat archlm, lags(4)

arch lrins d7, arch(1) garch(1)  nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1

arch lrkse d7, arch(1) garch(1) tarch(1) nolog vsquish
test [ARCH]L.arch + [ARCH]L.garch == 1


////OLS Results

reg lrkse d3
reg lrbnk d3
reg lrins d3

reg lrkse d5
reg lrbnk d5
reg lrins d5

reg lrkse d7
reg lrbnk d7
reg lrins d7



//Graphs for GARCH Models
