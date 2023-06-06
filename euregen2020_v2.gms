* Cause dollar statements to appear in lst file
$ondollar
* Set EOL comment indicator to the default of !!
$oneolcom

* * * Fundamentals
set
t                                Model time periods
tbase(t)                         Model base year
v                                Vintages of generation capacity
vbase(v)                         First active vintage
oldv(v)                          Existing vintages
newv(v)                          New vintages
tv(t,v)                          Time period in which vintage v is installed
vt(v,t)                          Vintages active in time period t
r                                Model regions
cty                              Countries
xcty                             Map regions countries
;

$gdxin database\setpar_%n%.gdx
$load t, tbase, v, vbase, oldv, newv, tv, vt
$load r, cty, xcty
$gdxin

alias(r,rr);
alias(t,tt);
alias(v,vv);

* * * Timeseries
set
i                                Generation technology
h                                Hours
m                                Months
s                                Segments
hm(h,m)                          Map between hours and months for assembling availability factors
sm(s,m)                          Map between segments and months for assembling availability factors
hmaps(h,s)                       Map between hours and segments (which segment is for which real hour)
srep(s,h)                        Map from segments to representative (chosen) hours
peak(s,r)                        Peak segment
;

$gdxin database\setpar_%n%.gdx
$load i, h, m, s, hm, sm, hmaps, srep, peak=peak_s
$gdxin

set
superirnw
qshare_sz
quantiles
irnw_mapq(i,quantiles)
superirnw_mapq(i,quantiles,superirnw)
;

$gdxin database\setpar_%n%.gdx
$load superirnw, qshare_sz, quantiles, superirnw_mapq, irnw_mapq
$gdxin

parameter
hours(s)                                Number of hours per load segment
load(s,r)                               Base year load across segments including both retail and direct (GW) (corrected)
load_s(s,r)                             Base year load across segments including both retail and direct (GW) (uncorrected)
loadcorr(r)                             Correction of load to meet demand
peakload(r)                             Peakload in each region
minload(r)                              Minload in each region
dref(r,t)                               Indexed reference growth path
daref(r,t)                              Reference annual demand by region over time (TWh)
daref_s(r)                              Annual demand (segments)
vrsc(s,i,v,r)                           Capacity factor for variable resources (techboost yes no)
vrsc_s(s,i,v,r)                         Capacity factor for variable resources (uncorrected)
vrsc_ss(s,i,v,r)                        Capacity factor for variable resources (corrected)
vrsccorr(i,v,r)                         Correction of wind to meet full-load hours
irnwflh_h(i,v,r)                        Intermittent renewables full-load hours (hours)
irnwflh_s(i,v,r)                        Intermittent renewables full-load hours (segments)
irnwflh_check(i,v,r)                    Intermittent renewables full-load hours (segments) control calculation
number                                  Number of segments
irnwlimUP_quantiles(i,r,quantiles)      Upper limit per quantile
qshare(qshare_sz,superirnw,quantiles)   Quantile share per scenario (0 .. 1)
;

$gdxin database\setpar_%n%.gdx
$load hours, load_s, loadcorr, peakload=peakload_s, minload=minload_s, dref, daref, daref_s
$load vrsc_s, vrsccorr, irnwflh_h, irnwflh_s, number, irnwlimUP_quantiles, qshare
$gdxin

* Correct time series to match annual load and full-load hours of renewables
$if      set corr_peak                          vrsc(s,i,v,r)$(vrsccorr(i,v,r) > 0) = min(vrsccorr(i,v,r) * vrsc_s(s,i,v,r), 1) + eps ;
$if      set corr_peak                          load(s,r)                           = min(loadcorr(r) * load_s(s,r), peakload(r)) + eps ;

$if      set corr_full                          vrsc(s,i,v,r)$(vrsccorr(i,v,r) > 0) = vrsccorr(i,v,r) * vrsc_s(s,i,v,r) + eps ;
$if      set corr_full                          load(s,r)                           = loadcorr(r) * load_s(s,r) + eps ;

$if not  set corr_full $if not set corr_peak    vrsc(s,i,v,r)                       = vrsc_s(s,i,v,r) + eps ;
$if not  set corr_full $if not set corr_peak    load(s,r)                           = load_s(s,r) + eps ;

irnwflh_check(i,v,r) = sum(s, hours(s) * vrsc(s,i,v,r)) ;

* * * Generation technology
set
new(i)                           New generation technology
exi(i)                           Existing technologies (or capacities) in base year - EXISTING BLOCKS
dspt(i)                          Dispatchable capacity blocks
ndsp(i)                          Non-Dispatchble capacity blocks (there are none of these in 4NEMO only price decides)
ccs(i)                           CCS generation technologies (or capacities) - CCS BLOCKS
conv(i)                          Conventional generation technologies
irnw(i)                          Intermittent renewable generation technologies
gas(i)                           Gas technologies
bio(i)                           Biomass technologies
sol(i)                           Solar technologies
wind(i)                          Wind technologies
windon(i)                        Wind onshore technologies 
windoff(i)                       Wind offshore technologies 
rnw(i)                           Renewable technologies
lowcarb(i)                       Low-carbon technologies
nuc(i)                           Nuclear technologies
type                             Generation type
idef(i,type)                     Map between technology and type
iidef(i,type)                    Map between technology and type

;

$gdxin database\setpar_%n%.gdx
$load new, exi, dspt, ndsp, ccs, irnw, conv, sol, wind, windoff, rnw, lowcarb, nuc, type, idef, gas, bio
$gdxin

iidef(i,type) = idef(i,type) ;

parameter
cap(i,v,r)                       Capacity installed by region (GW)
invlimUP(i,r,t)                  Upper bounds on investment based on potential (cumulative since last time period) (GW)
invlimLO(i,r,t)                  Lower bounds on investment based on current pipeline (cumulative since last time period) (GW)
invlimUP_eu(i,t)                 Lower bounds on investment based on current pipeline (cumulative since last time period) (GW)
invlife(i,v)                     Capacity lifetime
invdepr(i,v)                     Investment depreciation
capcost(i,v,r)                   Capacity cost (investment) by region
fomcost_int(i,v,r)               Fixed OM cost
fomcost(i,v,r)                   Fixed OM cost
vomcost(i,v,r)                   Variable OM cost
effrate(i,v,r)                   Efficiency
co2captured(i,v,r)               CCS capture rate
emit(i,v,r)                      Emission factor
reliability(i,v,r)               Reliability factor by region and technology
capcred(i,v,r)                   Capacity credit by region and technology
mindisp(i,v,r)                   Min load by region and technology
sclim_int(r)                         Upper bound on geologic storage of carbon (GtCO2)
sclim_eu_int                         Upper bound on geologic storage of carbon (GtCO2)
sclim(r)                         Upper bound on geologic storage of carbon (GtCO2)
sclim_eu                         Upper bound on geologic storage of carbon (GtCO2)
biolim_int(r,t)                  Upper bounds by region on biomass use (MWh)
biolim_eu_int(t)                 Upper bounds by region on biomass use (MWh)
biolim(r,t)                      Upper bounds by region on biomass use (MWh)
biolim_eu(t)                     Upper bounds by region on biomass use (MWh)
;

$gdxin database\setpar_%n%.gdx
$load cap, invlimUP, invlimLO, invlimUP_eu, invlife, invdepr, capcost, fomcost_int=fomcost, vomcost, effrate, co2captured, emit, reliability, capcred, mindisp
$load sclim_int=sclim, sclim_eu_int=sclim_eu, biolim_int=biolim, biolim_eu_int=biolim_eu
$gdxin

* Correcting nuclear fix cost
fomcost(i,v,r) = fomcost_int(i,v,r) ;
$if      set nuclear50         fomcost("Nuclear",v,r) = 0.5 * fomcost_int("Nuclear",v,r) ;
$if      set nuclear150        fomcost("Nuclear",v,r) = 1.5 * fomcost_int("Nuclear",v,r) ;
$if      set nuclear200        fomcost("Nuclear",v,r) = 2.0 * fomcost_int("Nuclear",v,r) ;    
$if      set nuclear250        fomcost("Nuclear",v,r) = 2.5 * fomcost_int("Nuclear",v,r) ;
$if      set nuclear300        fomcost("Nuclear",v,r) = 3.0 * fomcost_int("Nuclear",v,r) ;

* Correcting SC limits because much of this potential is needed after 2050 when "sucking" technologies become competitive (to restore climate)
$if      set nosccfrictions    sclim_eu = 1   * sclim_eu_int ;
$if      set sclim10           sclim_eu = 0.1 * sclim_eu_int ;
$if      set sclim20           sclim_eu = 0.2 * sclim_eu_int ;
$if      set sclim50           sclim_eu = 0.5 * sclim_eu_int ;
$if      set sclim100          sclim_eu = 1.0 * sclim_eu_int ;
$if      set nosccfrictions    sclim(r) = 1   * sclim_int(r) ;
$if      set sclim10           sclim(r) = 0.1 * sclim_int(r) ;
$if      set sclim20           sclim(r) = 0.2 * sclim_int(r) ;
$if      set sclim50           sclim(r) = 0.5 * sclim_int(r) ;
$if      set sclim100          sclim(r) = 1.0 * sclim_int(r) ;

* Correcting biomass limits because not all biomass can go into the power plants (food, traffic, ...)
$if not  set biolim            biolim_eu(t) = 1 * biolim_eu_int(t) ;
$if      set biolimnormal      biolim_eu(t) = 1 * biolim_eu_int(t) ;
$if      set biolimhalf        biolim_eu(t) = 0.5 * biolim_eu_int(t) ;
$if      set biolimdouble      biolim_eu(t) = 2 * biolim_eu_int(t) ;
$if not  set biolim_r          biolim(r,t) = 1 * biolim_int(r,t) ;
$if      set biolimnormal      biolim(r,t) = 1 * biolim_int(r,t) ;
$if      set biolimhalf        biolim(r,t) = 0.5 * biolim_int(r,t) ;
$if      set biolimdouble      biolim(r,t) = 2 * biolim_int(r,t) ;

$if      set bioliminterpol    biolim_eu(t) = 189.3 / 136.84 * 403 + (t.val - 2020)/30 * (0.5 * biolim_eu_int(t) - 403) ;
$if      set nobiofrictions    biolim_eu(t) = 0.5 * biolim_eu_int(t) ;
$if      set bioliminterpol    biolim(r,t)  = biolim_int(r,t) * biolim_eu(t) / biolim_eu("2050") ;

* Correcting biomass emissions factors according to biomass neutral treatment (socially and politically questionable)    
$if      set bioneutral        emit("Bioenergy",v,r) = 0 ;
$if      set bioneutral        emit("Bio_CCS",v,r) = - co2captured("Bio_CCS",v,r) ;
      
* * * Storage technology
set
j                                Storage technology
newj(j)                          New storage technology
exij(j)                          Existing storage technology
;

$gdxin database\setpar_%n%.gdx
$load j, newj, exij
$gdxin

parameter
gcap(j,v,r)                      Storage capacity by region (GW)
ghours(j,v,r)                    Hours of storage (room size relative to door size)
chrgpen(j,v,r)                   Charge efficiency penalty for storage by region (< 1)
dchrgpen(j,v,r)                  Discharge efficiency penalty for storage by region (< 1)
dischrg(j,v,r)                   Automatic storage discharge by region (in percent) (< 1)
gcapcost_int(j,v,r)              Capital cost of storage charge-discharge capacity by region (EUR per MW)
gcapcost(j,v,r)                  Capital cost of storage charge-discharge capacity by region (EUR per MW)
gfomcost(j,v,r)                  Fixed OM cost for storage by region(EUR per MW)
gvomcost(j,v,r)                  Variable OM cost for storage by region (EUR per MWh)
greliability(j,v,r)              Storage reliability factor by region and technology
gcapcred(j,v,r)                  Storage capacity credit by region and technology
ginvlife(j,v)                    Storage investment life for new capacity additions (years)
ginvdepr(j,v)                    Storage investment life for new capacity additions (years)
ginvlimLO(j,r,t)                 Storage investment lower bound (GW)
ginvlimUP(j,r,t)                 Storage investment upper bound (GW)
ginvlimUP_eu(j,t)                Storage investment upper bound (GW)
;

$gdxin database\setpar_%n%.gdx
$load gcap, ghours, chrgpen, dchrgpen, dischrg, gcapcost_int=gcapcost, gfomcost, gvomcost, greliability, gcapcred, ginvlife, ginvdepr, ginvlimLO, ginvlimUP, ginvlimUP_eu
$gdxin

gcapcost(j,v,r)                                          = 1   * gcapcost_int(j,v,r) ;
$if      set halfgcc     gcapcost(j,v,r)$(v.val ge 2020) = 0.5 * gcapcost_int(j,v,r) ;
$if      set doublegcc   gcapcost(j,v,r)$(v.val ge 2020) = 2   * gcapcost_int(j,v,r) ;
$if      set triplegcc   gcapcost(j,v,r)$(v.val ge 2020) = 3   * gcapcost_int(j,v,r) ;

* * * Transmission technology
set
k                               Transmission technologies
tmap_cty(k,cty,cty)  Countries eligible for transmission exchange
tmap(k,r,r)          Regions eligible for transmission exchange by technology
xtmap(r,r,cty,cty)              Map regions countries eligible for transmission exchange
;

$gdxin database\setpar_%n%.gdx
$load k, tmap, xtmap, tmap_cty
$gdxin

parameter
tcap(k,r,r)                     Transmission capacity from region X to region Y (GW)
tcapcost(k,r,r)                 Transmission investment cost ($ per kW)
tfomcost(k,r,r)                 Fixed O&M cost of new transmision capacity (euro per kW-year)
tvomcost(k,r,r)                 Variable O&M cost of new transmision capacity (euro per MWh)
trnspen(k,r,r)                  Transmission loss penalty
tinvlimUP_int(k,r,r,t)          Upper bound on total transmission capacity from region X to region Y (GW)
tinvlimUP(k,r,r,t)              Upper bound on total transmission capacity from region X to region Y (GW)
tinvlimLO(k,r,r,t)              Lower bound on total transmission capacity from region X to region Y (GW)
tinvlimUP_eu(k,t)               Lower bound on total transmission capacity from region X to region Y (GW)
tcapcred(k,r,r)                 Capacity credit for transmisson by region and technology
tinvlife(k)                     Capacity lifetime (years)
tinvdepr(k)                     Investment depreciation (years)
;

$gdxin database\setpar_%n%.gdx
$load tcap, tcapcost, tfomcost, tvomcost, trnspen, tinvlimUP_int=tinvlimUP, tinvlimLO, tinvlimUP_eu, tcapcred, tinvlife, tinvdepr
$gdxin

tinvlimUP(k,r,rr,t)                                           = 1   * tinvlimUP_int(k,r,rr,t) ;
$if      set lowntc      tinvlimUP(k,r,rr,t)$(t.val ge 2035)  =       tinvlimLO(k,r,rr,t) ;
$if      set doublentc   tinvlimUP(k,r,rr,t)$(t.val ge 2035)  = 2   * tinvlimUP_int(k,r,rr,t) ;
$if      set triplentc   tinvlimUP(k,r,rr,t)$(t.val ge 2035)  = 3   * tinvlimUP_int(k,r,rr,t) ;

* * * Enabling to reduce frictions
$if      set noinvfrictions       invlimLO(i,r,t)    = 0 ;
$if      set noinvfrictions       invlimUP(i,r,t)    = inf ;
$if      set notinvfrictions     tinvlimLO(k,r,rr,t) = 0 ;
$if      set notinvfrictions     tinvlimUP(k,r,rr,t) = inf ;
$if      set noginvfrictions     ginvlimLO(j,r,t)    = 0 ;
$if      set noginvfrictions     ginvlimUP(j,r,t)    = inf ;

* * * Discounting
parameter
tk                              Investment tax
nyrs(t)                         Number of years since last time step
drate                           Annual discount rate
dfact(t)                        Discount factor for time period t (reflects number of years) for both
annuity(i,v)                     Annuity factor for generation capacity
gannuity(j,v)                   Annuity factor for storage capacity
tannuity(k)                     Annuity factor for transmission capacity
;

$gdxin database\setpar_%n%.gdx
$load tk, nyrs, drate, dfact, annuity, gannuity, tannuity
$gdxin

* * * Lifetime and depreciation
parameter
lifetime(i,v,r,t)               Lifetime coefficient for existing and new capacity
deprtime(i,v,r,t)               Depreciation coefficient for existing and new capacity
glifetime(j,v,r,t)              Lifetime coefficient for existing and new capacity
gdeprtime(j,v,r,t)              Depreciation coefficient for existing and new capacity
tlifetime(k,v,r,t)              Depreciation coefficient for existing and new capacity
tdeprtime(k,v,r,t)              Fraction of discounted annualized payment stream contained in remaining model time horizon
endeffect(i,v,r,t)              Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
gendeffect(j,v,r,t)             Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
tendeffect(k,v,r,t)             Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
modeldepr(i,v,r,t)              Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
gmodeldepr(j,v,r,t)             Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
tmodeldepr(k,v,r,t)             Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
modeldepr_nodisc(i,v,r,t)       Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
gmodeldepr_nodisc(j,v,r,t)      Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
tmodeldepr_nodisc(k,v,r,t)      Fraction of (non-)discounted annualized payment stream contained in remaining model time horizon (depreciation)
;

$gdxin database\setpar_%n%.gdx
$load lifetime, deprtime
$load glifetime, gdeprtime
$load tlifetime, tdeprtime
$load modeldepr, modeldepr_nodisc
$load gmodeldepr, gmodeldepr_nodisc
$load tmodeldepr, tmodeldepr_nodisc
;

* * * Myopic module
$gdxin database\setpar_%n%.gdx
$if not  set myopic $if not set nodisc                           $load endeffect=modeldepr
$if not  set myopic $if     set nodisc                           $load endeffect=modeldepr_nodisc
$if not  set myopic $if not set nodisc                           $load gendeffect=gmodeldepr
$if not  set myopic $if     set nodisc                           $load gendeffect=gmodeldepr_nodisc
$if not  set myopic $if not set nodisc                           $load tendeffect=tmodeldepr
$if not  set myopic $if     set nodisc                           $load tendeffect=tmodeldepr_nodisc
$if      set myopic $if not set nodisc   $if set overlap1        $load endeffect=modeldepr_myopic
$if      set myopic $if set nodisc       $if set overlap1        $load endeffect=modeldepr_nodisc_myopic
$if      set myopic $if not set nodisc   $if set overlap2        $load endeffect=modeldepr_myopic_overlap2
$if      set myopic $if set nodisc       $if set overlap2        $load endeffect=modeldepr_nodisc_myopic_overlap2
$if      set myopic $if not set nodisc   $if set overlap3        $load endeffect=modeldepr_myopic_overlap3
$if      set myopic $if set nodisc       $if set overlap3        $load endeffect=modeldepr_nodisc_myopic_overlap3
$if      set myopic $if not set nodisc   $if set overlap4        $load endeffect=modeldepr_myopic_overlap4
$if      set myopic $if set nodisc       $if set overlap4        $load endeffect=modeldepr_nodisc_myopic_overlap4
$if      set myopic $if not set nodisc   $if set overlap5        $load endeffect=modeldepr_myopic_overlap5
$if      set myopic $if set nodisc       $if set overlap5        $load endeffect=modeldepr_nodisc_myopic_overlap5
$if      set myopic $if not set nodisc   $if set overlap6        $load endeffect=modeldepr_myopic_overlap6
$if      set myopic $if set nodisc       $if set overlap6        $load endeffect=modeldepr_nodisc_myopic_overlap6
$if      set myopic $if not set nodisc   $if set overlap7        $load endeffect=modeldepr_myopic_overlap7
$if      set myopic $if set nodisc       $if set overlap7        $load endeffect=modeldepr_nodisc_myopic_overlap7
$if      set myopic $if not set nodisc   $if set overlap1        $load gendeffect=gmodeldepr_myopic
$if      set myopic $if set nodisc       $if set overlap1        $load gendeffect=gmodeldepr_nodisc_myopic
$if      set myopic $if not set nodisc   $if set overlap2        $load gendeffect=gmodeldepr_myopic_overlap2
$if      set myopic $if set nodisc       $if set overlap2        $load gendeffect=gmodeldepr_nodisc_myopic_overlap2
$if      set myopic $if not set nodisc   $if set overlap3        $load gendeffect=gmodeldepr_myopic_overlap3
$if      set myopic $if set nodisc       $if set overlap3        $load gendeffect=gmodeldepr_nodisc_myopic_overlap3
$if      set myopic $if not set nodisc   $if set overlap4        $load gendeffect=gmodeldepr_myopic_overlap4
$if      set myopic $if set nodisc       $if set overlap4        $load gendeffect=gmodeldepr_nodisc_myopic_overlap4
$if      set myopic $if not set nodisc   $if set overlap5        $load gendeffect=gmodeldepr_myopic_overlap5
$if      set myopic $if set nodisc       $if set overlap5        $load gendeffect=gmodeldepr_nodisc_myopic_overlap5
$if      set myopic $if not set nodisc   $if set overlap6        $load gendeffect=gmodeldepr_myopic_overlap6
$if      set myopic $if set nodisc       $if set overlap6        $load gendeffect=gmodeldepr_nodisc_myopic_overlap6
$if      set myopic $if not set nodisc   $if set overlap7        $load gendeffect=gmodeldepr_myopic_overlap7
$if      set myopic $if set nodisc       $if set overlap7        $load gendeffect=gmodeldepr_nodisc_myopic_overlap7
$if      set myopic $if not set nodisc   $if set overlap1        $load tendeffect=tmodeldepr_myopic
$if      set myopic $if set nodisc       $if set overlap1        $load tendeffect=tmodeldepr_nodisc_myopic
$if      set myopic $if not set nodisc   $if set overlap2        $load tendeffect=tmodeldepr_myopic_overlap2
$if      set myopic $if set nodisc       $if set overlap2        $load tendeffect=tmodeldepr_nodisc_myopic_overlap2
$if      set myopic $if not set nodisc   $if set overlap3        $load tendeffect=tmodeldepr_myopic_overlap3
$if      set myopic $if set nodisc       $if set overlap3        $load tendeffect=tmodeldepr_nodisc_myopic_overlap3
$if      set myopic $if not set nodisc   $if set overlap4        $load tendeffect=tmodeldepr_myopic_overlap4
$if      set myopic $if set nodisc       $if set overlap4        $load tendeffect=tmodeldepr_nodisc_myopic_overlap4
$if      set myopic $if not set nodisc   $if set overlap5        $load tendeffect=tmodeldepr_myopic_overlap5
$if      set myopic $if set nodisc       $if set overlap5        $load tendeffect=tmodeldepr_nodisc_myopic_overlap5
$if      set myopic $if not set nodisc   $if set overlap6        $load tendeffect=tmodeldepr_myopic_overlap6
$if      set myopic $if set nodisc       $if set overlap6        $load tendeffect=tmodeldepr_nodisc_myopic_overlap6
$if      set myopic $if not set nodisc   $if set overlap7        $load tendeffect=tmodeldepr_myopic_overlap7
$if      set myopic $if set nodisc       $if set overlap7        $load tendeffect=tmodeldepr_nodisc_myopic_overlap7
$gdxin

set
$if not  set myopic $if not set shortrun tmyopic(t)      Optimization periods /2020,2025,2030,2035,2040,2045,2050/
$if not  set myopic     $if set shortrun tmyopic(t)      Optimization periods /2020,2021,2022,2023,2024,2025,2026,2027,2028,2029,2030,2035,2040,2045,2050/

$if      set myopic2020 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2020/
$if      set myopic2025 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2025/
$if      set myopic2030 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2030/
$if      set myopic2035 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2035/
$if      set myopic2040 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2040/
$if      set myopic2045 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2045/
$if      set myopic2050 $if set overlap1 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2020,2025/
$if      set myopic2025 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2025,2030/
$if      set myopic2030 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2030,2035/
$if      set myopic2035 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2035,2040/
$if      set myopic2040 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2040,2045/
$if      set myopic2045 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap2 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2020,2025,2030/
$if      set myopic2025 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2025,2030,2035/
$if      set myopic2030 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2030,2035,2040/
$if      set myopic2035 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2035,2040,2045/
$if      set myopic2040 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2040,2045,2050/
$if      set myopic2045 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap3 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2020,2025,2030,2035/
$if      set myopic2025 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2025,2030,2035,2040/
$if      set myopic2030 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2030,2035,2040,2045/
$if      set myopic2035 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2035,2040,2045,2050/
$if      set myopic2040 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2040,2045,2050/
$if      set myopic2045 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap4 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2020,2025,2030,2035,2040/
$if      set myopic2025 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2025,2030,2035,2040,2045/
$if      set myopic2030 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2030,2035,2040,2045,2050/
$if      set myopic2035 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2035,2040,2045,250/
$if      set myopic2040 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2040,2045,2050/
$if      set myopic2045 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap5 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2020,2025,2030,2035,2040,2045/
$if      set myopic2025 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2025,2030,2035,2040,2045,2050/
$if      set myopic2030 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2030,2035,2040,2045,2050/
$if      set myopic2035 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2035,2040,2045,2050/
$if      set myopic2040 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2040,2045,2050/
$if      set myopic2045 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap6 tmyopic(t)      Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2020,2025,2030,2035,2040,2045,2050/
$if      set myopic2025 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2025,2030,2035,2040,2045,2050/
$if      set myopic2030 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2030,2035,2040,2045,2050/
$if      set myopic2035 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2035,2040,2045,2050/
$if      set myopic2040 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2040,2045,2050/
$if      set myopic2045 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2045,2050/
$if      set myopic2050 $if set overlap7 tmyopic(t)      Myopic (or static) optimization year /2050/
;

* Define correspoinding parameters for myopic and overlapping myopic runs
parameter
$if not  set myopic                      tmyopicLO         Myopic (or static) optimization year /2020/
$if not  set myopic                      tmyopicUP         Myopic (or static) optimization year /2500/

$if      set myopic2020                  tmyopicLO         Myopic (or static) optimization year /2020/
$if      set myopic2025                  tmyopicLO         Myopic (or static) optimization year /2025/
$if      set myopic2030                  tmyopicLO         Myopic (or static) optimization year /2030/
$if      set myopic2035                  tmyopicLO         Myopic (or static) optimization year /2035/
$if      set myopic2040                  tmyopicLO         Myopic (or static) optimization year /2040/
$if      set myopic2045                  tmyopicLO         Myopic (or static) optimization year /2045/
$if      set myopic2050                  tmyopicLO         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2020/
$if      set myopic2025 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2025/
$if      set myopic2030 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2030/
$if      set myopic2035 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2035/
$if      set myopic2040 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2040/
$if      set myopic2045 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2050 $if set overlap1 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2025/
$if      set myopic2025 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2030/
$if      set myopic2030 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2035/
$if      set myopic2035 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2040/
$if      set myopic2040 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2045 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap2 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2030/
$if      set myopic2025 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2035/
$if      set myopic2030 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2040/
$if      set myopic2035 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2040 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap3 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2035/
$if      set myopic2025 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2040/
$if      set myopic2030 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2035 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2040 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap4 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2040/
$if      set myopic2025 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2030 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2035 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2040 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap5 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2045/
$if      set myopic2025 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2030 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2035 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2040 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap6 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2025 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2030 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2035 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2040 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap7 tmyopicUP         Myopic (or static) optimization year /2050/

$if      set myopic2020 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2025 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2030 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2035 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2040 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2045 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
$if      set myopic2050 $if set overlap8 tmyopicUP         Myopic (or static) optimization year /2050/
;

parameter
$if not  set myopic                             dummy
$if      set myopic $if      set myopic2020     dd_myopic_int(r,t)
$if      set myopic $if      set myopic2020     bs_myopic_int(s,r,t)
$if      set myopic $if      set myopic2020     x_myopic_int(s,i,v,r,t)
$if      set myopic $if      set myopic2020     xc_myopic_int(i,v,r,t)
$if      set myopic $if      set myopic2020     ix_myopic_int(i,r,t)
$if      set myopic $if      set myopic2020     xcs_myopic_int(s,i,v,r,t)
$if      set myopic $if      set myopic2020     xtwh_myopic_int(i,v,r,t)
$if      set myopic $if      set myopic2020     e_myopic_int(s,k,r,r,t)
$if      set myopic $if      set myopic2020     it_myopic_int(k,r,r,t)
$if      set myopic $if      set myopic2020     g_myopic_int(s,j,v,r,t)
$if      set myopic $if      set myopic2020     gd_myopic_int(s,j,v,r,t)
$if      set myopic $if      set myopic2020     gc_myopic_int(j,v,r,t)
$if      set myopic $if      set myopic2020     ig_myopic_int(j,r,t)
$if      set myopic $if      set myopic2020     gb_myopic_int(s,j,v,r,t)
$if      set myopic $if      set myopic2020     sc_myopic_int(r,t)
$if      set myopic $if      set myopic2020     da_myopic_int(r,t)
$if      set myopic $if      set myopic2020     tc_myopic_int(k,r,r,t)
$if      set myopic                             dd_myopic(r,t)
$if      set myopic                             bs_myopic(s,r,t)
$if      set myopic                             x_myopic(s,i,v,r,t)
$if      set myopic                             xc_myopic(i,v,r,t)
$if      set myopic                             ix_myopic(i,r,t)
$if      set myopic                             xcs_myopic(s,i,v,r,t)
$if      set myopic                             xtwh_myopic(i,v,r,t)
$if      set myopic                             e_myopic(s,k,r,r,t)
$if      set myopic                             it_myopic(k,r,r,t)
$if      set myopic                             g_myopic(s,j,v,r,t)
$if      set myopic                             gd_myopic(s,j,v,r,t)
$if      set myopic                             gc_myopic(j,v,r,t)
$if      set myopic                             ig_myopic(j,r,t)
$if      set myopic                             gb_myopic(s,j,v,r,t)
$if      set myopic                             sc_myopic(r,t)
$if      set myopic                             da_myopic(r,t)
$if      set myopic                             tc_myopic(k,r,r,t)
;

$if not  set myopic                             dummy = 0 ;
$if      set myopic $if      set myopic2020     d_myopic(r,t) = 0 ;
$if      set myopic $if      set myopic2020     bs_myopic(s,r,t) = 0 ;
$if      set myopic $if      set myopic2020     x_myopic(s,i,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     xc_myopic(i,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     ix_myopic(i,r,t) = 0 ;
$if      set myopic $if      set myopic2020     xcs_myopic(s,i,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     xtwh_myopic(i,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     e_myopic(s,k,r,rr,t) = 0 ;
$if      set myopic $if      set myopic2020     it_myopic(k,r,rr,t) = 0 ;
$if      set myopic $if      set myopic2020     g_myopic(s,j,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     gd_myopic(s,j,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     gc_myopic(j,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     ig_myopic(j,r,t) = 0 ;
$if      set myopic $if      set myopic2020     gb_myopic(s,j,v,r,t) = 0 ;
$if      set myopic $if      set myopic2020     sc_myopic(r,t) = 0 ;
$if      set myopic $if      set myopic2020     da_myopic(r,t) = 0 ;
$if      set myopic $if      set myopic2020     tc_myopic(k,r,rr,t) = 0 ;
* Load variables (need to fix because there are new variables)
$if      set myopic $if not  set myopic2020     $gdxin limits_%m%\%e%_limits.gdx
$if      set myopic $if not  set myopic2020     $load dd_myopic=dd_myopic_int, bs_myopic=bs_myopic_int, x_myopic=x_myopic_int, xc_myopic=xc_myopic_int, ix_myopic=ix_myopic_int, xcs_myopic=xcs_myopic_int, xtwh_myopic=xtwh_myopic_int, e_myopic=e_myopic_int
$if      set myopic $if not  set myopic2020     $load it_myopic=it_myopic_int,
$if      set myopic $if not  set myopic2020     $load g_myopic=g_myopic_int, gd_myopic=gd_myopic_int, gc_myopic=gc_myopic_int, ig_myopic=ig_myopic_int
$if      set myopic $if not  set myopic2020     $load gb_myopic=gb_myopic_int, sc_myopic=sc_myopic_int, da_myopic=da_myopic_int, tc_myopic=tc_myopic_int
$if      set myopic $if not  set myopic2020     $gdxin
* Myopic model fixes
$if      set myopic      BS.FX(s,r,t)$(t.val < tmyopicLO)                 = bs_myopic(s,r,t) ;
$if      set myopic      X.FX(s,i,v,r,t)$(t.val < tmyopicLO)              = x_myopic(s,i,v,r,t) ;
$if      set myopic      XC.FX(i,v,r,t)$(t.val < tmyopicLO)               = xc_myopic(i,v,r,t) ;
$if      set myopic      IX.FX(i,r,t)$(t.val < tmyopicLO)                 = ix_myopic(i,r,t) ;
$if      set myopic      XCS.FX(s,i,v,r,t)$(t.val < tmyopicLO)            = xcs_myopic(s,i,v,r,t) ;
$if      set myopic      XTWH.FX(i,v,r,t)$(t.val < tmyopicLO)             = xtwh_myopic(i,v,r,t) ;
$if      set myopic      E.FX(s,k,r,rr,t)$(t.val < tmyopicLO)             = e_myopic(s,k,r,rr,t) ;
$if      set myopic      IT.FX(k,r,rr,t)$(t.val < tmyopicLO)              = it_myopic(k,r,rr,t) ;
$if      set myopic      G.FX(s,j,v,r,t)$(t.val < tmyopicLO)              = g_myopic(s,j,v,r,t) ;
$if      set myopic      GD.FX(s,j,v,r,t)$(t.val < tmyopicLO)             = gd_myopic(s,j,v,r,t) ;
$if      set myopic      GC.FX(j,v,r,t)$(t.val < tmyopicLO)               = gc_myopic(j,v,r,t) ;
$if      set myopic      IG.FX(j,r,t)$(t.val < tmyopicLO)                 = ig_myopic(j,r,t) ;
$if      set myopic      GB.FX(s,j,v,r,t)$(t.val < tmyopicLO)             = gb_myopic(s,j,v,r,t) ;
$if      set myopic      SC.FX(r,t)$(t.val < tmyopicLO)                   = sc_myopic(r,t) ;
$if      set myopic      TC.FX(k,r,rr,t)$(t.val < tmyopicLO)              = tc_myopic(k,r,rr,t) ;
$if      set myopic      BS.FX(s,r,t)$(t.val > tmyopicUP)                 = eps ;
$if      set myopic      X.FX(s,i,v,r,t)$(t.val > tmyopicUP)              = eps ;
$if      set myopic      XC.FX(i,v,r,t)$(t.val > tmyopicUP)               = eps ;
$if      set myopic      IX.FX(i,r,t)$(t.val > tmyopicUP)                 = eps ;
$if      set myopic      XCS.FX(s,i,v,r,t)$(t.val > tmyopicUP)            = eps ;
$if      set myopic      XTWH.FX(i,v,r,t)$(t.val > tmyopicUP)             = eps ;
$if      set myopic      E.FX(s,k,r,rr,t)$(t.val > tmyopicUP)             = eps ;
$if      set myopic      IT.FX(k,r,rr,t)$(t.val > tmyopicUP)              = eps ;
$if      set myopic      G.FX(s,j,v,r,t)$(t.val > tmyopicUP)              = eps ;
$if      set myopic      GD.FX(s,j,v,r,t)$(t.val > tmyopicUP)             = eps ;
$if      set myopic      GC.FX(j,v,r,t)$(t.val > tmyopicUP)               = eps ;
$if      set myopic      IG.FX(j,r,t)$(t.val > tmyopicUP)                 = eps ;
$if      set myopic      GB.FX(s,j,v,r,t)$(t.val > tmyopicUP)             = eps ;
$if      set myopic      SC.FX(r,t)$(t.val > tmyopicUP)                   = eps ;
$if      set myopic      TC.FX(k,r,rr,t)$(t.val > tmyopicUP)              = eps ;

* * * Investor module
set
inv
drateopt
;

$gdxin database\setpar_%n%.gdx
$load inv, drateopt
$gdxin

parameter
share_invr(inv,r)
shareinv_invir(inv,i,r)  
shareinv_invjr(inv,j,r)  
shareinv_invkr(inv,k,r)    
dfact_int2(drateopt,t)
deprtime_invi(inv,i,v,r,t)                                
deprtime_invj(inv,j,v,r,t) 
deprtime_invk(inv,k,v,r,t)
lifetime_invi(inv,i,v,r,t)                                
lifetime_invj(inv,j,v,r,t) 
lifetime_invk(inv,k,v,r,t)
zeta_invir(drateopt,inv,i,v,r)
zeta_invjr(drateopt,inv,j,v,r)
zeta_invkr(drateopt,inv,k,v,r)
;

$gdxin database\setpar_%n%.gdx
$load share_invr
$load shareinv_invir  
$load shareinv_invjr  
$load shareinv_invkr  
$load dfact_int2
$load deprtime_invi    
$load deprtime_invj 
$load deprtime_invk
$load lifetime_invi    
$load lifetime_invj 
$load lifetime_invk
$if not  set myopic     $if not  set nodisc                         $load   zeta_invir  =   zetastar_invir
$if not  set myopic     $if not  set nodisc                         $load   zeta_invjr  =   zetastar_invjr
$if not  set myopic     $if not  set nodisc                         $load   zeta_invkr  =   zetastar_invkr
$if not  set myopic     $if      set nodisc                         $load   zeta_invir  =   zetastar_invir_nodisc
$if not  set myopic     $if      set nodisc                         $load   zeta_invjr  =   zetastar_invjr_nodisc
$if not  set myopic     $if      set nodisc                         $load   zeta_invkr  =   zetastar_invkr_nodisc
$if      set myopic     $if not  set nodisc     $if set noverlap    $load   zeta_invir  =   zetastar_invir_noverlap
$if      set myopic     $if not  set nodisc     $if set noverlap    $load   zeta_invjr  =   zetastar_invjr_noverlap
$if      set myopic     $if not  set nodisc     $if set noverlap    $load   zeta_invkr  =   zetastar_invkr_noverlap
$if      set myopic     $if not  set nodisc     $if set overlap1    $load   zeta_invir  =   zetastar_invir_overlap1
$if      set myopic     $if not  set nodisc     $if set overlap1    $load   zeta_invjr  =   zetastar_invjr_overlap1
$if      set myopic     $if not  set nodisc     $if set overlap1    $load   zeta_invkr  =   zetastar_invkr_overlap1
$if      set myopic     $if not  set nodisc     $if set overlap2    $load   zeta_invir  =   zetastar_invir_overlap2
$if      set myopic     $if not  set nodisc     $if set overlap2    $load   zeta_invjr  =   zetastar_invjr_overlap2
$if      set myopic     $if not  set nodisc     $if set overlap2    $load   zeta_invkr  =   zetastar_invkr_overlap2
$if      set myopic     $if not  set nodisc     $if set overlap3    $load   zeta_invir  =   zetastar_invir_overlap3
$if      set myopic     $if not  set nodisc     $if set overlap3    $load   zeta_invjr  =   zetastar_invjr_overlap3
$if      set myopic     $if not  set nodisc     $if set overlap3    $load   zeta_invkr  =   zetastar_invkr_overlap3
$if      set myopic     $if not  set nodisc     $if set overlap4    $load   zeta_invir  =   zetastar_invir_overlap4
$if      set myopic     $if not  set nodisc     $if set overlap4    $load   zeta_invjr  =   zetastar_invjr_overlap4
$if      set myopic     $if not  set nodisc     $if set overlap4    $load   zeta_invkr  =   zetastar_invkr_overlap4
$if      set myopic     $if not  set nodisc     $if set overlap5    $load   zeta_invir  =   zetastar_invir_overlap5
$if      set myopic     $if not  set nodisc     $if set overlap5    $load   zeta_invjr  =   zetastar_invjr_overlap5
$if      set myopic     $if not  set nodisc     $if set overlap5    $load   zeta_invkr  =   zetastar_invkr_overlap5
$if      set myopic     $if not  set nodisc     $if set overlap6    $load   zeta_invir  =   zetastar_invir_overlap6
$if      set myopic     $if not  set nodisc     $if set overlap6    $load   zeta_invjr  =   zetastar_invjr_overlap6
$if      set myopic     $if not  set nodisc     $if set overlap6    $load   zeta_invkr  =   zetastar_invkr_overlap6
$if      set myopic     $if not  set nodisc     $if set overlap7    $load   zeta_invir  =   zetastar_invir_overlap7
$if      set myopic     $if not  set nodisc     $if set overlap7    $load   zeta_invjr  =   zetastar_invjr_overlap7
$if      set myopic     $if not  set nodisc     $if set overlap7    $load   zeta_invkr  =   zetastar_invkr_overlap7
$if      set myopic     $if      set nodisc     $if set noverlap    $load   zeta_invir  =   zetastar_invir_nodisc_noverlap
$if      set myopic     $if      set nodisc     $if set noverlap    $load   zeta_invjr  =   zetastar_invjr_nodisc_noverlap
$if      set myopic     $if      set nodisc     $if set noverlap    $load   zeta_invkr  =   zetastar_invkr_nodisc_noverlap
$if      set myopic     $if      set nodisc     $if set overlap1    $load   zeta_invir  =   zetastar_invir_nodisc_overlap1
$if      set myopic     $if      set nodisc     $if set overlap1    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap1
$if      set myopic     $if      set nodisc     $if set overlap1    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap1
$if      set myopic     $if      set nodisc     $if set overlap2    $load   zeta_invir  =   zetastar_invir_nodisc_overlap2
$if      set myopic     $if      set nodisc     $if set overlap2    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap2
$if      set myopic     $if      set nodisc     $if set overlap2    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap2
$if      set myopic     $if      set nodisc     $if set overlap3    $load   zeta_invir  =   zetastar_invir_nodisc_overlap3
$if      set myopic     $if      set nodisc     $if set overlap3    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap3
$if      set myopic     $if      set nodisc     $if set overlap3    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap3
$if      set myopic     $if      set nodisc     $if set overlap4    $load   zeta_invir  =   zetastar_invir_nodisc_overlap4
$if      set myopic     $if      set nodisc     $if set overlap4    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap4
$if      set myopic     $if      set nodisc     $if set overlap4    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap4
$if      set myopic     $if      set nodisc     $if set overlap5    $load   zeta_invir  =   zetastar_invir_nodisc_overlap5
$if      set myopic     $if      set nodisc     $if set overlap5    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap5
$if      set myopic     $if      set nodisc     $if set overlap5    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap5
$if      set myopic     $if      set nodisc     $if set overlap6    $load   zeta_invir  =   zetastar_invir_nodisc_overlap6
$if      set myopic     $if      set nodisc     $if set overlap6    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap6
$if      set myopic     $if      set nodisc     $if set overlap6    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap6
$if      set myopic     $if      set nodisc     $if set overlap7    $load   zeta_invir  =   zetastar_invir_nodisc_overlap7
$if      set myopic     $if      set nodisc     $if set overlap7    $load   zeta_invjr  =   zetastar_invjr_nodisc_overlap7
$if      set myopic     $if      set nodisc     $if set overlap7    $load   zeta_invkr  =   zetastar_invkr_nodisc_overlap7
$gdxin


parameter
share(inv,i,r)
gshare(inv,j,r)
tshare(inv,k,r)
zeta(inv,i,v,r)
gzeta(inv,j,v,r)
tzeta(inv,k,v,r)
;

* Shares according to options
$if      set opt1   share(inv,i,r)  = share_invr(inv,r) ;
$if      set opt3   share(inv,i,r)  = shareinv_invir(inv,i,r) ;
$if      set opt1   gshare(inv,j,r) = share_invr(inv,r) ;
$if      set opt3   gshare(inv,j,r) = shareinv_invjr(inv,j,r) ;
$if      set opt1   tshare(inv,k,r) = share_invr(inv,r) ;
$if      set opt3   tshare(inv,k,r) = shareinv_invkr(inv,k,r) ;
* Lifetimes according to options (overriding the old option)
$if      set opt1   lifetime(i,v,r,t)      = sum(inv, lifetime_invi(inv,i,v,r,t) * share_invr(inv,r)) ;
$if      set opt1   glifetime(j,v,r,t)     = sum(inv, lifetime_invj(inv,j,v,r,t) * share_invr(inv,r)) ;
$if      set opt1   tlifetime(k,v,r,t)     = sum(inv, lifetime_invk(inv,k,v,r,t) * share_invr(inv,r)) ;
$if      set opt3   lifetime(i,v,r,t)      = sum(inv, lifetime_invi(inv,i,v,r,t) * shareinv_invir(inv,i,r)) ;
$if      set opt3   glifetime(j,v,r,t)     = sum(inv, lifetime_invj(inv,j,v,r,t) * shareinv_invjr(inv,j,r)) ;
$if      set opt3   tlifetime(k,v,r,t)     = sum(inv, lifetime_invk(inv,k,v,r,t) * shareinv_invkr(inv,k,r)) ;
* Investment cost factor according to options
$if      set opt1   zeta(inv,i,v,r)  = zeta_invir("opt1",inv,i,v,r) ;
$if      set opt3   zeta(inv,i,v,r)  = zeta_invir("opt3",inv,i,v,r) ;
$if      set opt1   gzeta(inv,j,v,r) = zeta_invjr("opt1",inv,j,v,r) ;
$if      set opt3   gzeta(inv,j,v,r) = zeta_invjr("opt3",inv,j,v,r) ;
$if      set opt1   tzeta(inv,k,v,r) = zeta_invkr("opt1",inv,k,v,r) ;
$if      set opt3   tzeta(inv,k,v,r) = zeta_invkr("opt3",inv,k,v,r) ;
* Adjustment of discount rate according to options
$if      set opt1   dfact(t) = dfact_int2("opt1",t) ;
$if      set opt3   dfact(t) = dfact_int2("opt3",t) ;
* No discouting option
$if      set nodisc dfact(t) = nyrs(t) ;
* Germany nuclear extension and Steckbetrieb (adjustments are necessary here and not above)
$if      set extension      $if not set shortrun    lifetime("Nuclear","1990","Germany","2025")                              = 0.2 + round((1.41 + 1.31 + 1.335)/(1.41 + 1.41 + 1.31 + 1.335), 8) * 0.8 ;
$if      set extension      $if not set shortrun    lifetime("Nuclear","1990","Germany","2030")                              = round((1.41 + 1.31 + 1.335)/(1.41 + 1.41 + 1.31 + 1.335), 8) ;
$if      set streckbetrieb  $if not set shortrun    lifetime("Nuclear","1990","Germany","2025")                              = 0.2 + round((1.41 + 1.31 + 1.335)/(1.41 + 1.41 + 1.31 + 1.335), 8) * 0.4 ;
$if      set streckbetrieb  $if not set shortrun    lifetime("Nuclear","1990","Germany","2030")                     	     = 0 ;
$if      set extension      $if     set shortrun    lifetime("Nuclear","1990","Germany",t)$(t.val ge 2023 and t.val le 2030) = lifetime("Nuclear","1990","Germany","2022") ;
$if      set streckbetrieb  $if     set shortrun    lifetime("Nuclear","1990","Germany","2023")                              = lifetime("Nuclear","1990","Germany","2022") ;

* * * Prices
set
fuel                             Fuel
xfueli(fuel,i)                   Map fuel technology
price_sc                         Price adder scenarios
;

$gdxin database\setpar_%n%.gdx
$load fuel, xfueli, price_sc
$gdxin

parameter
pfuel(fuel,r,t)                         Fuel price (EUR er MWh)
pfadd(fuel,r,t)                         Absolute fuel price adders (EUR per MWh)
pfadd_rel_int(price_sc,fuel,r,t)        Relative fuel price adders (value between 0 (no adding) and x)
pfadd_rel(fuel,r,t)                     Relative fuel price adders (value between 0 (no adding) and x)
pco2_r(r,t)                             CO2 price by region (EUR per tCO2)
pco2_int(t)                             CO2 price (EUR per tCO2) standard
pco2(t)                                 CO2 price (EUR per tCO2)
biocost(r,t)                            Bioenegy cost (EUR per MWh)
biocost_eu(t)                           Bioenegy cost (EUR per MWh)
ccscost(r,t)                            CCS CO2 transportation cost (EUR per tCO2)
ccscost_eu(t)                           CCS CO2 transportation cost (EUR per tCO2)
;

$gdxin database\setpar_%n%.gdx
$load pfuel, pfadd, pco2_r, pco2_int=pco2, biocost, biocost_eu, ccscost, ccscost_eu, pfadd_rel_int=pfadd_rel
$gdxin

pco2(t)                                          = 1 * pco2_int(t) ;
$if      set flatpco2    pco2(t)$(t.val ge 2025) = 1 * pco2_int("2020") ;
$if      set doublepco2  pco2(t)$(t.val ge 2025) = 2 * pco2_int(t) ;
$if      set triplepco2  pco2(t)$(t.val ge 2025) = 3 * pco2_int(t) ;

* Price adjustments must happen here because discost follow before the rest of the "lag"-module is defined
$if      set bauprice                           pfadd_rel(fuel,r,t) = pfadd_rel_int("bauprice",fuel,r,t) ;
$if      set high                               pfadd_rel(fuel,r,t) = pfadd_rel_int("high",fuel,r,t) ;
$if      set recovery                           pfadd_rel(fuel,r,t) = pfadd_rel_int("recovery",fuel,r,t) ;


* * *  Calibration
parameter
loss(r)         
loss_mon(m,r)   
af_int(i,r)       
af_mon(m,i,r)  
voll(r,t)       
voll_mon(m,r,t)
irnwflh2020(i,r)
af_mon_ivrt(m,i,v,r,t)
;

$onUndf
$gdxin database\setpar_%n%.gdx
$load loss, loss_mon, af_int=af, af_mon, voll, voll_mon, irnwflh2020, af_mon_ivrt
$gdxin


* * * Optional modules to activate when analyzing certain research questions

* * * Learning

* * * R&D

* * * Spillover

* * * Policy
set
pol_sc                   Defines a policy scenario
co2cap_sc                Defines a carbon cap scenario
rnwtgt_sc                Defines a renewable energy share (absolute value) target scenario
irnwtgt_sc               Defines a intermittent renewable energy share (absolute value) target scenario
coalexit_sc              Defines a coalexit scenario
nucexit_sc               Defines a nuclear exit scenario
gasexit_sc
;

$gdxin database\setpar_%n%.gdx
$load pol_sc, co2cap_sc, rnwtgt_sc, irnwtgt_sc, coalexit_sc, nucexit_sc, gasexit_sc
$gdxin

parameter
* Interim parameter from database with scenario
co2p_int(pol_sc,t)               Carbon price (EUR per t) (system)
co2cap_r_int(co2cap_sc,r,t)      Carbon emissions cap (GtCO2) (regions)
co2cap_int(pol_sc,t)             Carbon emissions cap (GtCO2) (system)
rnwtgt_r_int(rnwtgt_sc,r,t)      Renewable energy share target (regions)
rnwtgt_int(rnwtgt_sc,t)          Renewable energy share target (system)
irnwtgt_r_int(irnwtgt_sc,r,t)    Intermittent renewable energy share target (regions)
irnwtgt_int(irnwtgt_sc,t)        Intermittent renewable energy share target (system)
coallim_r_int(coalexit_sc,r,t)   Policy constraint on hard coal phase out (regions)
coallim_int(coalexit_sc,t)       Policy constraint on hard coal phase out (system)
lignlim_r_int(coalexit_sc,r,t)   Policy constraint on lignite phase out (regions)
lignlim_int(coalexit_sc,t)       Policy constraint on lignite phase out (system)
nuclim_r_int(nucexit_sc,r,t)     Policy constraint on nuclear phase out (regions)
nuclim_int(nucexit_sc,t)         Policy constraint on nuclear phase out (system)
gaslim_int(gasexit_sc,r,t)       Natural gas bugdets (TWh)
gaslim_eu_int(gasexit_sc,t)      Natural gas bugdets (TWh)
* Model parameter
co2p(t)                          Carbon price (EUR per t) (system)
co2cap_r(r,t)                    Carbon emissions cap (GtCO2) (regions)
co2cap(t)                        Carbon emissions cap (GtCO2) (system)
rnwtgt_r(r,t)                    Renewable energy share target (regions)
rnwtgt(t)                        Renewable energy share target (system)
irnwtgt_r(r,t)                   Intermittent renewable energy share target (regions)
irnwtgt(t)                       Intermittent renewable energy share target (system)
coallim_r(r,t)                   Policy constraint on hard coal phase out (regions)
coallim(t)                       Policy constraint on hard coal phase out (system)
lignlim_r(r,t)                   Policy constraint on lignite phase out (regions)
lignlim(t)                       Policy constraint on lignite phase out (system)
nuclim_r(r,t)                    Policy constraint on nuclear phase out (regions)
nuclim(t)                        Policy constraint on nuclear phase out (system)
gaslim(r,t)                      Natural gas bugdets (TWh)
gaslim_eu(t)                     Natural gas bugdets (TWh)
;

$gdxin database\setpar_%n%.gdx
$load co2p_int=co2p, co2cap_int=co2cap, co2cap_r_int=co2cap_r, rnwtgt_r_int=rnwtgt_r, rnwtgt_int=rnwtgt, irnwtgt_r_int=irnwtgt_r, irnwtgt_int=irnwtgt
$load coallim_int=coallim, coallim_r_int=coallim_r, lignlim_int=lignlim, lignlim_r_int=lignlim_r, nuclim_int=nuclim, nuclim_r_int=nuclim_r,
$load  gaslim_int=gaslim_r, gaslim_eu_int=gaslim
$gdxin

* Scenario switches
$if      set onlyelec       co2p(t) = co2p_int("onlyelec",t) ;
$if      set onlyeleccrisis co2p(t) = co2p_int("onlyeleccrisis",t) ;
$if      set sceuets        co2p(t) = co2p_int("sceuets",t) ;
$if      set sceuetscrisis  co2p(t) = co2p_int("sceuetscrisis",t) ;

$if      set onlyelec       co2cap(t) = co2cap_int("onlyelec",t) ;
$if      set onlyeleccrisis co2cap(t) = co2cap_int("onlyeleccrisis",t) ;
$if      set sceuets        co2cap(t) = co2cap_int("sceuets",t) ;
$if      set sceuetscrisis  co2cap(t) = co2cap_int("sceuetscrisis",t) ;

$if      set ger         coallim_r(r,t) = coallim_r_int("ger",r,t) ;
$if      set ger-fast    coallim_r(r,t) = coallim_r_int("ger-fast",r,t) ;
$if      set ger-slow    coallim_r(r,t) = coallim_r_int("ger-slow",r,t) ;
$if      set eu          coallim_r(r,t) = coallim_r_int("eu",r,t) ;
$if      set eu-fast     coallim_r(r,t) = coallim_r_int("eu-fast",r,t) ;
$if      set eu-slow     coallim_r(r,t) = coallim_r_int("eu-flow",r,t) ;

$if      set ger         lignlim_r(r,t) = lignlim_r_int("ger",r,t) ;
$if      set ger-fast    lignlim_r(r,t) = lignlim_r_int("ger-fast",r,t) ;
$if      set ger-slow    lignlim_r(r,t) = lignlim_r_int("ger-slow",r,t) ;
$if      set eu          lignlim_r(r,t) = lignlim_r_int("eu",r,t) ;
$if      set eu-fast     lignlim_r(r,t) = lignlim_r_int("eu-fast",r,t) ;
$if      set eu-slow     lignlim_r(r,t) = lignlim_r_int("eu-flow",r,t) ;

$if      set ger         nuclim_r(r,t) = nuclim_r_int("ger",r,t) ;
$if      set ger-fast    nuclim_r(r,t) = nuclim_r_int("ger-fast",r,t) ;
$if      set ger-slow    nuclim_r(r,t) = nuclim_r_int("ger-slow",r,t) ;
$if      set eu          nuclim_r(r,t) = nuclim_r_int("eu",r,t) ;
$if      set eu-fast     nuclim_r(r,t) = nuclim_r_int("eu-fast",r,t) ;
$if      set eu-slow     nuclim_r(r,t) = nuclim_r_int("eu-flow",r,t) ;

$if      set aaa         co2cap_r(r,t) = co2cap_r_int("aaa",r,t) ;
$if      set bbb         co2cap_r(r,t) = co2cap_r_int("bbb",r,t) ;
$if      set ccc         co2cap_r(r,t) = co2cap_r_int("ccc",r,t) ;

$if      set aaa         rnwtgt_r(r,t) = rnwtgt_r_int("aaa",r,t) ;
$if      set bbb         rnwtgt_r(r,t) = rnwtgt_r_int("bbb",r,t) ;
$if      set ccc         rnwtgt_r(r,t) = rnwtgt_r_int("ccc",r,t) ;

$if      set aaa         irnwtgt_r(r,t) = irnwtgt_r_int("aaa",r,t) ;
$if      set bbb         irnwtgt_r(r,t) = irnwtgt_r_int("bbb",r,t) ;
$if      set ccc         irnwtgt_r(r,t) = irnwtgt_r_int("ccc",r,t) ;

$if      set ger         coallim(t) = coallim_int("ger",t) ;
$if      set ger-fast    coallim(t) = coallim_int("ger-fast",t) ;
$if      set ger-slow    coallim(t) = coallim_int("ger-slow",t) ;
$if      set eu          coallim(t) = coallim_int("eu",t) ;
$if      set eu-fast     coallim(t) = coallim_int("eu-fast",t) ;
$if      set eu-slow     coallim(t) = coallim_int("eu-flow",t) ;

$if      set ger         lignlim(t) = lignlim_int("ger",t) ;
$if      set ger-fast    lignlim(t) = lignlim_int("ger-fast",t) ;
$if      set ger-slow    lignlim(t) = lignlim_int("ger-slow",t) ;
$if      set eu          lignlim(t) = lignlim_int("eu",t) ;
$if      set eu-fast     lignlim(t) = lignlim_int("eu-fast",t) ;
$if      set eu-slow     lignlim(t) = lignlim_int("eu-flow",t) ;

$if      set ger         nuclim(t) = nuclim_int("ger",t) ;
$if      set ger-fast    nuclim(t) = nuclim_int("ger-fast",t) ;
$if      set ger-slow    nuclim(t) = nuclim_int("ger-slow",t) ;
$if      set eu          nuclim(t) = nuclim_int("eu",t) ;
$if      set eu-fast     nuclim(t) = nuclim_int("eu-fast",t) ;
$if      set eu-slow     nuclim(t) = nuclim_int("eu-flow",t) ;

$if      set aaa         rnwtgt(t) = rnwtgt_int("aaa",t) ;
$if      set bbb         rnwtgt(t) = rnwtgt_int("bbb",t) ;
$if      set ccc         rnwtgt(t) = rnwtgt_int("ccc",t) ;

$if      set aaa         irnwtgt(t) = irnwtgt_int("aaa",t) ;
$if      set bbb         irnwtgt(t) = irnwtgt_int("bbb",t) ;
$if      set ccc         irnwtgt(t) = irnwtgt_int("ccc",t) ;

$if      set bau         gaslim(r,t) = gaslim_int("bau",r,t) ;
$if      set tenperc     gaslim(r,t) = gaslim_int("tenperc",r,t) ;
$if      set fiftyperc   gaslim(r,t) = gaslim_int("fiftyperc",r,t) ;
$if      set nogas       gaslim(r,t) = gaslim_int("nogas",r,t) ;

$if      set bau         gaslim_eu(t) = gaslim_eu_int("bau",t) ;
$if      set tenperc     gaslim_eu(t) = gaslim_eu_int("tenperc",t) ;
$if      set fiftyperc   gaslim_eu(t) = gaslim_eu_int("fiftyperc",t) ;
$if      set nogas       gaslim_eu(t) = gaslim_eu_int("nogas",t) ;

$if      set gergaslimit gaslim("Germany","2023") = 50 ;
$if      set gergaslimit gaslim("Germany","2024") = 200 ;

* * * market_out
set
ngclass          Natural gas supply classes
dbclass          Dedicated biomass supply classes
;

$gdxin database\setpar_%n%.gdx
$load ngclass, dbclass
$gdxin

parameter
ngref_r(r,t)                     Reference natural gas consumption (EJ) (regional)
ngref(t)                         Reference natural gas consumption (EJ) (system)
ngelas_r(r,t)                    Supply elasticity for natural gas (regional)
ngelas(t)                        Supply elasticity for natural gas (system)
ngcost_r(ngclass,r,t)            Cost of natural gas by supply class (EUR per MWh th) (regional)
ngcost(ngclass,t)                Cost of natural gas by supply class (EUR per MWh th) (system)
nglim_r(ngclass,r,t)             Class size of natural gas supply function (regional)
nglim(ngclass,t)                 Class size of natural gas supply function (system)
dbref_r(r,t)                     Reference dedicated biomass consumption (EJ) (regional)
dbref(t)                         Reference dedicated biomass consumption (EJ) (system)
dbelas_r(r,t)                    Supply elasticity for dedicated biomass (regional)
dbelas(t)                        Supply elasticity for dedicated biomass (system)
dbcost_r(dbclass,r,t)            Cost of dedicated biomass by supply class (EUR per MWh th) (regional)
dbcost(dbclass,t)                Cost of dedicated biomass by supply class (EUR per MWh th) (system)
dblim_r(dbclass,r,t)             Class size of dedicated biomass supply function (regional)
dblim(dbclass,t)                 Class size of dedicated biomass supply function (system)
;

$gdxin database\setpar_%n%.gdx
$load ngref, ngref_r, ngelas, ngelas_r, ngcost, ngcost_r, nglim, nglim_r
$load dbref, dbref_r, dbelas, dbelas_r, dbcost, dbcost_r, dblim, dblim_r
$gdxin

* * * Demand module
set
l                        Load or demand sector
sdclass                  Short-term demand supply classes
d                        Clustering dimensions
elasticity_sc            Elasticity scenario
;

$gdxin database\setpar_%n%.gdx
$load l, sdclass, d, elasticity_sc
$gdxin

parameter
daref_sec(r,t,l)        Sector demand (TWh)
pelas(r,t)              Price elasticity at reference point (a negative value)
paref(r,t)              Reference annual average price in euro per MWh
cb_1(r,t)               Consumer benefit linear coefficient
cb_2(r,t)               Consumer benefit quadratic coefficient
;

$gdxin database\setpar_%n%.gdx
$load daref_sec=daref_sec_r
$gdxin

* Demand function calibration
* Define consumer benefit based on a linear demand curve that has a negative elasticity
* pelas(r) at the point (daref,paref).  Consumer benefit for demand x is equal to
* the integral of the inverse demand function P(x) from 0 to x, where
* P(x) = paref + (1/pelas)*(paref/daref)*(x - daref).
* If we state the integral of P(x) as cb_1*x + 0.5*cb_2*x^2,
* the appropriate coefficients are as follows:

pelas(r,t) = 0;
paref(r,t) = 0;

cb_1(r,t)$pelas(r,t) = paref(r,t) * (1 - 1/pelas(r,t));
cb_2(r,t)$pelas(r,t) = (1/pelas(r,t))*(paref(r,t)/daref(r,t));

* * * Energy efficiency module

* * * Social cost module
set
ap                               Air pollutant
impactap                         Impact of air pollutant
emfap_sc                         Scenario emission factor ;

$gdxin database\setpar_%n%.gdx
$load ap, impactap, emfap_sc
$gdxin

parameter
gdpgrowth(r,t)                                           GDP growth index
gdpdistri(r,t)                                           GDP distributional index
emfap_int(i,emfap_sc,ap,v)                               Emission factor air pollutant (t per MWh thermal)
emitap_int(i,emfap_sc,ap,v,r)                            Emission factor air pollutant (t per MWh electric)
emfap(i,ap,v)                                            Emission factor air pollutant (t per MWh thermal)
emitap(i,ap,v,r)                                         Emission factor air pollutant (t per MWh electric)
scap_int(ap,impactap,r,t)                                Social cost of air pollution (2015er EUR per t)
scap_emit_impactap_int(impactap,emfap_sc,i,v,r,t)        Social cost of air pollution by impact (2015er EUR per MWh electric)
scap_emit_ap_int(ap,emfap_sc,i,v,r,t)                    Social cost of air pollution by pollutant (2015er EUR per MWh electric)
scap_emit_int(emfap_sc,i,v,r,t)                          Social cost of air pollution (2015er EUR per MWh electric)
scap_i(ap,impactap,r,t)                                  Social cost of air pollution (2015er EUR per t)
scap_emit_impactap_i(impactap,i,v,r,t)                   Social cost of air pollution by impact (2015er EUR per MWh electric)
scap_emit_ap_i(ap,i,v,r,t)                               Social cost of air pollution by pollutant (2015er EUR per MWh electric)
scap_emit_i(i,v,r,t)                                     Social cost of air pollution (2015er EUR per MWh electric)
scapr(ap,impactap,t)                                     Social cost of air pollution (2015er EUR per t)
scapr_emit_impactap(impactap,i,v,t)                      Social cost of air pollution by impact (2015er EUR per MWh electric)
scapr_emit_ap(ap,i,v,t)                                  Social cost of air pollution by pollutant (2015er EUR per MWh electric)
scapr_emit(i,v,t)                                        Social cost of air pollution (2015er EUR per MWh electric)
scap(ap,impactap,r,t)                                    Social cost of air pollution (2015er EUR per t)
scap_emit_impactap(impactap,i,v,r,t)                     Social cost of air pollution by impact (2015er EUR per MWh electric)
scap_emit_ap(ap,i,v,r,t)                                 Social cost of air pollution by pollutant (2015er EUR per MWh electric)
scap_emit(i,v,r,t)                                       Social cost of air pollution (2015er EUR per MWh electric)
scc(t)                                                   Social cost of carbon (2015er EUR per t)
scc_emit(i,v,r,t)                                        Social cost of carbon (2015er EUR per MWh electric)
scc_int(t)                                               Social cost of carbon (2015er EUR per t)
scc_emit_int(i,v,r,t)                                    Social cost of carbon (2015er EUR per MWh electric)
drate_scap                                               Annual discount rate
dfact_scap(t)                                            Discount factor for time period t (reflects number of years) for both
drate_scc                                                Annual discount rate
dfact_scc(t)                                             Discount factor for time period t (reflects number of years) for both
;

$gdxin database\setpar_%n%.gdx
$load gdpgrowth, gdpdistri, emfap_int=emfap, emitap_int=emitap, scap_i=scap, scap_int=scap, scap_emit_impactap_int=scap_emit_impactap, scap_emit_ap_int=scap_emit_ap, scap_emit_int=scap_emit, scc_int=scc, scc_emit_int=scc_emit
$load drate_scap, dfact_scap, drate_scc, dfact_scc
$gdxin

$if      set emfaplow            emfap(i,ap,v) = emfap_int(i,"emfap_midlow",ap,v) ;
$if      set emfapmid            emfap(i,ap,v) = emfap_int(i,"emfap_mid",ap,v) ;
$if      set emfaphigh           emfap(i,ap,v) = emfap_int(i,"emfap_high",ap,v) ;

$if      set emfaplow            emitap(i,ap,v,r) = emitap_int(i,"emfap_midlow",ap,v,r) ;
$if      set emfapmid            emitap(i,ap,v,r) = emitap_int(i,"emfap_mid",ap,v,r) ;
$if      set emfaphigh           emitap(i,ap,v,r) = emitap_int(i,"emfap_high",ap,v,r) ;

$if      set emfaplow            scap_emit_impactap_i(impactap,i,v,r,t) = scap_emit_impactap_int(impactap,"emfap_midlow",i,v,r,t) ;
$if      set emfapmid            scap_emit_impactap_i(impactap,i,v,r,t) = scap_emit_impactap_int(impactap,"emfap_mid",i,v,r,t) ;
$if      set emfaphigh           scap_emit_impactap_i(impactap,i,v,r,t) = scap_emit_impactap_int(impactap,"emfap_high",i,v,r,t) ;

$if      set emfaplow            scap_emit_ap_i(ap,i,v,r,t) = scap_emit_ap_int(ap,"emfap_midlow",i,v,r,t) ;
$if      set emfapmid            scap_emit_ap_i(ap,i,v,r,t) = scap_emit_ap_int(ap,"emfap_mid",i,v,r,t) ;
$if      set emfaphigh           scap_emit_ap_i(ap,i,v,r,t) = scap_emit_ap_int(ap,"emfap_high",i,v,r,t) ;

$if      set emfaplow            scap_emit_i(i,v,r,t) = scap_emit_int("emfap_midlow",i,v,r,t) ;
$if      set emfapmid            scap_emit_i(i,v,r,t) = scap_emit_int("emfap_mid",i,v,r,t) ;
$if      set emfaphigh           scap_emit_i(i,v,r,t) = scap_emit_int("emfap_high",i,v,r,t) ;

$if      set scap1               scap(ap,impactap,r,t)                   = 0.25 * scap_i(ap,impactap,r,t) ;
$if      set scap1               scap_emit_impactap(impactap,i,v,r,t)    = 0.25 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap1               scap_emit_ap(ap,i,v,r,t)                = 0.25 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap1               scap_emit(i,v,r,t)                      = 0.25 * scap_emit_i(i,v,r,t) ;

$if      set scap2               scap(ap,impactap,r,t)                   = 0.5 * scap_i(ap,impactap,r,t) ;
$if      set scap2               scap_emit_impactap(impactap,i,v,r,t)    = 0.5 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap2               scap_emit_ap(ap,i,v,r,t)                = 0.5 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap2               scap_emit(i,v,r,t)                      = 0.5 * scap_emit_i(i,v,r,t) ;

$if      set scap3               scap(ap,impactap,r,t)                   = 1 * scap_i(ap,impactap,r,t) ;
$if      set scap3               scap_emit_impactap(impactap,i,v,r,t)    = 1 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap3               scap_emit_ap(ap,i,v,r,t)                = 1 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap3               scap_emit(i,v,r,t)                      = 1 * scap_emit_i(i,v,r,t) ;

$if      set scap4               scap(ap,impactap,r,t)                   = 2 * scap_i(ap,impactap,r,t) ;
$if      set scap4               scap_emit_impactap(impactap,i,v,r,t)    = 2 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap4               scap_emit_ap(ap,i,v,r,t)                = 2 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap4               scap_emit(i,v,r,t)                      = 2 * scap_emit_i(i,v,r,t) ;

$if      set scap5               scap(ap,impactap,r,t)                   = 4 * scap_i(ap,impactap,r,t) ;
$if      set scap5               scap_emit_impactap(impactap,i,v,r,t)    = 4 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap5               scap_emit_ap(ap,i,v,r,t)                = 4 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap5               scap_emit(i,v,r,t)                      = 4 * scap_emit_i(i,v,r,t) ;

$if      set scap6               scap(ap,impactap,r,t)                   = 8 * scap_i(ap,impactap,r,t) ;
$if      set scap6               scap_emit_impactap(impactap,i,v,r,t)    = 8 * scap_emit_impactap_i(impactap,i,v,r,t) ;
$if      set scap6               scap_emit_ap(ap,i,v,r,t)                = 8 * scap_emit_ap_i(ap,i,v,r,t) ;
$if      set scap6               scap_emit(i,v,r,t)                      = 8 * scap_emit_i(i,v,r,t) ;

$if      set distri              scap(ap,impactap,r,t)                   = scap_i(ap,impactap,r,t)                       * gdpdistri(r,t) ;
$if      set distri              scap_emit_impactap(impactap,i,v,r,t)    = scap_emit_impactap_i(impactap,i,v,r,t)        * gdpdistri(r,t) ;
$if      set distri              scap_emit_ap(ap,i,v,r,t)                = scap_emit_ap_i(ap,i,v,r,t)                    * gdpdistri(r,t) ;
$if      set distri              scap_emit(i,v,r,t)                      = scap_emit_i(i,v,r,t)                          * gdpdistri(r,t) ;

$if      set scapequal           scapr(ap,impactap,t)                    = round( sum(r, daref(r,t) * scap_i(ap,impactap,r,t))                  / sum(r, daref(r,t)),4) ;
$if      set scapequal           scapr_emit_impactap(impactap,i,v,t)     = round( sum(r, daref(r,t) * scap_emit_impactap_i(impactap,i,v,r,t))   / sum(r, daref(r,t)),4) ;
$if      set scapequal           scapr_emit_ap(ap,i,v,t)                 = round( sum(r, daref(r,t) * scap_emit_ap_i(ap,i,v,r,t))               / sum(r, daref(r,t)),4) ;
$if      set scapequal           scapr_emit(i,v,t)                       = round( sum(r, daref(r,t) * scap_emit_i(i,v,r,t))                     / sum(r, daref(r,t)),4) ;

$if      set scapequal           scap(ap,impactap,r,t)                   = scapr(ap,impactap,t) ;
$if      set scapequal           scap_emit_impactap(impactap,i,v,r,t)    = scapr_emit_impactap(impactap,i,v,t) ;
$if      set scapequal           scap_emit_ap(ap,i,v,r,t)                = scapr_emit_ap(ap,i,v,t) ;
$if      set scapequal           scap_emit(i,v,r,t)                      = scapr_emit(i,v,t) ;

$if      set scapequaldistri     scapr(ap,impactap,t)                    = sum(r, daref(r,t) * scap_i(ap,impactap,r,t))                  / sum(r, daref(r,t)),4) ;
$if      set scapequaldistri     scapr_emit_impactap(impactap,i,v,t)     = sum(r, daref(r,t) * scap_emit_impactap_i(impactap,i,v,r,t))   / sum(r, daref(r,t)),4) ;
$if      set scapequaldistri     scapr_emit_ap(ap,i,v,t)                 = sum(r, daref(r,t) * scap_emit_ap_i(ap,i,v,r,t))               / sum(r, daref(r,t)),4) ;
$if      set scapequaldistri     scapr_emit(i,v,t)                       = sum(r, daref(r,t) * scap_emit_i(i,v,r,t))                     / sum(r, daref(r,t)),4) ;

$if      set scapequaldistri     scap(ap,impactap,r,t)                   = scapr(ap,impactap,t)  * gdpdistri(r,t) ;
$if      set scapequaldistri     scap_emit_impactap(impactap,i,v,r,t)    = scapr_emit_impactap(impactap,i,v,t) * gdpdistri(r,t) ;
$if      set scapequaldistri     scap_emit_ap(ap,i,v,r,t)                = scapr_emit_ap(ap,i,v,t)* gdpdistri(r,t) ;
$if      set scapequaldistri     scap_emit(i,v,r,t)                      = scapr_emit(i,v,t) * gdpdistri(r,t) ;

$if      set nogdpgrowth         scap(ap,impactap,r,t)                   = round( scap_i(ap,impactap,r,t)                   / gdpgrowth(r,t),4) ;
$if      set nogdpgrowth         scap_emit_impactap(impactap,i,v,r,t)    = round( scap_emit_impactap_i(impactap,i,v,r,t)    / gdpgrowth(r,t),4) ;
$if      set nogdpgrowth         scap_emit_ap(ap,i,v,r,t)                = round( scap_emit_ap_i(ap,i,v,r,t)                / gdpgrowth(r,t),4) ;
$if      set nogdpgrowth         scap_emit(i,v,r,t)                      = round( scap_emit_i(i,v,r,t)                      / gdpgrowth(r,t),4) ;

$if      set scapequalnogdp      scapr(ap,impactap,t)                    = round( sum(r, daref(r,t) * scap_i(ap,impactap,r,t)                    / gdpgrowth(r,t) )   / sum(r, daref(r,t)),4) ;
$if      set scapequalnogdp      scapr_emit_impactap(impactap,i,v,t)     = round( sum(r, daref(r,t) * scap_emit_impactap_i(impactap,i,v,r,t)     / gdpgrowth(r,t) )   / sum(r, daref(r,t)),4) ;
$if      set scapequalnogdp      scapr_emit_ap(ap,i,v,t)                 = round( sum(r, daref(r,t) * scap_emit_ap_i(ap,i,v,r,t)                 / gdpgrowth(r,t) )   / sum(r, daref(r,t)),4) ;
$if      set scapequalnogdp      scapr_emit(i,v,t)                       = round( sum(r, daref(r,t) * scap_emit_i(i,v,r,t)                       / gdpgrowth(r,t) )   / sum(r, daref(r,t)),4) ;

$if      set scapequalnogdp      scap(ap,impactap,r,t)                   = scapr(ap,impactap,t) ;
$if      set scapequalnogdp      scap_emit_impactap(impactap,i,v,r,t)    = scapr_emit_impactap(impactap,i,v,t) ;
$if      set scapequalnogdp      scap_emit_ap(ap,i,v,r,t)                = scapr_emit_ap(ap,i,v,t) ;
$if      set scapequalnogdp      scap_emit(i,v,r,t)                      = scapr_emit(i,v,t) ;

$if      set scc1                scc(t)                                  = 0.25 * scc_int(t) ;
$if      set scc1                scc_emit(i,v,r,t)                       = 0.25 * scc_emit_int(i,v,r,t) ;
$if      set scc2                scc(t)                                  = 0.5 * scc_int(t) ;
$if      set scc2                scc_emit(i,v,r,t)                       = 0.5 * scc_emit_int(i,v,r,t) ;
$if      set scc3                scc(t)                                  = 1 * scc_int(t) ;
$if      set scc3                scc_emit(i,v,r,t)                       = 1 * scc_emit_int(i,v,r,t) ;
$if      set scc4                scc(t)                                  = 2 * scc_int(t) ;
$if      set scc4                scc_emit(i,v,r,t)                       = 2 * scc_emit_int(i,v,r,t) ;
$if      set scc5                scc(t)                                  = 4 * scc_int(t) ;
$if      set scc5                scc_emit(i,v,r,t)                       = 4 * scc_emit_int(i,v,r,t) ;
$if      set scc6                scc(t)                                  = 8 * scc_int(t) ;
$if      set scc6                scc_emit(i,v,r,t)                       = 8 * scc_emit_int(i,v,r,t) ;
* No SCC adjustments according to scenarios in first period
scc("2020") = scc_int("2020") ;
scc_emit(i,v,r,"2020") = scc_emit_int(i,v,r,"2020") ;
* No air pollution internalization in first period
dfact_scap("2020") = 0 ;
* Switches to avoid SCC and SCAP in objective function (depending on policy question changes are necessary here)
$if not  set scc    dfact_scc(t)$(t.val >= 2025) = 0 ;
$if not  set scc    dfact_scc(t)  = 0 ;
$if not  set scap   dfact_scap(t) = 0 ;


* * * Subsidies and taxes (negative subsidies are taxes)
parameter
irnwsub(r,t)                     New irnw production subsidy (EUR per MWh)
rnwsub(r,t)                      New rnw production subsidy (EUR per MWh)
solsub(r,t)                      New solar PV production subsidy in (EUR per MWh)
windsub(r,t)                     New wind production subsidy (EUR per MWh)
nucsub(r,t)                      New nuclear production subsidy (EUR per MWh)
lowcarbsub(r,t)                  New rnw nuc and CCS production subsidy (EUR per MWh)
irnwsub_cap(r,t)                 New irnw capacity subsidy (EUR per kW)
rnwsub_cap(r,t)                  New rnw capacity subsidy (EUR per kW)
solsub_cap(r,t)                  New solar PV capacity subsidy in (EUR per kW)
windsub_cap(r,t)                 New wind capacity subsidy (EUR per kW)
nucsub_cap(r,t)                  New nuclear capacity subsidy (EUR per kW)
lowcarbsub_cap(r,t)              New rnw nuc and CCS capacity subsidy (EUR per kW)
;

* Set irnw subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set irnwsub     irnwsub(r,t) = 0;
$if      set irnwsub     irnwsub(r,t) = %irnwsub%;
* Set rnw subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set rnwsub      rnwsub(r,t) = 0;
$if      set rnwsub      rnwsub(r,t) = %rnwsub%;
* Set solar PV subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set solsub      solsub(r,t) = 0;
$if      set solsub      solsub(r,t) = %solsub%;
* Set wind subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set windsub     windsub(r,t) = 0;
$if      set windsub     windsub(r,t) = %windsub%;
* Set low-carb subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set nucsub      nucsub(r,t) = 0;
$if      set nucsub      nucsub(r,t) = %lowcarbsub%;
* Set low-carb subsidy at indicated rate if set (usual 50 euro per MWh ~ 5 cents per kWh)
$if not  set lowcarbsub  lowcarbsub(r,t) = 0;
$if      set lowcarbsub  lowcarbsub(r,t) = %lowcarbsub%;

* Set irnw subsidy at indicated rate if set
$if not  set irnwsub_cap     irnwsub_cap(r,t) = 0;
$if      set irnwsub_cap     irnwsub_cap(r,t) = %irnwsub_cap%;
* Set rnw subsidy at indicated rate if set
$if not  set rnwsub_cap      rnwsub_cap(r,t) = 0;
$if      set rnwsub_cap      rnwsub_cap(r,t) = %rnwsub_cap%;
* Set solar PV subsidy at indicated rate if set
$if not  set solsub_cap      solsub_cap(r,t) = 0;
$if      set solsub_cap      solsub_cap(r,t) = %solsub_cap%;
* Set wind subsidy at indicated rate if set
$if not  set windsub_cap     windsub_cap(r,t) = 0;
$if      set windsub_cap     windsub_cap(r,t) = %windsub_cap%;
* Set low-carb subsidy at indicated rate if set
$if not  set nucsub_cap      nucsub_cap(r,t) = 0;
$if      set nucsub_cap      nucsub_cap(r,t) = %lowcarbsub_cap%;
* Set low-carb subsidy at indicated rate if set
$if not  set lowcarbsub_cap  lowcarbsub_cap(r,t) = 0;
$if      set lowcarbsub_cap  lowcarbsub_cap(r,t) = %lowcarbsub_cap%;

* * * Sets of relevant generators
set
ivrt(i,v,r,t)           Active vintage-capacity blocks
jvrt(j,v,r,t)           Active storage vintage-capacity blocks
tvrt(k,v,r,t)  Active transmission vintage-capacity blocks
;

* * Generation technologies (ivrt)
ivrt(i,v,r,t)$(cap(i,v,r) * lifetime(i,v,r,t) or (new(i) and newv(v) and lifetime(i,v,r,t)))                                             = YES ;
ivrt(irnw(i),v,r,t)$(sum(s, vrsc(s,i,v,r)) * lifetime(i,v,r,t) eq 0)                                                                     = NO ;
* Individual according to quantiles
*ivrt(i,v,r,t)$(sameas(i,"RoofPV_q90") or sameas(i,"RoofPV_q75"))                                                                        = NO ;
*ivrt(i,v,r,t)$(sameas(i,"OpenPV_q90") or sameas(i,"OpenPV_q75"))                                                                        = NO ;
*ivrt(i,v,r,t)$(sameas(i,"WindOn_q90") or sameas(i,"WindOn_q75"))                                                                        = NO ;
*ivrt(i,v,r,t)$(sameas(i,"WindOff_q90") or sameas(i,"WindOff_q75"))                                                                      = NO ;
* Other technologies to exlcude
$if      set nooil       ivrt("OilOther",newv(v),r,t)                                                                                    = NO ;
$if      set nocoa       ivrt(i,newv(v),r,t)$(sameas(i,"coal") or sameas(i,"coal_CCS"))                                                  = NO ;
$if      set nolig       ivrt("Lignite",newv(v),r,t)                                                                                     = NO ; 
$if      set noccs       ivrt(ccs(i),newv(v),r,t)                                                                                        = NO ;
$if      set nonuc       ivrt(nuc(i),newv(v),r,t)                                                                                        = NO ;
$if      set nogas       ivrt(gas(i),newv(v),r,t)                                                                                        = NO ;
* * Storage technologies (jvrt)
jvrt(j,v,r,t)$(gcap(j,v,r) * glifetime(j,v,r,t) or (newj(j) and newv(v) and glifetime(j,v,r,t)))                                        = YES ;
$if not  set storage     jvrt(j,v,r,t)                                                                                                  = NO ;
* * Transmission (tvrt)
tvrt(k,v,r,t)$(sum(tmap(k,r,rr), tlifetime(k,v,r,t)))                                                                                   = YES ;
$if not  set trans       tvrt(k,v,r,t)                                                                                                  = NO ;                                                      

* * * Dispatch cost
parameter
discost(i,v,r,t)         Dispatch cost (EUR per MWh el)
;

* * * Define dispatch cost
discost(i,v,r,t)$(ivrt(i,v,r,t) and effrate(i,v,r)) = 
*        Variable O&M costs
                           vomcost(i,v,r)
*        Fuel costs (including region-specific price delta) including regional adder relative                    
                         + round(sum(xfueli(fuel,i), pfuel(fuel,r,t)  * (1 + pfadd_rel(fuel,r,t))) / effrate(i,v,r), 8)
* Determine true average load of each vintages and calibrate for ramping cost here
$if      set ramcost     * (1 + effloss(i,v,r) / 0.5 )
*        Regional adder absolute
*                         + (pfadd(fuel,r,t)$xfueli(fuel,i))$effrate(i,v,r)
*        CO2 price (includes benefits from negative emissions)
$if      set co2price    + emit(i,v,r) * co2p(t)
*        CCS costs (from capturing)
$if      set ccs         + round(co2captured(i,v,r) * ccscost(r,t), 8)
;


* * * Availability factor matrix (too large to read in)
parameter
af(s,i,v,r,t)                Availability factor
;

af(s,i,v,r,t) = 1 ;
af(s,i,oldv(v),r,t)$(t.val le 2021 and sameas(i,"Nuclear") and reliability(i,v,r) > 0)                          = round(sum(sm(s,m), af_mon(m,i,r)) / reliability(i,v,r), 4) ;
af(s,i,oldv(v),r,t)$(t.val le 2021 and sameas(i,"Bioenergy") and reliability(i,v,r) > 0)                        = round(sum(sm(s,m), af_mon(m,i,r)) / reliability(i,v,r), 4) ;
af(s,i,oldv(v),r,t)$(t.val le 2025 and sameas(i,"Nuclear") and sameas(r,"France") and reliability(i,v,r) > 0)   = round(sum(sm(s,m), af_mon_ivrt(m,i,v,r,t)) / reliability(i,v,r), 4) ;
af(s,"Hydro",v,r,t) = 1 ;
$if      set af1 af(s,i,v,r,t) = 1 ;

* * * Run-time switches to consider alterantive scenarios
* Assume no growth in demand
$if      set flatload    dref(r,t) = 1;
* Treat co-firing as a conversion with fixed dispatch proportions
$if      set cofirconve  xcapadj_cr(cofir) = 1;
* Remove all constraints on transmission additions
$if      set tinf        tinvlimUP(k,r,rr,t)$tmap(k,r,rr) = inf ;
* Assume no new transmission additions are allowed
$if      set tzero       tinvlimUP(kr,rr,t)$tmap(k,r,rr) = 0 ;
* Assume no transmission losses
$if      set notrnspen   trnspen(k,r,r) = 1 ;
* Set regional/distribution losses to zero for model comparison
$if      set noregloss   loss(r) = 0;
* Add 160 euro per kW to cost of on-shore wind to reflect intra-region transmission (~$200/kW)
$if      set windcost    capcost(i,v,r)$(wind(i) and capcost(i,v,r)) = capcost(i,v,r) + 160 ;
* Make solar PV 10% cheaper
$if      set solcost     capcost(i,v,r)$(sol(i) and capcost(i,v,r)) = 0.9 * capcost(i,v,r) ;
* Assume no cost increase
$if      set flatcost    capcost(i,v,r) = capcost(i,"2020",r);
* Set transmission and storage values to zero when transmission/storage are disabled
$if not  set trans       tcap(k,r,rr) = 0;
$if not  set storage     gcap(j,v,r) = 0;

* * * CHP module
PARAMETER
sharechp(i,v,r)
;

sharechp(i,oldv(v),r)$(cap(i,v,r) > 0 and sameas(i,"Bioenergy") and sameas(r,"Germany")) = 6.6  / sum(vv, cap(i,vv,r)) ;
sharechp(i,oldv(v),r)$(cap(i,v,r) > 0 and gas(i) and not ccs(i) and sameas(r,"Germany")) = 12.4 / sum(vv, cap("Gas_OCGT",vv,r) + cap("Gas_CCGT",vv,r) + cap("Gas_ST",vv,r)) ;
sharechp(i,oldv(v),r)$(cap(i,v,r) > 0 and sameas(i,"OilOther")  and sameas(r,"Germany")) = 0.8  / sum(vv, cap(i,vv,r)) ;
sharechp(i,oldv(v),r)$(cap(i,v,r) > 0 and sameas(i,"Lignite")   and sameas(r,"Germany")) = 0.8  / sum(vv, cap(i,vv,r)) ;
sharechp(i,oldv(v),r)$(cap(i,v,r) > 0 and sameas(i,"Coal")      and sameas(r,"Germany")) = 1.6  / sum(vv, cap(i,vv,r)) ;
$if not  set chp        sharechp(i,v,r) = 0 ;

* * * Declare Model
positive variable
* Demand
BS(s,r,t)               Lost load (backstop demand option) (GW)
* Generation
X(s,i,v,r,t)            Unit dispatch by segment (GW)
XNOR(s,i,v,r,t)         Unit dispatch by segment (GW)
XNOC(s,i,v,r,t)         Unit dispatch by segment (GW)
XCHP(s,i,v,r,t)         Unit dispatch by segment (GW)

XTWH(i,v,r,t)           Annual generation for sparsity purposes (TWh)

XC(i,v,r,t)             Installed generation capacity (GW)
XCNOR(i,v,r,t)          Installed generation capacity (GW)
XCNOC(i,v,r,t)          Installed generation capacity (GW)
XCCHP(i,v,r,t)          Installed generation capacity (GW)

XCS(s,i,v,r,t)          Copies of XC over s for sparsity purposes (GW)
IX(i,r,t)               New vintage investment (total GW to be added from t-1 to t) (GW)
* Storage
G(s,j,v,r,t)            Energy storage charge (GW)
GD(s,j,v,r,t)           Energy storage discharge (GW)
GC(j,v,r,t)             Energy storage charge-discharge capacity (GW)
GCS(s,j,v,r,t)          Energy storage charge-discharge capacity (GW)
GB(s,j,v,r,t)           Energy storage accumulated balance (100 GWh)
IG(j,r,t)               Investment in storage charge-discharge capacity (GW)
* Transmission
E(s,k,r,r,t)            Bilateral trade flows by load segment (GW)
TC(k,r,r,t)             New Trade flow capacity (GW)
TCS(s,k,r,r,t)          New Trade flow capacity (GW)
IT(k,r,r,t)             Investment in transmission (total GW to be added from t-1 to t)
* Market and policy variables
DBS(dbclass,t)          Dedicated biomass supply by class (MWh)
DBSR(dbclass,r,t)       Dedicated biomass supply by class by region (MWh)
NGS(ngclass,t)          Total supply of natural gas by class (MWh)
NGSR(ngclass,r,t)       Total supply of natural gas by class by region (MWh)
* Potential variables
BC_r(r,t)               Annual flow of biomass used (TWh)
BC(t)                   Annual flow of biomass used (TWh)
GASC_r(r,t)             Annual flow of natural gas used (TWh)
GASC(t)                 Annual flow of natural gas used (TWh)
SC_r(r,t)               Annual flow of geologically stored carbon (MtCO2)
SC(t)                   Annual flow of geologically stored carbon (MtCO2)
;

variable
SURPLUS                         Social surplus (negative) (million EUR)
;

equation
objdef                           Objection function -- definition of surplus
*Demand equations
demand(s,r,t)                    Electricity market clearing condition
demand_rsa(s,r,t)                Regional system adequacy condition
* Generation and capacity
capacity(s,i,v,r,t)              Generation capacity constraint on dispatch
capacity_hel(s,i,v,r,t)
capacity_noc(s,i,v,r,t)
capacity_chp(s,i,v,r,t)
capacity_bio(s,i,v,r,t)          Generation capacity constraint on dispatch of bioenergy (to avoid implementing a subsidy on bioenergy)
capacity_dsp(s,i,v,r,t)          Dispatched capacity
capacity_nsp(s,i,v,r,t)          Non-dispatched capacity
capacity_cofir(s,i,r,t)          Coal and Lignite capacity can be dispatched with or without co-fire
invest(i,v,r,t)                  Accumulation of annual investment flows
exlife(i,v,r,t)                  Existing capacity including conversions
exlife2020(i,v,r,t)              Existing capacity in 2020 is fix
exlife_hel(i,v,r,t)
exlife_noc(i,v,r,t)
exlife_chp(i,v,r,t)
exlife_bio(i,v,r,t)              Existing capacity of bioenergy is fix to avoid decomm (no subsidy implemented yet)
newlife(i,v,r,t)                 New vintages are subject to lifetime constraint
retire(i,v,r,t)                  Monotonicity constraint on installed capacity
investlimUP(i,r,t)               Upper limits on investment (region)
investlimLO(i,r,t)               Lower limits on investment (region)
investlimUP_eu(i,t)              Upper limits on investment (system)
investlimUP_irnw(i,r,t,quantiles) Upper limits on investment for intermittent renewables per quantile (region)
* Storage equations
chargelim(s,j,v,r,t)             Charge cannot exceed capacity
dischargelim(s,j,v,r,t)          Discharge cannot exceed capacity
storagebal(s,j,v,r,t)            Storage balance accumulation
storagelim(s,j,v,r,t)            Storage reservoir capacity
ginvest(j,v,r,t)                 Investment in storage charge-discharge capacity
gexlife(j,v,r,t)                 Existing storage capacity
gexlife2020(j,v,r,t)             Existing capacity in 2020 is fix
gexlife_pump(j,v,r,t)            Existing capacity of pumphydro is fix to avoid decomm (for the myopic runs)
gnewlife(j,v,r,t)                Storage wew vintages are subject to lifetime constraint
gretire(j,v,r,t)                 Monotonicity constraint on installed storage capacity
ginvestlimUP(j,r,t)              Upper limits on storage investment (region)
ginvestlimLO(j,r,t)              Lower limits on storage investment (region)
ginvestlimUP_eu(j,t)             Upper limits on storage investment (EU)
* Transmission equations
tcapacity(s,k,r,r,t)             Transmission capacity constraint on trade
tinvestexi(k,r,r,t)              Accumulation of annual transmission investment flows
tinvestnew(k,r,r,t)              Accumulation of annual transmission investment flows
tinvestlimUP(k,r,r,t)            Upper limit on total transmission capacity (between regions)
tinvestlimLO(k,r,r,t)            Lower limit on total transmission capacity (between regions)
tinvestlimUP_eu(k,t)             Upper limit on per period transmission investment (EU)
* Market equations
biomarket(t)                     System-wide market for bioenergy or supply equal demand for bioenergy
biomarket_r(r,t)                 Supply equal demand for bioenergy (regional)
gasmarket(t)                     System-wide market for natural gas or supply equal demand for natural gas
gasmarket_r(r,t)                 Supply equal demand for natural gas (regional)
* Policy equations
rnwtgtmarket(t)                  Target market for renewables (system)
rnwtgtmarket_r(r,t)              Target market for renewables (regional)
irnwtgtmarket(t)                 Target market for intermittent renewables (system)
irnwtgtmarket_r(r,t)             Target market for interimittet renewables (regional)
coalphaseout(t)                  Policy constraint on hard coal phase out
coalphaseout_r(r,t)              Policy constraint on hard coal phase out (regions)
lignphaseout(t)                  Policy constraint on lignite phase out
lignphaseout_r(r,t)              Policy constraint on lignite phase out (regions)
nucphaseout(t)                   Policy constraint on nuclear phase out
nucphaseout_r(r,t)               Policy constraint on nuclear phase out (regions)
* Limit equations
bioflow(t)                       Annual flow of biomass
bioflow_r(r,t)                   Annual flow of biomass (per region)
cumbio2020(t)                    Limits on cumulative use of bioenergy (per region)
cumbio(t)                        Limits on cumulative use of bioenergy (per region)
cumbio_r(r,t)                    Limits on cumulative use of bioenergy (per region)
gasflow(t)                       Annual flow of gasmass
gasflow_r(r,t)                   Annual flow of gasmass (per region)
cumgas(t)                        Limits on cumulative use of gasenergy (per region)
cumgas_r(r,t)                    Limits on cumulative use of gasenergy (per region)
ccsflow(t)                       Annual flow of captured carbon for geologic storage
ccsflow_r(r,t)                   Annual flow of captured carbon for geologic storage
cumccs                           Limits on cumulative geologic storage of carbon
cumccs_r(r)                      Limits on cumulative geologic storage of carbon
* Structual equations
xtwhdef(i,v,r,t)                 Calculate XTWH from X
copyxc(s,i,v,r,t)                Make copies of XC in XCS
copygc(s,j,v,r,t)                Make copies of GC in GCS
copytc(s,k,r,r,t)                Make copies of TC in TCS
;

* * * Minimum dispatch module (minimum dispatch of all technologies, this condition is deactivitated if not "techmin=yes")
SET
$if not  set nucmin  techmini(i)         Technologies with techmin constraints /Nuclear,Coal,Coal_CCS,Lignite,Bioenergy,Bio_CCS,Gas_CCGT,Gas_OCGT,OilOther,Gas_ST/
$if      set nucmin  techmini(i)         Technologies with techmin constraints /Nuclear/
;

PARAMETER
stacost(i,v,r)      Start-up cost (EUR per MWh)
;

stacost("Nuclear",v,r)$(v.val le 2015)  = 80 ;
stacost("Nuclear",v,r)$(v.val ge 2020)  = 50 ;
stacost("Coal",v,r)$(v.val le 2015)     = 28.5 ;
stacost("Coal",v,r)$(v.val ge 2020)     = 36.25 ;
stacost("Coal_CCS",v,r)                 = 28.5 ;
stacost("Lignite",v,r)$(v.val le 2015)  = 28.5;
stacost("Lignite",v,r)$(v.val ge 2020)  = 36.25;
stacost(bio(i),v,r)$(v.val le 2015)     = 28.5 ;
stacost(bio(i),v,r)$(v.val ge 2020)     = 36.25 ;
stacost("Gas_CCGT",v,r)                 = 23 ;
stacost("Gas_CCS",v,r)                  = 23 ;
stacost("Gas_OCGT",v,r)                 = 16 ;
stacost("OilOther",v,r)                 = 19.5 ;
stacost("Gas_ST",v,r)                   = 16 ;

$if      set nucmin  stacost(i,v,r)     = 0 ;
$if      set nucmin  stacost("Nuclear",v,r)$(v.val le 2015)  = 80 ;
$if      set nucmin  stacost("Nuclear",v,r)$(v.val ge 2020)  = 50 ;

BINARY VARIABLE
ONOFF(s,i,v,r,t)        Binary variable that indicates whether vintage is completely out (=0) or on (=1)    
;

POSITIVE VARIABLE
NUMONOFF(s,i,v,r,t)       Number of on off times
;

EQUATION
capacity_techmin(s,i,v,r,t)     Minimum dispatch of other capacity
capacity_nucmin(s,i,v,r,t)      Minimum dispatch of nuclear capacity
eq_numonofflo(s,i,v,r,t)        Equation that determines whether vintage started or not
eq_numonoffup(s,i,v,r,t)        Equation that determines whether vintage started or not
;

* Minimum dispatch of all technologies (this condition is deactivitated if not "techmin=yes"
capacity_techmin(s,ivrt(i,v,r,t))$(techmini(i) and mindisp(i,v,r) and tmyopic(t))..
                 X(s,i,v,r,t) =g=  ONOFF(s,i,v,r,t) * XCS(s,i,v,r,t) * mindisp(i,v,r) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;                

* Collecting number of starts
eq_numonofflo(s,ivrt(i,v,r,t))$(techmini(i) and mindisp(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 NUMONOFF(s,i,v,r,t) =g= ONOFF(s,i,v,r,t) - ONOFF(s-1,i,v,r,t) ;
                 
eq_numonoffup(s,ivrt(i,v,r,t))$(techmini(i) and mindisp(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 NUMONOFF(s,i,v,r,t) =l= 1 ;                

$if      set ramping    ONOFF.L(s,ivrt(i,v,r,t))$(techmini(i)) = 1 ;
$if      set ramcost    NUMONOFF.L(s,ivrt(i,v,r,t))$(techmini(i)) = 0 ;

* * * Ramping module (ramping up and down ability for a set of technologies, this condition is deactiviated if not "ramping=yes")
SET
ram(i)          Technologies with ramping constraints /Nuclear,Coal,Coal_CCS,Lignite,Bioenergy,Bio_CCS,Gas_CCGT,Gas_OCGT,OilOther,Gas_ST/
;

PARAMETER
ramrate(i,v,r)  ramping quota (% per hour)
ramcost(i,v,r)  ramping cost (EUR per MW(h))
effloss(i,v,r)  efficiency loss from ramping (% points)
;

ramrate("Nuclear",v,r)$(v.val le 2015)  = 0.2 ;
ramrate("Nuclear",v,r)$(v.val ge 2020)  = 0.4 ;
ramrate("Coal",v,r)$(v.val le 2015)     = 0.4 ;
ramrate("Coal",v,r)$(v.val ge 2020)     = 0.6 ;
ramrate("Coal_CCS",v,r)                 = 0.6 ;
ramrate("Lignite",v,r)$(v.val le 2015)  = 0.3 ;
ramrate("Lignite",v,r)$(v.val ge 2020)  = 0.45 ;
ramrate(bio(i),v,r)$(v.val le 2015)     = 0.4 ;
ramrate(bio(i),v,r)$(v.val ge 2020)     = 0.6 ;
ramrate("Gas_CCGT",v,r)                 = 0.9 ;
ramrate("Gas_CCS",v,r)                  = 0.9 ;
ramrate("Gas_OCGT",v,r)                 = 1 ;
ramrate("OilOther",v,r)                 = 1 ;
ramrate("Gas_ST",v,r)                   = 0.75 ;

ramcost("Nuclear",v,r)$(v.val le 2015)  = 1.5 ;
ramcost("Nuclear",v,r)$(v.val ge 2020)  = 0.75 ;
ramcost("Coal",v,r)$(v.val le 2015)     = 1.6 ;
ramcost("Coal",v,r)$(v.val ge 2020)     = 1.3 ;
ramcost("Coal_CCS",v,r)                 = 1.3 ;
ramcost("Lignite",v,r)$(v.val le 2015)  = 1.6 ;
ramcost("Lignite",v,r)$(v.val ge 2020)  = 1.3 ;
ramcost(bio(i),v,r)$(v.val le 2015)     = 1.6 ;
ramcost(bio(i),v,r)$(v.val ge 2020)     = 1.3 ;
ramcost("Gas_CCGT",v,r)                 = 0.25 ;
ramcost("Gas_CCS",v,r)                  = 0.25 ;
ramcost("Gas_OCGT",v,r)                 = 0.66 ;
ramcost("OilOther",v,r)                 = 0.66 ;
ramcost("Gas_ST",v,r)                   = 1.17 ;

effloss("Nuclear",v,r)$(v.val le 2015)  = 0.05 ;
effloss("Nuclear",v,r)$(v.val ge 2020)  = 0.03 ;
effloss("Coal",v,r)$(v.val le 2015)     = 0.02 ;
effloss("Coal",v,r)$(v.val ge 2020)     = 0.04 ;
effloss("Coal_CCS",v,r)                 = 0.02 ;
effloss("Lignite",v,r)$(v.val le 2015)  = 0.08 ;
effloss("Lignite",v,r)$(v.val ge 2020)  = 0.04 ;
effloss(bio(i),v,r)$(v.val le 2015)     = 0.06 ;
effloss(bio(i),v,r)$(v.val ge 2020)     = 0.03 ;
effloss("Gas_CCGT",v,r)                 = 0.08 ;
effloss("Gas_CCS",v,r)                  = 0.08 ;
effloss("Gas_OCGT",v,r)                 = 0.2 ;
effloss("OilOther",v,r)                 = 0.2 ;
effloss("Gas_ST",v,r)                   = 0.04 ;

POSITIVE VARIABLE
RPNEG(s,i,v,r,t)                    Amount of ramrate (GW)
RPPOS(s,i,v,r,t)                    Amount of ramrate (GW)
;

EQUATION
capacity_ramrateneg(s,i,v,r,t)      Calculates the amount of ramrate
capacity_ramratepos(s,i,v,r,t)      Calculates the amount of ramrate
capacity_rampdown(s,i,v,r,t)        Constrains ramrate down
capacity_rampup(s,i,v,r,t)          Constrains ramrate up
;

capacity_ramrateneg(s,ivrt(i,v,r,t))$(ram(i) and ramrate(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 RPNEG(s,i,v,r,t) =g= X(s,i,v,r,t) - X(s-1,i,v,r,t) ;

capacity_ramratepos(s,ivrt(i,v,r,t))$(ram(i) and ramrate(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 RPPOS(s,i,v,r,t) =g= X(s-1,i,v,r,t) - X(s,i,v,r,t) ;
                 
capacity_rampdown(s,ivrt(i,v,r,t))$(ram(i) and ramrate(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 RPPOS(s,i,v,r,t) =l=  ramrate(i,v,r) * XCS(s,i,v,r,t) ;
                 
capacity_rampup(s,ivrt(i,v,r,t))$(ram(i) and ramrate(i,v,r) and tmyopic(t) and not sameas(s,"1"))..
                 RPNEG(s,i,v,r,t) =l=  ramrate(i,v,r) * XCS(s,i,v,r,t) ;

* * * Objective function definition
objdef..
*        Surplus is defined in million EUR
         SURPLUS =e=
*        Sum over all time period t
                !! begin period sum
                sum(t$tmyopic(t),
*               Sum over all regions r
                !! begin region sum
                sum(r, 1
*               INVESTMENT COST
*               New, including discounting via zeta---the net present value investment cost factor---and follow from capacity cost (EUR/kW) of total period investments (GW)
                !! begin investment cost 
$if                             set mixed      + sum(new(i),              sum(inv,  share(inv,i,r) * IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),  capcost(i,v,r)  *  zeta(inv,i,v,r)))) 
$if      set storage    $if     set mixed      + sum(newj(j),             sum(inv, gshare(inv,j,r) * IG(j,r,t)    * sum(tv(t,v)$jvrt(j,v,r,t), gcapcost(j,v,r)  * gzeta(inv,j,v,r)))) 
$if      set trans      $if     set mixed      + sum((rr,k)$tmap(k,r,rr), sum(inv, tshare(inv,k,r) * IT(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t), tcapcost(k,r,rr) * tzeta(inv,k,v,r)))) 
                !! end investment cost (new, including discounting via investment cost factor)
*               DISCOUNTING                
                !! begin discounting
              + dfact(t) * (               
*               INVESTMENT COST
*               Old, excluding discouting via normal annui, and ccost)                
                !! begin investment cost (old)
*               We need nyrs because investments happens once only but production nyrs-times)
                1 / nyrs(t) * (1 + tk) * (1 
*                                   Normal investor consider total investment cost in the period of investment
$if                             set normal    + sum(new(i),                                                                              IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),  capcost(i,v,r)  *  endeffect(i,v,r,t)))
$if      set storage    $if     set normal    + sum(newj(j),                                                                             IG(j,r,t)    * sum(tv(t,v)$jvrt(j,v,r,t), gcapcost(j,v,r)  * gendeffect(j,v,r,t)))
$if      set trans      $if     set normal    + sum((rr,k)$tmap(k,r,rr),                                                                 IT(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t), tcapcost(k,r,rr) * tendeffect(k,v,r,t)))
*                                   Investment costs follow from annuities (%) of borrowed capital (EUR/kW * GW)
$if                             set annui     + sum(new(i),  sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(i,v,r,tt)),             IX(i,r,tt)   *  capcost(i,v,r)  *  deprtime(i,v,r,tt) *  annuity(i,v)  * nyrs(t)))
$if      set storage    $if     set annui     + sum(newj(j), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(j,v,r,tt)),             IG(j,r,tt)   * gcapcost(j,v,r)  * gdeprtime(j,v,r,tt) * gannuity(j,v)  * nyrs(t)))
$if      set trans      $if     set annui     + sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * tannuity(k)    * nyrs(t)))
*                                   Investment costs follow from WACC (%) of capital stock (EUR/kW * GW)
$if                             set ccost     + sum(new(i), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(i,v,r,tt)),              IX(i,r,tt)   *  capcost(i,v,r)  *  deprtime(i,v,r,tt) * drate * nyrs(t)))
$if      set storage    $if     set ccost     + sum(newj(j), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(j,v,r,tt)),             IG(j,r,tt)   * gcapcost(j,v,r)  * gdeprtime(j,v,r,tt) * drate * nyrs(t)))
$if      set trans      $if     set ccost     + sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * drate * nyrs(t)))
                )
                !! end investment cost (old, excluding discount via investment cost factor)
*               DISPATCH COST
*               Are measured in €/MWh and generation in GWh, so that we need to correct by 1e-3
                !! begin dispatch cost (regional)
*                       Dispatch cost (EUR/MWh) for generation (GWh)
$if not  set chp        + 1e-3 * sum(ivrt(i,v,r,t),            discost(i,v,r,t) * sum(s, hours(s) * X(s,i,v,r,t)))
$if      set chp        + 1e-3 * sum(ivrt(i,v,r,t),            discost(i,v,r,t) * sum(s, hours(s) * (XNOR(s,i,v,r,t) + XNOCHP(s,i,v,r,t))))
$if      set chp        + 1e-3 * sum(ivrt(i,v,r,t),     (-50 + discost(i,v,r,t))* sum(s, hours(s) * XCHP(s,i,v,r,t)))
*                       Ramping cost (EUR/MWh) for ramping up and down (GWh) plus efficiency losses when not operating optimal (assumed to be linear and at mean for new vintages to avoid non-linearities)
$if      set ramcost    + 1e-3 * sum(ivrt(i,v,r,t),            ramcost(i,v,r)   * sum(s, hours(s) * (RPNEG(s,i,v,r,t) + RPPOS(s,i,v,r,t))))
*                       Start-up cost (EUR/MW) for starting power plant after offtime 
$if      set stacost    + 1e-3 * sum(ivrt(i,v,r,t),            stacost(i,v,r)   * sum(s, hours(s) * NUMONOFF(s,i,v,r,t)))
*                       Variable operation and maintenance cost (EUR/MWh) for storage charge and discharge (GWh)
$if      set storage    + 1e-3 * sum(jvrt(j,v,r,t),            gvomcost(j,v,r)  * sum(s, hours(s) * G(s,j,v,r,t) + hours(s) * GD(s,j,v,r,t)))
*                       Variable operation and maintenance cost (EUR/MWh) for exports only (GWh)
$if      set trans      + 1e-3 * sum((k,rr)$tmap(k,r,rr),      tvomcost(k,r,rr) * sum(s, hours(s) * E(s,k,r,rr,t)))
*                        Cost of biomass fuel supply (we add "true" cost of receiving biomass by accouting for a step-wise biomass supply function; dispatch cost follow from pfuel)
$if      set biomark_r  + 1e-3 * sum(dbclass, DBSR(dbclass,r,t) * (dbcost_r(dbclass,r,t) - pfuel("Bioenergy",r,t)))
*                        Cost of natural gas fuel supply (we add "true" cost of receiving natural gas by accouting for a step-wise natural gas supply function; dispatch cost follow from pfuel)
$if      set gasmark_r  + 1e-3 * sum(ngclass, NGSR(ngclass,r,t) * (ngcost_r(ngclass,r,t) - pfuel("Gas",r,t)))
                !! end dispatch cost (regional)              
*               POLICY COST
*               Are from the perspective of the investor/firm/generator whose costs decrease when receiving a subsidy but increase by taxing (this is not a welfare optimum)
                !! begin policy cost
*                       Production subsidy (also for old vintage capacity in the moment, one can play around with newv(v))
*                       MM (todo): Think about introducing subsidy by vintage level to reflect feed-in tariff structures
                        - 1e-3 * sum(ivrt(i,v,r,t)$irnw(i),             irnwsub(r,t)            * sum(s, X(s,i,v,r,t) * hours(s) ))
                        - 1e-3 * sum(ivrt(i,v,r,t)$rnw(i),              rnwsub(r,t)             * sum(s, X(s,i,v,r,t) * hours(s) ))
                        - 1e-3 * sum(ivrt(i,v,r,t)$sol(i),              solsub(r,t)             * sum(s, X(s,i,v,r,t) * hours(s) ))
                        - 1e-3 * sum(ivrt(i,v,r,t)$wind(i),             windsub(r,t)            * sum(s, X(s,i,v,r,t) * hours(s) ))
                        - 1e-3 * sum(ivrt(i,v,r,t)$nuc(i),              nucsub(r,t)             * sum(s, X(s,i,v,r,t) * hours(s) ))
                        - 1e-3 * sum(ivrt(i,v,r,t)$lowcarb(i),          lowcarbsub(r,t)         * sum(s, X(s,i,v,r,t) * hours(s) ))
*                       Capacity subsidy (paid for new vintage capacity only)
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$irnw(i),       irnwsub_cap(r,t)        * sum(tv(t,v), IX(i,r,t) ))
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$rnw(i),        rnwsub_cap(r,t)         * sum(tv(t,v), IX(i,r,t) ))
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$sol(i),        solsub_cap(r,t)         * sum(tv(t,v), IX(i,r,t) ))
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$wind(i),       windsub_cap(r,t)        * sum(tv(t,v), IX(i,r,t) ))
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$nuc(i),        nucsub_cap(r,t)         * sum(tv(t,v), IX(i,r,t) ))
                        - 1e-3 * sum(ivrt(i,newv(v),r,t)$lowcarb(i),    lowcarbsub_cap(r,t)     * sum(tv(t,v), IX(i,r,t) ))
                !! end policy cost
*               SOCIAL COST
                !! begin social cost
*                       Cost (EUR/MWh) of lost load/backstop (GWh)
                        + 1e-3 * voll(r,t) * sum(s, BS(s,r,t) * hours(s))
*                       Public acceptance cost (EUR/MWh) for incremental nuclear generation (GWh)
*                       MM (todo): Think about public acceptance cost for nuclear capacity (and also other capacities)
$if      set scn        + round( dfact_scc(t)  / dfact(t) * 1e-3,4) * sum(ivrt(i,v,r,t), scn_emit(i,v,r,t)) * sum(s, X(s,i,v,r,t) * hours(s) ))
*                       Social cost of air pollution (EUR per MWh) from generation (GWh)
                        + round( dfact_scap(t) / dfact(t) * 1e-3,4) * sum(ivrt(i,v,r,t), scap_emit(i,v,r,t) * sum(s, X(s,i,v,r,t) * hours(s) ))
*                       Social cost of carbon (EUR per MWh) from generation (GWh)
                        + round( dfact_scc(t)  / dfact(t) * 1e-3,4) * sum(ivrt(i,v,r,t), scc_emit(i,v,r,t)  * sum(s, X(s,i,v,r,t) * hours(s) ))
*                       MM (todo): Introduce wind turbine public cost from visibility and noise (metric was already implemented once from Christoph) here (wait for the calibration from the Master thesis of Patrick)
                !! end social cost
*               FIXED COST
                !! begin fixed cost
*                       Fixed operation and maintenance cost (EUR/kW) for generation capacity (GW)
                        + sum(ivrt(i,v,r,t),       XC(i,v,r,t)  *  fomcost(i,v,r))
*                       Fixed operation and maintenance cost (EUR/kW) for storage capacity (GW)
$if      set storage    + sum(jvrt(j,v,r,t),       GC(j,v,r,t)  * gfomcost(j,v,r))
*                       Fixed operation and maintenance cost (EUR/kW) for transmission capacity (GW)
$if      set trans      + sum((k,rr)$tmap(k,r,rr), TC(k,r,rr,t) * tfomcost(k,r,rr))
                !! end fixed cost
                )
                !! end discounting
                )
                !! end region sum
*               DISPATCH COST (system-level)
                !! begin dispatch cost (system)
*               Cost of biomass and natural gas fuel supply come truely from system-wide prices
$if      set biomark    + 1e-3 * sum(dbclass, DBS(dbclass,t) * (dbcost(dbclass,t) - sum((r,dbclass), pfuel("Bioenergy",r,t) * dblim_r(dbclass,r,t))) )
$if      set gasmark    + 1e-3 * sum(ngclass, NGS(ngclass,t) * (ngcost(ngclass,t) - sum((r,ngclass), pfuel("Gas",r,t) * nglim_r(ngclass,r,t))) )
                !! end dispatch cost (system)
                )
                !! end time period sum
;



* * * * * Demand equations
* * * Electricity market clearance condition (in each segment)
demand(s,r,t)$tmyopic(t)..
*        Scale from GW to TWh (so that dual variable (marginals/shadow price) is reported directly in EUR/MWh)
                         1e-3 * hours(s)
*        Dispatched generation in region
                         * (sum(ivrt(i,v,r,t), X(s,i,v,r,t))
*        Plus inter-region imports
$if      set trans       + sum((k,rr)$tmap(k,rr,r), E(s,k,rr,r,t))
*        Less inter-region exports (penalty for transmission losses is charged on the export site only)
$if      set trans       - sum((k,rr)$tmap(k,r,rr), E(s,k,r,rr,t) / trnspen(k,r,rr))
*        Plus discharges from storage times discharge efficiency (less supply than stored) less charges from storage (the penalties apply at the storage accumulation)
$if      set storage     + sum(jvrt(j,v,r,t), GD(s,j,v,r,t) * dchrgpen(j,v,r) - G(s,j,v,r,t))
*        Plus a backstop option (lost load) representing segment-level demand response
$if      set lostload    + BS(s,r,t) * (1 + loss(r))
         )
*        Equals (annually scaled) demand including losses
         =e=             1e-3 * hours(s) * round(dref(r,t) * load(s,r) * (1 + loss(r)),4)
;

* * * Regional system adequacy constraint
* Hypothetical shadow electricity market with no transmission in the default version
* In the 4NEMO version it has changed by using capcredits. Here, transmission capacity is offered a tcapcredit of 0.1
demand_rsa(peak(s,r),t)$(not tbase(t) and tmyopic(t))..
*        Scale from GW to TWh (so that dual variable (marginals/shadow price) is reported directly in euro per MWh)
                         1e-3 * hours(s) * (
*        Upper bound on available generation in region
                         + sum(ivrt(i,v,r,t), XCS(s,i,v,r,t) *  capcred(i,v,r))
*        Plus discharges from storage less charges (plus penalty)
$if      set storage     + sum(jvrt(j,v,r,t),  GD(s,j,v,r,t) * gcapcred(j,v,r))
*        Plus inter-region imports
$if      set trans       + sum((k,rr)$tmap(k,rr,r), TC(k,rr,r,t) * tcapcred(k,rr,r))
         )
*        Equals (annually scaled) demand including losses
         =g=             1e-3 * hours(s) * round(dref(r,t) * load(s,r) * (1 + loss(r)),4)
;

* * * * * Generation and capacity equations

* * * Dispatch of units cannot exceed available capacity
* A variety of adjustment factors are applied to capacity to determine potential dispatch.
* These include availability factors that may or may not vary by segment (af and af_i),
* variable resource factors that vary by segment (vrsc), and in some cases time trends in the
* shape of availability or variability (af_t and vrsc_t).  In each case, the parameter applies
* to only a subset of technologies.
* To avoid creating a very large parameter matrix with many placeholder entries of 1, we use the following construct to perform a conditional product:
* 1 + (par(i) - 1)$par(i) = par(i) if it is defined, 1 otherwise
* This constuct requires that Eps is used for parameters where only some of the segments are populated.
* In these cases the Eps / zero / missing value should be treated as a zero instead of an implicit 1.
* The model will abort if vrsc is equal to 0 (rather than Eps) for an allowable renewable class.

* af are the monthly availability factor of dispatchable power and vrsc those of intermittent renewables (reliability is used if not af)
capacity(s,ivrt(i,v,r,t))$(not sharechp(i,v,r) > 0 and tmyopic(t))..
$if not  set chp X(s,i,v,r,t) =l=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
$if      set chp XNOR(s,i,v,r,t) =l=  XC(i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Helping chp generation
capacity_hel(s,ivrt(i,v,r,t))$(tmyopic(t))..                 
                 X(s,i,v,r,t) =e= XNOR(s,i,v,r,t) + XNOCHP(s,i,v,r,t) + XCHP(s,i,v,r,t) ;
* No CHP are not mustrun
capacity_noc(s,ivrt(i,oldv(v),r,t))$(sharechp(i,v,r) > 0 and tmyopic(t))..
                 XNOC(s,i,v,r,t) =l=  XC(i,v,r,t) * (1 - sharechp(i,v,r)) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* CHP are mustrun
capacity_chp(s,ivrt(i,oldv(v),r,t))$(sharechp(i,v,r) > 0 and tmyopic(t))..
                 XCHP(s,i,v,r,t) =e=  XCCHP(i,v,r,t) * sharechp(i,v,r) * 0.5708 ;
* Sometime we differentiate between technologies that are dispatchable (dspt) and those that are not (ndsp) (* This constraints is deactivated in the model setup when must-run is not "yes")
capacity_dsp(s,ivrt(dspt(i),v,r,t))$tmyopic(t)..
                 X(s,i,v,r,t) =l=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r))* (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Non-dispatchable technologies cannot adjust their production (see equality sign) (This constraints is deactivated in the model setup when must-run is not "yes")
capacity_nsp(s,ivrt(ndsp(i),v,r,t))$tmyopic(t)..
                 X(s,i,v,r,t) =e=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r))* (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Bioenergy is must-run (This constraint is also generally deactivated (could come with numerical difficulties but need further testing))
capacity_bio(s,ivrt(i,v,r,t))$(sameas(i,"Bioenergy") and tmyopic(t))..
                 X(s,i,v,r,t) =e=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r))* (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Co-firing dispatch has more complicated constraints (Existing coal or lignite capacity can be dispatched with or without co-firing) (co-fire is deactivated if not "cofiring=yes")
*capacity_cofir(s,ivrt(cofir,v,r,t))$tmyopic(t)..
*        Generation in co-fire mode (from any vintage) plus all-lign/coal generation in the underlying capacity blocks
*         sum(ivrt(cofir,v,r,t), X(s,cofir,v,r,t)) + sum(xcofir(cofir,i,vv)$ivrt(i,vv,r,t), X(s,i,vv,r,t))
*        Must not exceed availability of the underlying capacity blocks
*         =l= sum(xcofir(cofir,i,vv)$ivrt(i,vv,r,t), XCS(s,i,vv,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ) ;

* * * Investment flows accumulate as new vintage capacity
invest(new(i),newv(v),r,t)$(tv(t,v) and tmyopic(t))..
         XC(i,v,r,t) =l= IX(i,r,t) ;
* * * Existing vintages have fixed lifetime
* Cannot be decommissioned in 2020
exlife2020(ivrt(i,oldv(v),r,t))$(t.val le 2021 and tmyopic(t))..
         XC(i,v,r,t) =e= cap(i,v,r) * lifetime(i,v,r,t) ;
* Standard exlife constraint
exlife(ivrt(i,oldv(v),r,t))$(t.val ge 2022 and not sharechp(i,v,r) > 0 and tmyopic(t))..
$if not  set chp    XC(i,v,r,t) =l= cap(i,v,r) * lifetime(i,v,r,t) ;
$if      set chp    XCNOR(i,v,r,t) =l= cap(i,v,r) * lifetime(i,v,r,t) ;
* Helping chp vintage capacity
exlife_hel(ivrt(i,oldv(v),r,t))$(t.val ge 2022 and tmyopic(t))..
         XC(i,v,r,t) =e= XCNOR(i,v,r,t) + XCNOC(i,v,r,t) + XCCHP(i,v,r,t) ;
* No CHP plants can be decommissioned before lifetime
exlife_noc(ivrt(i,oldv(v),r,t))$(t.val ge 2022 and sharechp(i,v,r) > 0 and tmyopic(t))..
         XCNOC(i,v,r,t) =l= cap(i,v,r) * lifetime(i,v,r,t) * (1 - sharechp(i,v,r)) ;
* CHP plants cannot be decommissioned before lifetime         
exlife_chp(ivrt(i,oldv(v),r,t))$(t.val ge 2022 and sharechp(i,v,r) > 0  and tmyopic(t))..
         XCCHP(i,v,r,t) =e= cap(i,v,r) * lifetime(i,v,r,t) * sharechp(i,v,r) ;
* Bioenergy cannot be decommissioned before lifetime
exlife_bio(ivrt(i,oldv(v),r,t))$(sameas(i,"Bioenergy") and not sameas(t,"2020") and tmyopic(t))..
         XC(i,v,r,t) =e= cap(i,v,r) * lifetime(i,v,r,t) ;


* * * Upper bounds on lignite and coal CCS retrofit
* Retro is deactivatd if no "retrofit=yes"
*retro(retro,r,t)$tmyopic(t)..
*         sum(ivrt(retro,v,r,t), XC(retro,v,r,t) * xcapadj_retro(retro)) =l= ccs_retro(retro,r);

* * * New vintages have a lifetime profile for enforced retirement
newlife(ivrt(new(i),newv(v),r,t))$(not sameas(v,"2050") and tmyopic(t))..
        XC(i,v,r,t) =l= lifetime(i,v,r,t) * sum(tv(tt,v), IX(i,r,tt)) ;

* * * All vintages must be monotonically decreasing (except 2050)
* For myopic runs the tstatic not has to be here because otherwise step-in-step-out of capacities is possible
retire(ivrt(i,v,r,t))$(not sameas(v,"2050") and tmyopic(t))..
        XC(i,v,r,t+1) =l= XC(i,v,r,t) ;

* * * Upper and lower limits on investments based on current pipeline or other regional constraints
* Upper limit
investlimUP(i,r,t)$(new(i) and conv(i) and invlimUP(i,r,t) and not sameas(t,"2020") and tmyopic(t))..
         IX(i,r,t) =l= invlimUP(i,r,t) ;
* Lower limit
investlimLO(i,r,t)$(new(i) and invlimLO(i,r,t) and not sameas(t,"2020") and tmyopic(t))..
         IX(i,r,t) =g= invlimLO(i,r,t) ;
* Upper limit for whole system (in general deactivated)
investlimUP_eu(i,t)$(invlimUP_eu(i,t) < inf and tmyopic(t))..
         sum(r, IX(i,r,t)) =l= invlimUP_eu(i,t) ;

investlimUP_irnw(irnw(i),r,t,quantiles)$(irnwlimUP_quantiles(i,r,quantiles) and tmyopic(t) and not sameas(i,"Hydro") and not sameas(t,"2020"))..       
        sum(irnw_mapq(i,quantiles), sum(v, XC(i,v,r,t))) 
        =l= irnwlimUP_quantiles(i,r,quantiles) ;

* * * * * Transmission equations

* * * Enforce capacity constraint on inter-region trade flows
tcapacity(s,k,r,rr,t)$(tmap(k,r,rr) and tmyopic(t))..
         E(s,k,r,rr,t) =l= TCS(s,k,r,rr,t) ;
* Accumulation of transmission capacity investments
tinvestexi(k,r,rr,t)$(tmap(k,r,rr) and sameas(t,"2020") and tmyopic(t))..
         TC(k,r,rr,t) =l= tcap(k,r,rr) ;
tinvestnew(k,r,rr,t)$(tmap(k,r,rr) and (t.val ge 2025) and tmyopic(t))..
         TC(k,r,rr,t) =l= IT(k,r,rr,t) + TC(k,r,rr,t-1) ;
* Upper limit
tinvestlimUP(k,r,rr,t)$(tinvlimUP(k,r,rr,t) and tmyopic(t))..
         TC(k,r,rr,t) =l= tinvlimUP(k,r,rr,t) ;
* Lower limit
tinvestlimLO(k,r,rr,t)$(tinvlimLO(k,r,rr,t) and tmyopic(t))..
         TC(k,r,rr,t) =g= tinvlimLO(k,r,rr,t) ;
* Upper limit for whole system (in general deactivated)
tinvestlimUP_eu(k,t)$(tinvlimUP_eu(k,t) < inf and tmyopic(t))..
         sum((r,rr), TC(k,r,rr,t)) =l= tinvlimUP_eu(k,t) ;


* * * * * Storage equations

* * * Storage charge-discharge and accumulation
* Charge must not exceed charge capacity (size of door - entry)
chargelim(s,j,v,r,t)$tmyopic(t)..
         G(s,j,v,r,t)  =l= GCS(s,j,v,r,t) ;
* Discharge must not exceed charge capacity (size of door - exit)
dischargelim(s,j,v,r,t)$tmyopic(t)..
         GD(s,j,v,r,t) =l= GCS(s,j,v,r,t) ;
* Dynamic accumulation of storage balance (automatic discharge and charge efficiency apply here)
storagebal(s,j,v,r,t)$tmyopic(t)..
         GB(s,j,v,r,t) =e= GB(s-1,j,v,r,t) * (1 - dischrg(j,v,r)) +
$if      set storage_absweights   hours(s) *
* MM (comment): number = 100 means that we "implicitly" model 87.6 storage cycles
$if      set storage_relweights   hours(s) * round(number / 8760,4) *
         (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;
* Accumulated balance must not exceed storage capacity (size of room - reservoir)
storagelim(s,j,v,r,t)$tmyopic(t)..
         GB(s,j,v,r,t) =l= ghours(j,v,r) * GCS(s,j,v,r,t) * 1e-3 ;

* * * Allow accumulation of storage charge capacity investments
ginvest(newj(j),newv(v),r,t)$(tv(t,v) and tmyopic(t))..
         GC(j,v,r,t) =l= IG(j,r,t) + GC(j,v,r,t-1)$(sameas(v,"2050") and t.val > 2050);

* * * Existing storage vintages have fixed lifetime
* MM (todo): Think about implementing different constraints for myopic runs since it might be that endogenous decommissioning needs to get disablted anyway
* No decomissioning in 2015
gexlife2020(jvrt(j,oldv(v),r,t))$(sameas(t,"2020") and tmyopic(t))..
         GC(j,v,r,t) =e= gcap(j,v,r) * glifetime(j,v,r,t) ;
* Decommissioning possible >2015
gexlife(jvrt(j,oldv(v),r,t))$(not sameas(t,"2020") and tmyopic(t))..
         GC(j,v,r,t) =l= gcap(j,v,r) * glifetime(j,v,r,t) ;
* Avoid decommissioning of pump storage capacty
gexlife_pump(jvrt(j,oldv(v),r,t))$(sameas(j,"PumpStorage") and not sameas(t,"2020") and tmyopic(t))..
         GC(j,v,r,t) =e= gcap(j,v,r) * glifetime(j,v,r,t) ;

* * * New storage vintages have a lifetime profile for enforced retirement
gnewlife(jvrt(newj(j),newv(v),r,t))$(not sameas(v,"2050") and tmyopic(t))..
        GC(j,v,r,t) =l= glifetime(j,v,r,t) * sum(tv(tt,v), IG(j,r,tt));

* * * All storage vintages must be monotonically decreasing (except 2050)
gretire(j,v,r,t)$(not sameas(v,"2050") and tmyopic(t))..
        GC(j,v,r,t+1) =l= GC(j,v,r,t) ;

* * * Upper and lower limits
* Upper limit
ginvestlimUP(j,r,t)$tmyopic(t)..
         IG(j,r,t) =l= ginvlimUP(j,r,t) ;
* Lower limit
ginvestlimLO(j,r,t)$tmyopic(t)..
         IG(j,r,t) =g= ginvlimLO(j,r,t) ;
* Upper limits for whole system (again mostly inactive)
ginvestlimUP_eu(j,t)$(newj(j) and ginvlimUP_eu(j,t) < inf)..
         sum(r, IG(j,r,t)) =l= ginvlimUP_eu(j,t) ;

* * * Bioenergy market
* for whole system (allows for trade and the marginal is then the "price")
biomarket(t)$(sum(dbclass, dblim(dbclass,t)) and tmyopic(t))..
               sum(dbclass, DBS(dbclass,t))     =e= sum(r, sum(ivrt(i,v,r,t)$(sameas(i,"Bioenergy") or sameas(i,"Bio_CCS")), round(1 / effrate(i,v,r),4) * XTWH(i,v,r,t)) * 1e+6 ) ;
* for each region (does not allow for system-wide trade)
biomarket_r(r,t)$(sum(dbclass, dblim_r(dbclass,r,t)) and tmyopic(t))..
               sum(dbclass, DBSR(dbclass,r,t))  =e=        sum(ivrt(i,v,r,t)$(sameas(i,"Bioenergy") or sameas(i,"Bio_CCS")), round(1 / effrate(i,v,r),4) * XTWH(i,v,r,t)) * 1e+6 ;

* * * Natural gas market
* for whole system (allows for trade and the marginal is then the "price")
gasmarket(t)$(sum(ngclass, nglim(ngclass,t)) and tmyopic(t))..
               sum(ngclass, NGS(ngclass,t))     =e= sum(r, sum(ivrt(i,v,r,t)$(sameas(i,"Gas_OCGT") or sameas(i,"Gas_CCGT") or sameas(i,"Gas_ST") or sameas(i,"Gas_CCS")), round(1 / effrate(i,v,r),4) * XTWH(i,v,r,t)) * 1e+6 ) ;
* for each region (does not allow for system-wide trade)
gasmarket_r(r,t)$(sum(ngclass, nglim_r(ngclass,r,t)) and tmyopic(t))..
               sum(ngclass, NGSR(ngclass,r,t))  =e=        sum(ivrt(i,v,r,t)$(sameas(i,"Gas_OCGT") or sameas(i,"Gas_CCGT") or sameas(i,"Gas_ST") or sameas(i,"Gas_CCS")), round(1 / effrate(i,v,r),4) * XTWH(i,v,r,t)) * 1e+6 ;

* * * Renewable energy share market
* for whole system (allows for trade and the marginal is then the "price")
rnwtgtmarket(t)$(rnwtgt(t) and tmyopic(t))..
        sum(r, sum(ivrt(rnw(i),v,r,t), XTWH(i,v,r,t)))  =g=  rnwtgt(t)     * sum(r, sum(ivrt(i,v,r,t), XTWH(i,v,r,t)) ) ;
* for each region (does not allow for system-wide trade)
rnwtgtmarket_r(r,t)$(rnwtgt_r(r,t) and tmyopic(t))..
               sum(ivrt(rnw(i),v,r,t), XTWH(i,v,r,t))   =g=  rnwtgt_r(r,t) *        sum(ivrt(i,v,r,t), XTWH(i,v,r,t)) ;

* * * Intermittent renewable energy share market
* for whole system (allows for trade and the marginal is then the "price")
irnwtgtmarket(t)$(irnwtgt(t) and tmyopic(t))..
        sum(r, sum(ivrt(irnw(i),v,r,t), XTWH(i,v,r,t))) =g= irnwtgt(t)     * sum(r, sum(ivrt(i,v,r,t), XTWH(i,v,r,t)) ) ;
* for each region (does not allow for system-wide trade)
irnwtgtmarket_r(r,t)$(irnwtgt_r(r,t) and tmyopic(t))..
               sum(ivrt(irnw(i),v,r,t), XTWH(i,v,r,t))  =g= irnwtgt_r(r,t) *        sum(ivrt(i,v,r,t), XTWH(i,v,r,t)) ;

* * * Bioenergy potential
* for whole system (allows for trade and the marginal is then the "price")
bioflow(t)$(biolim_eu(t) and (biolim_eu(t) < inf) and tmyopic(t))..         BC(t)           =e= sum(r, sum(ivrt(i,v,r,t)$(sameas(i,"Bioenergy") or sameas(i,"Bio_CCS")), round(1 / effrate(i,v,r), 8) * XTWH(i,v,r,t))) ;
cumbio2020(t)$(biolim_eu(t) and tbase(t) and tmyopic(t))..                  BC(t)           =e= biolim_eu(t) ;
cumbio(t)$(biolim_eu(t) and not tbase(t) and tmyopic(t))..                  BC(t)           =l= biolim_eu(t) ;
* for each region (does not allow for system-wide trade)
bioflow_r(r,t)$(biolim(r,t) and (biolim(r,t) < inf) and tmyopic(t))..       BC_r(r,t)       =e=        sum(ivrt(i,v,r,t)$(sameas(i,"Bioenergy") or sameas(i,"Bio_CCS")), round(1 / effrate(i,v,r), 8) * XTWH(i,v,r,t)) ;
cumbio_r(r,t)$(biolim(r,t) and (biolim(r,t) < inf) and tmyopic(t))..        BC_r(r,t)       =l= biolim(r,t) ;        
* * * Gas budget equations
* for whole system (allows for trade and the marginal is then the "price")
gasflow(t)$(gaslim_eu(t) and (gaslim_eu(t) < inf) and tmyopic(t))..         GASC(t)         =e= sum(r, sum(ivrt(i,v,r,t)$(sameas(i,"Gas_OCGT") or sameas(i,"Gas_CCGT") or sameas(i,"Gas_ST") or sameas(i,"Gas_CCS")), round(1 / effrate(i,v,r), 8) * XTWH(i,v,r,t))) ;
cumgas(t)$(gaslim_eu(t) and (gaslim_eu(t) < inf) and tmyopic(t))..          GASC(t)         =l= gaslim_eu(t) ;
* for each region (does not allow for system-wide trade)
gasflow_r(r,t)$(gaslim(r,t) and (gaslim(r,t) < inf) and tmyopic(t))..       GASC_r(r,t)     =e=        sum(ivrt(i,v,r,t)$(sameas(i,"Gas_OCGT") or sameas(i,"Gas_CCGT") or sameas(i,"Gas_ST") or sameas(i,"Gas_CCS")), round(1 / effrate(i,v,r), 8) * XTWH(i,v,r,t)) ;
cumgas_r(r,t)$(gaslim(r,t) and (gaslim(r,t) < inf) and tmyopic(t))..        GASC_r(r,t)     =l= gaslim(r,t) ;      
* * * Geologic storage of carbon
* for whole system (system-wide constraints allow for trade and the marginal is then the "price")
ccsflow(t)$(not tbase(t) and tmyopic(t))..       SC(t) =e=  sum(r, sum(ivrt(i,v,r,t), co2captured(i,v,r) * XTWH(i,v,r,t)));
cumccs..                                         sum(t, nyrs(t) * SC(t)) =l= sclim_eu ;
* for each region (does not allow for system-wide trade)
ccsflow_r(r,t)$(not tbase(t) and tmyopic(t))..   SC_r(r,t)  =e= sum(ivrt(i,v,r,t), co2captured(i,v,r) * XTWH(i,v,r,t));
cumccs_r(r)..                                    sum(t, nyrs(t) * SC_r(r,t)) =l= sclim(r) ;

* * * Structural equations to aid solver
xtwhdef(ivrt(i,v,r,t))$tmyopic(t)..                 XTWH(i,v,r,t)   =e= 1e-3 * sum(s, X(s,i,v,r,t) * hours(s)) ;
copyxc(s,ivrt(i,v,r,t))$tmyopic(t)..                XCS(s,i,v,r,t)  =e= XC(i,v,r,t)$(ord(s) eq 1)  + XCS(s-1,i,v,r,t)$(ord(s) > 1) ;
copygc(s,jvrt(j,v,r,t))$tmyopic(t)..                GCS(s,j,v,r,t)  =e= GC(j,v,r,t)$(ord(s) eq 1)  + GCS(s-1,j,v,r,t)$(ord(s) > 1) ;
copytc(s,k,r,rr,t)$(tmap(k,r,rr) and tmyopic(t))..  TCS(s,k,r,rr,t) =e= TC(k,r,rr,t)$(ord(s) eq 1) + TCS(s-1,k,r,rr,t)$(ord(s) > 1) ;

* * * EU ETS MSR version of the model (this condition is deactivated if not "euetsmsr=yes")
PARAMETER
co2ele_int(t)
co2ind_int(t)
co2can_int(t)
co2indfix_int(t)
co2indshare_int(t)
co2add_int(t)
co2allocated_int(t)
co2auctioned_int(t)
tnac_int(t)
tnacuse_int(t)
msr_int(t)
msrin_int(t)
msrstart_int
tnacstart_int
;

* * * * * Carbon markets
* We have four model versions: (1) simple cap w/o shortrun, (2) simple cap with banking w/o shortrun, (3) EU ETS MSR iterative w/o shortrun, and (4) EU ETS MSR MIP w/o shotrun
* * * Loadings from simulation model (simple cap uses the respective MIP module)
$onecho >temp\gdxxrw.rsp
par=co2ele_in           rng=co2ele_in!a2             rdim=1 cdim=0
par=co2ind_in           rng=co2ind_in!a2             rdim=1 cdim=0
par=co2can_in           rng=co2can_in!a2             rdim=1 cdim=0
par=co2indfix_in        rng=co2indfix_in!a2          rdim=1 cdim=0
par=co2indshare_in      rng=co2indshare_in!a2        rdim=1 cdim=0
par=co2add_in           rng=co2add_in!a2             rdim=1 cdim=0 
par=co2allocated_in     rng=co2allocated_in!a2       rdim=1 cdim=0
par=co2auctioned_in     rng=co2auctioned_in!a2       rdim=1 cdim=0
par=msr_in              rng=msr_in!a2                rdim=1 cdim=0
par=msrin_in            rng=msrin_in!a2              rdim=1 cdim=0
par=msrstart_in         rng=msrstart_in!a2           rdim=0 cdim=0
par=tnac_in             rng=tnac_in!a2               rdim=1 cdim=0
par=tnacuse_in          rng=tnacuse_in!a2            rdim=1 cdim=0
par=tnacstart_in        rng=tnacstart_in!a2          rdim=0 cdim=0
$offecho
* * Indformula routine
* Define iterative loading loop (iter 0 always loads from the "base" files)
$if     set co2iter $if     set iter0   $if not set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_indformula_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2ITER_indformula_shortrun.gdx          trace=3 log=temp\EUETS_MSR_CO2ITER_indformula_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2iter $if     set iter0   $if     set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_crisis_indformula_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2ITER_crisis_indformula_shortrun.gdx   trace=3 log=temp\EUETS_MSR_CO2ITER_crisis_indformula_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set bauprice    $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_bauprice_indformula_shortrun.xlsx o=euetsmsr\EUETS_MSR_CO2ITER_bauprice_indformula_shortrun.gdx trace=3 log=temp\EUETS_MSR_CO2ITER_bauprice_indformula_shortrun.log @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set recovery    $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_recovery_indformula_shortrun.xlsx o=euetsmsr\EUETS_MSR_CO2ITER_recovery_indformula_shortrun.gdx trace=3 log=temp\EUETS_MSR_CO2ITER_recovery_indformula_shortrun.log @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set high        $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_high_indformula_shortrun.xlsx     o=euetsmsr\EUETS_MSR_CO2ITER_high_indformula_shortrun.gdx     trace=3 log=temp\EUETS_MSR_CO2ITER_high_indformula_shortrun.log     @temp\gdxxrw.rsp';
$if     set co2iter $if     set iter0   $if not set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_indformula_shortrun      
$if     set co2iter $if     set iter0   $if     set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_crisis_indformula_shortrun
$if     set co2iter $if not set iter0   $if     set bauprice    $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_bauprice_indformula_shortrun
$if     set co2iter $if not set iter0   $if     set recovery    $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_recovery_indformula_shortrun
$if     set co2iter $if not set iter0   $if     set high        $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_high_indformula_shortrun
* Define mip loading routine
$if     set co2mips                     $if not set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MIPS_indformula_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2MIPS_indformula_shortrun.gdx         trace=3 log=temp\EUETS_MSR_CO2MIPS_indformula_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2mips                     $if     set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MIPS_crisis_indformula_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2MIPS_crisis_indformula_shortrun.gdx  trace=3 log=temp\EUETS_MSR_CO2MIPS_crisis_indformula_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2mips                     $if not set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MIPS_indformula_shortrun
$if     set co2mips                     $if     set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MIPS_crisis_indformula_shortrun
* Define co2market loading routine
$if     set co2mark                     $if not set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_indformula_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2MARK_indformula_shortrun.gdx         trace=3 log=temp\EUETS_MSR_CO2MARK_indformula_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2mark                     $if     set crisis      $if     set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula_shortrun.gdx  trace=3 log=temp\EUETS_MSR_CO2MARK_crisis_indformula_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2mark                     $if not set crisis      $if     set indformula  $if not set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_indformula.xlsx                   o=euetsmsr\EUETS_MSR_CO2MARK_indformula.gdx                  trace=3 log=temp\EUETS_MSR_CO2MARK_indformula.log                   @temp\gdxxrw.rsp';
$if     set co2mark                     $if     set crisis      $if     set indformula  $if not set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula.xlsx            o=euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula.gdx           trace=3 log=temp\EUETS_MSR_CO2MARK_crisis_indformula.log            @temp\gdxxrw.rsp';
$if     set co2mark                     $if not set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_indformula_shortrun
$if     set co2mark                     $if     set crisis      $if     set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula_shortrun
$if     set co2mark                     $if not set crisis      $if     set indformula  $if not set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_indformula
$if     set co2mark                     $if     set crisis      $if     set indformula  $if not set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_crisis_indformula
* * Indfix routine
* Define iterative loading loop (iter 0 always loads from the "base" files)
$if     set co2iter $if     set iter0   $if not set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2ITER_shortrun.gdx          trace=3 log=temp\EUETS_MSR_CO2ITER_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2iter $if     set iter0   $if     set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_crisis_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2ITER_crisis_shortrun.gdx   trace=3 log=temp\EUETS_MSR_CO2ITER_crisis_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set bauprice    $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_bauprice_shortrun.xlsx o=euetsmsr\EUETS_MSR_CO2ITER_bauprice_shortrun.gdx trace=3 log=temp\EUETS_MSR_CO2ITER_bauprice_shortrun.log @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set recovery    $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_recovery_shortrun.xlsx o=euetsmsr\EUETS_MSR_CO2ITER_recovery_shortrun.gdx trace=3 log=temp\EUETS_MSR_CO2ITER_recovery_shortrun.log @temp\gdxxrw.rsp';
$if     set co2iter $if not set iter0   $if     set high        $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2ITER_high_shortrun.xlsx     o=euetsmsr\EUETS_MSR_CO2ITER_high_shortrun.gdx     trace=3 log=temp\EUETS_MSR_CO2ITER_high_shortrun.log     @temp\gdxxrw.rsp';
$if     set co2iter $if     set iter0   $if not set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_shortrun      
$if     set co2iter $if     set iter0   $if     set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_crisis_shortrun
$if     set co2iter $if not set iter0   $if     set bauprice    $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_bauprice_shortrun
$if     set co2iter $if not set iter0   $if     set recovery    $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_recovery_shortrun
$if     set co2iter $if not set iter0   $if     set high        $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2ITER_high_shortrun
* Define mip loading routine
$if     set co2mips                     $if not set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MIPS_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2MIPS_shortrun.gdx         trace=3 log=temp\EUETS_MSR_CO2MIPS_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2mips                     $if     set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MIPS_crisis_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2MIPS_crisis_shortrun.gdx  trace=3 log=temp\EUETS_MSR_CO2MIPS_crisis_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2mips                     $if not set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MIPS_shortrun
$if     set co2mips                     $if     set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MIPS_crisis_shortrun
* Define co2market loading routine
$if     set co2mark                     $if not set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_shortrun.xlsx          o=euetsmsr\EUETS_MSR_CO2MARK_shortrun.gdx         trace=3 log=temp\EUETS_MSR_CO2MARK_shortrun.log          @temp\gdxxrw.rsp';
$if     set co2mark                     $if     set crisis      $if not set indformula  $if     set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_crisis_shortrun.xlsx   o=euetsmsr\EUETS_MSR_CO2MARK_crisis_shortrun.gdx  trace=3 log=temp\EUETS_MSR_CO2MARK_crisis_shortrun.log   @temp\gdxxrw.rsp';
$if     set co2mark                     $if not set crisis      $if not set indformula  $if not set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK.xlsx                   o=euetsmsr\EUETS_MSR_CO2MARK.gdx                  trace=3 log=temp\EUETS_MSR_CO2MARK.log                   @temp\gdxxrw.rsp';
$if     set co2mark                     $if     set crisis      $if not set indformula  $if not set shortrun    $call 'gdxxrw i=euetsmsr\EUETS_MSR_CO2MARK_crisis.xlsx            o=euetsmsr\EUETS_MSR_CO2MARK_crisis.gdx           trace=3 log=temp\EUETS_MSR_CO2MARK_crisis.log            @temp\gdxxrw.rsp';
$if     set co2mark                     $if not set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_shortrun
$if     set co2mark                     $if     set crisis      $if not set indformula  $if     set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_crisis_shortrun
$if     set co2mark                     $if not set crisis      $if not set indformula  $if not set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK
$if     set co2mark                     $if     set crisis      $if not set indformula  $if not set shortrun           $gdxin   euetsmsr\EUETS_MSR_CO2MARK_crisis
* * Final load
$load co2ele_int=co2ele_in
$load co2ind_int=co2ind_in
$load co2indfix_int=co2indfix_in
$load co2indshare_int=co2indshare_in
$load co2add_int=co2add_in
$load co2can_int=co2can_in
$load co2allocated_int=co2allocated_in
$load co2auctioned_int=co2auctioned_in
$load tnac_int=tnac_in
$load tnacuse_int=tnacuse_in
$load tnacstart_int=tnacstart_in
$load msr_int=msr_in
$load msrin_int=msrin_in
$load msrstart_int=msrstart_in
$gdxin

PARAMETER
co2ele_in(t)
co2ind_in(t)
co2can_in(t)
co2indfix_in(t)
co2indshare_in(t)
co2add_in(t)
co2allocated_in(t)
co2auctioned_in(t)
tnac_in(t)
tnacuse_in(t)
msr_in(t)
msrin_in(t)
msrstart_in
tnacstart_in
;

co2ele_in(t) = round(co2ele_int(t), 8) ;
co2ind_in(t) = round(co2ind_int(t), 8) ;
co2indfix_in(t) = round(co2indfix_int(t), 8) ;
co2indshare_in(t) = round(co2indshare_int(t), 8) ;
co2can_in(t) = round(co2can_int(t), 8) ;
co2add_in(t) = round(co2add_int(t), 8) ;
co2allocated_in(t) = round(co2allocated_int(t), 8) ;
co2auctioned_in(t) = round(co2auctioned_int(t), 8) ;
tnac_in(t) = round(tnac_int(t), 8) ;
tnacuse_in(t) = round(tnacuse_int(t), 8) ;
msr_in(t) = round(msr_int(t), 8) ;
msrin_in(t) = round(msrin_int(t), 8) ;
msrstart_in = round(msrstart_int, 8) ;
tnacstart_in = round(tnacstart_int, 8) ;

POSITIVE VARIABLE
TNAC(t)             Cumulative banked allowances (Mt)
;

VARIABLE
EC(t)               Annual flow of CO2 emissions (GtCO2)
EC_r(r,t)           Annual flow of CO2 emissions (MtCO2)
TNACUSE(t)          Allowance usage from bank (Mt)
;

* Fix some general starting variables
$if     set banking     $if not set onlyelec            TNACUSE.FX(t)$(t.val le 2021) = tnacuse_in(t) ;
$if     set banking     $if not set onlyeleccrisis      TNACUSE.FX(t)$(t.val le 2021) = tnacuse_in(t) ;

$if     set banking     $if     set onlyelec            TNACUSE.FX(t)$(t.val le 2021) = 0 ;
$if     set banking     $if     set onlyeleccrisis      TNACUSE.FX(t)$(t.val le 2021) = 0 ;

* Determine some general ending variables
$if     set banking     TNAC.FX("2045") = 0 ;
$if     set banking     TNAC.FX("2050") = 0 ;
$if     set banking     TNACUSE.FX("2050") = 0 ;

EQUATION
co2flow_r(r,t)          Annual flow of CO2 emissions (regional) (Mt)
co2flow(t)              Annual flow of CO2 emissions (system) (Mt)
co2market_r(r,t)        Cap market for CO2 emissions (regional) (Mt)
co2market(t)            Cap market for CO2 emissions (system) (Mt)
co2market_indformula(t) Cap market for CO2 emissions (system) (Mt)
co2marban(t)            Cap market for CO2 emissions with banking and optional industrial emissions (system) (Mt)
co2marban_indformula(t) Cap market for CO2 emissions (system) (Mt)
co2tnac(t)              Total number of allowances in circulation (system) (Mt)
;

* Determine CO2 flow
co2flow_r(r,t)$(tmyopic(t)).. EC_r(r,t) =e=        sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t)) ;
co2flow(t)$(tmyopic(t))..     EC(t)     =e= sum(r, sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;

* * * Simple carbon market without MSR dynamics (this module is deactived if not (1) "co2mark_r=yes", (2) "co2market=yes", (3) "co2mark_informula=yes", (4) "co2mban=yes", or (5) "co2mban_indformula=yes")
PARAMETER
co2sup1(t)
co2sup1_indformula(t)
co2sup2(t)
co2sup2_indformula(t)
;

co2sup1(t)$(t.val le 2021)              = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) + tnacuse_in(t) ;
co2sup1_indformula(t)$(t.val le 2021)   = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) + tnacuse_in(t) ;
co2sup2(t)$(t.val le 2021)              = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) ;
co2sup2_indformula(t)$(t.val le 2021)   = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) ;

co2sup1(t)$(t.val ge 2022)              = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) + tnacuse_in(t) ;
co2sup1_indformula(t)$(t.val ge 2022)   = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) + tnacuse_in(t) ;
co2sup2(t)$(t.val ge 2022)              = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) ;
co2sup2_indformula(t)$(t.val ge 2022)   = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) ;

* There are no industrial emissions and no bank to use when only modeling electricity emissions (bank can be build up)
$if     set onlyelec        co2ind_in(t) = 0 ;
$if     set onlyelec        tnacstart_in = 0 ;
$if     set onlyeleccrisis  co2ind_in(t) = 0 ;
$if     set onlyeleccrisis  tnacstart_in = 0 ;

$if     set onlyelec        co2sup1(t)$(t.val ge 2020)              = co2ele_in(t) + co2ind_in(t) + co2can_in(t) ;
$if     set onlyelec        co2sup1_indformula(t)$(t.val ge 2020)   = co2ele_in(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) ;
$if     set onlyelec        co2sup2(t)$(t.val ge 2020)              = co2ele_in(t) + co2ind_in(t) + co2can_in(t) ;
$if     set onlyelec        co2sup2_indformula(t)$(t.val ge 2020)   = co2ele_in(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) ;

$if     set onlyeleccrisis  co2sup1(t)$(t.val ge 2020)              = co2ele_in(t) + co2ind_in(t) + co2can_in(t) ;
$if     set onlyeleccrisis  co2sup1_indformula(t)$(t.val ge 2020)   = co2ele_in(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) ;
$if     set onlyeleccrisis  co2sup2(t)$(t.val ge 2020)              = co2ele_in(t) + co2ind_in(t) + co2can_in(t) ;
$if     set onlyeleccrisis  co2sup2_indformula(t)$(t.val ge 2020)   = co2ele_in(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) ;


* * (1) Regional market is always without industrial emissions and banking
co2market_r(r,t)$(tmyopic(t))..         EC_r(r,t)                                                                                         =l= co2cap_r(r,t) ;
* * (2) - (3) Simple European cap without banking with optional industrial emissions (fix and formula)
co2market(t)$(tmyopic(t))..             EC(t) + co2ind_in(t) + co2can_in(t)                                                               =l= co2sup1(t)  ;
co2market_indformula(t)$(tmyopic(t))..  EC(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) =l= co2sup1_indformula(t)  ;
* * (4) - (5) Simple European cap with banking including industrial emissions
co2marban(t)$(tmyopic(t))..             EC(t) + co2ind_in(t) + co2can_in(t)                                                               =e= co2sup2(t) + TNACUSE(t) ;
co2marban_indformula(t)$(tmyopic(t))..  EC(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) =e= co2sup2_indformula(t) + TNACUSE(t) ;
co2tnac(t)$(tmyopic(t))..               TNAC(t)                                                                                           =e= tnacstart_in - sum(tt$(tt.val le t.val), TNACUSE(tt) * nyrs(tt)) ;


* * * Iterative "shortrun" EU ETS MSR version of the model (this module is deactived if not "co2iter=yes")
EQUATION
it_co2flow(t)
it_euets(t)
it_euets_indformula(t)
it_tnac(t)
;

it_co2flow(t)$tmyopic(t)..                                                  EC(t)                =e= sum(r, sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;
it_euets(t)$tmyopic(t)..                                                    EC(t) + co2ind_in(t) + co2can_in(t)
                                                                                                 =e= co2sup2(t) + TNACUSE(t) ;
it_euets_indformula(t)$tmyopic(t)..                                         EC(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t)
                                                                                                 =e= co2sup2(t) + TNACUSE(t) ;
it_tnac(t)$tmyopic(t)..                                                     TNAC(t)              =e= tnacstart_in - sum(tt$(tt.val le t.val), TNACUSE(tt) * nyrs(tt)) ;

* Constrain freedom of variables to be closer to the simulation model and prevent "race-to-the-bottom" (i.e., cancelling circle)
*$if      set co2iter  $if      set shortrun                           EC.UP(t)  = co2ele_in(t) + 50 ;
*$if      set co2iter  $if      set shortrun                           EC.LO(t)  = co2ele_in(t) - 50 ;
* Fix starting and endling values (2020 and 2021, 2045 and 2050)
*$if      set co2iter  $if      set shortrun   TNACUSE.FX("2020") = tnacuse_in("2020") ;
*$if      set co2iter  $if      set shortrun   TNACUSE.FX("2021") = tnacuse_in("2021") ;

* * * MIP EU ETS MSR version of the model
BINARY VARIABLE
UPP(t)                  TNAC is above 833 Mio
MID(t)                  TNAC is between 400 and 800 Mio.
LOW(t)                  TNAC is below 400 Mio
BAN(t)                  Banking is active (no usage of TNAC)
;

POSITIVE VARIABLE
MSR(t)
CANCEL(t)
MSRIN(t)
MSROUT(t)
;

* * * Reduced shortrun EU ETS MSR version of the model
EQUATION
eqs_co2flow(t)
eqs_euets(t)
eqs_euets_indformula(t)
eqs_msrin2023(t)
eqs_msrin(t)
eqs_msrout2023(t)
eqs_msrout(t)
eqs_tnac(t)
eqs_msr(t)
eqs_cancel(t)
eqs_tnacup(t)
eqs_tnaclo(t)
eqs_binary(t)
;

eqs_co2flow(t)$(tmyopic(t))..                                               EC(t)                       =e= sum(r, sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;
eqs_euets(t)$(tmyopic(t))..                                                 EC(t) + co2ind_in(t) + co2can_in(t) 
                                                                                                        =e= co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - MSRIN(t) + MSROUT(t) + TNACUSE(t) ;
eqs_euets_indformula(t)$(tmyopic(t))..                                      EC(t) * (1 - co2indfix_in(t)) * co2indshare_in(t) + co2indfix_in(t) * co2ind_in(t) + co2can_in(t) 
                                                                                                        =e= co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - MSRIN(t) + MSROUT(t) + TNACUSE(t) ;
eqs_msrin2023(t)$(sameas(t,"2023") and tmyopic(t))..                        MSRIN(t)                    =e= UPP(t-1) * 0.24 * TNAC(t-1) ;
eqs_msrin(t)$((t.val ge 2024 and t.val le 2045) and tmyopic(t))..           MSRIN(t)                    =e= UPP(t-1) * 0.12 * TNAC(t-1) ;
eqs_msrout2023(t)$(sameas(t,"2023") and tmyopic(t))..                       MSROUT(t)                   =e= LOW(t-1) * 200 ;
eqs_msrout(t)$((t.val ge 2024 and t.val le 2045) and tmyopic(t))..          MSROUT(t)                   =l= LOW(t-1) * 100 ;
eqs_tnac(t)$((t.val ge 2020 and t.val le 2045) and tmyopic(t))..            TNAC(t)                     =e= tnacstart_in - sum(tt$(tt.val le t.val), TNACUSE(tt) * nyrs(tt)) ;
eqs_msr(t)$((t.val ge 2020 and t.val le 2045) and tmyopic(t))..             MSR(t)                      =e= msrstart_in  + sum(tt$(tt.val le t.val), (MSRIN(tt) - MSROUT(tt) - CANCEL(tt)) * nyrs(tt)) ;
eqs_cancel(t)$((t.val ge 2023 and t.val le 2045) and tmyopic(t))..          CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - co2auctioned_in(t-1) + MSRIN(t-1) - MSROUT(t-1) ;
eqs_tnacup(t)$((t.val ge 2020 and t.val le 2045) and tmyopic(t))..          TNAC(t)                     =g=                MID(t) * 400 + UPP(t) *  833 ;
eqs_tnaclo(t)$((t.val ge 2020 and t.val le 2045) and tmyopic(t))..          TNAC(t)                     =l= LOW(t) * 400 + MID(t) * 833 + UPP(t) * 2000 ;
eqs_binary(t)$((t.val ge 2020 and t.val le 2045) and tmyopic(t))..          LOW(t) + UPP(t) + MID(t)    =e= 1 ;

$if      set co2mips  $if      set shortrun   TNACUSE.L(t)                = tnacuse_in(t) ;
$if      set co2mips  $if      set shortrun   TNAC.L(t)                   = tnac_in(t) ;
$if      set co2mips  $if      set shortrun   MSRIN.L(t)$(msr_in(t) >= 0) = msrin_in(t) ;
$if      set co2mips  $if      set shortrun   MSROUT.L(t)$(msr_in(t) < 0) = msrin_in(t) ;
$if      set co2mips  $if      set shortrun   LOW.L(t)$(tnac_in(t) <  400)  = 1 ;
$if      set co2mips  $if      set shortrun   LOW.L(t)$(tnac_in(t) >= 400)  = 0 ;
$if      set co2mips  $if      set shortrun   MID.L(t)$(tnac_in(t) <= 833 and tnac_in(t) >= 400) = 1 ;
$if      set co2mips  $if      set shortrun   MID.L(t)$(tnac_in(t) <  400 or  tnac_in(t) >  833) = 0 ;
$if      set co2mips  $if      set shortrun   UPP.L(t)$(tnac_in(t) >  833) = 1 ;
$if      set co2mips  $if      set shortrun   UPP.L(t)$(tnac_in(t) <= 833) = 0 ;

$if      set co2mips  $if      set shortrun   TNACUSE.FX("2020") = tnacuse_in("2020") ;
$if      set co2mips  $if      set shortrun   TNACUSE.FX("2021") = tnacuse_in("2021") ;
$if      set co2mips  $if      set shortrun   MSRIN.FX("2020") = msrin_in("2020") ;
$if      set co2mips  $if      set shortrun   MSRIN.FX("2021") = msrin_in("2021") ;
$if      set co2mips  $if      set shortrun   MSROUT.FX("2020") = 0 ;
$if      set co2mips  $if      set shortrun   MSROUT.FX("2021") = 0 ;
$if      set co2mips  $if      set shortrun   LOW.FX("2020") = 0 ;
$if      set co2mips  $if      set shortrun   LOW.FX("2021") = 0 ;
$if      set co2mips  $if      set shortrun   MID.Fx("2020") = 0 ;
$if      set co2mips  $if      set shortrun   MID.FX("2021") = 0 ;
$if      set co2mips  $if      set shortrun   UPP.FX("2020") = 1 ;
$if      set co2mips  $if      set shortrun   UPP.FX("2021") = 1 ;

* * * Ukraine Russian war investment lag module (should work for both shortrun and not)
parameter
ixfx(i,r,t)
itfx(k,r,r,t)
igfx(j,r,t)
;

$if not  set bauprice   $gdxin limits\limits_%l%_bauprice.gdx
$if not  set bauprice   $load ixfx, itfx, igfx
$if not  set bauprice   $gdxin
* Investment limits depending on (not) shortrun modeling
$if not  set bauprice                           IX.FX(conv(i),r,t)$(t.val le 2030)      = ixfx(i,r,t) ;
$if not  set bauprice                           IX.FX(nuc(i),r,t)$(t.val le 2035)       = ixfx(i,r,t) ;
$if not  set bauprice   $if     set shortrun    IX.FX(sol(i),r,t)$(t.val le 2023)       = ixfx(i,r,t) ;
$if not  set bauprice   $if not set shortrun    IX.FX(sol(i),r,t)$(t.val le 2025)       = ixfx(i,r,t) ;
$if not  set bauprice   $if     set shortrun    IX.FX(wind(i),r,t)$(t.val le 2024)      = ixfx(i,r,t) ;
$if not  set bauprice   $if     set shortrun    IX.FX(wind(i),r,t)$(t.val le 2025)      = ixfx(i,r,t) ;
$if not  set bauprice                           IX.FX(windoff(i),r,t)$(t.val le 2026)   = ixfx(i,r,t) ;
$if not  set bauprice                           IX.FX(windoff(i),r,t)$(t.val le 2025)   = ixfx(i,r,t) ;
$if not  set bauprice                           IT.FX(k,r,rr,t)$(t.val le 2035)         = itfx(k,r,rr,t) ;
$if not  set bauprice                           IG.FX("Storage_ST",r,t)$(t.val le 2025) = igfx("Storage_ST",r,t) ;
$if not  set bauprice                           IG.FX("Storage_LT",r,t)$(t.val le 2025) = igfx("Storage_LT",r,t) ;
* Availability parameter shortrun modeling adjustments
$if not  set bauprice   $if     set shortrun    af(s,"Hydro",v,"Norway","2022") = 0.9 ;
$if not  set bauprice   $if     set shortrun    af(s,"Hydro",v,"Italy","2022")  = 0.9 ;
$if not  set bauprice   $if     set shortrun    af(s,"Hydro",v,"Austria","2022")  = 0.9 ;
$if not  set bauprice   $if     set shortrun    af(s,"Nuclear",v,"France","2021") = 0.85 ;
$if not  set bauprice   $if     set shortrun    af(s,"Nuclear",v,"France","2022") = 0.7 ;
$if not  set bauprice   $if     set shortrun    af(s,"Nuclear",v,"France","2023") = 0.85 ;
* Availability parameter not shortrun modeling adjustments
$if not  set bauprice   $if not set shortrun    af(s,"Hydro",v,"Norway","2025") = 0.9 ;
$if not  set bauprice   $if not set shortrun    af(s,"Hydro",v,"Italy","2025")  = 0.9 ;
$if not  set bauprice   $if not set shortrun    af(s,"Hydro",v,"Austria","2025")  = 0.9 ;
$if not  set bauprice   $if not set shortrun    af(s,"Nuclear",v,"France","2025") = 0.85 ;

* * * Model fixes
* No investment in base year
IX.FX(i,r,t)$(t.val le 2021) = 0 ;
$if      set trans       IT.FX(k,r,rr,t)$(t.val le 2021) = 0 ;
$if      set storage     IG.FX(j,r,t)$(t.val le 2021) = 0 ;
$if not  set noinvbiofrictions IX.UP(bio(i),r,t)$(t.val le 2030 and t.val ge 2022) = sum(oldv(v), cap(i,v,r)) * nyrs(t) / 5 ;
$if not  set noinvccsfrictions IX.FX(ccs(i),r,t)$(t.val le 2030) = 0 ;
$if not  set noinvnucfrictions IX.FX(nuc(i),r,t)$(t.val le 2035 and not invlimLO(i,r,t) > 0) = 0 ;
* No transmission when not set transmission
$if not  set trans       IT.FX(k,r,rr,t) = 0 ;
$if not  set trans       E.FX(s,k,r,rr,t) = 0 ;
$if not  set trans       TC.FX(k,r,rr,t) = 0 ;
* No storage when not set storage
$if not  set storage     IG.FX(j,r,t) = 0 ;
$if not  set storage     G.FX(s,j,v,r,t) = 0 ;
$if not  set storage     GB.FX(s,j,v,r,t) = 0 ;
$if not  set storage     GC.FX(j,v,r,t) = 0 ;
$if not  set storage     GD.FX(s,j,v,r,t) = 0 ;
* Initial storage level should be empty
$if      set storage     GB.FX("1",j,v,r,t) = 0 ;
* Remove backstop unless explicitly allowed
$if not  set lostload    BS.FX(s,r,t) = 0 ;
* Upper bound on dedicated biomass supply (depends on biomass carbon price scenario)
$if      set biomark_r   DBSR.UP(dbclass,r,t)    = dblim_r(dbclass,r,t) ;
$if      set biomark     DBS.UP(dbclass,t)       = dblim(dbclass,t) ;
$if      set gasmark_r   NGSR.UP(ngclass,r,t)    = nglim_r(ngclass,r,t) ;
$if      set gasmark     NGS.UP(ngclass,t)       = nglim(ngclass,t) ;

* * * * * Model declaration and solution
model euregen /
objdef
* * * Demand equations
demand
$if set rsa                                      demand_rsa
* Generation
                                                 capacity
$if      set chp                                 generation                                               
$if      set chp                                 capacity_nochp
$if      set chp                                 capacity_chp
*MM (todo): The mustrun conditions lead to (numerical) infeasibilities in the moment (need to check)
$if      set mustrun                             capacity_bio
$if      set mustrun                             capacity_dsp
$if      set mustrun                             capacity_nsp
$if      set cofiring                            capacity_cofir
invest
exlife2020
                                                 exlife
$if      set chp                                 exlife_nochp
$if      set chp                                 exlife_chp
$if      set nodecombio                          exlife_bio
newlife
$if not  set myopic                              retire
investlimUP
investlimLO
$if      set limeu                               investlimUP_eu
investlimUP_irnw
* * * Storage
$if      set storage                             ginvest
$if      set storage                             gexlife
$if      set storage                             gexlife2020
$if      set storage   $if      set myopic       gexlife_pump
$if      set storage                             gnewlife
$if      set storage   $if not  set myopic       gretire
$if      set storage                             chargelim
$if      set storage                             dischargelim
$if      set storage                             storagebal
$if      set storage                             storagelim
$if      set storage                             ginvestlimUP
$if      set storage                             ginvestlimLO
$if      set storage   $if      set glimeu       ginvestlimUP_eu
* Transmission
$if      set trans                               tcapacity
$if      set trans                               tinvestexi
$if      set trans                               tinvestnew
$if      set trans                               tinvestlimUP
$if      set trans                               tinvestlimLO
$if      set trans     $if      set tlimeu       tinvestlimUP_eu
* Minimum dispatch
$if      set techmin                             capacity_techmin
$if      set techmin   $if      set stacost      eq_numonoffup
$if      set techmin   $if      set stacost      eq_numonofflo
* Ramping
$if      set ramping                             capacity_ramratepos
$if      set ramping                             capacity_ramrateneg
$if      set ramping                             capacity_rampdown
$if      set ramping                             capacity_rampup
* Biomass and naturgal gas markets
$if      set biomark                             biomarket
$if      set biomark_r                           biomarket_r
$if      set gasmark                             gasmarket
$if      set gasmark_r                           gasmarket_r
* Biomass, naturgal gas, and CCS markets (or limits)
$if      set biolim                              bioflow
*$if      set biolim2020                          cumbio2020
$if      set biolim                              cumbio
$if      set biolim_r                            bioflow_r
$if      set biolim_r                            cumbio_r
$if      set gaslim                              gasflow
$if      set gaslim                              cumgas
$if      set gaslim_r                            gasflow_r
$if      set gaslim_r                            cumgas_r
$if      set sclim                               cumccs
$if      set sclim                               ccsflow
$if      set sclim_r                             cumccs_r
$if      set sclim_r                             ccsflow_r
* CO2 market without MSR dynamic and w/o banking
$if      set co2mark_r                           co2flow_r
$if      set co2mark_r                           co2market_r
$if      set co2mark                             co2flow
$if      set co2mark   $if not  set banking      $if not  set indformula    co2market
$if      set co2mark   $if not  set banking      $if      set indformula    co2market_indformula
$if      set co2mark   $if      set banking      $if not  set indformula    co2marban
$if      set co2mark   $if      set banking      $if      set indformula    co2marban_indformula
$if      set co2mark   $if      set banking                                 co2tnac
* CO2 market with MSR dynamics via iterative modeling (only shortrun)
$if      set co2iter   $if      set shortrun     it_co2flow
$if      set co2iter   $if      set shortrun     $if not  set indformula    it_euets
$if      set co2iter   $if      set shortrun     $if      set indformula    it_euets_indformula
$if      set co2iter   $if      set shortrun     it_tnac
* CO2 market with MSR dynamics as simple as possible (only shortrun)
$if      set co2mips   $if      set shortrun     eqs_co2flow
$if      set co2mips   $if      set shortrun     $if not  set indformula    eqs_euets
$if      set co2mips   $if      set shortrun     $if      set indformula    eqs_euets_indformula
$if      set co2mips   $if      set shortrun     eqs_msrin2023
$if      set co2mips   $if      set shortrun     eqs_msrin
$if      set co2mips   $if      set shortrun     eqs_msrout2023
$if      set co2mips   $if      set shortrun     eqs_msrout
$if      set co2mips   $if      set shortrun     eqs_tnac
$if      set co2mips   $if      set shortrun     eqs_msr
$if      set co2mips   $if      set shortrun     eqs_cancel
$if      set co2mips   $if      set shortrun     eqs_tnacup
$if      set co2mips   $if      set shortrun     eqs_tnaclo
$if      set co2mips   $if      set shortrun     eqs_binary
* Policy
$if      set rnwtarget                           rnwtgtmarket
$if      set rnwtarget_r                         rnwtgtmarket_r
$if      set irnwtarget                          irnwtgtmarket
$if      set irnwtarget_r                        irnwtgtmarket_r
$if      set coalexit                            coalphaseout
$if      set coalexit_r                          coalphaseout_r
$if      set lignexit                            lignphaseout
$if      set lignexit_r                          lignphaseout_r
$if      set nucexit                             nucphaseout
$if      set nucexit_r                           nucphaseout_r
* * * Structural equations to aid solver
xtwhdef
copyxc
$if      set storage                             copygc
$if      set trans                               copytc
/;

* Intialize different CO2 markets to ensure report compiles even when the constraint is excluded
co2market_r.M(r,t)  = 0 ;
co2market.M(t)      = 0 ;
co2market_indformula.M(t)      = 0 ;
co2marban.M(t)      = 0 ;
co2marban_indformula.M(t)      = 0 ;
it_euets.M(t)       = 0 ;
it_euets_indformula.M(t)       = 0 ;
eqs_euets.M(t)      = 0 ;
eqs_euets_indformula.M(t)      = 0 ;

$if not set solver $set solver gurobi
*$if not set solver $set solver cplex
option lp=%solver% ;
option qcp=%solver% ;
option mip=%solver% ;
option rmip=%solver% ;
option miqcp=%solver% ;
option rmiqcp=%solver% ;

euregen.optfile = 1;
euregen.holdfixed = 1;
*euregen.reslim = 7200;
euregen.reslim = 1204800;
option solprint = on;

$if      set co2mips                      solve euregen using miqcp minimizing SURPLUS ;
$if      set techmin                      solve euregen using miqcp minimizing SURPLUS ;
$if not  set co2mips $if not  set techmin solve euregen using lp    minimizing SURPLUS ;

*Don't include report so that restart file can be used with modified report without re-running model

