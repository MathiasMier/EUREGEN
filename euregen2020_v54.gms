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

* * * Timeseries and calibration
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

alias(s,ss) ;


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
vrscincrease(i,v,r)
;

$gdxin database\setpar_%n%.gdx
$load hours, load_s, loadcorr, peakload=peakload_s, minload=minload_s, dref, daref, daref_s
$load vrsc_s, vrsccorr, irnwflh_h, irnwflh_s, number, irnwlimUP_quantiles, qshare, vrscincrease
$gdxin

* Correct time series to match annual load and full-load hours of renewables
$if      set corr_peak                          vrsc(s,i,v,r)$(vrsccorr(i,v,r) > 0) = round(min(vrsccorr(i,v,r) * vrsc_s(s,i,v,r)  * vrscincrease(i,v,r), 1), 4) + eps ;
$if      set corr_peak                          load(s,r)                           = round(min(loadcorr(r) * load_s(s,r), peakload(r)), 4) + eps ;

$if      set corr_full                          vrsc(s,i,v,r)$(vrsccorr(i,v,r) > 0) = round(vrsccorr(i,v,r) * vrsc_s(s,i,v,r) * vrscincrease(i,v,r), 4) + eps ;
$if      set corr_full                          load(s,r)                           = round(loadcorr(r) * load_s(s,r), 4) + eps ;

$if not  set corr_full $if not set corr_peak    vrsc(s,i,v,r)                       = round(vrsc_s(s,i,v,r) * vrscincrease(i,v,r), 4) + eps ;
$if not  set corr_full $if not set corr_peak    load(s,r)                           = round(load_s(s,r), 4) + eps ;



parameter
loadmax(r)
;

loadmax(r) = smax(s, load(s,r)) ;
peak(s,r) = YES$(load(s,r) eq loadmax(r)) ;

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
chp(i)
nochp(i)
mapchp(i,i)
;

$gdxin database\setpar_%n%.gdx
$load new, exi, dspt, ndsp, ccs, irnw, conv, sol, wind, windon, windoff, rnw, lowcarb, nuc, type, idef, gas, bio, chp, nochp, mapchp
$gdxin

iidef(i,type) = idef(i,type) ;
alias(i,ii) ;

parameter
cap_int(i,v,r)                   Capacity installed by region (GW)
cap(i,v,r)                       Capacity installed by region (GW)
invlimUP(i,r,t)                  Upper bounds on investment based on potential (cumulative since last time period) (GW)
invlimLO(i,r,t)                  Lower bounds on investment based on current pipeline (cumulative since last time period) (GW)
invlimUP_eu(i,t)                 Lower bounds on investment based on current pipeline (cumulative since last time period) (GW)
invlife(i,v)                     Capacity lifetime
invdepr(i,v)                     Investment depreciation
capcost_int(i,v,r)               Capacity cost (investment) by region
capcost(i,v,r)                   Capacity cost (investment) by region
fomcost_int(i,v,r)               Fixed OM cost
fomcost(i,v,r)                   Fixed OM cost
vomcost(i,v,r)                   Variable OM cost
effrate(i,v,r)                   Efficiency
co2captured_int(i,v,r)           CCS capture rate
co2captured(i,v,r)               CCS capture rate
emit_int(i,v,r)                  Emission factor
emit(i,v,r)                      Emission factor
reliability(i,v,r)               Reliability factor by region and technology
capcred(i,v,r)                   Capacity credit by region and technology
mindisp(i,v,r)                   Min load by region and technology
sclim_int(r)                     Upper bound on geologic storage of carbon (GtCO2)
sclim_eu_int                     Upper bound on geologic storage of carbon (GtCO2)
sclim(r)                         Upper bound on geologic storage of carbon (GtCO2)
sclim_eu                         Upper bound on geologic storage of carbon (GtCO2)
biolim_int(r,t)                  Upper bounds by region on biomass use (MWh)
biolim_eu_int(t)                 Upper bounds by region on biomass use (MWh)
biolim(r,t)                      Upper bounds by region on biomass use (MWh)
biolim_eu(t)                     Upper bounds by region on biomass use (MWh)
;

$gdxin database\setpar_%n%.gdx
$load cap_int=cap, invlimUP, invlimLO, invlimUP_eu, invlife, invdepr, capcost_int, fomcost_int=fomcost, vomcost, effrate, co2captured_int=co2captured, emit_int=emit, reliability, capcred, mindisp
$load sclim_int=sclim, sclim_eu_int=sclim_eu, biolim_int=biolim, biolim_eu_int=biolim_eu
$gdxin

capcost(i,v,r) = capcost_int(i,v,r) ;
$if      set scwindon10        capcost(windon(i),v,r) = 1.1 * capcost_int(i,v,r) ;
$if      set scwindon20        capcost(windon(i),v,r) = 1.2 * capcost_int(i,v,r) ;
$if      set scwindon30        capcost(windon(i),v,r) = 1.3 * capcost_int(i,v,r) ;
$if      set scwindon40        capcost(windon(i),v,r) = 1.4 * capcost_int(i,v,r) ;
$if      set scwindon50        capcost(windon(i),v,r) = 1.5 * capcost_int(i,v,r) ;
$if      set scwindon60        capcost(windon(i),v,r) = 1.6 * capcost_int(i,v,r) ;
$if      set scwindon70        capcost(windon(i),v,r) = 1.7 * capcost_int(i,v,r) ;
$if      set scwindon80        capcost(windon(i),v,r) = 1.8 * capcost_int(i,v,r) ;
$if      set scwindon90        capcost(windon(i),v,r) = 1.9 * capcost_int(i,v,r) ;
$if      set scwindon100        capcost(windon(i),v,r) = 2.0 * capcost_int(i,v,r) ;

cap(i,v,r) = cap_int(i,v,r) ;
$if not  set chp    cap(nochp(i),v,r)   = cap_int(i,v,r) + sum(mapchp(i,ii), cap_int(ii,v,r)) ;
$if not  set chp    cap(chp(i),v,r)     = 0 ;

* Correcting nuclear fix cost
fomcost(i,v,r) = fomcost_int(i,v,r) ;

set
rnonuc(r)
rnuc(r)
;

rnonuc(r)$(capcost("nuclear","2022",r) = 0) = YES ;
rnuc(r)$(capcost("nuclear","2022",r) > 0) = YES ;

$if     set nucall  capcost("Nuclear",newv(v),rnonuc)    	     = capcost("Nuclear",v,"France") ;
$if     set nucall  fomcost("Nuclear",newv(v),rnonuc)            = fomcost("Nuclear",v,"France") ;
$if     set nucall  vomcost("Nuclear",newv(v),rnonuc)            = vomcost("Nuclear",v,"France") ;
$if     set nucall  reliability("Nuclear",newv(v),rnonuc)        = reliability("Nuclear",v,"France") ;
$if     set nucall  effrate("Nuclear",newv(v),rnonuc)            = effrate("Nuclear",v,"France") ;
$if     set nucall  capcred("Nuclear",newv(v),rnonuc)            = capcred("Nuclear",v,"France") ;
$if     set nucall  invlimUP("Nuclear",rnonuc,t)$(t.val ge 2022) = invlimUP("Nuclear","France",t) ;

$if      set windoff10         fomcost(windoff(i),v,r) = 0.1 * fomcost_int(i,v,r) ;
$if      set windoff20         fomcost(windoff(i),v,r) = 0.2 * fomcost_int(i,v,r) ;
$if      set windoff30         fomcost(windoff(i),v,r) = 0.3 * fomcost_int(i,v,r) ;
$if      set windoff40         fomcost(windoff(i),v,r) = 0.4 * fomcost_int(i,v,r) ;
$if      set windoff50         fomcost(windoff(i),v,r) = 0.5 * fomcost_int(i,v,r) ;
$if      set windoff60         fomcost(windoff(i),v,r) = 0.6 * fomcost_int(i,v,r) ;
$if      set windoff70         fomcost(windoff(i),v,r) = 0.7 * fomcost_int(i,v,r) ; 
$if      set windoff80         fomcost(windoff(i),v,r) = 0.8 * fomcost_int(i,v,r) ;
$if      set windoff90         fomcost(windoff(i),v,r) = 0.9 * fomcost_int(i,v,r) ;

$if      set windoffcap        capcost(windoff(i),v,r)$(v.val ge 2025) = 0.95 * capcost_int(i,v,r) ;
$if      set windoffcap        capcost(windoff(i),v,r)$(v.val ge 2030) = 0.9 * capcost_int(i,v,r) ;
$if      set windoffcap        capcost(windoff(i),v,r)$(v.val ge 2035) = 0.85 * capcost_int(i,v,r) ;
$if      set windoffcap        capcost(windoff(i),v,r)$(v.val ge 2040) = 0.8 * capcost_int(i,v,r) ;
$if      set windoffcap        capcost(windoff(i),v,r)$(v.val ge 2045) = 0.75 * capcost_int(i,v,r) ;

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

$if      set bioliminterpol    biolim_eu(t) = round(0.25 * 0.5 * biolim_eu_int("2050") + (t.val - 2020)/30 * (0.5 * biolim_eu_int(t) - 0.25 * 0.5 * biolim_eu_int("2050")), 4) ;
$if      set nobiofrictions    biolim_eu(t) = biolim_eu_int(t) ;
$if      set bioliminterpol    biolim(r,t)  = round(biolim_int(r,t) * biolim_eu(t) / biolim_eu("2050"), 4) ;

* Correction of emission factors (calibration issue)
* Check CCS in database emit
emit(i,v,r)             = emit_int(i,v,r) ;
emit("Coal",v,r)        = 0.9 * emit_int("Coal",v,r) ;
emit("Coal_CCS",v,r)    = 0.9 * emit_int("Coal_CCS","2030",r) ;
emit("Lignite",v,r)     = 0.8 * emit_int("Lignite",v,r) ;
emit("Lignite_CCS",v,r) = 0.8 * emit_int("Lignite_CCS",v,r) ;
emit("Bioenergy",v,r)   = 0.8 * emit_int("Bioenergy",v,r) ;
emit("Bio_CCS",v,r)     = 0.8 * emit_int("Bio_CCS",v,r) ;

co2captured(i,v,r)              = 0.9 * co2captured_int(i,v,r) ;
co2captured("Lignite_CCS",v,r)  = 0.8 * co2captured_int("Lignite_CCS",v,r) ;
co2captured("Bio_CCS",v,r)      = 0.8 * co2captured_int("Bio_CCS",v,r) ;

* Correcting biomass emissions factors according to biomass neutral treatment (socially and politically questionable)    
$if      set bioneutral        emit("Bioenergy",v,r) = 0 ;
$if      set bioneutral        emit("Bio_CCS",v,r) = - co2captured("Bio_CCS",v,r) ;
$if      set bio66             emit("Bioenergy",v,r) = round(emit("Bioenergy",v,r) * 0.3333, 4) ;
$if      set bio66             emit("Bio_CCS",v,r)   = round(- co2captured("Bio_CCS",v,r) * 0.6667, 4) ;

      
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

ghours("Storage_ST",v,r) = 4 ;
ghours("Storage_LT",v,r) = 720 ;

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

tinvlimLO(k,r,rr,t)$(tinvlimLO(k,r,rr,t) < tcap(k,r,rr)) =  tcap(k,r,rr) ;
tinvlimUP(k,r,rr,t)$(tinvlimUP(k,r,rr,t) < tcap(k,r,rr)) =  tcap(k,r,rr) ;
tinvlimUP(k,r,rr,t)$(tinvlimUP(k,r,rr,t) < tinvlimLO(k,r,rr,t)) =  tcap(k,r,rr) ;

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
$if not  set myopic     $if set shortrun  tmyopic(t)     Optimization periods /2022,2023,2024,2025,2026,2027,2028,2029,2030,2035,2040,2045,2050/
$if not  set myopic     $if set shortlong tmyopic(t)     Optimization periods /2022,2023,2024,2025,2030,2035,2040,2045,2050/
$if not  set myopic     $if set longrun   tmyopic(t)     Optimization periods /2022,2025,2030,2035,2040,2045,2050/

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

$if     set nucall  lifetime_invi(inv,"Nuclear",newv(v),rnonuc,t)$(t.val ge 2022) = lifetime_invi(inv,"Nuclear",v,"France",t) ;

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

$if     set nucall  zeta(inv,"Nuclear",newv(v),rnonuc) = zeta(inv,"Nuclear",v,"France") ;

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
$if      set extension      $if     set shortrun    lifetime("Nuclear","1990","Germany",t)$(t.val ge 2023 and t.val le 2029) = lifetime("Nuclear","1990","Germany","2022") ;
$if      set streckbetrieb  $if     set shortrun    lifetime("Nuclear","1990","Germany","2023")                              = lifetime("Nuclear","1990","Germany","2022") ;
$if      set strext         $if     set shortrun    lifetime("Nuclear","1990","Germany",t)$(t.val ge 2023 and t.val le 2030) = lifetime("Nuclear","1990","Germany","2022") ;

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
$if      set long                               pfadd_rel(fuel,r,t) = pfadd_rel_int("long",fuel,r,t) ;

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

$if      set gergaslimit gaslim("Germany","2023") = 75 ;
$if      set gergaslimit gaslim("Germany","2024") = 100 ;

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

$ontext
ivrt("Hydro",newv(v),r,t)       = NO ;
ivrt("Lignite",newv(v),r,t)     = NO ;
ivrt("Lignite_CCS",newv(v),r,t) = NO ;
ivrt("Coal",newv(v),r,t)        = NO ;
ivrt("Coal_CCS",newv(v),r,t)    = NO ;
ivrt("OilOther",newv(v),r,t)    = NO ;
ivrt("Geothermal",newv(v),r,t)  = NO ;

ivrt("RoofPV_q90",newv(v),r,t)$(not sameas(r,"Spain"))    = NO ;
ivrt("RoofPV_q70",newv(v),r,t)$(not sameas(r,"Spain"))    = NO ;
ivrt("RoofPV_q50",newv(v),r,t)                            = NO ;
ivrt("RoofPV_q30",newv(v),r,t)                            = NO ;
ivrt("RoofPV_q10",newv(v),r,t)                            = NO ;

ivrt("OpenPV_q70",newv(v),r,t)$(not sameas(r,"Spain") or not sameas(r,"Italy") or not sameas(r,"Greece")) = NO ;
ivrt("OpenPV_q50",newv(v),r,t)$(not sameas(r,"Spain") or not sameas(r,"Italy") or not sameas(r,"Greece")) = NO ;
ivrt("OpenPV_q30",newv(v),r,t)                                                                            = NO ;
ivrt("OpenPV_q10",newv(v),r,t)                                                                            = NO ;

ivrt("WindOn_q50",newv(v),r,t)$(not sameas(r,"Denmark")) = NO ;
ivrt("WindOn_q30",newv(v),r,t)                           = NO ;
ivrt("WindOn_q10",newv(v),r,t)                           = NO ;

ivrt("WindOff_q70",newv(v),r,t)                          = NO ;
ivrt("WindOff_q50",newv(v),r,t)                          = NO ;
ivrt("WindOff_q30",newv(v),r,t)                          = NO ;
ivrt("WindOff_q10",newv(v),r,t)                          = NO ;

ivrt(i,v,r,t)$(t.val le 2021)                                    = NO ;
ivrt(ccs(i),newv(v),r,t)$(t.val le 2030)                         = NO ;
*ivrt(nuc(i),newv(v),r,t)$(sum(tt$(tt.val le t.val), invlimLO(i,r,tt)) eq 0 and t.val le 2030) = NO ;
$offtext
 
ivrt(i,v,r,t)$(not tmyopic(t))                                     = NO ;
ivrt("Lignite_CCS",v,r,t) = NO ;
     

* * Storage technologies (jvrt)
jvrt(j,v,r,t)$(gcap(j,v,r) * glifetime(j,v,r,t) or (newj(j) and newv(v) and glifetime(j,v,r,t)))                                        = YES ;
$if not  set storage     jvrt(j,v,r,t)                                                                                                  = NO ;
jvrt("Storage_ST",v,r,t)$(v.val le 2022)        = NO ;
jvrt("Storage_LT",v,r,t)$(v.val le 2030)        = NO ;
jvrt(j,v,r,t)$(not tmyopic(t))                  = NO ;

* * Transmission (tvrt)
tvrt(k,v,r,t)$(sum(tmap(k,r,rr), tlifetime(k,v,r,t)))                                                                                   = YES ;
$if not  set trans       tvrt(k,v,r,t)                                                                                                  = NO ;                                                      
tvrt(k,v,r,t)$(not tmyopic(t))                  = NO ;

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
* Determine true average load of each vintages and calibrate for ramping cost here
$if      set ramcost     * (1 + effloss(i,v,r) / 0.5 )
*        Regional adder absolute
*                         + (pfadd(fuel,r,t)$xfueli(fuel,i))$effrate(i,v,r)
*        CO2 price (includes benefits from negative emissions)
$if      set co2price    + emit(i,v,r) * co2p(t)
*        CCS costs (from capturing)
$if      set ccs         + round(co2captured(i,v,r) * ccscost(r,t), 8)
;


parameter
loss(r)         
loss_mon(m,r)   
af_int(i,r)       
af_mon(m,i,r)  
voll(r,t)       
voll_mon(m,r,t)
irnwflh2020(i,r)
loss2021(r)         
loss_mon2021(m,r)   
af2021_int(i,r)       
af_mon2021(m,i,r)
af_mon2022(m,i,r)
irnwflh2021(i,r)
af_mon_ivrt(m,i,v,r,t)
afnew(m,i,r,t)
;

$onUndf
$gdxin database\setpar_%n%.gdx
$load loss, loss_mon, af_int=af, af_mon, voll, voll_mon, irnwflh2020, af_mon_ivrt
$load loss2021, loss_mon2021, af2021_int=af2021, af_mon2021, irnwflh2021
$load af_mon2022, afnew
$gdxin

parameter
irnwflh_control(i,v,r)
vrsc_control(s,i,v,r)
vrsc_normali(s,i,v,r)
;

irnwflh_control(windon(i),v,r) = sum(s, hours(s) * vrsc(s,i,v,r)) ;
vrsc_control(s,windon(i),v,r) = vrsc(s,i,v,r) ;
vrsc_normali(s,windon(i),v,r)$(irnwflh_control(i,v,r) > 0) = vrsc(s,i,v,r) / irnwflh_control(i,v,r) ;

vrsc(s,windon(i),v,r)$(sameas(r,"Sweden")  and v.val eq 2020  and irnwflh_control(i,"2020",r) > 0) = vrsc_control(s,i,v,r) * irnwflh2020(i,r) / irnwflh_control(i,"2020",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(sameas(r,"Sweden")  and v.val ge 2021  and irnwflh_control(i,"2021",r) > 0) = vrsc_control(s,i,v,r) * irnwflh2021(i,r) / irnwflh_control(i,"2021",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(sameas(r,"Sweden")  and v.val le 2019  and irnwflh_control(i,"2020",r) > 0) = vrsc(s,i,"2020",r) ;

vrsc(s,windon(i),v,r)$(sameas(r,"Finland")  and v.val eq 2020 and irnwflh_control(i,"2020",r) > 0) = vrsc_control(s,i,v,r) * irnwflh2020(i,r) / irnwflh_control(i,"2020",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(sameas(r,"Finland")  and v.val ge 2021 and irnwflh_control(i,"2021",r) > 0) = vrsc_control(s,i,v,r) * irnwflh2021(i,r) / irnwflh_control(i,"2021",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(sameas(r,"Finland")  and v.val le 2019 and irnwflh_control(i,"2020",r) > 0) = vrsc(s,i,"2020",r) ;


vrsc(s,windon(i),v,r)$(                         v.val eq 2020 and irnwflh_control(i,"2020",r) > 0 and irnwflh_control(i,"2020",r) < irnwflh2020(i,r)) = vrsc_control(s,i,v,r) * irnwflh2020(i,r) / irnwflh_control(i,"2020",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(                         v.val ge 2021 and irnwflh_control(i,"2021",r) > 0 and irnwflh_control(i,"2021",r) < irnwflh2021(i,r)) = vrsc_control(s,i,v,r) * irnwflh2021(i,r) / irnwflh_control(i,"2021",r) * irnwflh_control(i,v,r) / irnwflh_control("WindOn_q90",v,r);
vrsc(s,windon(i),v,r)$(                         v.val le 2019 and irnwflh_control(i,"2020",r) > 0 and irnwflh_control(i,"2020",r) < irnwflh2020(i,r)) = vrsc(s,i,"2020",r) ;


voll(r,"2022") = 1000 ;
$if not  set longrun    voll(r,"2023") = 2000 ;
$if not  set longrun    voll(r,"2024") = 3000 ;
voll(r,"2025") = 4000 ;

* * * Availability factor matrix (too large to read in)
parameter
af(s,i,v,r,t)                Availability factor
;

* Set availability of old vintage nuclear, hydro, and bioenergy to zero 
af(s,ivrt(i,oldv(v),r,t))$(sameas(i,"Nuclear")) = 1 ;
af(s,ivrt(i,oldv(v),r,t))$(sameas(i,"Hydro")) = 1 ;
af(s,ivrt(i,oldv(v),r,t))$(sameas(i,"Bioenergy")) = 1 ;

* Set reliability of the very same vintage technologies to 1 (availability is only steered via availability)
reliability(i,oldv(v),r)$(sameas(i,"Nuclear") and cap(i,v,r) > 0)   = 1 ;
reliability(i,oldv(v),r)$(sameas(i,"Hydro") and cap(i,v,r) > 0)     = 1 ;
reliability(i,oldv(v),r)$(sameas(i,"Bioenergy") and cap(i,v,r) > 0) = 1 ;

* Set 2020, 2021, and 2022 availability to real world availability
af(s,ivrt(i,oldv(v),r,t))$(sameas(t,"2022") and sameas(i,"Nuclear")  )      = sum(sm(s,m), afnew(m,i,r,t)) ;
af(s,ivrt(i,oldv(v),r,t))$(sameas(t,"2022") and sameas(i,"Bioenergy"))      = sum(sm(s,m), afnew(m,i,r,t)) ;

* Set 2023+ availability to average of 2020 and 2021
af(s,ivrt(i,oldv(v),r,t))$(t.val ge 2023    and sameas(i,"Nuclear")  )      = round(sum(sm(s,m), (afnew(m,i,r,"2020") + afnew(m,i,r,"2021"))/2), 4) ;
af(s,ivrt(i,oldv(v),r,t))$(t.val ge 2023    and sameas(i,"Bioenergy"))      = round(sum(sm(s,m), (afnew(m,i,r,"2020") + afnew(m,i,r,"2021"))/2), 4) ;
* New hydro timeseries out of calibration data created above and now higher availability used in case necessary
$if     set newhydrotimeseries  vrsc(s,i,v,r)$(sameas(i,"Hydro") and cap(i,v,r) > 0) = round(sum(sm(s,m), afnew(m,i,r,"2020")/2 + afnew(m,i,r,"2021")/2), 4) ;

irnwflh_check(i,v,r) = sum(s, hours(s) * vrsc(s,i,v,r)) ;

* Set French nuclear availability in 2021 and 2022 equal to 2020 as what-if-not-case
$if     set frnucnormal     af(s,ivrt(i,oldv(v),r,t))$(t.val ge 2021 and t.val le 2022 and sameas(i,"Nuclear") and sameas(r,"France") and reliability(i,v,r) > 0) = af(s,i,v,r,"2020") ;
* Set French nuclear availability in 2023 as in 2022 as what-if-still-case
$if     set frnuc2023       af(s,ivrt(i,oldv(v),r,t))$(sameas(t,"2023")                and sameas(i,"Nuclear") and sameas(r,"France") and reliability(i,v,r) > 0) = af(s,i,v,r,"2022") ;
* Lower hydro availability according to reduced hydro availability in 2022
$if not set hydronormal     af(s,ivrt(i,oldv(v),r,t))$(sameas(t,"2022") and sameas(i,"Hydro") and reliability(i,v,r) > 0 and sum(sm(s,m), afnew(m,i,r,"2020") + afnew(m,i,r,"2021")) > 0) = round(sum(sm(s,m), afnew(m,i,r,"2022") / (afnew(m,i,r,"2020")/2 + afnew(m,i,r,"2021")/2)), 4) ;
* Assume that lower hydro availability prevails in 2023
$if     set hydro2023       af(s,ivrt(i,oldv(v),r,t))$(sameas(t,"2023") and sameas(i,"Hydro") and reliability(i,v,r) > 0 and sum(sm(s,m), afnew(m,i,r,"2020") + afnew(m,i,r,"2021")) > 0) = round(sum(sm(s,m), afnew(m,i,r,"2022") / (afnew(m,i,r,"2020")/2 + afnew(m,i,r,"2021")/2)), 4) ;
* Assume that lower hydro availability prevails forever
$if     set hydro20XX       af(s,ivrt(i,oldv(v),r,t))$(t.val ge 2023   and sameas(i,"Hydro") and reliability(i,v,r) > 0 and sum(sm(s,m), afnew(m,i,r,"2020") + afnew(m,i,r,"2021")) > 0) = round(sum(sm(s,m), afnew(m,i,r,"2022") / (afnew(m,i,r,"2020")/2 + afnew(m,i,r,"2021")/2)), 4) ;

parameter
af_mon2022_ger(m,i,r)
af_mon2023_ext(m,i,r)
af_mon2023_str(m,i,r)
af_mon2023_strext(m,i,r)
;

* German nuclear adjustments 
af_mon2022_ger(m,i,r)$(sameas(i,"Nuclear") and sameas(r,"Germany")) = afnew(m,i,r,"2022") * 2 ;
af_mon2023_ext(m,i,r)$(sameas(i,"Nuclear") and sameas(r,"Germany")) = afnew(m,i,r,"2020")/2 + afnew(m,i,r,"2021")/2 ;
af_mon2023_str("1","Nuclear","Germany") = 0.75 ;
af_mon2023_str("2","Nuclear","Germany") = 0.8  ;
af_mon2023_str("3","Nuclear","Germany") = 0.7  ;
af_mon2023_str("4","Nuclear","Germany") = 0.35  ;
af_mon2023_str(m,"Nuclear","Germany")$(m.val >= 5) = eps ;

af_mon2023_strext(m,i,r) = af_mon2023_str(m,i,r) ;

af_mon2023_strext(m,i,r)$(m.val ge 9 and sameas(i,"Nuclear") and sameas(r,"Germany")) = af_mon2023_ext(m,i,r) ;

af(s,ivrt("Nuclear","1990","Germany","2022"))$(reliability("Nuclear","1990","Germany") > 0) = sum(sm(s,m), af_mon2022_ger(m,"Nuclear","Germany")) + eps ;

$if      set extension      $if not set longrun af(s,ivrt("Nuclear","1990","Germany","2023"))$(reliability("Nuclear","1990","Germany") > 0) = sum(sm(s,m), af_mon2023_ext(m,"Nuclear","Germany")) + eps ; 
$if      set streckbetrieb  $if not set longrun af(s,ivrt("Nuclear","1990","Germany","2023"))$(reliability("Nuclear","1990","Germany") > 0) = sum(sm(s,m), af_mon2023_str(m,"Nuclear","Germany")) + eps ; 
$if      set strext         $if not set longrun af(s,ivrt("Nuclear","1990","Germany","2023"))$(reliability("Nuclear","1990","Germany") > 0) = sum(sm(s,m), af_mon2023_strext(m,"Nuclear","Germany")) + eps ;

$if      set af1 af(s,i,v,r,t)$(reliability(i,v,r) > 0) = 1 ;


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

* * * Declare Model
positive variable
* Demand
BS(s,r,t)               Lost load (backstop demand option) (GW)
* Generation
X(s,i,v,r,t)            Unit dispatch by segment (GW)
XTWH(i,v,r,t)           Annual generation for sparsity purposes (TWh)
XC(i,v,r,t)             Installed generation capacity (GW)
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
capacity_mus(s,i,v,r,t)          Generation capacity must-run 
capacity_chp(s,i,v,r,t)          CHP generation capacity
capacity_bio(s,i,v,r,t)          Generation capacity constraint on dispatch of bioenergy (to avoid implementing a subsidy on bioenergy)
capacity_dsp(s,i,v,r,t)          Dispatched capacity
capacity_nsp(s,i,v,r,t)          Non-dispatched capacity
capacity_cofir(s,i,r,t)          Coal and Lignite capacity can be dispatched with or without co-fire
invest(i,v,r,t)                  Accumulation of annual investment flows
exlife(i,v,r,t)                  Existing capacity including conversions
exlife2020(i,v,r,t)              Existing capacity in 2020 is fix
exlife_chp(i,v,r,t)
exlife2030_chp(i,v,r,t)
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
storagebal(s,j,v,r,t)            Storage balance accumulation seas tech
storagebalann(j,v,r,t)           Storage annual balance accumulation seas tech
storagebal_ps(s,j,v,r,t)         Storage balance accumulation PumpStorage
storagebal_ps0(s,j,v,r,t)        Storage balance accumulation PumpStorage
storagebalann_ps(j,v,r,t)        Storage annual balance accumulation PumpStorage 
storagebal_st(s,j,v,r,t)         Storage balance accumulation Battery peak gtech
storagebal_st0(s,j,v,r,t)        Storage balance accumulation Battery peak gtech
storagebalann_st(j,v,r,t)        Storage annual balance accumulation Battery 
storagebal_lt(s,j,v,r,t)         Storage balance accumulation seas tech
storagebal_lt0(s,j,v,r,t)        Storage balance accumulation seas tech
storagebalann_lt(j,v,r,t)        Storage annual balance accumulation Power-to-gas h
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
                 
* * * LBD: Learning-by-doing
set
i_del(i)         Technologies to exclude from the model
i_lea(i)         Technologies to learn
r_lea(r)         Regions to learn
ir_lea(i,r)      Technology region pair under learning
ls               Number of line segments
;

$gdxin database\setpar_%n%.gdx
$load i_del, i_lea, r_lea, ls
$gdxin

ir_lea(i,r) = YES$(i_lea(i) and r_lea(r)) ;

$if set learning capcost(i,v,r)$(i_lea(i)) = capcost_int(i,v,r) ;
$if set learning capcost(i_del(i),v,r) = 0 ;

$if set learning lifetime(i_del(i),v,r,t) = NO ;
$if set learning deprtime(i_del(i),v,r,t) = NO ;
$if set learning capcost(i_del(i),v,r)    = 0 ;
$if set learning vrsc(s,i_del(i),v,r)       = 0 ;
$if set learning invlimLO(i_del(i),r,t)   = 0 ;
$if set learning cap(i_del(i),v,r)        = 0 ;

parameter
ls_weight(ls)            Weight to determine breakpoints
delta_q_pa               Annual depreciation factor of the experience stock
delta_q                  Periodical depreciation factor of the experience stock
;

$gdxin database\setpar_%n%.gdx
$load ls_weight,delta_q_pa, delta_q
$gdxin

* * * Regional Learning-by-doing (LBD)
parameter
b_q(i,r)                 Learning rate from capacity (Q) expansion by technology and region
qFIRST(i,r)              First capacity stock unit (GW)
qSTART(i,r)              Initial capacity stock (GW)
qLAST(i,r)               Maximum capacity stock (GW)
qlsLO(i,r,ls)            Lower kink points of capacity stock (GW)
qlsUP(i,r,ls)            Upper kink points of capacity stock (GW)
capcost0(i,r)            Cost of the first unit installed (EUR per kW)
capcostFIRST(i,r)        Cost of the first unit installed (EUR per kW)
capcostSTART(i,r)        Cost of the first unit to install in 2020
capcostLAST(i,r)         Cost of the last possible unit installed (EUR per kW)
capcostLO(i,r,ls)        Cost of the units at the breakpoints
capcostUP(i,r,ls)        Cost of the units at the breakpoints
capcostAV(i,r,ls)        Cost of the units at the breakpoints
acc_capexFIRST(i,r)      First unit capacity stock accumulated cost (million)
acc_capexSTART(i,r)      Initial capacity stock accumulated cost (million)
acc_capexLAST(i,r)       Maximum capacity stock accumulated cost (million)
acc_capexLO(i,r,ls)      Lower kink points of capacity stock accumulated cost (million)
acc_capexUP(i,r,ls)      Upper kink points of capacity stock accumulated cost (million)
slope_lin(i,r)           Constant slope of linear approximated function (EUR per kW)
slope_mip(i,r,ls)        Slope of linear approximated function (EUR per kW)
test_slope(i,r,ls,*)     Difference to average (EUR per kW)
test_slope2(i,r,ls,*)    Average cost per line segment (EUR per kW)
;

$gdxin database\setpar_%n%.gdx
$load b_q,qFIRST,qSTART,qLAST,qlsLO,qlsUP,capcost0,capcostFIRST,capcostSTART,capcostLAST,capcostLO,capcostUP,capcostAV,acc_capexFIRST,acc_capexSTART,acc_capexLAST,acc_capexLO,acc_capexUP,slope_lin,slope_mip,test_slope,test_slope2
$gdxin


positive variable
CAPEX_CON(i,v,r)            Capacity cost of learning technologies (million)
CAPEX_NLP(i,v,r)            Capacity cost of learning technologies (million)
CAPEX_NLP_LEG(i,v,r)        Capacity cost of learning technologies (million)
CAPEX_MIP(i,v,r)            Capacity cost of learning technologies (trillion)
QTRY(i,r,t)                 Stock of accumulated capacity (TW)
QTRY_LEG(i,r,t)             Stock of accumulated legacy capacity (from previous periods) (TW)
QLS(i,r,t,ls)               Stock of capacity on line segment ls (TW)
QLS_LEG(i,r,t,ls)           Stock of legacy capacity (from previous periods) on line segment ls (TW)
ACC_CAPEX_NLP(i,r,t)        Accumulated capacity cost of learning technologies (million)
ACC_CAPEX_NLP_LEG(i,r,t)    Accumulated legacy capacity cost of learning technologies (million)
ACC_CAPEX_MIP(i,r,t)        Accumulated capacity cost of learning technologies (trillion)
ACC_CAPEX_MIP_LEG(i,r,t)    Accumulated legacy capacity cost of learning technologies (trillion)
;

binary variable
RHO(i,r,t,ls)                    Binary variable that reflects piecewise linear segment of learning curve
RHO_LEG(i,r,t,ls)                Binary variable that reflects piecewise linear segment of learning curve (for legacy capacity)
;

Equation
acc_q_recall2020(i,r,t)          Accumulation of capacity in 2015 (doing)
acc_q_leg_recall2020(i,r,t)      Accumulation of legacy capacity in 2015 (doing)
acc_q_recall(i,r,t)              Accumulation of capacity (doing)
acc_q_leg_recall(i,r,t)          Accumulation of legacy capacity (doing)
acc_q_continuous2020(i,r,t)      Accumulation of capacity in 2015 (doing)
acc_q_leg_continuous2020(i,r,t)  Accumulation of legacy capacity in 2015 (doing)
acc_q_continuous(i,r,t)          Accumulation of capacity (doing)
acc_q_leg_continuous(i,r,t)      Accumulation of legacy capacity (doing)
acc_q_discrete2020(i,r,t)        Accumulation of capacity in 2015 (doing)
acc_q_leg_discrete2020(i,r,t)    Accumulation of legacy capacity in 2015 (doing)
acc_q_discrete(i,r,t)            Accumulation of capacity (doing)
acc_q_leg_discrete(i,r,t)        Accumulation of legacy capacity (doing)
rho_mixedip(i,r,t)               Equation that enforeces one rho = 1
rho_leg_mixedip(i,r,t)           Equation that enforeces one rho = 1 (for legacy capacity)
capex_constant(i,v,r)            Equation that describes evolution of CAPEX
capex_nonlinear(i,v,r)           Equation that describes evolution of CAPEX
capex_mixedip(i,v,r)             Equation that describes evolution of CAPEX (trillion EUR)
acc_capex_nonlinear(i,r,t)       Equation that describes evolution of accumulated CAPEX
acc_capex_leg_nonlinear(i,r,t)   Equation that describes evolution of accumulated legacy CAPEX
acc_capex_mixedip(i,r,t)         Equation that describes evolution of accumulated CAPEX (trillion EUR)
acc_capex_leg_mixedip(i,r,t)     Equation that describes evolution of accumulated legacy CAPEX (trillion EUR)
qlsLO_mixedip(i,r,t,ls)          Equation that enforeces the lower bound of linear segment
qlsLO_leg_mixedip(i,r,t,ls)      Equation that enforeces the lower bound of linear segment (for legacy capacity)
qlsUP_mixedip(i,r,t,ls)          Equation that enforeces the upper bound of linear segment
qlsUP_leg_mixedip(i,r,t,ls)      Equation that enforeces the upper bound of linear segment (for legacy capacity)
acc_qls_mixedip(i,r,t)           Equation that describes evolution of QLS
acc_qls_leg_mixedip(i,r,t)       Equation that describes evolution of legacy QLS
* Try a monotonicity constraint to speed up problem (for perfect recall only)
acc_q_mono(i,r,t)                Does not allow to reduce learning capacity stock (for perfect recall)
acc_q_leg_mono(i,r,t)            Does not allow to reduce learning capacity stock (for perfect recall)
acc_q_max(i,r,t)                 Limits learning capacity stock to max value
acc_q_leg_max(i,r,t)             Limits learning capacity stock to max value
rho_mixedip_mono(i,r,t,ls)       Does not allow to move backwards for rho (for perfect recall)
rho_leg_mixedip_mono(i,r,t,ls)   Does not allow to move backwards for rho (for perfect recall)
qls_mixedip_mono(i,r,t)          Does not allow to move backwards for rho (for perfect recall)
qls_leg_mixedip_mono(i,r,t)      Does not allow to move backwards for rho (for perfect recall)
;

* * * Regional Learning-by-doing
* * Accumulated capacity stock (legacy capacity concept is used to account for the fact that some capacity depreciates between period t and t-1 and to thus become cost right)
* with perfect recall
acc_q_recall2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= qSTART(i,r) * 1e-3 ;
acc_q_leg_recall2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= QTRY(i,r,t) ;
acc_q_recall(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= qSTART(i,r) * 1e-3 + sum(tt$(tt.val le t.val), IX(i,r,tt)) * 1e-3 ;
acc_q_leg_recall(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= QTRY(i,r,t-1) ;

* with continuous depreciation
acc_q_continuous2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= sum(oldv(v), round(delta_q_pa**(t.val - v.val),4) * cap(i,v,r)) * 1e-3  ;
acc_q_leg_continuous2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= QTRY(i,r,t);
acc_q_continuous(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= QTRY(i,r,t-1) * round(delta_q_pa**nyrs(t),4) + IX(i,r,t) * 1e-3 ;                
acc_q_leg_continuous(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= QTRY(i,r,t-1) * round(delta_q_pa**nyrs(t),4) ;

* with discrete depreciation
acc_q_discrete2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= sum(oldv, deprtime(i,oldv,r,t) * cap(i,oldv,r)) * 1e-3 ;
acc_q_leg_discrete2020(i,r,t)$(t.val le 2022 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= QTRY(i,r,t);
acc_q_discrete(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)        =e= sum(oldv, deprtime(i,oldv,r,t) * cap(i,oldv,r)) * 1e-3 + sum(newv(v)$(v.val < t.val), deprtime(i,v,r,t) * sum(tv(tt,v), IX.L(i,r,tt))) * 1e-3 + IX.L(i,r,t) * 1e-3 ;
acc_q_leg_discrete(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)    =e= sum(oldv, deprtime(i,oldv,r,t) * cap(i,oldv,r)) * 1e-3 + sum(newv(v)$(v.val < t.val), deprtime(i,v,r,t) * sum(tv(tt,v), IX.L(i,r,tt))) * 1e-3 ;
  
* Try a monotonicity constraint to speed up problem (for perfect recall only)                 
acc_q_mono(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)       =g= QTRY(i,r,t-1) ;
acc_q_leg_mono(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)   =g= QTRY_LEG(i,r,t-1) ;
* Maximum values
acc_q_max(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY(i,r,t)       =l= qLAST(i,r) * 1e-3 ;
acc_q_leg_max(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..
                 QTRY_LEG(i,r,t)   =l= qLAST(i,r) * 1e-3 ;            

* * Unit cost
* Constant
capex_constant(i,newv(v),r)$(i_lea(i) and r_lea(r))..
                 CAPEX_CON(i,v,r)        =e= capcost(i,v,r) * sum(tv(t,v), IX(i,r,t)) ;
* Nonlinear
capex_nonlinear(i,newv(v),r)$(i_lea(i) and r_lea(r))..
$if      set leg CAPEX_NLP(i,v,r)        =e= sum(tv(t,v), ACC_CAPEX_NLP(i,r,t) - ACC_CAPEX_NLP_LEG(i,r,t)) ;
$if not  set leg CAPEX_NLP(i,v,r)        =e= sum(tv(t,v), ACC_CAPEX_NLP(i,r,t) - ACC_CAPEX_NLP(i,r,t-1)) ;

* MIP
capex_mixedip(i,newv(v),r)$(i_lea(i) and r_lea(r))..
$if      set leg CAPEX_MIP(i,v,r)        =e= sum(tv(t,v), ACC_CAPEX_MIP(i,r,t) - ACC_CAPEX_MIP_LEG(i,r,t)) ;
$if not  set leg CAPEX_MIP(i,v,r)        =e= sum(tv(t,v), ACC_CAPEX_MIP(i,r,t) - ACC_CAPEX_MIP(i,r,t-1)) ;

* * Accumulated cost (Constant unit cost does not demand for accumulation equations)
* Nonlinear
acc_capex_nonlinear(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 ACC_CAPEX_NLP(i,r,t)     =e= capcost0(i,r) / (1 + b_q(i,r)) * (QTRY(i,r,t)    *1e+9)**(1 + b_q(i,r)) * 1e-6 ;
acc_capex_leg_nonlinear(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 ACC_CAPEX_NLP_LEG(i,r,t) =e= capcost0(i,r) / (1 + b_q(i,r)) * (QTRY_LEG(i,r,t)*1e+9)**(1 + b_q(i,r)) * 1e-6 ;
* MIP
acc_capex_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 ACC_CAPEX_MIP(i,r,t)     =e= sum(ls, RHO(i,r,t,ls)     * acc_capexLO(i,r,ls) + slope_mip(i,r,ls) * (QLS(i,r,t,ls) * 1e+3     - qlsLO(i,r,ls) * RHO(i,r,t,ls))) * 1e-6 ;
acc_capex_leg_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 ACC_CAPEX_MIP_LEG(i,r,t) =e= sum(ls, RHO_LEG(i,r,t,ls) * acc_capexLO(i,r,ls) + slope_mip(i,r,ls) * (QLS_LEG(i,r,t,ls) * 1e+3 - qlsLO(i,r,ls) * RHO_LEG(i,r,t,ls))) * 1e-6 ;

* * Mixed integer variable rho and related equations
* This equation enforeces that always just one line segment is active
rho_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 sum(ls, RHO(i,r,t,ls))     =e= 1 ;
rho_leg_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 sum(ls, RHO_LEG(i,r,t,ls)) =e= 1 ;

* Capacity stock per line segment is greater than the lower bound of that line segment (Learning by doing)
qlsLO_mixedip(i,r,t,ls)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QLS(i,r,t,ls)           =g= qlsLO(i,r,ls) * RHO(i,r,t,ls) * 1e-3 ;
qlsLO_leg_mixedip(i,r,t,ls)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QLS_LEG(i,r,t,ls)       =g= qlsLO(i,r,ls) * RHO_LEG(i,r,t,ls)* 1e-3  ;

* Capacity stock per line segment is lower than the upper bound of that line segment (Learning by doing)
qlsUP_mixedip(i,r,t,ls)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QLS(i,r,t,ls)           =l= qlsUP(i,r,ls) * RHO(i,r,t,ls) * 1e-3 ;
qlsUP_leg_mixedip(i,r,t,ls)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QLS_LEG(i,r,t,ls)       =l= qlsUP(i,r,ls) * RHO_LEG(i,r,t,ls) * 1e-3 ;

* Capacity stock per "active" (rho = 1) line segment is equal to capacity stock  (Learning by doing)
acc_qls_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QTRY(i,r,t)             =e= sum(ls, QLS(i,r,t,ls)) ;
acc_qls_leg_mixedip(i,r,t)$(i_lea(i) and r_lea(r)and tmyopic(t))..
                 QTRY_LEG(i,r,t)         =e= sum(ls, QLS_LEG(i,r,t,ls)) ;
                                  
* Try a monotonicity constraint to speed up problem (for perfect recall only)
rho_mixedip_mono(i,r,t,ls)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..              
                 RHO(i,r,t,ls) =g= RHO(i,r,t-1,ls) ;
rho_leg_mixedip_mono(i,r,t,ls)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..              
                 RHO_LEG(i,r,t,ls) =g= RHO_LEG(i,r,t-1,ls) ;
                 
* Try a monotonicity constraint to speed up problem (for perfect recall only)
qls_mixedip_mono(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..              
                 sum(ls, QLS(i,r,t,ls)) =g= sum(ls, QLS(i,r,t-1,ls)) ;
qls_leg_mixedip_mono(i,r,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i) and r_lea(r))..              
                 sum(ls, QLS_LEG(i,r,t,ls)) =g= sum(ls, QLS_LEG(i,r,t-1,ls)) ;  


* * * European Learning-by-doing
parameter
b_qeur(i)                 Learning rate from capacity (Q) expansion by technology and region
qeurFIRST(i)              First capacity stock unit (GW)
qeurSTART(i)              Initial capacity stock (GW)
qeurLAST(i)               Maximum capacity stock (GW)
qeurlsLO(i,ls)            Lower kink points of capacity stock (GW)
qeurlsUP(i,ls)            Upper kink points of capacity stock (GW)
capcosteur0(i)            Cost of the first unit installed (EUR per kW)
capcosteurFIRST(i)        Cost of the first unit installed (EUR per kW)
capcosteurSTART(i)        Cost of the first unit to install in 2020
capcosteurLAST(i)         Cost of the last possible unit installed (EUR per kW)
capcosteurLO(i,ls)        Cost of the units at the breakpoints
capcosteurUP(i,ls)        Cost of the units at the breakpoints
capcosteurAV(i,ls)        Cost of the units at the breakpoints
acc_capexeurFIRST(i)      First unit capacity stock accumulated cost (million)
acc_capexeurSTART(i)      Initial capacity stock accumulated cost (million)
acc_capexeurLAST(i)       Maximum capacity stock accumulated cost (million)
acc_capexeurLO(i,ls)      Lower kink points of capacity stock accumulated cost (million)
acc_capexeurUP(i,ls)      Upper kink points of capacity stock accumulated cost (million)
slopeeur_lin(i)           Constant slope of linear approximated function (EUR per kW)
slopeeur_mip(i,ls)        Slope of linear approximated function (EUR per kW)
test_slopeeur(i,ls,*)     Difference to average (EUR per kW)
test_slopeeur2(i,ls,*)    Average cost per line segment (EUR per kW)
;


$gdxin database\setpar_%n%.gdx
$load b_qeur,qeurFIRST,qeurSTART,qeurLAST,qeurlsLO,qeurlsUP,capcosteur0,capcosteurSTART,capcosteurLAST,capcosteurLO,capcosteurUP,capcosteurAV,acc_capexeurFIRST,acc_capexeurSTART,acc_capexeurLAST,acc_capexeurLO,acc_capexeurUP,slopeeur_lin,slopeeur_mip,test_slopeeur,test_slopeeur2
$gdxin

positive variable
CAPEXEUR_CON(i,v)           Capacity cost of learning technologies (million)
CAPEXEUR_NLP(i,v)           Capacity cost of learning technologies (million)
CAPEXEUR_NLP_LEG(i,v)       Capacity cost of learning technologies (million)
CAPEXEUR_MIP(i,v)           Capacity cost of learning technologies (trillion)
QTRYEUR(i,t)                Stock of accumulated capacity (TW)
QTRYEUR_LEG(i,t)            Stock of accumulated legacy capacity (from previous periods) (TW)
QEURLS(i,t,ls)              Stock of capacity on line segment ls (TW)
QEURLS_LEG(i,t,ls)          Stock of legacy capacity (from previous periods) on line segment ls (TW)
ACC_CAPEXEUR_NLP(i,t)       Accumulated capacity cost of learning technologies (million)
ACC_CAPEXEUR_NLP_LEG(i,t)   Accumulated legacy capacity cost of learning technologies (million)
ACC_CAPEXEUR_MIP(i,t)       Accumulated capacity cost of learning technologies (trillion)
ACC_CAPEXEUR_MIP_LEG(i,t)   Accumulated legacy capacity cost of learning technologies (trillion)
;

binary variable
RHOEUR(i,t,ls)                   Binary variable that reflects piecewise linear segment of learning curve (for European metric)
RHOEUR_LEG(i,t,ls)               Binary variable that reflects piecewise linear segment of learning curve (for legacy capacity)
;

Equation
* European Learning-by-doing
acc_qeur_recall2020(i,t)         Accumulation of capacity in 2015 in Europe (doing)
acc_qeur_leg_recall2020(i,t)     Accumulation of legacy capacity in 2015 in Europe (doing)
acc_qeur_recall(i,t)             Accumulation of capacity in Europe (doing)
acc_qeur_leg_recall(i,t)         Accumulation of legacy capacity in Europe (doing)
acc_qeur_continuous2020(i,t)     Accumulation of capacity in 2015 in Europe (doing)
acc_qeur_leg_continuous2020(i,t) Accumulation of legacy capacity in 2015 in Europe (doing)
acc_qeur_continuous(i,t)         Accumulation of capacity in Europe (doing)
acc_qeur_leg_continuous(i,t)     Accumulation of legacy capacity in Europe (doing)
acc_qeur_discrete2020(i,t)       Accumulation of capacity in 2015 in Europe (doing)
acc_qeur_leg_discrete2020(i,t)   Accumulation of legacy capacity in 2015 in Europe (doing)
acc_qeur_discrete(i,t)           Accumulation of capacity in Europe (doing)
acc_qeur_leg_discrete(i,t)       Accumulation of legacy capacity in Europe (doing)
rhoeur_mixedip(i,t)              Equation that enforeces one rho = 1 in Europe
rhoeur_leg_mixedip(i,t)          Equation that enforeces one rho = 1 in Europe (for legacy capacity)
capexeur_constant(i,v)           Equation that describes evolution of CAPEX in Europe
capexeur_nonlinear(i,v)          Equation that describes evolution of CAPEX in Europe
capexeur_mixedip(i,v)            Equation that describes evolution of CAPEX in Europe (trillion EUR)
acc_capexeur_nonlinear(i,t)      Equation that describes evolution of accumulated CAPEX in Europe
acc_capexeur_leg_nonlinear(i,t)  Equation that describes evolution of accumulated legacy CAPEX in Europe
acc_capexeur_mixedip(i,t)        Equation that describes evolution of accumulated CAPEX in Europe (trillion EUR)
acc_capexeur_leg_mixedip(i,t)    Equation that describes evolution of accumulated legacy CAPEX in Europe (trillion EUR)
qeurlsLO_mixedip(i,t,ls)         Equation that enforeces the lower bound of linear segment in Europe
qeurlsLO_leg_mixedip(i,t,ls)     Equation that enforeces the lower bound of linear segment in Europe (for legacy capacity)
qeurlsUP_mixedip(i,t,ls)         Equation that enforeces the upper bound of linear segment in Europe
qeurlsUP_leg_mixedip(i,t,ls)     Equation that enforeces the upper bound of linear segment in Europe (for legacy capacity)
acc_qeurls_mixedip(i,t)          Equation that describes evolution of QLS in Europe
acc_qeurls_leg_mixedip(i,t)      Equation that describes evolution of legacy QLS in Europe
* Try a monotonicity constraint to speed up problem (for perfect recall only)
acc_qeur_mono(i,t)               Does not allow to reduce learning capacity stock (for perfect recall)
acc_qeur_leg_mono(i,t)           Does not allow to reduce learning capacity stock (for perfect recall)
acc_qeur_max(i,t)                Limits learning capacity stock to max value
acc_qeur_leg_max(i,t)            Limits learning capacity stock to max value
rhoeur_mixedip_mono(i,t)         Does not allow to move backwards for rho (for perfect recall)
rhoeur_leg_mixedip_mono(i,t)     Does not allow to move backwards for rho (for perfect recall)
qeurls_mixedip_mono(i,t)         Does not allow to move backwards for rho (for perfect recall)
qeurls_leg_mixedip_mono(i,t)     Does not allow to move backwards for rho (for perfect recall)
;
* * Accumulated capacity stock (legacy capacity concept is used to account for the fact that some capacity depreciates between period t and t-1 and to thus become cost right)
* with perfect recall
acc_qeur_recall2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= qeurSTART(i) * 1e-3 ;
acc_qeur_leg_recall2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= QTRYEUR(i,t) ;
acc_qeur_recall(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= qeurSTART(i) * 1e-3 + sum(tt$(tt.val le t.val), sum(r, IX(i,r,tt))) * 1e-3  ;
acc_qeur_leg_recall(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= QTRYEUR(i,t-1) ;   

* with continuous depreciation
acc_qeur_continuous2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= sum(oldv(v), round(delta_q_pa**(t.val - v.val),4) * sum(r, cap(i,v,r))) * 1e-3 ;
acc_qeur_leg_continuous2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= QTRYEUR(i,t);
acc_qeur_continuous(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= QTRYEUR(i,t-1) * round(delta_q_pa**nyrs(t),4) + sum(r, IX(i,r,t)) * 1e-3 ;
acc_qeur_leg_continuous(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= QTRYEUR(i,t-1) * round(delta_q_pa**nyrs(t),4) ;

* with discrete depreciation
acc_qeur_discrete2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= sum(oldv, sum(r, deprtime(i,oldv,r,t) * cap(i,oldv,r))) * 1e-3 ;
acc_qeur_leg_discrete2020(i,t)$(t.val le 2022 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= QTRYEUR(i,t);
acc_qeur_discrete(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)        =e= sum(oldv, sum(r, deprtime(i,oldv,r,t) * cap(i,oldv,r))) * 1e-3 + sum(newv(v)$(v.val < t.val), sum(r, deprtime(i,v,r,t) * sum(tv(tt,v), IX(i,r,tt)))) * 1e-3 + sum(r, IX(i,r,t)) * 1e-3 ;
acc_qeur_leg_discrete(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)    =e= sum(oldv, sum(r, deprtime(i,oldv,r,t) * cap(i,oldv,r))) * 1e-3 + sum(newv(v)$(v.val < t.val), sum(r, deprtime(i,v,r,t) * sum(tv(tt,v), IX(i,r,tt)))) * 1e-3 ;

* Try a monotonicity constraint to speed up problem (for perfect recall only)                 
acc_qeur_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)       =g= QTRYEUR(i,t-1) ;
acc_qeur_leg_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)   =g= QTRYEUR_LEG(i,t-1) ;
* Maximum values
acc_qeur_max(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR(i,t)       =l= qeurLAST(i) * 1e-3 ;
acc_qeur_leg_max(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..
                 QTRYEUR_LEG(i,t)   =l= qeurLAST(i) * 1e-3 ;   

* * Unit cost
* Constant
capexeur_constant(i,newv(v))$(i_lea(i))..
                 CAPEXEUR_CON(i,v)        =e= sum(r, capcost(i,v,r) * sum(tv(t,v), IX(i,r,t))) ;
* Nonlinear
capexeur_nonlinear(i,newv(v))$(i_lea(i))..
$if      set leg CAPEXEUR_NLP(i,v)        =e= sum(tv(t,v), ACC_capexeur_NLP(i,t) - ACC_capexeur_NLP_LEG(i,t)) ;
$if not  set leg CAPEXEUR_NLP(i,v)        =e= sum(tv(t,v), ACC_capexeur_NLP(i,t) - ACC_capexeur_NLP(i,t-1)) ;
* MIP
capexeur_mixedip(i,newv(v))$(i_lea(i))..
$if      set leg CAPEXEUR_MIP(i,v)        =e= sum(tv(t,v), ACC_capexeur_MIP(i,t) - ACC_capexeur_MIP_LEG(i,t)) ;
$if not  set leg CAPEXEUR_MIP(i,v)        =e= sum(tv(t,v), ACC_capexeur_MIP(i,t) - ACC_capexeur_MIP(i,t-1)) ;

* * Accumulated cost (Constant unit cost does not demand for accumulation equations)
* Nonlinear
acc_capexeur_nonlinear(i,t)$(i_lea(i) and tmyopic(t))..
                 ACC_capexeur_NLP(i,t)     =e= capcosteur0(i) / (1 + b_qeur(i)) * (QTRYEUR(i,t)    *1e+9)**(1 + b_qeur(i)) * 1e-6 ;
acc_capexeur_leg_nonlinear(i,t)$(i_lea(i) and tmyopic(t))..
                 ACC_capexeur_NLP_LEG(i,t) =e= capcosteur0(i) / (1 + b_qeur(i)) * (QTRYEUR_LEG(i,t)*1e+9)**(1 + b_qeur(i)) * 1e-6 ;
* MIP
acc_capexeur_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 ACC_capexeur_MIP(i,t)     =e= sum(ls, RHOEUR(i,t,ls)     * acc_capexeurLO(i,ls) + slopeeur_mip(i,ls) * (QEURLS(i,t,ls)  * 1e+3     - qeurlsLO(i,ls) * RHOEUR(i,t,ls))) * 1e-6 ;
acc_capexeur_leg_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 ACC_capexeur_MIP_LEG(i,t) =e= sum(ls, RHOEUR_LEG(i,t,ls) * acc_capexeurLO(i,ls) + slopeeur_mip(i,ls) * (QEURLS_LEG(i,t,ls) * 1e+3  - qeurlsLO(i,ls) * RHOEUR_LEG(i,t,ls))) * 1e-6 ;

* * Mixed integer variable rho and related equations
* This equation enforeces that always just one line segment is active
rhoeur_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 sum(ls, RHOEUR(i,t,ls))     =e= 1 ;
rhoeur_leg_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 sum(ls, RHOEUR_LEG(i,t,ls)) =e= 1 ;
                 
* Capacity stock per line segment is greater than the lower bound of that line segment (Learning by doing)
qeurlsLO_mixedip(i,t,ls)$(i_lea(i) and tmyopic(t))..
                 QEURLS(i,t,ls)           =g= qeurlsLO(i,ls) * RHOEUR(i,t,ls) * 1e-3 ;
qeurlsLO_leg_mixedip(i,t,ls)$(i_lea(i) and tmyopic(t))..
                 QEURLS_LEG(i,t,ls)       =g= qeurlsLO(i,ls) * RHOEUR_LEG(i,t,ls) * 1e-3 ;

* Capacity stock per line segment is lower than the upper bound of that line segment (Learning by doing)
qeurlsUP_mixedip(i,t,ls)$(i_lea(i) and tmyopic(t))..
                 QEURLS(i,t,ls)           =l= qeurlsUP(i,ls) * RHOEUR(i,t,ls) * 1e-3 ;
qeurlsUP_leg_mixedip(i,t,ls)$(i_lea(i) and tmyopic(t))..
                 QEURLS_LEG(i,t,ls)       =l= qeurlsUP(i,ls) * RHOEUR_LEG(i,t,ls) * 1e-3  ;

* Capacity stock per "active" (rho = 1) line segment is equal to capacity stock  (Learning by doing)
acc_qeurls_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 QTRYEUR(i,t)             =e= sum(ls, QEURLS(i,t,ls)) ;
acc_qeurls_leg_mixedip(i,t)$(i_lea(i) and tmyopic(t))..
                 QTRYEUR_LEG(i,t)         =e= sum(ls, QEURLS_LEG(i,t,ls)) ;
                 
* Try a monotonicity constraint to speed up problem (for perfect recall only)
rhoeur_mixedip_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..              
                 sum(ls, RHOEUR(i,t,ls)) =g= sum(ls, RHOEUR(i,t-1,ls)) ;
rhoeur_leg_mixedip_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..              
                 sum(ls, RHOEUR_LEG(i,t,ls)) =g= sum(ls, RHOEUR_LEG(i,t-1,ls)) ; 
                 
* Try a monotonicity constraint to speed up problem (for perfect recall only)
qeurls_mixedip_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..              
                 sum(ls,QEURLS(i,t,ls)) =g= sum(ls, QEURLS(i,t-1,ls)) ;
qeurls_leg_mixedip_mono(i,t)$(t.val ge 2023 and tmyopic(t) and i_lea(i))..              
                 sum(ls, QEURLS_LEG(i,t,ls)) =g= sum(ls, QEURLS_LEG(i,t-1,ls)) ;  
                 
* Monotonicity (for perfect recall)
* Make cutting  plans to reduce feasible space (because come feasible space is not really feasible) ... makes LP relaxation outcome (corner solution) to a actually feasible solution
* mixed integer rounding cut
* clique cut
* disjunction cut
* gurobi callback function
* try to remove constraint ?! when the model keeps as it is, then you know that there are not relevant
* use feasible relax feature
* try mipfocus 2 or 3 (tighten formulation)

* * * R&D: Learning-by-lbs
set
ki_del(i)         Technologies to exclude from the model
ki_lea(i)         Technologies to learn
kr_lea(r)         Regions to learn
kir_lea(i,r)      Technology region pair under learning
kls               Number of line segments
;

$gdxin database\setpar_%n%.gdx
$load ki_del, ki_lea, kr_lea, kls
$gdxin


parameter
kcapcost(i,v,r)
kls_weight(kls)          Weight to determine breakpoints
delta_k_pa               Annual depreciation factor of the experience stock
delta_k                  Periodical depreciation factor of the experience stock
;

$gdxin database\setpar_%n%.gdx
$load kls_weight,delta_k_pa, delta_k, kcapcost
$gdxin


* * * Regional Learning-by-lbs
parameter
b_k(i,r)                 Learning rate from capacity (Q) expansion by technology and region
kFIRST(i,r)              First capacity stock unit (GW)
kSTART(i,r)              Initial capacity stock (GW)
kLAST(i,r)               Maximum capacity stock (GW)
klsLO(i,r,kls)           Lower kink points of capacity stock (GW)
klsUP(i,r,kls)           Upper kink points of capacity stock (GW)
kcapcost0(i,r)           Cost of the first unit installed (EUR per kW)
kcapcostFIRST(i,r)       Cost of the first unit installed (EUR per kW)
kcapcostSTART(i,r)       Cost of the first unit to install in 2020
kcapcostLAST(i,r)        Cost of the last possible unit installed (EUR per kW)
kcapcostLO(i,r,kls)      Cost of the units at the breakpoints
kcapcostUP(i,r,kls)      Cost of the units at the breakpoints
kcapcostAV(i,r,kls)      Cost of the units at the breakpoints
kacc_capexFIRST(i,r)     First unit capacity stock accumulated cost (million)
kacc_capexSTART(i,r)     Initial capacity stock accumulated cost (million)
kacc_capexLAST(i,r)      Maximum capacity stock accumulated cost (million)
kacc_capexLO(i,r,kls)    Lower kink points of capacity stock accumulated cost (million)
kacc_capexUP(i,r,kls)    Upper kink points of capacity stock accumulated cost (million)
kslope_lin(i,r)          onstant slope of linear approximated function (EUR per kW)
kslope_mip(i,r,kls)      Slope of linear approximated function (EUR per kW)
ktest_slope(i,r,kls,*)   Difference to average (EUR per kW)
ktest_slope2(i,r,kls,*)  Average cost per line segment (EUR per kW)
rd_budget(i,r,t)         RD budget (million EUR)
kspillover(i,r,r)        Spillover from r to r
k_exo(i,r,v)
;

$gdxin database\setpar_%n%.gdx
$load b_k,kFIRST,kSTART,kLAST,klsLO,klsUP,kcapcost0,kcapcostFIRST,kcapcostSTART,kcapcostLAST,kcapcostLO,kcapcostUP,kcapcostAV,kacc_capexFIRST,kacc_capexSTART,kacc_capexLAST,kacc_capexLO,kacc_capexUP,kslope_lin,kslope_mip,ktest_slope,ktest_slope2,rd_budget
$load kspillover
$load k_exo
$gdxin

kir_lea(i,r) = YES$(kcapcost0(i,r) > 0) ;

$if      set lbs    capcost(i,v,r)$(ki_lea(i)) = kcapcost(i,v,r) ;
$if      set lbseur capcost(i,v,r)$(kir_lea(i,r)) = kcapcost(i,v,r) ;
$if      set lbsbenchmark   capcost(i,v,r)$(kir_lea(i,r)) = kcapcost(i,v,r) ;


positive variable
KTRY(i,r,t)                 Stock of accumulated R&D spendings (million)
KQLS(i,r,t,kls)             Stock of accumulated R&D spendings on line segment kls  (million)
IK(i,r,t)                   R&D investments (million)
KCAPCOST_MIP(i,r,t)         Per unit capacity cost of learning technologies (1000 EUR per kW)
KCAPEX_MIP(i,v,r)           Capacity cost of learning technologies (billion EUR)
IXLS(i,r,t,kls)             Variable that replaces the nonlinear product IX*RHO as part of a linearisation strategy
;

$if set kfixrdinvest IK.FX(i,r,t) = rd_budget(i,r,t) ;

binary variable
KRHO(i,r,t,kls)                    Binary variable that reflects piecewise linear segment of learning curve
;

equation
* Regional Learning-by-Searching
acc_k_continuous2020(i,r,t)      Accumulation of R&D (lbs)
acc_k_continuous(i,r,t)          Accumulation of R&D (lbs)
rho_mixedip_k(i,r,t)             Equation that enforeces one rho = 1
capex_mixedip_k(i,v,r)           Equation that describes evolution of CAPEX
capex_mixedip_k2020(i,v,r)
lbs_helper1(i,r,t,kls)     Equation that helps to linearise the nonlinear product IX*RHO
lbs_helper2(i,r,t,kls)     Equation that helps to linearise the nonlinear product IX*RHO
lbs_helper3(i,r,t,kls)     Equation that helps to linearise the nonlinear product IX*RHO
lbs_helper4(i,r,t,kls)     Equation that helps to linearise the nonlinear product IX*RHO
capcost_mixedip_k(i,r,t)         Equation that describes the evolution of capacity cost
klsLO_mixedip(i,r,t,kls)         Equation that enforeces the lower bound of linear segment
klsUP_mixedip(i,r,t,kls)         Equation that enforeces the upper bound of linear segment
acc_kls_mixedip(i,r,t)           Equation that describes evolution of KQLS
;

parameter
tspillover(i,i)
;

tspillover("WindOn_q90","WindOff_q90") = 0 ;
tspillover("WindOff_q90","WindOn_q90") = 0 ;

$if set fulltechspillover   tspillover("WindOn_q90","WindOff_q90") = 1 ;
$if set fulltechspillover   tspillover("WindOff_q90","WindOn_q90") = 1 ;
$if set halftechspillover   tspillover("WindOn_q90","WindOff_q90") = 0.5 ;
$if set halftechspillover   tspillover("WindOff_q90","WindOn_q90") = 0.5 ;
$if set quartechspillover   tspillover("WindOn_q90","WindOff_q90") = 0.25 ;
$if set quartechspillover   tspillover("WindOff_q90","WindOn_q90") = 0.25 ;

parameter
kspillover_int(i,r,r)
;

kspillover_int(i,r,rr) = kspillover(i,r,rr) ;
$if set spill2  kspillover(i,r,rr) = 2  * kspillover_int(i,r,rr) ;
$if set spill5  kspillover(i,r,rr) = 5  * kspillover_int(i,r,rr) ;

* * * Global learning-by-doing
* We use the European metric but "add" an exogenous assumption about rest-of-the-world (ROW) capacity

* * * Regional Learning-by-Searching
* Accumulation of knowledge stock
acc_k_continuous2020(i,r,t)$(t.val le 2022 and tmyopic(t) and kir_lea(i,r))..
                 KTRY(i,r,t)       =e=    k_exo(i,r,"2022")             
                 ;
                 
acc_k_continuous(i,r,t)$(t.val ge 2023 and tmyopic(t) and kir_lea(i,r) and not sameas(t,"2050"))..
                 KTRY(i,r,t)       =e=    KTRY(i,r,t-1) * round(delta_k_pa**nyrs(t),4) + IK(i,r,t) * nyrs(t)
$if set spillover                  + sum(rr, IK(i,rr,t) * kspillover(i,r,rr))
$if set techspillover              + sum(ii, IK(ii,r,t) * tspillover(i,ii))    
                 ;
* * * Assume nonlinear unit cost (leads to NLP)
* Comment/ToDo JA: Add NLP implementation for learning by lbs

* * * Assume MIP approximation of NLP problem
* Capacity cost follow from the investment on a line segment and the slope of this line segment
capex_mixedip_k2020(i,v,r)$(sameas(v,"2022") and kir_lea(i,r))..
                 KCAPEX_MIP(i,v,r)        =e=  sum(tv(t,v), IX(i,r,t)) * capcost(i,v,r) ;
capex_mixedip_k(i,v,r)$(v.val ge 2023 and kir_lea(i,r))..
                 KCAPEX_MIP(i,v,r)        =e=  sum(tv(t,v), sum(kls, IXLS(i,r,t,kls) * kslope_mip(i,r,kls))) ;
* Additional constraints in order to linearise IX*RHO, which is replaced by a new helper variable IXLS above
* RHO of t-1 to realise the time lag of one period until the cost degressions materialise
lbs_helper1(i,r,t,kls)$(t.val ge 2023 and tmyopic(t) and kir_lea(i,r))..
                 IXLS(i,r,t,kls)          =l=     200 * KRHO(i,r,t-1,kls) ;
lbs_helper2(i,r,t,kls)$(t.val ge 2023 and tmyopic(t) and kir_lea(i,r))..
                 IXLS(i,r,t,kls)          =l=     IX(i,r,t) ;
lbs_helper3(i,r,t,kls)$(t.val ge 2023 and tmyopic(t) and kir_lea(i,r))..
                 IXLS(i,r,t,kls)          =g=     IX(i,r,t) - 200 * (1 - KRHO(i,r,t-1,kls)) ;
lbs_helper4(i,r,t,kls)$(t.val ge 2023 and tmyopic(t) and kir_lea(i,r))..
                 IXLS(i,r,t,kls)          =g=     0 ;
* Capacity cost follow from the linear approximation of the learning curve (Learning by lbs) (just placeholder equation, maybe delete later)
capcost_mixedip_k(i,r,t)$(kir_lea(i,r) and t.val ge 2023 and tmyopic(t))..
                 KCAPCOST_MIP(i,r,t)             =e= sum(kls, KRHO(i,r,t-1,kls) * kslope_mip(i,r,kls) ) ;
* This equation enforeces that always just one line segment is active
rho_mixedip_k(i,r,t)$(kir_lea(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 sum(kls, KRHO(i,r,t,kls))       =e= 1 ;
* Capacity stock per line segment is greater than the lower bound of that line segment (Learning by lbs)
klsLO_mixedip(i,r,t,kls)$(kir_lea(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 KQLS(i,r,t,kls)                 =g= klsLO(i,r,kls) * KRHO(i,r,t,kls) ;
* Capacity stock per line segment is lower than the upper bound of that line segment (Learning by lbs)
klsUP_mixedip(i,r,t,kls)$(kir_lea(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 KQLS(i,r,t,kls)                 =l= klsUP(i,r,kls) * KRHO(i,r,t,kls) ;
* Capacity stock per "active" (rho = 1) line segment is equal to capacity stock (Learning by lbs)
acc_kls_mixedip(i,r,t)$(kir_lea(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 KTRY(i,r,t)                     =e= sum(kls, KQLS(i,r,t,kls)) ;

* * * European Learning-by-lbs
parameter
b_keur(i)                Learning rate from capacity (Q) expansion by technology and region
keurFIRST(i)             First capacity stock unit (GW)
keurSTART(i)             Initial capacity stock (GW)
keurLAST(i)              Maximum capacity stock (GW)
keurlsLO(i,kls)          Lower kink points of capacity stock (GW)
keurlsUP(i,kls)          Upper kink points of capacity stock (GW)
kcapcosteur0(i)          Cost of the first unit installed (EUR per kW)
kcapcosteurFIRST(i)      Cost of the first unit installed (EUR per kW)
kcapcosteurSTART(i)      Cost of the first unit to install in 2020
kcapcosteurLAST(i)       Cost of the last possible unit installed (EUR per kW)
kcapcosteurLO(i,kls)     Cost of the units at the breakpoints
kcapcosteurUP(i,kls)     Cost of the units at the breakpoints
kcapcosteurAV(i,kls)     Cost of the units at the breakpoints
kacc_capexeurFIRST(i)    First unit capacity stock accumulated cost (million)
kacc_capexeurSTART(i)    Initial capacity stock accumulated cost (million)
kacc_capexeurLAST(i)     Maximum capacity stock accumulated cost (million)
kacc_capexeurLO(i,kls)   Lower kink points of capacity stock accumulated cost (million)
kacc_capexeurUP(i,kls)   Upper kink points of capacity stock accumulated cost (million)
kslopeeur_lin(i)         Constant slope of linear approximated function (EUR per kW)
kslopeeur_mip(i,kls)     Slope of linear approximated function (EUR per kW)
ktest_slopeeur(i,kls,*)  Difference to average (EUR per kW)
ktest_slopeeur2(i,kls,*) Average cost per line segment (EUR per kW)
rd_budgeteur(i,t)        RD budget (million EUR)
kcapcosteur(i,v)
;

$gdxin database\setpar_%n%.gdx
$load kcapcosteur, b_keur,keurFIRST,keurSTART,keurLAST,keurlsLO,keurlsUP,kcapcosteur0,kcapcosteurSTART,kcapcosteurLAST,kcapcosteurLO,kcapcosteurUP,kcapcosteurAV,kacc_capexeurFIRST,kacc_capexeurSTART,kacc_capexeurLAST,kacc_capexeurLO,kacc_capexeurUP,kslopeeur_lin,kslopeeur_mip,ktest_slopeeur,ktest_slopeeur2,rd_budgeteur
$gdxin

$if      set lbsnobenchmark capcost(i,v,r)$(kir_lea(i,r)) = kcapcosteur(i,v) ;


positive variable
KTRYEUR(i,t)                Stock of accumulated R&D spendings (million)
KEURLS(i,t,kls)             Stock of accumulated R&D spendings on line segment kls  (million)
IKEUR(i,t)                  R&D investments (million)
KCAPCOSTEUR_MIP(i,t)        Per unit capacity cost of learning technologies (EUR per kW)
KCAPEXEUR_MIP(i,t)          Capacity cost of learning technologies (million)
IXEURLS(i,t,kls)            Variable that replaces the nonlinear product IX*RHO as part of a linearisation strategy
;

$if set kfixrdinvest IKEUR.FX(i,t) = rd_budgeteur(i,t) ;

binary variable
KRHOEUR(i,t,kls)                   Binary variable that reflects piecewise linear segment of learning curve (for European metric)
;

equation
acc_keur_continuous2020(i,t)     Accumulation of 2015 R&D (lbs)
acc_keur_continuous(i,t)         Accumulation of R&D (lbs)
rhoeur_mixedip_k(i,t)            Equation that enforces one rho = 1 in Europe
capexeur_mixedip_k(i,t)          Equation that describes evolution of CAPEX in Europe
lbseur_helper1(i,t,kls)    Equation that helps to linearise the nonlinear product IX*RHO
lbseur_helper2(i,t,kls)    Equation that helps to linearise the nonlinear product IX*RHO
lbseur_helper3(i,t,kls)    Equation that helps to linearise the nonlinear product IX*RHO
lbseur_helper4(i,t,kls)    Equation that helps to linearise the nonlinear product IX*RHO
capcosteur_mixedip_k(i,t)        Equation that describes the evolution of capacity cost
keurlsLO_mixedip(i,t,kls)        Equation that enforeces the lower bound of linear segment in Europe
keurlsUP_mixedip(i,t,kls)        Equation that enforeces the upper bound of linear segment in Europe
acc_keurls_mixedip(i,t)          Equation that describes evolution of KQLS in Europe
;

* * * European Learning-by-Searching
* Accumulation of knowledge stock
acc_keur_continuous2020(i,t)$(t.val le 2022 and tmyopic(t) and ki_lea(i))..
                 KTRYEUR(i,t)       =e=    sum(r, k_exo(i,r,"2022")) ;
acc_keur_continuous(i,t)$(t.val ge 2023 and tmyopic(t) and ki_lea(i) and not sameas(t,"2050"))..
                 KTRYEUR(i,t)       =e=    KTRYEUR(i,t-1) * round(delta_k_pa**nyrs(t),4) + IKEUR(i,t) * nyrs(t) ;
* * * Assume nonlinear unit cost (leads to NLP)
* Comment/ToDo JA: Add NLP implementation for learning by lbs

* * * Assume MIP approximation of NLP problem
* Capacity cost follow from the investment on a line segment and the slope of this line segment
capexeur_mixedip_k(i,t)$(t.val ge 2023 and tmyopic(t) and ki_lea(i))..
                 KCAPEXEUR_MIP(i,t)        =e=  sum(kls, IXEURLS(i,t,kls) * kslopeeur_mip(i,kls)) ;
* Additional constraints in order to linearise IX*RHO, which is replaced by a new helper variable IXLS above
* RHO of t-1 to realise the time lag of one period until the cost degressions materialise
lbseur_helper1(i,t,kls)$(t.val ge 2023 and tmyopic(t) and ki_lea(i))..
                 IXEURLS(i,t,kls)          =l=     2000 * KRHOEUR(i,t-1,kls) ;
lbseur_helper2(i,t,kls)$(t.val ge 2023 and tmyopic(t) and ki_lea(i))..
                 IXEURLS(i,t,kls)          =l=     sum(r, IX(i,r,t)) ;
lbseur_helper3(i,t,kls)$(t.val ge 2023 and tmyopic(t) and ki_lea(i))..
                 IXEURLS(i,t,kls)          =g=     sum(r, IX(i,r,t))  - 2000 * (1 - KRHOEUR(i,t-1,kls)) ;
lbseur_helper4(i,t,kls)$(t.val ge 2023 and tmyopic(t) and ki_lea(i))..
                 IXEURLS(i,t,kls)          =g=     0 ;
* Capacity cost follow from the linear approximation of the learning curve (Learning by lbs) (just placeholder equation, maybe delete later)
capcosteur_mixedip_k(i,t)$(ki_lea(i) and t.val ge 2023 and tmyopic(t))..
                 KCAPCOSTEUR_MIP(i,t)             =e= sum(kls, KRHOEUR(i,t-1,kls) * kslopeeur_mip(i,kls) ) * 1e-3 ;
* This equation enforeces that always just one line segment is active
rhoeur_mixedip_k(i,t)$(ki_lea(i) and not sameas(t,"2050") and tmyopic(t))..
                 sum(kls, KRHOEUR(i,t,kls))       =e= 1 ;
* Capacity stock per line segment is greater than the lower bound of that line segment (Learning by lbs)
keurlsLO_mixedip(i,t,kls)$(ki_lea(i) and not sameas(t,"2050") and tmyopic(t))..
                 KEURLS(i,t,kls)                  =g= keurlsLO(i,kls) * KRHOEUR(i,t,kls) ;
* Capacity stock per line segment is lower than the upper bound of that line segment (Learning by lbs)
keurlsUP_mixedip(i,t,kls)$(ki_lea(i) and not sameas(t,"2050") and tmyopic(t))..
                 KEURLS(i,t,kls)                  =l= keurlsUP(i,kls) * KRHOEUR(i,t,kls) ;
* Capacity stock per "active" (rho = 1) line segment is equal to capacity stock (Learning by lbs)
acc_keurls_mixedip(i,t)$(ki_lea(i) and not sameas(t,"2050") and tmyopic(t))..
                 KTRYEUR(i,t)                     =e= sum(kls, KEURLS(i,t,kls)) ;
                 
* * * R&D budget allocation
equation
eq_lbs_rdbudget_irt(i,r,t) 
eq_lbs_rdbudget_rt(r,t)
eq_lbs_rdbudget_it(i,t)
eq_lbs_rdbudget_ir(i,r)
eq_lbs_rdbudget_t(t)
eq_lbs_rdbudget_r(r)
eq_lbs_rdbudget_i(i)
eq_lbs_rdbudget
eq_lbseur_rdbudget_it(i,t)
eq_lbseur_rdbudget_i(i)
eq_lbseur_rdbudget_t(t)
eq_lbseur_rdbudget
;

parameter
lbsrdbudget(i,r,v)
lbseurrdbudget(i,v)
lbsrdbudget_int(i,r,v)
lbseurrdbudget_int(i,v)
;

lbsrdbudget_int(i,r,v) = sum(tv(t,v), rd_budget(i,r,t)) ;
lbseurrdbudget_int(i,v) = sum(tv(t,v), rd_budgeteur(i,t)) ;

lbsrdbudget(i,r,v) = 1 * lbsrdbudget_int(i,r,v) ;
lbseurrdbudget(i,v) = 1 * lbseurrdbudget_int(i,v) ;

$if     set halfbudget      lbsrdbudget(i,r,v) = 0.5 * lbsrdbudget_int(i,r,v) ;
$if     set halfbudget      lbseurrdbudget(i,v) = 0.5 * lbseurrdbudget_int(i,v) ;

$if     set threeqbudget    lbsrdbudget(i,r,v) = 0.75 * lbsrdbudget_int(i,r,v) ;
$if     set threeqbudget    lbseurrdbudget(i,v) = 0.75 * lbseurrdbudget_int(i,v) ;

$if     set onefiftybudget  lbsrdbudget(i,r,v) = 1.5 * lbsrdbudget_int(i,r,v) ;
$if     set onefiftybudget  lbseurrdbudget(i,v) = 1.5 * lbseurrdbudget_int(i,v) ;

$if     set doublebudget    lbsrdbudget(i,r,v) = 2 * lbsrdbudget_int(i,r,v) ;
$if     set doublebudget    lbseurrdbudget(i,v) = 2 * lbseurrdbudget_int(i,v) ;

eq_lbs_rdbudget_irt(i,r,t)$(kir_lea(i,r) and tmyopic(t))..
$if not set fixbudget        IK(i,r,t) =l= sum(v$(t.val eq v.val), lbsrdbudget(i,r,v)) ;
$if     set fixbudget        IK(i,r,t) =e= sum(v$(t.val eq v.val), lbsrdbudget(i,r,v)) ;
eq_lbs_rdbudget_rt(r,t)$(tmyopic(t))..
$if not set fixbudget        sum(ki_lea(i), IK(i,r,t)) =l= sum(i, sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum(ki_lea(i), IK(i,r,t)) =e= sum(i, sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget_it(i,t)$(ki_lea(i) and tmyopic(t))..
$if not set fixbudget        sum(r, IK(i,r,t)) =l= sum(r, sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum(r, IK(i,r,t)) =e= sum(r, sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget_ir(kir_lea(i,r))..
$if not set fixbudget        sum(tmyopic(t), nyrs(t) * IK(i,r,t)) =l= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum(tmyopic(t), nyrs(t) * IK(i,r,t)) =e= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget_t(t)$(tmyopic(t))..
$if not set fixbudget        sum((kir_lea(i,r)), IK(i,r,t)) =l= sum((kir_lea(i,r)), sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum((kir_lea(i,r)), IK(i,r,t)) =e= sum((kir_lea(i,r)), sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget_r(r)..
$if not set fixbudget        sum((ki_lea(i),tmyopic(t)), nyrs(t) * IK(i,r,t) * nyrs(t)) =l= sum((ki_lea(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum((ki_lea(i),tmyopic(t)), nyrs(t) * IK(i,r,t) * nyrs(t)) =e= sum((ki_lea(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget_i(i)..
$if not set fixbudget        sum((r,tmyopic(t)), nyrs(t) * IK(i,r,t)) =l= sum((r,tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum((r,tmyopic(t)), nyrs(t) * IK(i,r,t)) =e= sum((r,tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbs_rdbudget..
$if not set fixbudget        sum((kir_lea(i,r),tmyopic(t)), nyrs(t) * IK(i,r,t)) =l= sum((kir_lea(i,r),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
$if     set fixbudget        sum((kir_lea(i,r),tmyopic(t)), nyrs(t) * IK(i,r,t)) =e= sum((kir_lea(i,r),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbsrdbudget(i,r,v))) ;
eq_lbseur_rdbudget_it(ki_lea(i),t)$(tmyopic(t))..
$if not set fixbudget        IKEUR(i,t) =l= sum(v$(t.val eq v.val), lbseurrdbudget(i,v)) ;
$if     set fixbudget        IKEUR(i,t) =e= sum(v$(t.val eq v.val), lbseurrdbudget(i,v)) ;
eq_lbseur_rdbudget_i(ki_lea(i))..
$if not set fixbudget        sum(tmyopic(t), nyrs(t) * IKEUR(i,t)) =l= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;
$if     set fixbudget        sum(tmyopic(t), nyrs(t) * IKEUR(i,t)) =e= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;
eq_lbseur_rdbudget_t(t)$(tmyopic(t))..
$if not set fixbudget        sum(ki_lea(i), IKEUR(i,t)) =l= sum(ki_lea(i), sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;
$if     set fixbudget        sum(ki_lea(i), IKEUR(i,t)) =e= sum(ki_lea(i), sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;
eq_lbseur_rdbudget..
$if not set fixbudget        sum((ki_lea(i),tmyopic(t)), nyrs(t) * IKEUR(i,t)) =l= sum((ki_lea(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;
$if     set fixbudget        sum((ki_lea(i),tmyopic(t)), nyrs(t) * IKEUR(i,t)) =e= sum((ki_lea(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), lbseurrdbudget(i,v))) ;

$if     set lbs              IK.FX(ki_lea(i),r,"2022") = lbsrdbudget(i,r,"2022") ;
$if     set lbseur           IKEUR.FX(ki_lea(i),"2022") = lbseurrdbudget(i,"2022") ;
$if     set lbs              IK.FX(ki_lea(i),r,"2050") = lbsrdbudget(i,r,"2050") ;
$if     set lbseur           IKEUR.FX(ki_lea(i),"2050") = lbseurrdbudget(i,"2050") ;


equation
nuclear_restriction(i) Restricts nuclear expansion to 100 GW
ccs_restriction(i) Restricts gas ccs expansion to 300 GW
wind_restriction(t) Restricts annual wind onshore expansion until 2030 to 50 GW
gas_restriction(t) Restricts annual wind onshore expansion until 2030 to 10 GW
;

nuclear_restriction(i)$(sameas(i,"Nuclear"))..
                 sum((r,tmyopic(t)), IX(i,r,t)) =l= 100 ;
                
ccs_restriction(i)$(sameas(i,"Gas_CCS"))..
                 sum((r,tmyopic(t)), IX(i,r,t)) =l= 300 ;
 

wind_restriction(t)$(tmyopic(t) and t.val ge 2023 and t.val le 2030)..
                 sum((windon(i),r), IX(i,r,t)) =l= 50 ;
                 
gas_restriction(t)$(tmyopic(t) and t.val ge 2022 and t.val le 2030)..
                 sum((gas(i),r), IX(i,r,t)) =l= 10 ;  

* * * FLH LBS
set
i_flh(i)
ir_flh(i,r)
flhls
;

$gdxin database\setpar_%n%.gdx
$load i_flh, ir_flh, flhls
$gdxin

ir_flh("OpenPV_q90",r) = NO ;
i_flh("OpenPV_q90") = NO ;

* * Regional
parameter
bflh(i,r) learning rate (%)
flhstock(i,r,v) knowledge stock (million €)
flhrdbudget(i,r,v) RD budget (million €)
flhindex(i,r,v) Average FLH (index 2022 = 1)
flh(i,r,v) Average FLH (h per a)
;

$gdxin database\setpar_%n%.gdx
$load bflh,flhstock,flhrdbudget,flhindex,flh
$gdxin

parameter
vrsc_nor(s,i,v,r)
flh_check(i,v,r)
;

vrsc_nor(s,i,v,r)$(ir_flh(i,r) and v.val ge 2023 and sum(ss, hours(ss) * vrsc(ss,i,v,r)) > 0) = vrsc(s,i,v,r) * sum(ss, hours(ss) * vrsc(ss,i,"2022",r)) / sum(ss, hours(ss) * vrsc(ss,i,v,r)) ;
flh_check(i,v,r) = sum(s, hours(s) * vrsc_nor(s,i,v,r)) ;

parameter
flhstockFIRST(i,r)
flhstockSTART(i,r)
flhstockLAST(i,r)
flhstockUP(i,r,flhls)
flhstockLO(i,r,flhls)
flhaccumFIRST(i,r)
flhaccumSTART(i,r)
flhaccumLAST(i,r)
flhaccumUP(i,r,flhls)
flhaccumLO(i,r,flhls)
flhindexFIRST(i,r)
flhindexSTART(i,r)
flhindexLAST(i,r)
flhindexUP(i,r,flhls)
flhindexLO(i,r,flhls)
flhindexSLOPE(i,r,flhls)
;

$gdxin database\setpar_%n%.gdx
$load flhstockFIRST
$load flhstockSTART
$load flhstockLAST
$load flhstockUP
$load flhstockLO
$load flhaccumFIRST
$load flhaccumSTART
$load flhaccumLAST
$load flhaccumUP
$load flhaccumLO
$load flhindexFIRST
$load flhindexSTART
$load flhindexLAST
$load flhindexUP
$load flhindexLO
$load flhindexSLOPE
$gdxin


positive variable
FLHTRY(i,r,t) knowledge stock to increase FLH (million €)
IFLH(i,r,t) investments into knowledge stock to increase FLH (million €)
FLHREGLS(i,r,t,flhls) line segment specific knowledge stock
XCFLH(i,v,r,t,flhls) XCS per line segment
;

$if set fixrdinvest IFLH.FX(i,r,t) = sum(v$(v.val eq t.val), flhrdbudget(i,r,v)) ;

binary variable
RHOFLH(i,r,t,flhls)
;

equation
acc_flh2020(i,r,t)
acc_flh(i,r,t)
rhoflh_mixedip(i,r,t)
flhlsLO_mixedip(i,r,t,flhls)
flhlsUP_mixedip(i,r,t,flhls)
acc_flhls_mixedip(i,r,t)
flh_helper1(i,v,r,t,flhls)
flh_helper2(i,v,r,t,flhls)
flh_helper3(i,v,r,t,flhls)
flh_helper4(i,v,r,t,flhls)
capacity_flholdv(s,i,v,r,t)
capacity_flh(s,i,v,r,t)
;

* Knowledge stock equations
acc_flh2020(i,r,t)$(sameas(t,"2022") and tmyopic(t) and ir_flh(i,r))..
FLHTRY(i,r,t) =e= flhstockSTART(i,r) ;
acc_flh(i,r,t)$(t.val ge 2023 and tmyopic(t) and ir_flh(i,r))..
FLHTRY(i,r,t) =e= FLHTRY(i,r,t - 1) * round(delta_k_pa**nyrs(t),4) + IFLH(i,r,t) * nyrs(t) ;

* RHO equations
rhoflh_mixedip(i,r,t)$(ir_flh(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 sum(flhls, RHOFLH(i,r,t,flhls)) =e= 1 ;                
flhlsLO_mixedip(i,r,t,flhls)$(ir_flh(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 FLHREGLS(i,r,t,flhls)              =g= flhstockLO(i,r,flhls) * RHOFLH(i,r,t,flhls) ;
flhlsUP_mixedip(i,r,t,flhls)$(ir_flh(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 FLHREGLS(i,r,t,flhls)              =l= flhstockUP(i,r,flhls) * RHOFLH(i,r,t,flhls) ;
acc_flhls_mixedip(i,r,t)$(ir_flh(i,r) and not sameas(t,"2050") and tmyopic(t))..
                 FLHTRY(i,r,t)                   =e= sum(flhls, FLHREGLS(i,r,t,flhls)) ;

* Helper equations
flh_helper1(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and ir_flh(i,r) and v.val le t.val and v.val ge 2023)..
                XCFLH(i,v,r,t,flhls) =l= irnwlimUP_quantiles(i,r,"q90") * flhindexSLOPE(i,r,flhls) * sum(tv(tt,v), RHOFLH(i,r,tt-1,flhls)) ;
flh_helper2(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and ir_flh(i,r) and v.val le t.val and v.val ge 2023)..
                XCFLH(i,v,r,t,flhls) =l= XC(i,v,r,t) * flhindexSLOPE(i,r,flhls) ;
flh_helper3(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and ir_flh(i,r) and v.val le t.val and v.val ge 2023)..
                XCFLH(i,v,r,t,flhls) =g= XC(i,v,r,t) * flhindexSLOPE(i,r,flhls) - irnwlimUP_quantiles(i,r,"q90") * flhindexSLOPE(i,r,flhls)* (1 - sum(tv(tt,v), RHOFLH(i,r,tt-1,flhls))) ;
flh_helper4(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and ir_flh(i,r) and v.val le t.val and v.val ge 2023)..
                XCFLH(i,v,r,t,flhls) =g= 0 ;

* Capacity equations
capacity_flholdv(s,ivrt(i,v,r,t))$(tmyopic(t) and ir_flh(i,r) and v.val le 2022)..
                X(s,i,v,r,t) =l=  XC(i,v,r,t) * vrsc(s,i,v,r) ;             
capacity_flh(s,ivrt(i,v,r,t))$(tmyopic(t) and ir_flh(i,r) and v.val ge 2023)..
                X(s,i,v,r,t) =l=  sum(flhls, XCFLH(i,v,r,t,flhls)) * vrsc_nor(s,i,v,r) ;
                
* * European
parameter
bflheur(i) learning rate (%)
flheurindex_reg(i,r,v) regional correction (0 ... X)
flheurstock(i,v) knowledge stock (million €)
flheurrdbudget(i,v) RD budget (million €)
flheurindex(i,v) Average FLH (index 2022 = 1)
flheur(i,v) Average FLH (h per a)
;

$gdxin database\setpar_%n%.gdx
$load bflheur,flheurstock,flheurindex_reg,flheurrdbudget,flheurindex,flheur
$gdxin

parameter
vrsceur_nor(s,i,v,r)
flheur_check(i,v,r)
;

vrsceur_nor(s,i,v,r)$(ir_flh(i,r) and v.val ge 2023 and sum(ss, hours(ss) * vrsc(ss,i,v,r)) > 0) = vrsc(s,i,v,r) * flheur(i,"2022") / sum(ss, hours(ss) * vrsc(ss,i,v,r)) ;
flheur_check(i,v,r) = sum(s, hours(s) * vrsceur_nor(s,i,v,r)) ;

parameter
flheurstockFIRST(i)
flheurstockSTART(i)
flheurstockLAST(i)
flheurstockUP(i,flhls)
flheurstockLO(i,flhls)
flheuraccumFIRST(i)
flheuraccumSTART(i)
flheuraccumLAST(i)
flheuraccumUP(i,flhls)
flheuraccumLO(i,flhls)
flheurindexFIRST(i)
flheurindexSTART(i)
flheurindexLAST(i)
flheurindexUP(i,flhls)
flheurindexLO(i,flhls)
flheurindexSLOPE(i,flhls)
;


$gdxin database\setpar_%n%.gdx
$load flheurstockFIRST
$load flheurstockSTART
$load flheurstockLAST
$load flheurstockUP
$load flheurstockLO
$load flheuraccumFIRST
$load flheuraccumSTART
$load flheuraccumLAST
$load flheuraccumUP
$load flheuraccumLO
$load flheurindexFIRST
$load flheurindexSTART
$load flheurindexLAST
$load flheurindexUP
$load flheurindexLO
$load flheurindexSLOPE
$gdxin

positive variable
FLHTRYEUR(i,t) knowledge stock to increase FLH (million €)
IFLHEUR(i,t) investments into knowledge stock to increase FLH (million €)
FLHEURLS(i,t,flhls) line segment specific knowledge stock
XCFLHEUR(i,v,r,t,flhls) XCS per line segment
;

$if set fixrdinvesteur IFLHEUR.FX(i,t) = sum(v$(v.val eq t.val), flheurrdbudget(i,v)) ;

binary variable
RHOFLHEUR(i,t,flhls)
;

equation
acc_flheur2020(i,t)
acc_flheur(i,t)
rhoflheur_mixedip(i,t)
flheurlsLO_mixedip(i,t,flhls)
flheurlsUP_mixedip(i,t,flhls)
acc_flheurls_mixedip(i,t)
flheur_helper1(i,v,r,t,flhls)
flheur_helper2(i,v,r,t,flhls)
flheur_helper3(i,v,r,t,flhls)
flheur_helper4(i,v,r,t,flhls)
capacity_flheuroldv(s,i,v,r,t)
capacity_flheur(s,i,v,r,t)
;

* Knowledge stock equations
acc_flheur2020(i,t)$(sameas(t,"2022") and tmyopic(t) and i_flh(i))..
FLHTRYEUR(i,t) =e= flheurstockSTART(i) ;
acc_flheur(i,t)$(t.val ge 2023 and tmyopic(t) and i_flh(i))..
FLHTRYEUR(i,t) =e= FLHTRYEUR(i,t-1) * round(delta_k_pa**nyrs(t),4) + IFLHEUR(i,t) * nyrs(t) ;

* RHO equations
rhoflheur_mixedip(i,t)$(i_flh(i) and not sameas(t,"2050") and tmyopic(t))..
                 sum(flhls, RHOFLHEUR(i,t,flhls)) =e= 1 ;                
flheurlsLO_mixedip(i,t,flhls)$(i_flh(i) and not sameas(t,"2050") and tmyopic(t))..
                 FLHEURLS(i,t,flhls)              =g= flheurstockLO(i,flhls) * RHOFLHEUR(i,t,flhls) ;
flheurlsUP_mixedip(i,t,flhls)$(i_flh(i) and not sameas(t,"2050") and tmyopic(t))..
                 FLHEURLS(i,t,flhls)              =l= flheurstockUP(i,flhls) * RHOFLHEUR(i,t,flhls) ;
acc_flheurls_mixedip(i,t)$(i_flh(i) and not sameas(t,"2050") and tmyopic(t))..
                 FLHTRYEUR(i,t)                   =e= sum(flhls, FLHEURLS(i,t,flhls)) ;
                 
* Helper equations
flheur_helper1(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and i_flh(i) and v.val le t.val and v.val ge 2023)..
                XCFLHEUR(i,v,r,t,flhls) =l= irnwlimUP_quantiles(i,r,"q90") * flheurindexSLOPE(i,flhls) * sum(tv(tt,v), RHOFLHEUR(i,tt-1,flhls)) ;
flheur_helper2(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and i_flh(i) and v.val le t.val and v.val ge 2023)..
                XCFLHEUR(i,v,r,t,flhls) =l= XC(i,v,r,t) * flheurindexSLOPE(i,flhls) ;
flheur_helper3(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and i_flh(i) and v.val le t.val and v.val ge 2023)..
                XCFLHEUR(i,v,r,t,flhls) =g= XC(i,v,r,t) * flheurindexSLOPE(i,flhls) - irnwlimUP_quantiles(i,r,"q90") * flheurindexSLOPE(i,flhls) * (1 - sum(tv(tt,v), RHOFLHEUR(i,tt-1,flhls))) ;
flheur_helper4(ivrt(i,v,r,t),flhls)$(t.val ge 2023 and tmyopic(t) and i_flh(i) and v.val le t.val and v.val ge 2023)..
                XCFLHEUR(i,v,r,t,flhls) =g= 0 ;

* Capacity equations
capacity_flheuroldv(s,ivrt(i,v,r,t))$(tmyopic(t) and i_flh(i) and v.val le 2022)..
                X(s,i,v,r,t) =l=  XC(i,v,r,t) * vrsc(s,i,v,r) ;             
capacity_flheur(s,ivrt(i,v,r,t))$(tmyopic(t) and i_flh(i) and v.val ge 2023)..
                X(s,i,v,r,t) =l=  sum(flhls, XCFLHEUR(i,v,r,t,flhls)) * vrsceur_nor(s,i,v,r) * flheurindex_reg(i,r,v) ;
            

equation
eq_flh_rdbudget_irt(i,r,t) 
eq_flh_rdbudget_rt(r,t)
eq_flh_rdbudget_it(i,t)
eq_flh_rdbudget_ir(i,r)
eq_flh_rdbudget_t(t)
eq_flh_rdbudget_r(r)
eq_flh_rdbudget_i(i)
eq_flh_rdbudget
eq_flheur_rdbudget_it(i,t)
eq_flheur_rdbudget_i(i)
eq_flheur_rdbudget_i(i)
eq_flheur_rdbudget_t(t)
eq_flheur_rdbudget
;

parameter
flhrdbudget_int(i,r,v)
flheurrdbudget_int(i,v)
;

flhrdbudget_int(i,r,v) = flhrdbudget(i,r,v) ;
flheurrdbudget_int(i,v) = flheurrdbudget(i,v) ;

$if     set halfbudget      flhrdbudget(i,r,v) = 0.5 * flhrdbudget_int(i,r,v) ;
$if     set halfbudget      flheurrdbudget(i,v) = 0.5 * flheurrdbudget_int(i,v) ;

$if     set threeqbudget    flhrdbudget(i,r,v) = 0.75 * flhrdbudget_int(i,r,v) ;
$if     set threeqbudget    flheurrdbudget(i,v) = 0.75 * flheurrdbudget_int(i,v) ;

$if     set onefiftybudget  flhrdbudget(i,r,v) = 1.5 * flhrdbudget_int(i,r,v) ;
$if     set onefiftybudget  flheurrdbudget(i,v) = 1.5 * flheurrdbudget_int(i,v) ;

$if     set doublebudget    flhrdbudget(i,r,v) = 2 * flhrdbudget_int(i,r,v) ;
$if     set doublebudget    flheurrdbudget(i,v) = 2 * flheurrdbudget_int(i,v) ;

eq_flh_rdbudget_irt(i,r,t)$(ir_flh(i,r) and tmyopic(t))..
$if not set fixbudget        IFLH(i,r,t) =l= sum(v$(t.val eq v.val), flhrdbudget(i,r,v)) ;
$if     set fixbudget        IFLH(i,r,t) =e= sum(v$(t.val eq v.val), flhrdbudget(i,r,v)) ;
eq_flh_rdbudget_rt(r,t)$(tmyopic(t))..
$if not set fixbudget        sum(i_flh(i), IFLH(i,r,t)) =l= sum(i, sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum(i_flh(i), IFLH(i,r,t)) =e= sum(i, sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget_it(i,t)$(i_flh(i) and tmyopic(t))..
$if not set fixbudget        sum(r, IFLH(i,r,t)) =l= sum(r, sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum(r, IFLH(i,r,t)) =e= sum(r, sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget_ir(ir_flh(i,r))..
$if not set fixbudget        sum(tmyopic(t), nyrs(t) * IFLH(i,r,t)) =l= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum(tmyopic(t), nyrs(t) * IFLH(i,r,t)) =e= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget_t(t)$(tmyopic(t))..
$if not set fixbudget        sum((ir_flh(i,r)), IFLH(i,r,t)) =l= sum((ir_flh(i,r)), sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum((ir_flh(i,r)), IFLH(i,r,t)) =e= sum((ir_flh(i,r)), sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget_r(r)..
$if not set fixbudget        sum((i_flh(i),tmyopic(t)), nyrs(t) * IFLH(i,r,t) * nyrs(t)) =l= sum((i_flh(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum((i_flh(i),tmyopic(t)), nyrs(t) * IFLH(i,r,t) * nyrs(t)) =e= sum((i_flh(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget_i(i)..
$if not set fixbudget        sum((r,tmyopic(t)), nyrs(t) * IFLH(i,r,t)) =l= sum((r,tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum((r,tmyopic(t)), nyrs(t) * IFLH(i,r,t)) =e= sum((r,tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flh_rdbudget..
$if not set fixbudget        sum((ir_flh(i,r),tmyopic(t)), nyrs(t) * IFLH(i,r,t)) =l= sum((ir_flh(i,r),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
$if     set fixbudget        sum((ir_flh(i,r),tmyopic(t)), nyrs(t) * IFLH(i,r,t)) =e= sum((ir_flh(i,r),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flhrdbudget(i,r,v))) ;
eq_flheur_rdbudget_it(i_flh(i),t)$(tmyopic(t))..
$if not set fixbudget        IFLHEUR(i,t) =l= sum(v$(t.val eq v.val), flheurrdbudget(i,v)) ;
$if     set fixbudget        IFLHEUR(i,t) =e= sum(v$(t.val eq v.val), flheurrdbudget(i,v)) ;
eq_flheur_rdbudget_i(i_flh(i))..
$if not set fixbudget        sum(tmyopic(t), nyrs(t) * IFLHEUR(i,t)) =l= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;
$if     set fixbudget        sum(tmyopic(t), nyrs(t) * IFLHEUR(i,t)) =e= sum(tmyopic(t), nyrs(t) * sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;
eq_flheur_rdbudget_t(t)$(tmyopic(t))..
$if not set fixbudget        sum(i_flh(i), IFLHEUR(i,t)) =l= sum(i_flh(i), sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;
$if     set fixbudget        sum(i_flh(i), IFLHEUR(i,t)) =e= sum(i_flh(i), sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;
eq_flheur_rdbudget..
$if not set fixbudget        sum((i_flh(i),tmyopic(t)), nyrs(t) * IFLHEUR(i,t)) =l= sum((i_flh(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;
$if     set fixbudget        sum((i_flh(i),tmyopic(t)), nyrs(t) * IFLHEUR(i,t)) =e= sum((i_flh(i),tmyopic(t)), nyrs(t) * sum(v$(t.val eq v.val), flheurrdbudget(i,v))) ;

$if     set flh              IFLH.FX(i_flh(i),r,"2022") = flhrdbudget(i,r,"2022") ;
$if     set flheur           IFLHEUR.FX(i_flh(i),"2022") = flheurrdbudget(i,"2022") ;
$if     set flh              IFLH.FX(i_flh(i),r,"2050") = flhrdbudget(i,r,"2050") ;
$if     set flheur           IFLHEUR.FX(i_flh(i),"2050") = flheurrdbudget(i,"2050") ;

set
ivt(i,v,t)              Active vintage-capacity blocks aggregated to European metric
;

parameter
deprtimeeur(i,v,t)      deprtime for European learning metric
endeffecteur(i,v,t)     endeffect for European learning metric
kendeffect(i,r,t)       endeffect for lbs
kendeffecteur(i,t)      endeffecteur for lbs
;

* ETC module
ivt(i,v,t) = YES$(ivrt(i,v,"Germany",t) and i_lea(i)) ;
deprtimeeur(i,v,t)$(sum(r, 1$deprtime(i,v,r,t)) > 0) = sum(r, deprtime(i,v,r,t)) / sum(r, 1$deprtime(i,v,r,t)) ;
endeffecteur(i,v,t)$(sum(r, 1$endeffect(i,v,r,t)) > 0) = sum(r, endeffect(i,v,r,t)) / sum(r, 1$endeffect(i,v,r,t)) ;
kendeffect(i,r,t)$(kir_lea(i,r)) = sum(tv(t,v), endeffect(i,v,r,t)) ;
kendeffecteur(i,t)$(ki_lea(i) and sum(r, 1$kendeffect(i,r,t)) > 0) = sum(r, kendeffect(i,r,t)) / sum(r, 1$kendeffect(i,r,t)) ;

parameter
rshare(inv,i)
rzeta(inv,i,v)
;

rzeta(inv,i,v) = sum(r, share(inv,i,r) * zeta(inv,i,v,r) * daref(r,"2022")) / sum(r, daref(r,"2022")) ;
rshare(inv,i)  = sum(r, share(inv,i,r) * daref(r,"2022")) / sum(r, daref(r,"2022")) ;

$ontext
* * * Spillover
parameter
lag time period lag for LBD spillover
klag time period lag for LBS spillover
spill(r,r) LBD spillover between region pair (1 = perfect spillover -> European LBD)
kspill(r,r) LBS spillover between region pair (1 = perfect spillover --> European LBS)
spilllag(r,r,lag) LBD spillover between region pair (1 = perfect spillover -> European LBD) in dependency of lag
kspilllag(r,r,klag) LBS spillover between region pair (1 = perfect spillover -> European LBS) in dependency of lag
;
$offtext

* * * Objective function definition
objdef..
*        Surplus is defined in million EUR
         SURPLUS =e=
*        Sum over all time period t
                !! begin period sum
                sum(t$tmyopic(t),
* European learning investment cost without region sum (old)
$if      set lbdcon     $if     set normal      1 / nyrs(t) * (1 + tk) * dfact(t) * sum(new(i)$( i_lea(i)),                          sum(tv(t,v)$ivt(i,v,t),  CAPEXEUR_CON(i,v) * 1e+6 *  endeffecteur(i,v,t)))  +
$if      set lbdnlp     $if     set normal      1 / nyrs(t) * (1 + tk) * dfact(t) * sum(new(i)$( i_lea(i)),                          sum(tv(t,v)$ivt(i,v,t),  CAPEXEUR_NLP(i,v) * 1e+6 *  endeffecteur(i,v,t)))  +
$if      set lbdeur     $if     set normal      1 / nyrs(t) * (1 + tk) * dfact(t) * sum(new(i)$( i_lea(i)),                          sum(tv(t,v)$ivt(i,v,t),  CAPEXEUR_MIP(i,v) * 1e+6 *  endeffecteur(i,v,t)))  +
$if      set lbseur     $if     set normal      1 / nyrs(t) * (1 + tk) * dfact(t) * sum(new(i)$(ki_lea(i)),                          sum(tv(t,v)$ivt(i,v,t), KCAPEXEUR_MIP(i,t) * 1e+6 *  endeffecteur(i,v,t)))  +
* European learning investment cost without region sum (new)
$if      set lbdcon     $if     set mixed                                           sum(new(i)$( i_lea(i)), sum(inv, rshare(inv,i) * sum(tv(t,v)$ivt(i,v,t),  CAPEXEUR_CON(i,v) * 1e+6 *       rzeta(inv,i,v)))) +
$if      set lbdnlp     $if     set mixed                                           sum(new(i)$( i_lea(i)), sum(inv, rshare(inv,i) * sum(tv(t,v)$ivt(i,v,t),  CAPEXEUR_NLP(i,v) * 1e+6 *       rzeta(inv,i,v)))) +
$if      set lbdeur     $if     set mixed                                           sum(new(i)$( i_lea(i)), sum(inv, rshare(inv,i) * sum(tv(t,v)$ivt(i,v,t), KCAPEXEUR_MIP(i,v) * 1e+6 *       rzeta(inv,i,v)))) +
$if      set lbseur     $if     set mixed                                         * sum(new(i)$(ki_lea(i)), sum(inv, rshare(inv,i) * sum(tv(t,v)$ivt(i,v,t), KCAPEXEUR_MIP(i,t) * 1e+6 *       rzeta(inv,i,v)))) +

*               Sum over all regions r
                !! begin region sum
                sum(r, 
*               INVESTMENT COST
                !! begin investment cost (new)
* Mixed investor investment cost including discounting
$if not  set etc        $if      set mixed      sum(new(i),                    sum(inv,  share(inv,i,r) * IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),   capcost(i,v,r)  *  zeta(inv,i,v,r)))) +
$if      set storage    $if      set mixed      sum(newj(j),                   sum(inv, gshare(inv,j,r) * IG(j,r,t)    * sum(tv(t,v)$jvrt(j,v,r,t),  gcapcost(j,v,r)  * gzeta(inv,j,v,r)))) +
$if      set trans      $if      set mixed      sum((rr,k)$tmap(k,r,rr),       sum(inv, tshare(inv,k,r) * IT(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t),  tcapcost(k,r,rr) * tzeta(inv,k,v,r)))) +
$if      set lbs        $if      set mixed      sum(new(i)$(not kir_lea(i,r)), sum(inv,  share(inv,i,r) * IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),   capcost(i,v,r)  *  zeta(inv,i,v,r)))) +
$if      set lbs        $if      set mixed      sum(new(i)$(    kir_lea(i,r)), sum(inv,  share(inv,i,r)                * sum(tv(t,v)$ivrt(i,v,r,t), KCAPEX_MIP(i,v,r) *  zeta(inv,i,v,r)))) +
                !! end investment cost (new)
*               DISCOUNTING                
                !! begin discounting
                dfact(t) * (               
*               INVESTMENT COST
*               Old, excluding discouting via normal annui, and ccost)                
                !! begin investment cost (old)
*               We need nyrs because investments happens once only but production nyrs-times)
                1 / nyrs(t) * (1 + tk) * (1 
*                                   Normal investor consider total investment cost in the period of investment
$if not  set etc        $if     set normal    + sum(new(i),                    IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),    capcost(i,v,r)  *  endeffect(i,v,r,t)))
$if      set storage    $if     set normal    + sum(newj(j),                   IG(j,r,t)    * sum(tv(t,v)$jvrt(j,v,r,t),   gcapcost(j,v,r)  * gendeffect(j,v,r,t)))
$if      set trans      $if     set normal    + sum((rr,k)$tmap(k,r,rr),       IT(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t),   tcapcost(k,r,rr) * tendeffect(k,v,r,t)))
$if      set lbs        $if     set normal    + sum(new(i)$(not kir_lea(i,r)), IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),    capcost(i,v,r)  *  endeffect(i,v,r,t)))
$if      set lbs        $if     set normal    + sum(new(i)$(    kir_lea(i,r)),                sum(tv(t,v)$ivrt(i,v,r,t), KCAPEX_MIP(i,v,r)  * kendeffect(i,r,t)  ))

*                                   Investment costs follow from annuities (%) of borrowed capital (EUR/kW * GW)
$if                             set annui     + sum(new(i),  sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(i,v,r,tt)),             IX(i,r,tt)   *  capcost(i,v,r)  *  deprtime(i,v,r,tt) *  annuity(i,v)  * nyrs(t)))
$if      set storage    $if     set annui     + sum(newj(j), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(j,v,r,tt)),             IG(j,r,tt)   * gcapcost(j,v,r)  * gdeprtime(j,v,r,tt) * gannuity(j,v)  * nyrs(t)))
$if      set trans      $if     set annui     + sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * tannuity(k)    * nyrs(t)))
*                                   Investment costs follow from WACC (%) of capital stock (EUR/kW * GW)
$if                             set ccost     + sum(new(i), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(i,v,r,tt)),              IX(i,r,tt)   *  capcost(i,v,r)  *  deprtime(i,v,r,tt) * drate * nyrs(t)))
$if      set storage    $if     set ccost     + sum(newj(j), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(j,v,r,tt)),             IG(j,r,tt)   * gcapcost(j,v,r)  * gdeprtime(j,v,r,tt) * drate * nyrs(t)))
$if      set trans      $if     set ccost     + sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * drate * nyrs(t)))
* Regional learning investment cost wit region sum
$if      set lbd        $if     set normal    + sum(new(i)$(not ir_lea(i,r)), IX(i,r,t)    * sum(tv(t,v)$ivrt(i,v,r,t),    capcost(i,v,r)  *  endeffect(i,v,r,t)))
$if      set lbdcon     $if     set normal    + sum(new(i)$(    ir_lea(i,r)), sum(tv(t,v)$ivrt(i,v,r,t),  CAPEX_CON(i,v,r)        *  endeffect(i,v,r,t) ))
$if      set lbdnlp     $if     set normal    + sum(new(i)$(    ir_lea(i,r)), sum(tv(t,v)$ivrt(i,v,r,t),  CAPEX_NLP(i,v,r)        *  endeffect(i,v,r,t) ))
$if      set lbdmip     $if     set normal    + sum(new(i)$(    ir_lea(i,r)), sum(tv(t,v)$ivrt(i,v,r,t),  CAPEX_MIP(i,v,r) * 1e+6 *  endeffect(i,v,r,t) ))


               )
                !! end investment cost (old, excluding discount via investment cost factor)
*               DISPATCH COST
*               Are measured in €/MWh and generation in GWh, so that we need to correct by 1e-3
                !! begin dispatch cost (regional)
*                       Dispatch cost (EUR/MWh) for generation (GWh)
                        + 1e-3 * sum(ivrt(i,v,r,t),            discost(i,v,r,t) * sum(s, hours(s) * X(s,i,v,r,t)))
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
* RD investment cost
                !! begin research cost
$if      set flh     $if set surplusbudget  + dfact(t) * sum(ir_flh(i,r), IFLH(i,r,t))
$if      set flheur  $if set surplusbudget  + dfact(t) * sum(i_flh(i),    IFLHEUR(i,t))
                )
                !! end research cost
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
$if      set lostload    + BS(s,r,t) *
$if      set lostload    $if not set lossnewtemp       (1 + loss(r))
$if      set lostload    $if     set lossnewtemp        (1 + losss(s,r,t))
         )
*        Equals (annually scaled) demand including losses
         =e=             1e-3 * hours(s) * round(dref(r,t) * load(s,r) *
$if not set lossnewtemp        (1 + loss(r)),4)
$if     set lossnewtemp        (1 + losss(s,r,t)),4)
;

* * * Regional system adequacy constraint
* Hypothetical shadow electricity market with no transmission in the default version
* In the 4NEMO version it has changed by using capcredits. Here, transmission capacity is offered a tcapcredit of 0.1
demand_rsa(peak(s,r),t)$(t.val ge
$if not   set uselimits     2023 and tmyopic(t))..
$if       set uselimits     2031 and tmyopic(t))..
*        Scale from GW to TWh (so that dual variable (marginals/shadow price) is reported directly in euro per MWh)
                         1e-3 * hours(s) * (
*        Upper bound on available generation in region
$if not  set flh        $if not set flheur   + sum(ivrt(i,v,r,t), XCS(s,i,v,r,t) *  capcred(i,v,r))
$if      set flh                             + sum(ivrt(i,v,r,t), XC(i,v,r,t) *  capcred(i,v,r))
$if      set flheur                           + sum(ivrt(i,v,r,t), XC(i,v,r,t) *  capcred(i,v,r))
*        Plus discharges from storage less charges (plus penalty)
$if      set storage     + sum(jvrt(j,v,r,t),  GD(s,j,v,r,t) * gcapcred(j,v,r))
*        Plus inter-region imports
$if      set trans       + sum((k,rr)$tmap(k,rr,r), TC(k,rr,r,t) * tcapcred(k,rr,r))
         )
*        Equals (annually scaled) demand including losses
         =g=             1e-3 * hours(s) * round(dref(r,t) * load(s,r) *
$if not set lossnewtemp        (1 + loss(r)),4)
$if     set lossnewtemp        (1 + losss(s,r,t)),4)
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
capacity(s,ivrt(i,v,r,t))$(not chp(i) and tmyopic(t)
$if      set flh           and not ir_flh(i,r)
$if      set flheur        and not i_flh(i)
                            )..
                 X(s,i,v,r,t) =l=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Nuclear, hydro, and bioenergy must be treated as must-run in 2022
capacity_mus(s,ivrt(i,v,r,t))$(sameas(i,"Nuclear") and t.val le 2022 and tmyopic(t))..
                 X(s,i,v,r,t) =e=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* CHP are mustrun
capacity_chp(s,ivrt(chp(i),oldv(v),r,t))$(not sameas(i,"Bio_CHP") and tmyopic(t))..
                 X(s,i,v,r,t) =e=  XCS(s,i,v,r,t) * 0.5708 ;
* Sometime we differentiate between technologies that are dispatchable (dspt) and those that are not (ndsp) (* This constraints is deactivated in the model setup when must-run is not "yes")
capacity_dsp(s,ivrt(dspt(i),v,r,t))$tmyopic(t)..
                 X(s,i,v,r,t) =l=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r))* (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Non-dispatchable technologies cannot adjust their production (see equality sign) (This constraints is deactivated in the model setup when must-run is not "yes")
capacity_nsp(s,ivrt(ndsp(i),v,r,t))$tmyopic(t)..
                 X(s,i,v,r,t) =e=  XCS(s,i,v,r,t) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r))* (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r)) ;
* Bioenergy is must-run (This constraint is also generally deactivated (could come with numerical difficulties but need further testing))
capacity_bio(s,ivrt(i,oldv(v),r,t))$(sameas(i,"Bioenergy") or sameas(i,"Bio_CHP") and t.val le 2030 and tmyopic(t))..
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
exlife2020(ivrt(i,oldv(v),r,t))$(t.val le 2022 and tmyopic(t))..
         XC(i,v,r,t) =e= cap(i,v,r) * lifetime(i,v,r,t) ;
* Standard exlife constraint
exlife(ivrt(i,oldv(v),r,t))$(t.val ge 2023 and not chp(i) and tmyopic(t))..
         XC(i,v,r,t) =l= cap(i,v,r) * lifetime(i,v,r,t) ;
* CHP plants cannot be decommissioned before lifetime         
exlife2030_chp(ivrt(chp(i),oldv(v),r,t))$(not sameas(i,"Bio_CHP") and t.val ge 2023 and t.val le 2030 and tmyopic(t))..
         XC(i,v,r,t) =e= cap(i,v,r) * lifetime(i,v,r,t) ;
exlife_chp(ivrt(chp(i),oldv(v),r,t))$(t.val ge 2031 and tmyopic(t))..
         XC(i,v,r,t) =l= cap(i,v,r) * lifetime(i,v,r,t) ;
* Bioenergy cannot be decommissioned before lifetime
exlife_bio(ivrt(i,oldv(v),r,t))$(sameas(i,"Bioenergy") or sameas(i,"Bio_CHP") and t.val ge 2023 and t.val le 2030 and tmyopic(t))..
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
investlimUP(i,r,t)$(new(i) and conv(i) and invlimUP(i,r,t) and t.val ge 2023 and tmyopic(t))..
         IX(i,r,t) =l= invlimUP(i,r,t) ;
* Lower limit
investlimLO(i,r,t)$(new(i) and invlimLO(i,r,t) and t.val ge 2023 and tmyopic(t))..
         IX(i,r,t) =g= invlimLO(i,r,t) ;
* Upper limit for whole system (in general deactivated)
investlimUP_eu(i,t)$(invlimUP_eu(i,t) < inf and t.val ge 2023 and tmyopic(t))..
         sum(r, IX(i,r,t)) =l= invlimUP_eu(i,t) ;

investlimUP_irnw(irnw(i),r,t,quantiles)$(irnwlimUP_quantiles(i,r,quantiles) and tmyopic(t) and not sameas(i,"Hydro") and t.val ge 2023)..       
        sum(irnw_mapq(i,quantiles), sum(v, XC(i,v,r,t))) 
        =l= irnwlimUP_quantiles(i,r,quantiles) ;

* * * * * Transmission equations

* * * Enforce capacity constraint on inter-region trade flows
tcapacity(s,k,r,rr,t)$(tmap(k,r,rr) and tmyopic(t))..
         E(s,k,r,rr,t) =l= TCS(s,k,r,rr,t) ;
* Accumulation of transmission capacity investments
tinvestexi(k,r,rr,t)$(tmap(k,r,rr) and t.val le 2022 and tmyopic(t))..
         TC(k,r,rr,t) =l= tcap(k,r,rr) + IT(k,r,rr,t) ;
tinvestnew(k,r,rr,t)$(tmap(k,r,rr) and t.val ge 2023 and tmyopic(t))..
         TC(k,r,rr,t) =l= IT(k,r,rr,t) + TC(k,r,rr,t-1) ;
* Upper limit
tinvestlimUP(k,r,rr,t)$(tmap(k,r,rr) and tinvlimUP(k,r,rr,t) and t.val ge 2022 and tmyopic(t))..
         TC(k,r,rr,t) =l= tinvlimUP(k,r,rr,t) ;
* Lower limit
tinvestlimLO(k,r,rr,t)$(tmap(k,r,rr) and tinvlimLO(k,r,rr,t) and t.val ge 2022 and tmyopic(t))..
         TC(k,r,rr,t) =g= tinvlimLO(k,r,rr,t) ;
* Upper limit for whole system (in general deactivated)
tinvestlimUP_eu(k,t)$(tinvlimUP_eu(k,t) < inf and t.val ge 2022 and tmyopic(t))..
         sum((r,rr), TC(k,r,rr,t)) =l= tinvlimUP_eu(k,t) ;


* * * * * Storage equations

* * * Storage charge-discharge and accumulation
* Charge must not exceed charge capacity (size of door - entry)
chargelim(s,jvrt(j,v,r,t))$tmyopic(t)..
         G(s,j,v,r,t)  =l= GCS(s,j,v,r,t) ;
* Discharge must not exceed charge capacity (size of door - exit)
dischargelim(s,jvrt(j,v,r,t))$tmyopic(t)..
         GD(s,j,v,r,t) =l= GCS(s,j,v,r,t) ;
* Dynamic accumulation of storage balance (automatic discharge and charge efficiency apply here)
storagebal(s,jvrt(j,v,r,t))$(sameas(j,"PumpStorage") and tmyopic(t))..
         GB(s,j,v,r,t) =e= GB(s-1,j,v,r,t) * (1 - dischrg(j,v,r)) +
$if      set storage_absweights   hours(s) *
* MM (comment): number = 100 means that we "implicitly" model 87.6 storage cycles
$if      set storage_relweights   hours(s) * round(number / 8760,4) *
         (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;       
storagebalann(jvrt(j,v,r,t))$(tmyopic(t))..
         sum(s, hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r) - GD(s,j,v,r,t))) * 1e-3 =g= 0 ;
* Pumpstorage
storagebal_ps0(s,jvrt(j,v,r,t))$(sameas(s,"1") and sameas(j,"PumpStorage") and tmyopic(t))..
         GB(s,j,v,r,t) =e= 0.75 * ghours(j,v,r) * gcap(j,v,r) * (1 - dischrg(j,v,r)) * 1e-3 +       
$if not set pumppeak    hours(s) *
                        (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;                       
storagebal_ps(s,jvrt(j,v,r,t))$(s.val ge 2 and sameas(j,"PumpStorage") and tmyopic(t))..
         GB(s,j,v,r,t) =e= GB(s-1,j,v,r,t) * (1 - dischrg(j,v,r)) +       
$if not set pumppeak    hours(s) *
                        (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;                      
storagebalann_ps(jvrt(j,v,r,t))$(sameas(j,"PumpStorage") and tmyopic(t))..
         sum(s, hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r) - GD(s,j,v,r,t))) * 1e-3  =g= 0 ;
* Power-to-gas
storagebal_lt0(s,jvrt(j,v,r,t))$(sameas(s,"1") and sameas(j,"Storage_LT") and tmyopic(t))..
         GB(s,j,v,r,t) =e= 0.75 * ghours(j,v,r) * gcap(j,v,r) * (1 - dischrg(j,v,r)) * 1e-3 + hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;
storagebal_lt(s,jvrt(j,v,r,t))$(s.val ge 2 and sameas(j,"Storage_LT") and tmyopic(t))..
         GB(s,j,v,r,t) =e= GB(s-1,j,v,r,t) * (1 - dischrg(j,v,r)) + hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;
storagebalann_lt(jvrt(j,v,r,t))$(sameas(j,"Storage_LT") and tmyopic(t))..
         sum(s, hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r) - GD(s,j,v,r,t))) * 1e-3  =g= 0 ;
* Batteries
storagebal_st0(s,jvrt(j,v,r,t))$(sameas(s,"1") and sameas(j,"Storage_ST") and tmyopic(t))..
         GB(s,j,v,r,t) =e= 0.5 * ghours(j,v,r) * gcap(j,v,r) * (1 - dischrg(j,v,r)) * 1e-3 +  (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;
storagebal_st(s,jvrt(j,v,r,t))$(s.val ge 2 and sameas(j,"Storage_ST") and tmyopic(t))..
         GB(s,j,v,r,t) =e= GB(s-1,j,v,r,t) * (1 - dischrg(j,v,r)) +  (G(s,j,v,r,t) * chrgpen(j,v,r)  - GD(s,j,v,r,t)) * 1e-3 ;
storagebalann_st(jvrt(j,v,r,t))$(sameas(j,"Storage_ST") and tmyopic(t))..
         sum(s, hours(s) * (G(s,j,v,r,t) * chrgpen(j,v,r) - GD(s,j,v,r,t))) * 1e-3  =g= 0 ;

* Accumulated balance must not exceed storage capacity (size of room - reservoir)
storagelim(s,jvrt(j,v,r,t))$tmyopic(t)..
         GB(s,j,v,r,t) =l= ghours(j,v,r) * GCS(s,j,v,r,t) * 1e-3 ;

* * * Allow accumulation of storage charge capacity investments
ginvest(jvrt(newj(j),newv(v),r,t))$(tv(t,v) and tmyopic(t))..
         GC(j,v,r,t) =l= IG(j,r,t) + GC(j,v,r,t-1)$(sameas(v,"2050") and t.val > 2050);

* * * Existing storage vintages have fixed lifetime
* MM (todo): Think about implementing different constraints for myopic runs since it might be that endogenous decommissioning needs to get disablted anyway
* No decomissioning in 2015
gexlife2020(jvrt(j,oldv(v),r,t))$(t.val le 2022 and tmyopic(t))..
         GC(j,v,r,t) =e= gcap(j,v,r) * glifetime(j,v,r,t) ;
* Decommissioning possible >2015
gexlife(jvrt(j,oldv(v),r,t))$(t.val ge 2023 and tmyopic(t))..
         GC(j,v,r,t) =l= gcap(j,v,r) * glifetime(j,v,r,t) ;
* Avoid decommissioning of pump storage capacty
gexlife_pump(jvrt(j,oldv(v),r,t))$(sameas(j,"PumpStorage") and t.val ge 2023 and tmyopic(t))..
         GC(j,v,r,t) =e= gcap(j,v,r) * glifetime(j,v,r,t) ;

* * * New storage vintages have a lifetime profile for enforced retirement
gnewlife(jvrt(newj(j),newv(v),r,t))$(not sameas(v,"2050") and tmyopic(t))..
        GC(j,v,r,t) =l= glifetime(j,v,r,t) * sum(tv(tt,v), IG(j,r,tt));

* * * All storage vintages must be monotonically decreasing (except 2050)
gretire(jvrt(j,v,r,t))$(not sameas(v,"2050") and tmyopic(t))..
        GC(j,v,r,t+1) =l= GC(j,v,r,t) ;

* * * Upper and lower limits
* Upper limit
ginvestlimUP(j,r,t)$(t.val ge 2023 and tmyopic(t) and ginvlimUP(j,r,t) > 0)..
         IG(j,r,t) =l= ginvlimUP(j,r,t) ;
* Lower limit
ginvestlimLO(j,r,t)$(t.val ge 2023 and tmyopic(t) and ginvlimLO(j,r,t) > 0)..
         IG(j,r,t) =g= ginvlimLO(j,r,t) ;
* Upper limits for whole system (again mostly inactive)
ginvestlimUP_eu(j,t)$(newj(j) and ginvlimUP_eu(j,t) < inf and t.val ge 2023)..
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
cumbio(t)$(biolim_eu(t) and tmyopic(t))..                                   BC(t)           =l= biolim_eu(t) ;
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
ccsflow(t)$(tmyopic(t))..                        SC(t) =e=  sum(r, sum(ivrt(i,v,r,t), co2captured(i,v,r) * XTWH(i,v,r,t))) * 1e-3 ;
cumccs..                                         sum(t, nyrs(t) * SC(t)) =l= sclim_eu ;
* for each region (does not allow for system-wide trade)
ccsflow_r(r,t)$(tmyopic(t))..                    SC_r(r,t)  =e= sum(ivrt(i,v,r,t), co2captured(i,v,r) * XTWH(i,v,r,t)) * 1e-3 ;
cumccs_r(r)..                                    sum(t, nyrs(t) * SC_r(r,t)) =l= sclim(r) ;

* * * Structural equations to aid solver
xtwhdef(ivrt(i,v,r,t))$tmyopic(t)..                 XTWH(i,v,r,t)   =e= 1e-3 * sum(s, X(s,i,v,r,t) * hours(s)) ;
copyxc(s,ivrt(i,v,r,t))$tmyopic(t)..                XCS(s,i,v,r,t)  =e= XC(i,v,r,t)$(ord(s) eq 1)  + XCS(s-1,i,v,r,t)$(ord(s) > 1) ;
copygc(s,jvrt(j,v,r,t))$tmyopic(t)..                GCS(s,j,v,r,t)  =e= GC(j,v,r,t)$(ord(s) eq 1)  + GCS(s-1,j,v,r,t)$(ord(s) > 1) ;
copytc(s,k,r,rr,t)$(tmap(k,r,rr) and tmyopic(t))..  TCS(s,k,r,rr,t) =e= TC(k,r,rr,t)$(ord(s) eq 1) + TCS(s-1,k,r,rr,t)$(ord(s) > 1) ;

* * * Calibration equations
parameter
daref_new(r,t)
dref_new(r,t)
imp(r,t)
expo(r,t)
losss(s,r,t)
loss_new(r,t)
load_new(s,r)
gen_nucl(r,t)
gen_ngas(r,t)
gen_sola(r,t)
gen_biom(r,t)
gen_coal(r,t)
gen_wind(r,t)
gen_hydr(r,t)
lign_out(r,t)
;

$gdxin database\setpar_%n%.gdx
$load daref_new
$load dref_new
$load imp
$load expo
$load losss
$load loss_new
$load load_new
$load gen_nucl
$load gen_ngas
$load gen_sola
$load gen_biom
$load gen_coal
$load gen_wind
$load gen_hydr
$load lign_out
$gdxin
 
*daref(r,"2020") = daref_new(r,"2020") ;
*daref(r,"2021") = daref(r,"2020") + 1/5 * (daref(r,"2025") - daref(r,"2020")) ;
*daref(r,"2022") = daref(r,"2020") + 2/5 * (daref(r,"2025") - daref(r,"2020")) ;
*daref(r,"2023") = daref(r,"2020") + 3/5 * (daref(r,"2025") - daref(r,"2020")) ;
*daref(r,"2024") = daref(r,"2020") + 4/5 * (daref(r,"2025") - daref(r,"2020")) ;
*dref(r,t) = daref(r,t) / daref(r,"2020") ;
*loss(r) = loss_new(r,"2020") ;

* Calibration adjustment in case of wrong predictions
daref(r,t)$(t.val ge 2020 and daref(r,"2025") < daref_new(r,"2022")) = daref_new(r,t) ;
dref(r,t) = daref(r,t) / daref(r,"2020") ;

$if set loadnew     daref(r,"2020") = daref_new(r,"2020") ;
$if set loadnew     daref(r,"2021") = daref_new(r,"2021") ;
$if set loadnew     daref(r,"2022") = daref_new(r,"2022") ;
$if set loadnew     daref(r,"2023") = daref(r,"2022") + 1/3 * (daref(r,"2025") - daref(r,"2022")) ;
$if set loadnew     daref(r,"2024") = daref(r,"2022") + 2/3 * (daref(r,"2025") - daref(r,"2022")) ;
$if set loadnew     daref(r,t)$(t.val ge 2023 and daref(r,"2025") < daref_new(r,"2022")) = daref_new(r,t) ;
$if set loadnew     daref(r,"2023") = daref(r,"2022") + 1/3 * (daref(r,"2025") - daref(r,"2022")) ;
$if set loadnew     daref(r,"2024") = daref(r,"2022") + 2/3 * (daref(r,"2025") - daref(r,"2022")) ;
$if set lossnew     loss(r) = loss_new(r,"2022") ;

gen_coal(r,t)$(t.val ge 2023) = gen_coal(r,"2022") ;

equation
impUP(r,t)
impLO(r,t)
expUP(r,t)
expLO(r,t)
;

impUP(r,t)$(tmyopic(t) and sameas(t,"2022") and imp(r,t) > 0)..
sum(rr,  sum((s,k)$tmap(k,rr,r), hours(s) * E(s,k,rr,r,t))) =l= imp(r,t) ;

expUP(r,t)$(tmyopic(t) and sameas(t,"2022") and expo(r,t) > 0)..
sum(rr, sum((s,k)$tmap(k,rr,r), hours(s) * E(s,k,r,rr,t))) =l= expo(r,t) ;

impLO(r,t)$(tmyopic(t) and sameas(t,"2022") and imp(r,t) > 0)..
sum(rr,  sum((s,k)$tmap(k,rr,r), hours(s) * E(s,k,rr,r,t))) =g= imp(r,t) ;

expLO(r,t)$(tmyopic(t) and sameas(t,"2022") and expo(r,t) > 0)..
sum(rr, sum((s,k)$tmap(k,rr,r), hours(s) * E(s,k,r,rr,t))) =g= expo(r,t) ;

equation
genUP_nucl(r,t)
genGER_nucl(r,t)
genUP_ngas(r,t)
genUP_sola(r,t)
genUP_biom(r,t)
genUP_coal(r,t)
genUP_wind(r,t)                Generation constraint to calibrate for base year generation
genUP_hydr(r,t)
genLO_nucl(r,t)
genLO_ngas(r,t)
genLO_sola(r,t)
genLO_biom(r,t)
genLO_coal(r,t)
genLO_wind(r,t)                Generation constraint to calibrate for base year generation
genLO_hydr(r,t)
genUP_lign(r,t)
genLO_lign(r,t)
;

genGER_nucl(r,t)$(tmyopic(t) and sameas(t,"2023") and sameas(r,"Germany"))..
    sum(ivrt(nuc(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= 0 
$if set streckbetrieb                                   + 6.74             
$if set strext                                          + 6.74 + 10
    ;

genUP_nucl(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(nuc(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= gen_nucl(r,t) ;

genUP_ngas(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(gas(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= gen_ngas(r,t) ;
    
genUP_sola(r,t)$(tmyopic(t))..
    sum(ivrt(sol(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= gen_sola(r,t) ;
    
genUP_wind(r,t)$(tmyopic(t))..
    sum(ivrt(wind(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= gen_wind(r,t) ;
    
genUP_coal(r,t)$(tmyopic(t))..
    sum(ivrt("Coal",oldv(v),r,t), XTWH("Coal",v,r,t)) + sum(ivrt("Coa_CHP",oldv(v),r,t), XTWH("Coa_CHP",v,r,t)) +
    sum(ivrt("Lig_CHP",oldv(v),r,t), XTWH("Lig_CHP",v,r,t)) + sum(ivrt("Lignite",oldv(v),r,t), XTWH("Lignite",v,r,t)) =l= gen_coal(r,t) ;
          
genUP_biom(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(bio(i),oldv(v),r,t), XTWH(i,v,r,t)) =l= gen_biom(r,t) ; 
    
genUP_hydr(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt("Hydro",oldv(v),r,t), XTWH("Hydro",v,r,t)) =l= gen_hydr(r,t) ;
    
genLO_nucl(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(nuc(i),oldv(v),r,t), XTWH(i,v,r,t)) =g= gen_nucl(r,t) ;

genLO_ngas(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(gas(i),oldv(v),r,t), XTWH(i,v,r,t)) =g= gen_ngas(r,t) ;
    
genLO_sola(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(sol(i),oldv(v),r,t), XTWH(i,v,r,t)) =g= gen_sola(r,t) ;
    
genLO_wind(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(wind(i),oldv(v),r,t), XTWH(i,v,r,t)) =g= gen_wind(r,t) ;
    
genLO_coal(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt("Coal",oldv(v),r,t), XTWH("Coal",v,r,t)) + sum(ivrt("Coa_CHP",oldv(v),r,t), XTWH("Coa_CHP",v,r,t)) +
    sum(ivrt("Lig_CHP",oldv(v),r,t), XTWH("Lig_CHP",v,r,t)) + sum(ivrt("Lignite",oldv(v),r,t), XTWH("Lignite",v,r,t)) =g= gen_coal(r,t) ;
    
genLO_biom(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt(bio(i),oldv(v),r,t), XTWH(i,v,r,t)) =g= gen_biom(r,t) ; 
    
genLO_hydr(r,t)$(tmyopic(t) and sameas(t,"2022"))..
    sum(ivrt("Hydro",oldv(v),r,t), XTWH("Hydro",v,r,t)) =g= gen_hydr(r,t) ;
    
set
rlignite(r)
;

rlignite(r)$(sameas(r,"Bulgaria") or sameas(r,"Czech") or sameas(r,"Germany") or sameas(r,"Greece") or sameas(r,"Hungary") or sameas(r,"Poland") or sameas(r,"Romania") or sameas(r,"Slovakia") or sameas(r,"Slovenia")) = YES ;

lign_out(r,t)$(t.val ge 2022) = lign_out(r,"2021") ;

genUP_lign(r,t)$(tmyopic(t) and rlignite(r))..
    sum(ivrt("Lig_CHP",oldv(v),r,t), XTWH("Lig_CHP",v,r,t)/effrate("Lig_CHP",v,r)) + sum(ivrt("Lignite",oldv(v),r,t), XTWH("Lignite",v,r,t)/effrate("Lignite",v,r)) =l= lign_out(r,t) * 1.1 ;
 
genLO_lign(r,t)$(tmyopic(t) and rlignite(r))..
    sum(ivrt("Lig_CHP",oldv(v),r,t), XTWH("Lig_CHP",v,r,t)/effrate("Lig_CHP",v,r)) + sum(ivrt("Lignite",oldv(v),r,t), XTWH("Lignite",v,r,t)/effrate("Lignite",v,r)) =g= lign_out(r,t) * 0.9 ;
     


* * * Targets equations  
equation
convtarget(i,r,t)
;

convtarget(i,r,t)$(sameas(i,"Nuclear") and sameas(r,"France") and t.val ge 2035 and tmyopic(t))..
    sum(ivrt(i,v,r,t)$(v.val le t.val), XTWH(i,v,r,t)) =g= 0.75 * daref(r,t) * (1 + loss(r)) ;

parameter
sha_constant(r,t)
sha_extra(r,t)
gen_constant(r,t)
gen_extra(r,t)
cap_constant(r,superirnw,t)
cap_constant_int(r,superirnw,t)
cap_extra(r,superirnw,t)
cap_extra_int(r,superirnw,t)
;

$onecho >temp\gdxxrw.rsp
par=sha_constant     rng=sha_constant!a2    rdim=1 cdim=1
par=sha_extra        rng=sha_extra!a2       rdim=1 cdim=1
par=cap_constant     rng=cap_constant!a2    rdim=2 cdim=1
par=cap_extra        rng=cap_extra!a2       rdim=2 cdim=1
$offecho

$call 'gdxxrw i=restarget\restarget.xlsx o=restarget\restarget.gdx trace=3 log=temp\restarget.log @temp\gdxxrw.rsp';

$gdxin restarget\restarget
$load sha_constant
$load sha_extra
$load cap_constant
$load cap_extra
$gdxin

gen_constant(r,t) = round(sha_constant(r,t) * daref(r,t) * (1 + loss(r)), 4) ;
gen_extra(r,t)    = round(sha_extra(r,t) * daref(r,t) * (1 + loss(r)), 4) ;

cap_constant_int(r,superirnw,t) = cap_constant(r,superirnw,t) ;
cap_constant(r,superirnw,t)$(cap_constant(r,superirnw,t) > 0) = min(cap_constant(r,superirnw,t),sum(superirnw_mapq(i,quantiles,superirnw), irnwlimUP_quantiles(i,r,quantiles)));

cap_extra_int(r,superirnw,t) = cap_extra(r,superirnw,t) ;
cap_extra(r,superirnw,t)$(cap_extra(r,superirnw,t) > 0) = min(cap_extra(r,superirnw,t),sum(superirnw_mapq(i,quantiles,superirnw), irnwlimUP_quantiles(i,r,quantiles)));

equation
resmarket(r,t) equation that ensures renewable generation target
capmarket(superirnw,r,t) equation that ensure renewable cap target
;

resmarket(r,t)$(t.val ge 2023 and tmyopic(t)
$if set constantgentargets        and gen_constant(r,t)
$if set extragentargets           and gen_extra(r,t) 
    )..
    sum(ivrt(rnw(i),v,r,t), XTWH(i,v,r,t)) =g=
$if set constantgentargets        gen_constant(r,t) +
$if set extragentargets           gen_extra(r,t) +
        0 ;
  

capmarket(superirnw,r,t)$(tmyopic(t) 
$if not set uselimits             and t.val ge 2023
$if     set uselimits             and t.val ge 2026   
$if set constantcaptargets        and cap_constant(r,superirnw,t)
$if set extracaptargets           and cap_extra(r,superirnw,t) 
    )..
    sum(superirnw_mapq(i,quantiles,superirnw), sum(ivrt(i,v,r,t), XC(i,v,r,t))) =g=
$if set constantcaptargets        cap_constant(r,superirnw,t) +
$if set extracaptargets           cap_extra(r,superirnw,t) +
        0 ;



* * * EU ETS MSR version of the model (this condition is deactivated if not "euetsmsr=yes")
PARAMETER
co2ele_int(t)

co2ind_int(t)
co2avi_int(t)
co2shi_int(t)
co2out_int(t)

co2can_int(t)
co2indfix_int(t)
co2indorgfix_int(t)
co2indshare_int(t)

co2ele_org_int(t)
co2ind_org_int(t)

co2add_int(t)
co2allocated_int(t)
co2auctioned_int(t)

tnac_int(t)
tnacuse_int(t)
tnacres_int(t)
tnacresuse_int(t)

msr_int(t)
msrin_int(t)
co2eleuk_int(t)
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
par=co2ele_org          rng=co2ele_org!a2            rdim=1 cdim=0
par=co2ind_org          rng=co2indorg_in!a2            rdim=1 cdim=0
par=co2add_in           rng=co2add_in!a2             rdim=1 cdim=0 
par=co2allocated_in     rng=co2allocated_in!a2       rdim=1 cdim=0
par=co2auctioned_in     rng=co2auctioned_in!a2       rdim=1 cdim=0
par=msr_in              rng=msr_in!a2                rdim=1 cdim=0
par=msrin_in            rng=msrin_in!a2              rdim=1 cdim=0
par=tnac_in             rng=tnac_in!a2               rdim=1 cdim=0
par=tnacuse_in          rng=tnacuse_in!a2            rdim=1 cdim=0
par=co2eleuk_in         rng=co2eleuk_in!a2           rdim=1 cdim=0
$offecho
* * Indformula routine
* Define iterative loading loop (iter 0 always loads from the "base" files)

$call 'gdxxrw i=euetsmsr\%p%\%s%.xlsx o=euetsmsr\%p%\%s%.gdx trace=3 log=temp\%p%_%s%.log @temp\gdxxrw.rsp';
$gdxin          euetsmsr\%p%\%s%

* * Final load
$load co2ele_int=co2ele_in

$load co2ind_int=co2ind_in
$if not set oldsheets   $load co2avi_int=co2avi_in
$if not set oldsheets   $load co2shi_int=co2shi_in
$if not set oldsheets   $load co2out_int=co2out_in

$load co2indfix_int=co2indfix_in
$if not set oldsheets   $load co2indorgfix_int=co2indorgfix_in
$load co2indshare_int=co2indshare_in

$load co2ind_org_int=co2ind_org
$load co2ele_org_int=co2ele_org

$load co2add_int=co2add_in
$load co2can_int=co2can_in
$load co2allocated_int=co2allocated_in
$load co2auctioned_int=co2auctioned_in

$load tnac_int=tnac_in
$load tnacuse_int=tnacuse_in
$if not set oldsheets   $load tnacres_int=tnacres_in
$if not set oldsheets   $load tnacresuse_int=tnacresuse_in

$load msr_int=msr_in
$load msrin_int=msrin_in
$load co2eleuk_int=co2eleuk_in
$gdxin

PARAMETER
co2ele_in(t)

co2ind_in(t)
co2avi_in(t)
co2shi_in(t)
co2out_in(t)

co2can_in(t)
co2indfix_in(t)
co2indorgfix_in(t)
co2indshare_in(t)

co2ele_org(t)
co2ind_org(t)

co2add_in(t)
co2allocated_in(t)
co2auctioned_in(t)

tnac_in(t)
tnacuse_in(t)

msr_in(t)
msrin_in(t)
msrstart_in
tnacstart_in
co2eleuk_in(t)
;

co2ele_in(t) = round(co2ele_int(t), 4) ;

co2ind_in(t) = round(co2ind_int(t), 4) ;
$if not set oldsheets   co2avi_in(t) = round(co2avi_int(t), 4) ;
$if not set oldsheets   co2shi_in(t) = round(co2shi_int(t), 4) ;
$if not set oldsheets   co2out_in(t) = round(co2out_int(t), 4) ;
$if     set oldsheets   co2avi_in(t) = 0 ;
$if     set oldsheets   co2shi_in(t) = 0 ;
$if     set oldsheets   co2out_in(t) = 0;

co2indfix_in(t) = round(co2indfix_int(t), 4) ;
$if not set oldsheets   co2indorgfix_in(t) = round(co2indorgfix_int(t), 4) ;
co2indshare_in(t) = round(co2indshare_int(t), 4) ;

co2ele_org(t) = round(co2ele_org_int(t), 4) ;
co2ind_org(t) = round(co2ind_org_int(t), 4) ;

co2can_in(t) = round(co2can_int(t), 4) ;
co2add_in(t) = round(co2add_int(t), 4) ;
co2allocated_in(t) = round(co2allocated_int(t), 4) ;
co2auctioned_in(t) = round(co2auctioned_int(t), 4) ;

tnac_in(t) =
$if not set hedgeeua    round(tnac_int(t), 4) ;
$if     set hedgeeua    round(tnacres_int(t), 4) ;

tnacuse_in(t) = 
$if not set hedgeeua    round(tnacuse_int(t), 4) ;
$if     set hedgeeua    round(tnacresuse_int(t), 4) ;

msr_in(t) = round(msr_int(t), 4) ;
msrin_in(t) = round(msrin_int(t), 4) ;
msrstart_in = 
$if     set co2mips     round(msr_int("2021"), 4) ;
$if not set co2mips     round(msr_int("2021"), 4) ;

tnacstart_in =
$if     set co2mips     round(tnac_int("2021"), 4) ;
$if not set co2mips     round(tnac_int("2021"), 4) ;

co2eleuk_in(t) = round(co2eleuk_int(t), 4) ;

parameter
co2elecind(t)
;

$if not set oldsheets   co2elecind(t) = co2indshare_in(t) ;
$if     set oldsheets   co2elecind(t) = (1 - co2indfix_in(t)) * co2indshare_in(t) ;
$if     set oldsheets   co2indorgfix_in(t) = co2indfix_in(t) * co2ind_org(t) ;

* * * Simple carbon market without MSR dynamics
PARAMETER
co2sup(t)
;

co2sup(t) = co2add_in(t) + co2allocated_in(t) + co2auctioned_in(t) - msrin_in(t) ;
 
POSITIVE VARIABLE
TNAC(t)             Cumulative banked allowances (Mt)
;

VARIABLE
EC(t)               Annual flow of CO2 emissions (MtCO2)
ECEU(t)             Annual flow of CO2 emissions (MtCO2) in European Union (plus Norway and Switzerland and Northern Ireland)
ECUK(t)             Annual flow of CO2 emissions (MtCO2) in UK (not Northern Ireland)
EC_r(r,t)           Annual flow of CO2 emissions (MtCO2)
TNACUSE(t)          Allowance usage from bank (Mt)
;

* Determine some general starting/ending variables and variable ranges
TNAC.FX("2020") = tnac_in("2020") ;
TNAC.FX("2021") = tnac_in("2021") ;
*$if     set real2022     TNAC.FX("2022") = tnac_in("2022") ;   
TNAC.FX("2045") = 0 ;
TNAC.FX("2050") = 0 ;

TNACUSE.FX("2020") = tnacuse_in("2020") ;
TNACUSE.FX("2021") = tnacuse_in("2021") ;
*$if     set real2022     TNACUSE.FX("2022") = tnacuse_in("2022") ;
TNACUSE.FX("2050") = 0 ;

$if not set banking     TNAC.FX(t)     = tnac_in(t) ;
$if not set banking     TNACUSE.FX(t)  = tnacuse_in(t) ;

$if set co2iter ECEU.UP(t)$(t.val ge 2022 and t.val le 2045) = co2ele_in(t) + 10 ;
$if set co2iter ECEU.LO(t)$(t.val ge 2022 and t.val le 2045) = co2ele_in(t) - 10 ;

EQUATION
co2flow(t)              Annual flow of CO2 emissions (regional) (Mt)
co2market(t)            Cap market for CO2 emissions (regional) (Mt)
co2flow_r(r,t)          Annual flow of CO2 emissions (regional) (Mt)
co2market_r(r,t)        Cap market for CO2 emissions (regional) (Mt)
co2floweu(t)            Annual flow of CO2 emissions (system) (Mt)
co2marketeu(t)          Cap market for CO2 emissions (system) (Mt)
co2tnac(t)              Total number of allowances in circulation (system) (Mt)
co2flowuk(t)            Annual flow of CO2 emissions (regional) (Mt)
ukets(t)                Cap market for British CO2 emissions (Mt)
;

co2flow(t)$(tmyopic(t))..               EC(t)                                                          =e= sum(r, sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;
co2market(t)$(tmyopic(t))..             EC(t)                                                          =e= co2ele_in(t) + co2eleuk_in(t) ;

co2flow_r(r,t)$(tmyopic(t))..           EC_r(r,t) =e= sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t)) ;
co2market_r(r,t)$(tmyopic(t))..         EC_r(r,t) =l= co2cap_r(r,t) ;

co2floweu(t)$(tmyopic(t))..             ECEU(t)                                                        =e= sum(r$(not sameas(r,"Britain")), sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;
co2marketeu(t)$(tmyopic(t))..           ECEU(t) * (1 + co2elecind(t)) + co2indorgfix_in(t) + co2can_in(t) + co2avi_in(t) + co2shi_in(t) =l= co2sup(t) + TNACUSE(t)
$if     set hedgeeua                                                                                                                        - co2out_in(t)
                                        ;
co2tnac(t)$(tmyopic(t) and t.val le 2045 and t.val ge 2022)..               TNAC(t)                                                        =e= tnacstart_in - sum(tt$(tt.val le t.val and tt.val ge 2022), TNACUSE(tt) * nyrs(tt)) ;

co2flowuk(t)$tmyopic(t)..               ECUK(t) =e= sum(r$(sameas(r,"Britain")),     sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH(i,v,r,t))) ;
ukets(t)$(tmyopic(t))..                 ECUK(t) =l= co2eleuk_in(t) ;

* * * Iterative "shortrun" EU ETS MSR version of the model (this module is deactived if not "co2iter=yes")
EQUATION
it_euets(t)
it_tnac(t)
;

it_euets(t)$(tmyopic(t))..                          ECEU(t) * (1 + co2elecind(t)) + co2indorgfix_in(t) + co2can_in(t) + co2avi_in(t) + co2shi_in(t) =l= co2sup(t) + TNACUSE(t)
$if     set hedgeeua                                                                                                                        - co2out_in(t)
                                                                        ;
it_tnac(t)$(tmyopic(t)  and t.val le 2045 and t.val ge 2022)..        TNAC(t) =e= tnacstart_in - sum(tt$(tt.val le t.val and tt.val ge 2022), TNACUSE(tt) * nyrs(tt)) ;


* * * MIP EU ETS MSR version of the model
BINARY VARIABLE
UPP(t)                  TNAC is above 833 Mio
MID(t)                  TNAC is between 400 and 800 Mio
UPPMID(t)               TNAC is between 833 and 1096 Mio
LOWMID(t)               TNAC is between 200 and 400 Mio
LOW(t)                  TNAC is below 200 Mio
;

POSITIVE VARIABLE
MSR(t)
CANCEL(t)
MSROUT(t)
MSRIN(t)
;

* * * Reduced shortrun EU ETS MSR version of the model
EQUATION
eqs_euets(t)

eqs_msrin2023_fix(t)
eqs_msrin2023(t)
eqs_msrin_old(t)
eqs_msrin_new(t)

eqs_msrout2023(t)
eqs_msrout_old(t)
eqs_msrout_new(t)
eqs_msrout2030_old(t)
eqs_msrout2030_new(t)
eqs_msrout2045(t)

eqs_msrinout(t)
eqs_binary(t)

eqs_tnac(t)
eqs_tnacup(t)
eqs_tnaclo(t)


eqs_msr(t)
eqs_msrUP_old(t)
eqs_msrUP_new(t)

eqs_cancel2023(t)
eqs_cancel_old(t)
eqs_cancel_new(t)
eqs_cancel2045(t)
eqs_cancel2045_spe(t)
;

eqs_euets(t)$(tmyopic(t))..                                                 ECEU(t) * (1 + co2elecind(t)) + co2indorgfix_in(t) + co2can_in(t) + co2avi_in(t) + co2shi_in(t)
                                                                                                        =e= co2add_in(t) + co2allocated_in(t) + (co2auctioned_in(t) - MSRIN(t) + MSROUT(t)) + TNACUSE(t)
$if     set hedgeeua                                                                                        - co2out_in(t)
                                                                            ;
eqs_msrin2023_fix(t)$((t.val ge 2023 and t.val le 2023) and tmyopic(t))..   MSRIN(t)                    =e= 0.12 * TNAC(t-1) ;
eqs_msrin2023(t)$((t.val ge 2023 and t.val le 2023) and tmyopic(t))..       MSRIN(t)                    =e= UPP(t-1) * 0.12 * TNAC(t-1) + UPPMID(t-1) * 0.12 * TNAC(t-1) ;
eqs_msrin_old(t)$((t.val ge 2024 and t.val le 2040) and tmyopic(t))..       MSRIN(t)                    =e= UPP(t-1) * 0.12 * TNAC(t-1) + UPPMID(t-1) * (TNAC(t-1) - 833) * 0.5 ;
eqs_msrin_new(t)$((t.val ge 2024 and t.val le 2040) and tmyopic(t))..       MSRIN(t)                    =e= UPP(t-1) * 0.24 * TNAC(t-1) + UPPMID(t-1) * (TNAC(t-1) - 833) ;

eqs_msrout2023(t)$((t.val ge 2023 and t.val le 2023) and tmyopic(t))..      MSROUT(t)                   =l= LOW(t-1) * 100 + LOWMID(t-1) * 100 ;
eqs_msrout_old(t)$((t.val ge 2024 and t.val le 2045) and tmyopic(t))..      MSROUT(t)                   =l= LOW(t-1) * 100 + LOWMID(t-1) * 2.5 * (400 - TNAC(t-1)) ;
eqs_msrout_new(t)$((t.val ge 2024 and t.val le 2045) and tmyopic(t))..      MSROUT(t)                   =l= LOW(t-1) * 200 + LOWMID(t-1) * 5 * (400 - TNAC(t-1)) ;
eqs_msrout2030_old(t)$((t.val ge 2024 and t.val le 2030) and tmyopic(t))..  MSROUT(t)                   =l= LOW(t-1) * 100 + LOWMID(t-1) * 2.5 * (400 - TNAC(t-1)) ;
eqs_msrout2030_new(t)$((t.val ge 2024 and t.val le 2030) and tmyopic(t))..  MSROUT(t)                   =l= LOW(t-1) * 200 + LOWMID(t-1) * 5 * (400 - TNAC(t-1)) ;
eqs_msrout2045(t)$((t.val ge 2031 and t.val le 2045) and tmyopic(t))..      MSROUT(t)                   =e= (LOW(t-1) + LOWMID(t-1)) * MSR(t-1) / nyrs(t) ;

eqs_msrinout(t)$((t.val ge 2023 and t.val le 2045) and tmyopic(t))..        MSRIN(t) * (LOW(t) + LOWMID(t))                  =e= MSROUT(t) * (UPP(t) + UPPMID(t)) ;
eqs_binary(t)$((t.val ge 2022 and t.val le 2040) and tmyopic(t))..          LOW(t) + LOWMID(t) + UPP(t) + UPPMID(t) + MID(t) =e= 1 ;

eqs_tnac(t)$((t.val ge 2022 and t.val le 2045) and tmyopic(t))..            TNAC(t)                     =e= tnacstart_in - sum(tt$(tt.val le t.val and tt.val ge 2022), TNACUSE(tt) * nyrs(tt)) ;
eqs_tnacup(t)$((t.val ge 2022 and t.val le 2040) and tmyopic(t))..          TNAC(t)                     =g=                LOWMID(t) * 360 + MID(t) * 400 + UPPMID(t) *  833 + UPP(t) * 1096 ;
eqs_tnaclo(t)$((t.val ge 2022 and t.val le 2040) and tmyopic(t))..          TNAC(t)                     =l= LOW(t) * 360 + LOWMID(t) * 400 + MID(t) * 833 + UPPMID(t) * 1096 + UPP(t) * 2000 ;

eqs_msr(t)$((t.val ge 2022 and t.val le 2045) and tmyopic(t))..             MSR(t)                      =e= msrstart_in  + sum(tt$(tt.val le t.val and tt.val ge 2022), (MSRIN(tt) - MSROUT(tt) - CANCEL(tt)) * nyrs(tt)) ;
eqs_msrUP_old(t)$((t.val ge 2023 and t.val le 2045) and tmyopic(t))..       MSR(t)                      =l= (co2auctioned_in(t-1) - MSR(t-1) + MSROUT(t-1)) ;
eqs_msrUP_new(t)$((t.val ge 2023 and t.val le 2045) and tmyopic(t))..       MSR(t)                      =l= 400 ;

eqs_cancel2023(t)$((t.val ge 2023 and t.val le 2023) and tmyopic(t))..      CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - (co2auctioned_in(t-1) - MSRIN(t-1) + MSROUT(t-1)) ;
eqs_cancel_old(t)$((t.val ge 2024 and t.val le 2040) and tmyopic(t))..      CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - (co2auctioned_in(t-1) - MSRIN(t-1) + MSROUT(t-1)) ;
eqs_cancel_new(t)$((t.val ge 2024 and t.val le 2040) and tmyopic(t))..      CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - 400 ;
eqs_cancel2045(t)$((t.val ge 2024 and t.val le 2040) and tmyopic(t))..      CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - 400 ;
eqs_cancel2045_spe(t)$((t.val ge 2045 and t.val le 2045) and tmyopic(t))..  CANCEL(t)                   =e= MSR(t-1) + MSRIN(t) - MSROUT(t) - 0 ;

Parameter
cancel_in(t)
;

cancel_in(t)$(t.val ge 2023 and t.val le 2023) = msr_in(t-1) + msrin_in(t) -  (co2auctioned_in(t-1) - msrin_in(t-1)) ;
$if      set euetsold    cancel_in(t)$(t.val ge 2024 and t.val le 2040 and (msr_in(t-1) + msrin_in(t) - (co2auctioned_in(t-1) - msrin_in(t-1)) > 0)) = msr_in(t-1) + msrin_in(t) - (co2auctioned_in(t-1) - msrin_in(t-1)) ;
$if      set euetsmsrin  cancel_in(t)$(t.val ge 2024 and t.val le 2040 and (msr_in(t-1) + msrin_in(t) - (co2auctioned_in(t-1) - msrin_in(t-1)) > 0)) = msr_in(t-1) + msrin_in(t) - (co2auctioned_in(t-1) - msrin_in(t-1)) ;
$if      set euetscancel cancel_in(t)$(t.val ge 2024 and t.val le 2040 and (msr_in(t-1) + msrin_in(t) - 400) > 0) = msr_in(t-1) + msrin_in(t) - 400 ;
$if      set euetsnew    cancel_in(t)$(t.val ge 2024 and t.val le 2040 and (msr_in(t-1) + msrin_in(t) - 400) > 0) = msr_in(t-1) + msrin_in(t) - 400 ;
cancel_in(t)$(sameas(t,"2045") and (msr_in(t-1) + msrin_in(t) - 0 > 0))                 = msr_in(t-1) + msrin_in(t) - 0 ;





$if      set co2mips  $if not  set msrin2023                                    MSRIN.FX("2023") = msrin_in("2023") ;
$if      set co2mips  $if not  set msrout2023                                   MSROUT.FX("2023") = 0 ;

* Define priors
$if      set co2mips  ECEU.L(t) = co2ele_in(t) ;
$if      set co2mips  TNACUSE.L(t)                 = tnacuse_in(t) ;
$if      set co2mips  TNAC.L(t)                    = tnac_in(t) ;
$if      set co2mips  CANCEL.L(t)                  = cancel_in(t) ;
$if      set co2mips  MSRIN.L(t)$(msr_in(t) >= 0)  =   msrin_in(t) ;
$if      set co2mips  MSRIN.L(t)$(msr_in(t) < 0)  = 0 ;
$if      set co2mips  MSROUT.L(t)$(msr_in(t) >= 0)  = 0 ;
$if      set co2mips  MSROUT.L(t)$(msr_in(t) < 0)  = - msrin_in(t) ;
$if      set co2mips  LOW.L(t)$(tnac_in(t) <  360) = 1 ;
$if      set co2mips  LOW.L(t)$(tnac_in(t) >= 360) = 0 ;
$if      set co2mips  LOWMID.L(t)$(tnac_in(t) <  400 and tnac_in(t) >= 360) = 1 ;
$if      set co2mips  LOWMID.L(t)$(tnac_in(t) >= 400 or  tnac_in(t) < 360) = 0 ;
$if      set co2mips  MID.L(t)$(tnac_in(t) <= 833 and tnac_in(t) >= 400) = 1 ;
$if      set co2mips  MID.L(t)$(tnac_in(t) <  400 or  tnac_in(t) >  833) = 0 ;
$if      set co2mips  UPPMID.L(t)$(tnac_in(t) >  833 and tnac_in(t) <= 1096) = 1 ;
$if      set co2mips  UPPMID.L(t)$(tnac_in(t) <= 833 or  tnac_in(t) >  1096) = 0 ;
$if      set co2mips  UPP.L(t)$(tnac_in(t) >  1096) = 1 ;
$if      set co2mips  UPP.L(t)$(tnac_in(t) <= 1096) = 0 ;


$if      set co2mips  MSRIN.FX("2020") = msrin_in("2020") ;
$if      set co2mips  MSRIN.FX("2021") = msrin_in("2021") ;
$if      set co2mips  MSRIN.FX("2022") = msrin_in("2022") ;
$if      set co2mips  MSRIN.FX("2045") = 0 ;
$if      set co2mips  MSRIN.FX("2050") = 0 ;

* Fix variables
$if      set co2mips  MSR.FX("2020") = msr_in("2020") ;
$if      set co2mips  MSR.FX("2021") = msr_in("2021") ;
*$if      set co2mips  MSR.FX("2045") = 0 ;
$if      set co2mips  MSR.FX("2050") = 0 ;
$if      set co2mips  MSROUT.FX("2020") = 0 ;
$if      set co2mips  MSROUT.FX("2021") = 0 ;
$if      set co2mips  MSROUT.FX("2022") = 0 ;
$if      set co2mips  MSROUT.FX("2050") = 0 ;
$if      set co2mips  LOW.FX("2020") = 0 ;
$if      set co2mips  LOW.FX("2021") = 0 ;
$if      set co2mips  LOWMID.FX("2020") = 0 ;
$if      set co2mips  LOWMID.FX("2021") = 0 ;
$if      set co2mips  MID.FX("2020") = 0 ;
$if      set co2mips  MID.FX("2021") = 0 ;
$if      set co2mips  UPPMID.FX("2020") = 0 ;
$if      set co2mips  UPPMID.FX("2021") = 0 ;
$if      set co2mips  UPP.FX("2020") = 1 ;
$if      set co2mips  UPP.FX("2021") = 1 ;
$if      set co2mips  CANCEL.FX("2020") = 0 ;
$if      set co2mips  CANCEL.FX("2021") = 0 ;
;

parameter
co2diff(t)
;

equation
eqs_co2real2022(t)
eqs_co2monoUP(t)
eqs_co2monoLO(t)
;

co2diff(t)$(t.val ge 2021 and tmyopic(t) and (co2ele_in(t) - co2ele_in(t-1) >= 0)) = co2ele_in(t) - co2ele_in(t-1) ;
co2diff(t)$(t.val ge 2021 and tmyopic(t) and (co2ele_in(t) - co2ele_in(t-1) < 0)) = 0 ;

eqs_co2real2022(t)$(sameas(t,"2022"))..
                        ECEU(t) =e= co2ele_in(t) ;      
                        
eqs_co2monoUP(t)$(tmyopic(t) and t.val ge 2023 and t.val le 2030)..
    ECEU(t) =l= ECEU(t-1) + co2diff(t) + 25 ;
    
eqs_co2monoLO(t)$(tmyopic(t) and t.val ge 2023 and t.val le 2030)..
    ECEU(t) =g= ECEU(t-1) + co2diff(t) - 50 ;
    
    
 
* * * Ukraine Russian war investment lag module (should work for both shortrun and not)
parameter
ixfx(i,r,t)
itfx(k,r,r,t)
igfx(j,r,t)
;

$if set uselimits       $if     set banking     $gdxin limits\%l%_bauprice_%a%.gdx
$if set uselimits       $if not set banking     $gdxin limits\%l%_bauprice_%a%_nobanking.gdx

$if set uselimits                               $load ixfx, itfx, igfx
$if set uselimits                               $gdxin
* Investment limits depending on (not) shortrun modeling
$if set uselimits                               IX.UP(conv(i),r,t)$(t.val le 2030)      = ixfx(i,r,t) ;
$if set uselimits                               IX.UP(nuc(i),r,t)$(t.val le 2030)       = ixfx(i,r,t) ;

$if set uselimits       $if     set shortrun    IX.UP(sol(i),r,t)$(t.val le 2022)       = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(sol(i),r,t)$(t.val = 2023)        = round(ixfx(i,r,t) * 1.5   + 10 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(sol(i),r,t)$(t.val = 2024)        = round(ixfx(i,r,t) * 2     + 20 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(sol(i),r,t)$(t.val = 2025)        = round(ixfx(i,r,t) * 3     + 30 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set shortrun    IX.UP(windon(i),r,t)$(t.val le 2023)    = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windon(i),r,t)$(t.val = 2024)     = round(ixfx(i,r,t) * 1.5   +  5 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windon(i),r,t)$(t.val = 2025)     = round(ixfx(i,r,t) * 2     + 10 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windon(i),r,t)$(t.val = 2026)     = round(ixfx(i,r,t) * 3     + 15 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set shortrun    IX.UP(windoff(i),r,t)$(t.val le 2024)   = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windoff(i),r,t)$(t.val = 2025)    = round(ixfx(i,r,t) * 1.5   +  1 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windoff(i),r,t)$(t.val = 2026)    = round(ixfx(i,r,t) * 2     +  2 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortrun    IX.UP(windoff(i),r,t)$(t.val = 2027)    = round(ixfx(i,r,t) * 3     +  3 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set shortlong    IX.UP(sol(i),r,t)$(t.val le 2022)       = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(sol(i),r,t)$(t.val = 2023)        = round(ixfx(i,r,t) * 1.5   + 10 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(sol(i),r,t)$(t.val = 2024)        = round(ixfx(i,r,t) * 2     + 20 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(sol(i),r,t)$(t.val = 2025)        = round(ixfx(i,r,t) * 3     + 30 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set shortlong    IX.UP(windon(i),r,t)$(t.val le 2023)    = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(windon(i),r,t)$(t.val = 2024)     = round(ixfx(i,r,t) * 1.5   +  5 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(windon(i),r,t)$(t.val = 2025)     = round(ixfx(i,r,t) * 2     + 10 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set shortlong    IX.UP(windoff(i),r,t)$(t.val le 2024)   = round(ixfx(i,r,t), 4) ;
$if set uselimits       $if     set shortlong    IX.UP(windoff(i),r,t)$(t.val = 2025)    = round(ixfx(i,r,t) * 1.5   +  1 * daref(r,"2020") / daref("Germany","2020"), 4) ;

$if set uselimits       $if     set longrun     IX.UP(sol(i),r,t)$(t.val le 2025)       = round(ixfx(i,r,t) * 2     + 20 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set longrun     IX.UP(windon(i),r,t)$(t.val le 2025)    = round(ixfx(i,r,t) * 1.5   +  5 * daref(r,"2020") / daref("Germany","2020"), 4) ;
$if set uselimits       $if     set longrun     IX.UP(windoff(i),r,t)$(t.val le 2025)   = round(ixfx(i,r,t), 4) ;

$if set uselimits                               IT.UP(k,r,rr,t)$(t.val le 2030)         = itfx(k,r,rr,t) ;
$if set uselimits                               IG.UP("Storage_ST",r,t)$(t.val le 2025) = igfx("Storage_ST",r,t) ;
$if set uselimits                               IG.UP("Storage_LT",r,t)$(t.val le 2025) = igfx("Storage_LT",r,t) ;

* * * Model fixes
* No investment in base year
IX.FX(i,r,t)$(t.val le 2021) = 0 ;
IX.FX(i,r,"2022")$(not gas(i)) = 0 ;
$if set noinvest2022    IX.FX(i,r,t)$(t.val le 2022) = 0 ;


set
rlostload(r)
;

rlostload("Bulgaria") = YES ;
rlostload("Lithuania") = YES ;
rlostload("Finland") = YES ;
rlostload("Norway") = YES ;
rlostload("Estonia") = YES ;
rlostload("Sweden") = YES ;

*IX.FX(i,r,t)$(sameas(i,"Gas_CCGT") and (t.val ge 2022 and t.val le 2030) and not rlostload(r)) = 0 ;

$if     set trans           IT.FX(k,r,rr,t)$(t.val le 2021) = 0 ;
$if     set storage         IG.FX(j,r,t)$(t.val le 2022) = 0 ;

$if not set freepipeline    IX.FX(nuc(i),r,t)$(t.val le 2030 and not invlimLO(i,r,t) > 0) = 0 ;
$if not set freepipeline    IX.UP(nuc(i),r,t)$(t.val le 2030 and     invlimLO(i,r,t) > 0) = invlimLO(i,r,t) ;

IX.FX(ccs(i),r,t)$(t.val le 2030) = 0 ;

IX.FX("RoofPV_q99",r,t) = 0 ;
IX.FX("RoofPV_q97",r,t) = 0 ;
IX.FX("RoofPV_q95",r,t) = 0 ;
IX.FX("RoofPV_q93",r,t) = 0 ;
IX.FX("RoofPV_q91",r,t) = 0 ;
IX.FX("RoofPV_q85",r,t) = 0 ;
IX.FX("RoofPV_q75",r,t) = 0 ;

IX.FX("OpenPV_q99",r,t) = 0 ;
IX.FX("OpenPV_q97",r,t) = 0 ;
IX.FX("OpenPV_q95",r,t) = 0 ;
IX.FX("OpenPV_q93",r,t) = 0 ;
IX.FX("OpenPV_q91",r,t) = 0 ;
IX.FX("OpenPV_q85",r,t) = 0 ;
IX.FX("OpenPV_q75",r,t) = 0 ;

IX.FX("WindOn_q99",r,t) = 0 ;
IX.FX("WindOn_q97",r,t) = 0 ;
IX.FX("WindOn_q95",r,t) = 0 ;
IX.FX("WindOn_q93",r,t) = 0 ;
IX.FX("WindOn_q91",r,t) = 0 ;
IX.FX("WindOn_q85",r,t) = 0 ;
IX.FX("WindOn_q75",r,t) = 0 ;

IX.FX("WindOff_q99",r,t) = 0 ;
IX.FX("WindOff_q97",r,t) = 0 ;
IX.FX("WindOff_q95",r,t) = 0 ;
IX.FX("WindOff_q93",r,t) = 0 ;
IX.FX("WindOff_q91",r,t) = 0 ;
IX.FX("WindOff_q85",r,t) = 0 ;
IX.FX("WindOff_q75",r,t) = 0 ;

IX.FX("Lignite",r,t) = 0 ;
IX.FX("Lignite_CCS",r,t) = 0 ;
IX.FX("Geothermal",r,t) = 0 ;

$if set flheur IX.FX("WindOn_q70",r,t) = 0 ;
$if set flheur IX.FX("WindOn_q50",r,t) = 0 ;
$if set flheur IX.FX("WindOn_q30",r,t) = 0 ;
$if set flheur IX.FX("WindOn_q10",r,t) = 0 ;
$if set flheur IX.FX("WindOff_q70",r,t) = 0 ;
$if set flheur IX.FX("WindOff_q50",r,t) = 0 ;
$if set flheur IX.FX("WindOff_q30",r,t) = 0 ;
$if set flheur IX.FX("WindOff_q10",r,t) = 0 ;

$if set flh  IX.FX("WindOn_q70",r,t) = 0 ;
$if set flh  IX.FX("WindOn_q50",r,t) = 0 ;
$if set flh  IX.FX("WindOn_q30",r,t) = 0 ;
$if set flh  IX.FX("WindOn_q10",r,t) = 0 ;
$if set flh  IX.FX("WindOff_q70",r,t) = 0 ;
$if set flh  IX.FX("WindOff_q50",r,t) = 0 ;
$if set flh  IX.FX("WindOff_q30",r,t) = 0 ;
$if set flh  IX.FX("WindOff_q10",r,t) = 0 ;

$if set simpmip IX.FX("Bio_CCS",r,t)$(t.val le 2035) = 0 ;
$if set simpmip IX.FX("Bioenergy",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Coal",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Coal_CCS",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Geothermal",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("OilOther",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Lignite",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Lignite_CCS",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("Hydro",r,t)$(t.val le 2050) = 0 ;

$if set simpmip IX.FX("RoofPV_q90",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("RoofPV_q70",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("RoofPV_q50",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("RoofPV_q30",r,t)$(t.val le 2050) = 0 ;
$if set simpmip IX.FX("RoofPV_q10",r,t)$(t.val le 2050) = 0 ;

$if set simpmip IX.FX("OpenPV_q70",r,t) = 0 ;
$if set simpmip IX.FX("OpenPV_q50",r,t) = 0 ;
$if set simpmip IX.FX("OpenPV_q30",r,t) = 0 ;
$if set simpmip IX.FX("OpenPV_q10",r,t) = 0 ;

$if set simpmip IX.FX("WindOn_q70",r,t) = 0 ;
$if set simpmip IX.FX("WindOn_q50",r,t) = 0 ;
$if set simpmip IX.FX("WindOn_q30",r,t) = 0 ;
$if set simpmip IX.FX("WindOn_q10",r,t) = 0 ;

$if set simpmip IX.FX("WindOff_q70",r,t) = 0 ;
$if set simpmip IX.FX("WindOff_q50",r,t) = 0 ;
$if set simpmip IX.FX("WindOff_q30",r,t) = 0 ;
$if set simpmip IX.FX("WindOff_q10",r,t) = 0 ;

*$if not  set noinvbiofrictions IX.UP(bio(i),r,t)$(t.val le 2030 and t.val ge 2022) = sum(oldv(v), cap(i,v,r)) * nyrs(t) / 5 ;
*$if not  set noinvccsfrictions IX.FX(ccs(i),r,t)$(t.val le 2030) = 0 ;
*$if not  set noinvnucfrictions IX.FX(nuc(i),r,t)$(t.val le 2035 and not invlimLO(i,r,t) > 0) = 0 ;
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

set
lasts(s)
;

lasts(s) = s.last ;

*$if      set storage     GB.FX("1","PumpStorage",v,r,t)     = 0.75 * ghours("PumpStorage",v,r) * gcap("PumpStorage",v,r) * 1e-3 ;
$if      set storage     GB.FX(lasts,"PumpStorage",v,r,t)   = 0.75 * ghours("PumpStorage",v,r) * gcap("PumpStorage",v,r) * 1e-3 ;
*$if      set storage     GB.FX("1","Storage_LT",v,r,t)      = 0.75 * ghours("Storage_LT",v,r)  * gcap("Storage_LT",v,r)  * 1e-3 ;
$if      set storage     GB.FX(lasts,"Storage_LT",v,r,t)    = 0.75 * ghours("Storage_LT",v,r)  * gcap("Storage_LT",v,r)  * 1e-3 ;
*$if      set storage     GB.FX("1","Storage_ST",v,r,t)      = 0.50 * ghours("Storage_ST",v,r)  * gcap("Storage_ST",v,r)  * 1e-3 ;
$if      set storage     GB.FX(lasts,"Storage_ST",v,r,t)    = 0.50 * ghours("Storage_ST",v,r)  * gcap("Storage_ST",v,r)  * 1e-3 ;


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
$if      set mustrun                             capacity_mus
$if      set chp                                 capacity_chp
*MM (todo): The mustrun conditions lead to (numerical) infeasibilities in the moment (need to check)
$if      set biosub                              capacity_bio
*$if      set mustrun                             capacity_dsp
*$if      set mustrun                             capacity_nsp
$if      set cofiring                            capacity_cofir
invest
exlife2020
                                                 exlife
$if      set chp                                 exlife2030_chp
$if      set chp                                 exlife_chp
$if      set biosub                              exlife_bio
newlife
$if not  set myopic                              retire
investlimUP
$if not  set nopipeline                          investlimLO
$if      set limeu                               investlimUP_eu
investlimUP_irnw
* * * Storage
$if      set storage                             ginvest
$if      set storage                             gexlife
$if      set storage                             gexlife2020
$if      set storage                             gexlife_pump
$if      set storage                             gnewlife
$if      set storage   $if not  set myopic       gretire
$if      set storage                             chargelim
$if      set storage                             dischargelim
$if      set storage  $if not   set storspec                                storagebal
$if      set storage  $if not   set storspec                                storagebalann
$if      set storage  $if       set storspec                                storagebal_ps0
$if      set storage  $if       set storspec                                storagebal_ps
$if      set storage  $if       set storspec                                storagebalann_ps
$if      set storage  $if       set storspec                                storagebal_st0
$if      set storage  $if       set storspec                                storagebal_st
$if      set storage  $if       set storspec                                storagebalann_st
$if      set storage  $if       set storspec                                storagebal_lt0
$if      set storage  $if       set storspec                                storagebal_lt
$if      set storage  $if       set storspec                                storagebalann_lt
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
$if      set co2marktotal                        co2flow
$if      set co2marktotal                        co2market
$if      set co2mark_r                           co2flow_r
$if      set co2mark_r                           co2market_r
$if      set co2mark                             co2floweu
$if      set co2mark                             co2marketeu
$if      set co2mark   $if      set banking      co2tnac
$if      set co2mark                             co2flowuk
$if      set co2mark                             ukets
* CO2 market with MSR dynamics via iterative modeling (only shortrun)
$if      set co2iter                             co2floweu
$if      set co2iter                             it_euets
$if      set co2iter   $if      set banking      it_tnac
$if      set co2iter                             co2flowuk
$if      set co2iter                	         ukets
* CO2 market with MSR dynamics as simple as possible (only shortrun)
$if      set co2mips                                                            eqs_euets
$if      set co2mips    $if      set msrin2023      $if      set msrin2023fix   eqs_msrin2023_fix
$if      set co2mips    $if      set msrin2023      $if not  set msrin2023fix   eqs_msrin2023
$if      set co2mips    $if      set euetsold                                   eqs_msrin_old
$if      set co2mips    $if      set euetscancel                                eqs_msrin_old
$if      set co2mips    $if      set euetsmsrin                                 eqs_msrin_new
$if      set co2mips    $if      set euetsnew                                   eqs_msrin_new
$if      set co2mips    $if      set msrout2023                                 eqs_msrout2023
$if      set co2mips    $if      set euetsold       $if not  set msrout203045   eqs_msrout_old
$if      set co2mips    $if      set euetscancel    $if not  set msrout203045   eqs_msrout_old
$if      set co2mips    $if      set euetsmsrin     $if not  set msrout203045   eqs_msrout_new
$if      set co2mips    $if      set euetsnew       $if not  set msrout203045   eqs_msrout_new
$if      set co2mips    $if      set euetsold       $if      set msrout203045   eqs_msrout2030_old
$if      set co2mips    $if      set euetscancel    $if      set msrout203045   eqs_msrout2030_old
$if      set co2mips    $if      set euetsmsrin     $if      set msrout203045   eqs_msrout2030_new
$if      set co2mips    $if      set euetsnew       $if      set msrout203045   eqs_msrout2030_new
$if      set co2mips                                $if      set msrout203045   eqs_msrout2045
$if      set co2mips    $if      set msrinout                                   eqs_msrinout
$if      set co2mips                                                            eqs_binary
$if      set co2mips                                                            eqs_tnac
$if      set co2mips                                                            eqs_tnacup
$if      set co2mips                                                            eqs_tnaclo
$if      set co2mips                                                            eqs_msr
$if      set co2mips    $if     set msruplo                                     eqs_msrUP_old
$if      set co2mips    $if     set msruplo                                     eqs_msrUP_new
$if      set co2mips                                                            eqs_cancel2023
$if      set co2mips    $if      set euetsold                                   eqs_cancel_old
$if      set co2mips    $if      set euetsmsrin                                 eqs_cancel_old
$if      set co2mips    $if      set euetscancel                                eqs_cancel_new
$if      set co2mips    $if      set euetsnew                                   eqs_cancel_new
$if      set co2mips    $if not set cancel2045                                  eqs_cancel2045
$if      set co2mips    $if     set cancel2045                                  eqs_cancel2045_spe
$if      set real2022                                                           eqs_co2real2022
$if      set co2monoup                                                          eqs_co2monoUP
$if      set co2monolo                                                          eqs_co2monoLO
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
$if      set frnuctgt                            convtarget
$if      set resmarket                           resmarket
$if      set capmarket                           capmarket
* * * Structural equations to aid solver
xtwhdef
copyxc
$if      set storage                             copygc
$if      set trans                               copytc
* * * Calibration
$if      set calibration2022                     genUP_wind
$if      set calibration2022                     genUP_sola
*$if      set calibration2022                     genUP_biom
*$if      set calibration2022                     $if     set bauprice   genLO_ngas
$if      set calibration2022plus                 genUP_ngas
$if      set calibration2022plus                 genUP_nucl
$if      set calibration2022coal                 genUP_coal
$if      set calibration2022coal                 genUP_lign
$if      set streckbetrieb                       genGER_nucl
$if      set strext                              genGER_nucl
$if      set calibration2022plus                 genUP_hydr
*$if      set calibration2022                     impUP
*$if      set calibration2022                     expLO
* * * Regional Learning-by-Doing
$if      set doing       $if      set recall       $if not set eur                    acc_q_recall2020
$if      set doing       $if      set recall       $if not set eur  $if       set leg acc_q_leg_recall2020
$if      set doing       $if      set recall       $if not set eur                    acc_q_recall
$if      set doing       $if      set recall       $if not set eur  $if       set leg acc_q_leg_recall
$if      set doing       $if      set continuous   $if not set eur                    acc_q_continuous2020
$if      set doing       $if      set continuous   $if not set eur  $if       set leg acc_q_leg_continuous2020
$if      set doing       $if      set continuous   $if not set eur                    acc_q_continuous
$if      set doing       $if      set continuous   $if not set eur  $if       set leg acc_q_leg_continuous
$if      set doing       $if      set discrete     $if not set eur                    acc_q_discrete2020
$if      set doing       $if      set discrete     $if not set eur  $if       set leg acc_q_leg_discrete2020
$if      set doing       $if      set discrete     $if not set eur                    acc_q_discrete
$if      set doing       $if      set discrete     $if not set eur  $if       set leg acc_q_leg_discrete
$if      set doing       $if      set constant     $if not set eur                    capex_constant
$if      set doing       $if      set nonlinear    $if not set eur                    capex_nonlinear
$if      set doing       $if      set nonlinear    $if not set eur                    acc_capex_nonlinear
$if      set doing       $if      set nonlinear    $if not set eur  $if       set leg acc_capex_leg_nonlinear
$if      set doing       $if      set mip          $if not set eur                    capex_mixedip
$if      set doing       $if      set mip          $if not set eur                    acc_capex_mixedip
$if      set doing       $if      set mip          $if not set eur  $if       set leg acc_capex_leg_mixedip
$if      set doing       $if      set mip          $if not set eur                    rho_mixedip
$if      set doing       $if      set mip          $if not set eur  $if       set leg rho_leg_mixedip
$if      set doing       $if      set mip          $if not set eur                    qlsLO_mixedip
$if      set doing       $if      set mip          $if not set eur  $if       set leg qlsLO_leg_mixedip
$if      set doing       $if      set mip          $if not set eur                    qlsUP_mixedip
$if      set doing       $if      set mip          $if not set eur  $if       set leg qlsUP_leg_mixedip
$if      set doing       $if      set mip          $if not set eur                    acc_qls_mixedip
$if      set doing       $if      set mip          $if not set eur  $if       set leg acc_qls_leg_mixedip
* Max constraints
$if      set doing       $if      set mip          $if not set eur                    acc_q_max
$if      set doing       $if      set mip          $if not set eur  $if       set leg acc_q_leg_max
* Monotonicity constraints
$if      set doing       $if      set recall       $if not set eur                    acc_q_mono
$if      set doing       $if      set recall       $if not set eur  $if       set leg acc_q_leg_mono
$if      set doing       $if      set recall       $if not set eur                    rho_mixedip_mono
$if      set doing       $if      set recall       $if not set eur  $if       set leg rho_leg_mixedip_mono
$if      set doing       $if      set recall       $if not set eur                    qls_mixedip_mono
$if      set doing       $if      set recall       $if not set eur  $if       set leg qls_leg_mixedip_mono
* * * opean Learning-by-Doing
$if      set doing       $if      set recall       $if     set eur                    acc_q_recall2020
$if      set doing       $if      set recall       $if     set eur  $if       set leg acc_q_leg_recall2020
$if      set doing       $if      set recall       $if     set eur                    acc_q_recall
$if      set doing       $if      set recall       $if     set eur  $if       set leg acc_q_leg_recall
$if      set doing       $if      set continuous   $if     set eur                    acc_q_continuous2020
$if      set doing       $if      set continuous   $if     set eur  $if       set leg acc_q_leg_continuous2020
$if      set doing       $if      set continuous   $if     set eur                    acc_q_continuous
$if      set doing       $if      set continuous   $if     set eur  $if       set leg acc_q_leg_continuous
$if      set doing       $if      set discrete     $if     set eur                    acc_q_discrete2020
$if      set doing       $if      set discrete     $if     set eur  $if       set leg acc_q_leg_discrete2020
$if      set doing       $if      set discrete     $if     set eur                    acc_q_discrete
$if      set doing       $if      set discrete     $if     set eur  $if       set leg acc_q_leg_discrete
$if      set doing       $if      set constant     $if     set eur                    capex_constant
$if      set doing       $if      set nonlinear    $if     set eur                    capex_nonlinear
$if      set doing       $if      set nonlinear    $if     set eur                    acc_capex_nonlinear
$if      set doing       $if      set nonlinear    $if     set eur  $if       set leg acc_capex_leg_nonlinear
$if      set doing       $if      set mip          $if     set eur                    capex_mixedip
$if      set doing       $if      set mip          $if     set eur                    acc_capex_mixedip
$if      set doing       $if      set mip          $if     set eur  $if       set leg acc_capex_leg_mixedip
$if      set doing       $if      set mip          $if     set eur                    rho_mixedip
$if      set doing       $if      set mip          $if     set eur  $if       set leg rho_leg_mixedip
$if      set doing       $if      set mip          $if     set eur                    qlsLO_mixedip
$if      set doing       $if      set mip          $if     set eur  $if       set leg qlsLO_leg_mixedip
$if      set doing       $if      set mip          $if     set eur                    qlsUP_mixedip
$if      set doing       $if      set mip          $if     set eur  $if       set leg qlsUP_leg_mixedip
$if      set doing       $if      set mip          $if     set eur                    acc_qls_mixedip
$if      set doing       $if      set mip          $if     set eur  $if       set leg acc_qls_leg_mixedip
* Max constraints
$if      set doing       $if      set mip          $if     set eur                    acc_q_max
$if      set doing       $if      set mip          $if     set eur  $if       set leg acc_q_leg_max
* Monotonicity constraints
$if      set doing       $if      set recall       $if     set eur                    acc_q_mono
$if      set doing       $if      set recall       $if     set eur  $if       set leg acc_q_leg_mono
$if      set doing       $if      set recall       $if     set eur                    rho_mixedip_mono
$if      set doing       $if      set recall       $if     set eur  $if       set leg rho_leg_mixedip_mono
$if      set doing       $if      set recall       $if     set eur                    qls_mixedip_mono
$if      set doing       $if      set recall       $if     set eur  $if       set leg qls_leg_mixedip_mono
* * * Regional Learning-by-Searching
$if      set lbs                                    acc_k_continuous2020
$if      set lbs                                    acc_k_continuous
$if      set lbs                                    rho_mixedip_k
$if      set lbs                                    capex_mixedip_k2020
$if      set lbs                                    capex_mixedip_k
$if      set lbs                                    lbs_helper1
$if      set lbs                                    lbs_helper2
$if      set lbs                                    lbs_helper3
$if      set lbs                                    lbs_helper4
$if      set lbs                                    capcost_mixedip_k
$if      set lbs                                    klsLO_mixedip
$if      set lbs                                    klsUP_mixedip
$if      set lbs                                    acc_kls_mixedip
* Budget constraints
$if      set lbs        $if     set budget_irt      eq_lbs_rdbudget_irt        
$if      set lbs        $if     set budget_rt       eq_lbs_rdbudget_rt 
$if      set lbs        $if     set budget_it       eq_lbs_rdbudget_it 
$if      set lbs        $if     set budget_ir       eq_lbs_rdbudget_ir 
$if      set lbs        $if     set budget_t        eq_lbs_rdbudget_t 
$if      set lbs        $if     set budget_r        eq_lbs_rdbudget_r 
$if      set lbs        $if     set budget_i        eq_lbs_rdbudget_i 
$if      set lbs        $if     set budget          eq_lbs_rdbudget
* * * opean Learning-by-Searching
$if      set lbseur                                 acc_keur_continuous2020
$if      set lbseur                                 acc_keur_continuous
$if      set lbseur                                 rhoeur_mixedip_k
$if      set lbseur                                 capexeur_mixedip_k
$if      set lbseur                                 lbseur_helper1
$if      set lbseur                                 lbseur_helper2
$if      set lbseur                                 lbseur_helper3
$if      set lbseur                                 lbseur_helper4
$if      set lbseur                                 capcosteur_mixedip_k
$if      set lbseur                                 keurlsLO_mixedip
$if      set lbseur                                 keurlsUP_mixedip
$if      set lbseur                                 acc_keurls_mixedip
* Budget constraints
$if      set lbseur     $if     set budget_it       eq_lbseur_rdbudget_it 
$if      set lbseur     $if     set budget_i        eq_lbseur_rdbudget_i 
$if      set lbseur     $if     set budget_t        eq_lbseur_rdbudget_t 
$if      set lbseur     $if     set budget          eq_lbseur_rdbudget
* * * Regional FLHLearning-by-sarching
$if      set flh     acc_flh2020
$if      set flh     acc_flh
$if      set flh     rhoflh_mixedip
$if      set flh     flhlsLO_mixedip
$if      set flh     flhlsUP_mixedip
$if      set flh     acc_flhls_mixedip
$if      set flh     flh_helper1
$if      set flh     flh_helper2
$if      set flh     flh_helper3
$if      set flh     flh_helper4
$if      set flh     capacity_flholdv
$if      set flh     capacity_flh
* Budget constraints
$if      set flh        $if     set budget_irt      eq_flh_rdbudget_irt        
$if      set flh        $if     set budget_rt       eq_flh_rdbudget_rt 
$if      set flh        $if     set budget_it       eq_flh_rdbudget_it 
$if      set flh        $if     set budget_ir       eq_flh_rdbudget_ir 
$if      set flh        $if     set budget_t        eq_flh_rdbudget_t 
$if      set flh        $if     set budget_r        eq_flh_rdbudget_r 
$if      set flh        $if     set budget_i        eq_flh_rdbudget_i 
$if      set flh        $if     set budget          eq_flh_rdbudget
* * * European FLH Learning-by-sarching
$if      set flheur     acc_flheur2020
$if      set flheur     acc_flheur
$if      set flheur     rhoflheur_mixedip
$if      set flheur     flheurlsLO_mixedip
$if      set flheur     flheurlsUP_mixedip
$if      set flheur     acc_flheurls_mixedip
$if      set flheur     flheur_helper1
$if      set flheur     flheur_helper2
$if      set flheur     flheur_helper3
$if      set flheur     flheur_helper4
$if      set flheur     capacity_flheuroldv
$if      set flheur     capacity_flheur
* Budget constraints
$if      set flheur     $if     set budget_it       eq_flheur_rdbudget_it 
$if      set flheur     $if     set budget_i        eq_flheur_rdbudget_i 
$if      set flheur     $if     set budget_t        eq_flheur_rdbudget_t 
$if      set flheur     $if     set budget          eq_flheur_rdbudget
* * * Restriction constraints to help the solver into the right direction
$if      set nucrestrict                            nuclear_restriction
$if      set ccsrestrict                            ccs_restriction
$if      set windrestrict                           wind_restriction
$if      set gasrestrict                            gas_restriction
/;

* Intialize different CO2 markets to ensure report compiles even when the constraint is excluded
co2market.M(t)                  = 0 ;
co2market_r.M(r,t)              = 0 ;
co2marketeu.M(t)                = 0 ;
it_euets.M(t)                   = 0 ;
ukets.M(t)                      = 0 ;
eqs_euets.M(t)                  = 0 ;


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

$if      set mip                          solve euregen using mip minimizing SURPLUS ;
$if      set miqcp                        solve euregen using miqcp minimizing SURPLUS ;
$if      set co2mips                      solve euregen using miqcp minimizing SURPLUS ;
$if      set techmin                      solve euregen using miqcp minimizing SURPLUS ;
$if not set mip $if not set miqcp $if not  set co2mips $if not  set techmin solve euregen using lp    minimizing SURPLUS ;

*Don't include report so that restart file can be used with modified report without re-running model

