* * * Define reporting type for simplification
set
tyrpt                    Reporting technology types
                         /Bioenergy, Coal, Gas-CCGT, Gas-OCGT, Gas-ST, Geothermal, Hydro, Lignite, Nuclear,
                         OilOther, Solar, WindOff, WindOn, Bio-CCS, Coal-CCS, Gas-CCS/
xtyperpt(tyrpt,type)     Map between technology types
                         /Bioenergy.biow, Coal.hdcl, Gas-CCGT.ngcc, Gas-OCGT.nggt, Gas-ST.ngst, Geothermal.geot,
                         Hydro.Hydro, Lignite.lign, Nuclear.nuc, OilOther.ptsg, Solar.slpv,
                         WindOff.wind-os, WindOn.wind, Bio-CCS.becs, Coal-CCS.hdcs, Gas-CCS.ngcs/

rrpt                     Reporting regions
                         /North, South, Central, East/

xrrpt(rrpt,r)            Map rrpt r
$if      set spatialhighest                        /North.(Britain, Ireland, Norway, Sweden, Finland, Denmark),
$if      set spatialhighest                         South.(Portugal, Spain, France, Italy),
$if      set spatialhighest                         Central.(Belgium, Luxembourg, Netherlands, Austria, Switzerland, Germany)
$if      set spatialhighest                         East.(Czech,Poland,Slovakia,Estonia,Lithuania,Latvia,Croatia,Hungary,Slovenia,Bulgaria,Greece,Romania)/

$if      set spatialveryhigh                       /North.(Britain, Ireland, Norway, Sweden, Finland, Denmark),
$if      set spatialveryhigh                        South.(Portugal, Spain, France, Italy),
$if      set spatialveryhigh                        Central.(Belux, Netherlands, Austria, Switzerland, Germany)
$if      set spatialveryhigh                        East.(Czeslovak,Poland,EE-NE,EE-SW,Bulgaria,Greece,Romania)/

$if      set spatialhigh                           /North.(Britain, Norway, Sweden, Finland, Denmark),
$if      set spatialhigh                            South.(Iberia, France, Italy),
$if      set spatialhigh                            Central.(Belux, Netherlands, Alpine, Germany)
$if      set spatialhigh                            East.(Czeslovak,Poland,EE-NE,EE-SW,EE-SE)/

$if      set spatialmid                            /North.(Britain, Scanda),
$if      set spatialmid                             South.(Iberia, France, Italy),
$if      set spatialmid                             Central.(Benelux, Alpine, Germany)
$if      set spatialmid                             East.(EE-NW,EE-NE,EE-SW,EE-SE)/

$if      set spatiallow                            /North.(Britain, Scanda),
$if      set spatiallow                             South.(Iberia, France, Italy),
$if      set spatiallow                             Central.(Central)
$if      set spatiallow                             East.(East)/

$if      set spatialverylow                        /North.(North),
$if      set spatialverylow                         South.(South),
$if      set spatialverylow                         Central.(Central)
$if      set spatialverylow                         East.(East)/

xrrpt_(rrpt,r)           Alias map rrpt r
;

alias(r,rr) ;
alias(rrpt,rrpt_) ;
xrrpt_(rrpt,r)$xrrpt(rrpt,r) = YES ;

* * * Emissions reporting
parameters
co2emit(r,t)                     CO2 emissions (MtCO2)
co2emit_fuel(r,t,fuel)           CO2 emissions by fuel (MtCO2)
co2pr(t)                         CO2 emissions price (EUR per tCO2)
co2capt(r,t)                     CO2 emissions captued (MtCO2)
Emissions_rpt(t,r,*)             Emissions reporting vector (MtC2)
Emissions_ByFuel_rpt(t,r,*)      Emissions by fuel reporting vector (MtCO2)
Emissions_total_ByFuel_rpt(t,*)  Total emissions by fuel reporting vector (MtCO2)
Emissions_GER_ByFuel_rpt(t,*)    Total emissions by fuel reporting vector (MtCO2)
Emissions_total_rpt(t,*)         Total emissions reporting vector (MtC2)
Emissions_GER_rpt(t,*)           Total emissions reporting vector (MtC2)
gasuse(r,t)
gasuseeu(t)
;

gasuse(r,t)             = sum(ivrt(gas(i),v,r,t), XTWH.L(i,v,r,t) / effrate(i,v,r)) ;
gasuseeu(t)             = sum(r, gasuse(r,t)) ;
co2emit(r,t)            = sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH.L(i,v,r,t)) ;
co2emit_fuel(r,t,fuel)  = sum(xfueli(fuel,i), sum(ivrt(i,v,r,t), emit(i,v,r) * XTWH.L(i,v,r,t))) ;

co2pr(t)         = 0
$if      set scc                            + scc(t)
$if      set co2price                       + co2p(t)
$if      set co2mark                        + abs(co2market.M(t)) / dfact(t)
$if      set co2mark                        + abs(co2market_indformula.M(t)) / dfact(t)
$if      set co2mark    $if     set banking + abs(co2marban.M(t)) / dfact(t)
$if      set co2mark    $if     set banking + abs(co2marban_indformula.M(t)) / dfact(t)
$if      set co2iter                        + abs(it_euets.M(t)) / dfact(t)
$if      set co2mips                        + abs(eqs_euets.M(t)) / dfact(t)
$if      set co2mips                        + abs(eqs_euets_indformula.M(t)) / dfact(t)
                ;

co2capt(r,t)
     = sum(ivrt(i,v,r,t), co2captured(i,v,r) * XTWH.L(i,v,r,t)) ;

* CO2 emissions is the dummy for the python algorithm but could be filled by assumptions about remaining EU ETS emissions (for example)
Emissions_rpt(t,r,"CO2-emissions")                      = eps ;
Emissions_rpt(t,r,"CO2-emissions-elec")                 = co2emit(r,t) ;
Emissions_rpt(t,r,"CO2-price")                          = co2pr(t) ;
Emissions_rpt(t,r,"CO2-captured")                       = co2capt(r,t) ;

Emissions_total_rpt(t,"Total CO2-emissions-elec")       = sum(r, co2emit(r,t)) ;
Emissions_total_rpt(t,"Total CO2-captured")             = sum(r, co2capt(r,t)) ;
Emissions_total_rpt(t,"CO2 price")                      = co2pr(t) ;

Emissions_GER_rpt(t,"Total CO2-emissions-elec")         = sum(r$sameas(r,"Germany"), co2emit(r,t)) ;
Emissions_GER_rpt(t,"Total CO2-captured")               = sum(r$sameas(r,"Germany"), co2capt(r,t)) ;
Emissions_GER_rpt(t,"CO2 price")                        = co2pr(t) ;

Emissions_ByFuel_rpt(t,r,"CO2-emissions-bioenergy")     = co2emit_fuel(r,t,"Bioenergy") ;
Emissions_ByFuel_rpt(t,r,"CO2-emissions-coal")          = co2emit_fuel(r,t,"Coal") ;
Emissions_ByFuel_rpt(t,r,"CO2-emissions-gas")           = co2emit_fuel(r,t,"Gas") ;
Emissions_ByFuel_rpt(t,r,"CO2-emissions-lignite")       = co2emit_fuel(r,t,"Lignite") ;
Emissions_ByFuel_rpt(t,r,"CO2-emissions-oil/other")     = co2emit_fuel(r,t,"Oil") ;

Emissions_total_ByFuel_rpt(t,"CO2-emissions-bioenergy") = sum(r, co2emit_fuel(r,t,"Bioenergy")) ;
Emissions_total_ByFuel_rpt(t,"CO2-emissions-coal")      = sum(r, co2emit_fuel(r,t,"Coal")) ;
Emissions_total_ByFuel_rpt(t,"CO2-emissions-gas")       = sum(r, co2emit_fuel(r,t,"Gas")) ;
Emissions_total_ByFuel_rpt(t,"CO2-emissions-lignite")   = sum(r, co2emit_fuel(r,t,"Lignite")) ;
Emissions_total_ByFuel_rpt(t,"CO2-emissions-oil/other") = sum(r, co2emit_fuel(r,t,"Oil")) ;

Emissions_GER_ByFuel_rpt(t,"CO2-emissions-bioenergy") =  sum(r$sameas(r,"Germany"), co2emit_fuel(r,t,"Bioenergy")) ;
Emissions_GER_ByFuel_rpt(t,"CO2-emissions-coal") =       sum(r$sameas(r,"Germany"), co2emit_fuel(r,t,"Coal")) ;
Emissions_GER_ByFuel_rpt(t,"CO2-emissions-gas") =        sum(r$sameas(r,"Germany"), co2emit_fuel(r,t,"Gas")) ;
Emissions_GER_ByFuel_rpt(t,"CO2-emissions-lignite") =    sum(r$sameas(r,"Germany"), co2emit_fuel(r,t,"Lignite")) ;
Emissions_GER_ByFuel_rpt(t,"CO2-emissions-oil/other") =  sum(r$sameas(r,"Germany"), co2emit_fuel(r,t,"Oil")) ;

* * * Electricity reporting
set
sea                    Seasons of the year /w, s, m, strm, stra/
ssea(s,sea)            Map between segment and season
;

* Generate map between segments and seasons
ssea(s,"w")$(sm(s,"1") or sm(s,"2") or sm(s,"12")) = YES ;
ssea(s,"s")$(sm(s,"6") or sm(s,"7") or sm(s,"8"))  = YES ;
ssea(s,"m")$(not ssea(s,"s") and not ssea(s,"w"))  = YES ;
ssea(s,"strm")$(sm(s,"1") or sm(s,"2") or sm(s,"3"))                = YES ;
ssea(s,"stra")$(sm(s,"1") or sm(s,"2") or sm(s,"3") or sm(s,"4"))   = YES ;

parameter
price(s,r,t)                     Electricity price (EUR per MWh)
Electricity_rpt(t,r,*)           Electricity reporting vector (EUR per MWh and TWh)
Electricity_total_rpt(t,*)       Electricity reporting vector (EUR per MWh and TWh)
Electricity_GER_rpt(t,*)         Electricity reporting vector (EUR per MWh and TWh)
;

price(s,r,t)     = (demand.M(s,r,t)
*$if      set rsa + demand_rsa.M(s,r,t)
                 ) / dfact(t) ;

* Compile different prices
Electricity_rpt(t,r,"price-avg")                = sum(s,             price(s,r,t) * dref(r,t) * load(s,r) * hours(s)) / sum(s,             dref(r,t) * load(s,r) * hours(s)) ;
Electricity_rpt(t,r,"price-avg-winter")         = sum(s$ssea(s,"w"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s)) / sum(s$ssea(s,"w"), dref(r,t) * load(s,r) * hours(s)) ;
Electricity_rpt(t,r,"price-avg-summer")         = sum(s$ssea(s,"s"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s)) / sum(s$ssea(s,"s"), dref(r,t) * load(s,r) * hours(s)) ;
Electricity_rpt(t,r,"price-avg-midseason")      = sum(s$ssea(s,"m"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s)) / sum(s$ssea(s,"m"), dref(r,t) * load(s,r) * hours(s)) ;
Electricity_rpt(t,r,"price-max")                = smax(s, price(s,r,t)) ;
Electricity_rpt(t,r,"price-min")                = smin(s, price(s,r,t)) ;
Electricity_rpt(t,r,"elec-demand")              = sum(s, dref(r,t) * load(s,r) * hours(s)) * 1e-3 ;

Electricity_rpt(t,r,"price-nuc")$(sum(nuc(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(nuc(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(nuc(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-sol")$(sum(sol(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(sol(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(sol(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-wind")$(sum(wind(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(wind(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(wind(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-windon")$(sum(windon(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windon(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(windon(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-windoff")$(sum(windoff(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windoff(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(windoff(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-bio")$(sum(bio(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(bio(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(bio(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-gas")$(sum(gas(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(gas(i), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(gas(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-coa")$(sum(i$sameas(i,"Coal"), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Coal"), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(i$sameas(i,"Coal"), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"price-lig")$(sum(i$sameas(i,"Lignite"), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Lignite"), sum(s, price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(i$sameas(i,"Lignite"), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;

Electricity_rpt(t,r,"cost-nuc")$(sum(nuc(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(nuc(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(nuc(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-sol")$(sum(sol(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(sol(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(sol(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-wind")$(sum(wind(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(wind(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(wind(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-windon")$(sum(windon(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windon(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(windon(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-windoff")$(sum(windoff(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windoff(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(windoff(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-bio")$(sum(bio(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(bio(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(bio(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-gas")$(sum(gas(i), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(gas(i), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(gas(i), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-coa")$(sum(i$sameas(i,"Coal"), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Coal"), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(i$sameas(i,"Coal"), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_rpt(t,r,"cost-lig")$(sum(i$sameas(i,"Lignite"), sum(s, sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Lignite"), sum(s, sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum(v, XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(i$sameas(i,"Lignite"), sum(s,                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;

Electricity_total_rpt(t,"price-avg")            = sum(r, sum(s,             price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s,             dref(r,t) * load(s,r) * hours(s))) ;
Electricity_total_rpt(t,"price-avg-winter")     = sum(r, sum(s$ssea(s,"w"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s$ssea(s,"w"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_total_rpt(t,"price-avg-summer")     = sum(r, sum(s$ssea(s,"s"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s$ssea(s,"s"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_total_rpt(t,"price-avg-midseason")  = sum(r, sum(s$ssea(s,"m"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s$ssea(s,"m"), dref(r,t) * load(s,r) * hours(s))) ;

Electricity_total_rpt(t,"price-avg-janmar")  = sum(r, sum(s$ssea(s,"strm"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s$ssea(s,"strm"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_total_rpt(t,"price-avg-janapr")  = sum(r, sum(s$ssea(s,"stra"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r, sum(s$ssea(s,"stra"), dref(r,t) * load(s,r) * hours(s))) ;

Electricity_total_rpt(t,"price-max")            = smax((s,r), price(s,r,t)) ;
Electricity_total_rpt(t,"price-min")            = smin((s,r), price(s,r,t)) ;
Electricity_total_rpt(t,"elec-demand")          = sum((s,r), dref(r,t) * load(s,r) * hours(s)) * 1e-3  ;

Electricity_total_rpt(t,"price-nuc")$(sum(nuc(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(nuc(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(nuc(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-sol")$(sum(sol(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(sol(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(sol(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-wind")$(sum(wind(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(wind(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(wind(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-windon")$(sum(windon(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windon(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(windon(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-windoff")$(sum(windoff(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windoff(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(windoff(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-bio")$(sum(bio(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(bio(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(bio(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;                                                
Electricity_total_rpt(t,"price-gas")$(sum(gas(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(gas(i), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(gas(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-coa")$(sum(i$sameas(i,"Coal"), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Coal"), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(i$sameas(i,"Coal"), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"price-lig")$(sum(i$sameas(i,"Lignite"), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Lignite"), sum((s,r), price(s,r,t) * sum(v, X.L(s,i,v,r,t)) * hours(s)))
                                                / sum(i$sameas(i,"Lignite"), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
                                                
                                                
Electricity_total_rpt(t,"cost-nuc")$(sum(nuc(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(nuc(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(nuc(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-sol")$(sum(sol(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(sol(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(sol(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-wind")$(sum(wind(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(wind(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(wind(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-windon")$(sum(windon(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windon(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(windon(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-windoff")$(sum(windoff(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(windoff(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(windoff(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-bio")$(sum(bio(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(bio(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(bio(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;                                                
Electricity_total_rpt(t,"cost-gas")$(sum(gas(i), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(gas(i), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(gas(i), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-coa")$(sum(i$sameas(i,"Coal"), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Coal"), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(i$sameas(i,"Coal"), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;
Electricity_total_rpt(t,"cost-lig")$(sum(i$sameas(i,"Lignite"), sum((s,r), sum(v, X.L(s,i,v,r,t)) * hours(s))) > 0)
                                                = sum(i$sameas(i,"Lignite"), sum((s,r), sum(v, discost(i,v,r,t) * X.L(s,i,v,r,t)) * hours(s)) + sum((v,r), XC.L(i,v,r,t) * 1e+3 *  fomcost(i,v,r)))
                                                / sum(i$sameas(i,"Lignite"), sum((s,r),                sum(v, X.L(s,i,v,r,t)) * hours(s))) ;


Electricity_GER_rpt(t,"price-avg")              = sum(r$sameas(r,"Germany"), sum(s,             price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s,             dref(r,t) * load(s,r) * hours(s))) ;
Electricity_GER_rpt(t,"price-avg-winter")       = sum(r$sameas(r,"Germany"), sum(s$ssea(s,"w"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s$ssea(s,"w"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_GER_rpt(t,"price-avg-summer")       = sum(r$sameas(r,"Germany"), sum(s$ssea(s,"s"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s$ssea(s,"s"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_GER_rpt(t,"price-avg-midseason")    = sum(r$sameas(r,"Germany"), sum(s$ssea(s,"m"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s$ssea(s,"m"), dref(r,t) * load(s,r) * hours(s))) ;

Electricity_GER_rpt(t,"price-avg-janmar")       = sum(r$sameas(r,"Germany"), sum(s$ssea(s,"strm"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s$ssea(s,"strm"), dref(r,t) * load(s,r) * hours(s))) ;
Electricity_GER_rpt(t,"price-avg-janapr")       = sum(r$sameas(r,"Germany"), sum(s$ssea(s,"stra"), price(s,r,t) * dref(r,t) * load(s,r) * hours(s))) / sum(r$sameas(r,"Germany"), sum(s$ssea(s,"stra"), dref(r,t) * load(s,r) * hours(s))) ;

Electricity_GER_rpt(t,"price-max")              = smax((s,r)$sameas(r,"Germany"), price(s,r,t)) ;
Electricity_GER_rpt(t,"price-min")              = smin((s,r)$sameas(r,"Germany"), price(s,r,t)) ;
Electricity_GER_rpt(t,"elec-demand")            = sum((s,r)$sameas(r,"Germany"), dref(r,t) * load(s,r) * hours(s)) * 1e-3  ;
Electricity_GER_rpt(t,"price-nuc")              = Electricity_rpt(t,"Germany","price-nuc") ;
Electricity_GER_rpt(t,"price-sol")              = Electricity_rpt(t,"Germany","price-sol") ;
Electricity_GER_rpt(t,"price-wind")             = Electricity_rpt(t,"Germany","price-wind") ;
Electricity_GER_rpt(t,"price-windon")           = Electricity_rpt(t,"Germany","price-windon") ;
Electricity_GER_rpt(t,"price-windoff")          = Electricity_rpt(t,"Germany","price-windoff") ;
Electricity_GER_rpt(t,"price-bio")              = Electricity_rpt(t,"Germany","price-bio") ;
Electricity_GER_rpt(t,"price-gas")              = Electricity_rpt(t,"Germany","price-gas") ;
Electricity_GER_rpt(t,"price-coa")              = Electricity_rpt(t,"Germany","price-coa") ;
Electricity_GER_rpt(t,"price-lig")              = Electricity_rpt(t,"Germany","price-lig") ;

Electricity_GER_rpt(t,"cost-nuc")              = Electricity_rpt(t,"Germany","cost-nuc") ;
Electricity_GER_rpt(t,"cost-sol")              = Electricity_rpt(t,"Germany","cost-sol") ;
Electricity_GER_rpt(t,"cost-wind")             = Electricity_rpt(t,"Germany","cost-wind") ;
Electricity_GER_rpt(t,"cost-windon")           = Electricity_rpt(t,"Germany","cost-windon") ;
Electricity_GER_rpt(t,"cost-windoff")          = Electricity_rpt(t,"Germany","cost-windoff") ;
Electricity_GER_rpt(t,"cost-bio")              = Electricity_rpt(t,"Germany","cost-bio") ;
Electricity_GER_rpt(t,"cost-gas")              = Electricity_rpt(t,"Germany","cost-gas") ;
Electricity_GER_rpt(t,"cost-coa")              = Electricity_rpt(t,"Germany","cost-coa") ;
Electricity_GER_rpt(t,"cost-lig")              = Electricity_rpt(t,"Germany","cost-lig") ;

* * * Electricity generation reporting
Parameters
gen(i,r,t)                                       Generation by technology (TWh)
gen_type(type,r,t)                               Generation by type (TWh)
gen_xtype(tyrpt,r,t)                             Generation by xtype (TWh)
ElectricityGeneration_rpt(t,r,i)                 Electricity generation reporting vector (TWh)
ElectricityGeneration_total_rpt(t,i)             Electricity generation reporting vector (TWh)
ElectricityGeneration_type_rpt(t,r,type)         Electricity generation reporting vector (TWh)
ElectricityGeneration_total_type_rpt(t,type)     Electricity generation reporting vector (TWh)
ElectricityGeneration_xtype_rpt(t,r,tyrpt)       Electricity generation reporting vector (TWh)
ElectricityGeneration_total_xtype_rpt(t,tyrpt)   Electricity generation reporting vector (TWh)
ElectricityGeneration_GER_xtype_rpt(t,tyrpt)     Electricity generation reporting vector (TWh)
;

gen(i,r,t)               = sum(ivrt(i,v,r,t), XTWH.L(i,v,r,t)) ;
gen_type(type,r,t)       = sum(idef(i,type), gen(i,r,t));
gen_xtype(tyrpt,r,t)     = sum(xtyperpt(tyrpt,type), gen_type(type,r,t)) ;

ElectricityGeneration_rpt(t,r,i)                 = gen(i,r,t) ;
ElectricityGeneration_total_rpt(t,i)             = sum(r, gen(i,r,t)) ;
ElectricityGeneration_type_rpt(t,r,type)         = gen_type(type,r,t) ;
ElectricityGeneration_total_type_rpt(t,type)     = sum(r, gen_type(type,r,t)) ;
ElectricityGeneration_xtype_rpt(t,r,tyrpt)       = gen_xtype(tyrpt,r,t) ;
ElectricityGeneration_total_xtype_rpt(t,tyrpt)   = sum(r, gen_xtype(tyrpt,r,t)) + eps ;
ElectricityGeneration_GER_xtype_rpt(t,tyrpt)     = sum(r$sameas(r,"Germany"), gen_xtype(tyrpt,r,t)) + eps ;

* * * Intalled capacities reporting
Parameters
installed(i,r,t)                                 Installed capacity by region (GW)
installed_type(type,r,t)                         Installed capacity by region and type (GW)
InstalledCapacities_rpt(t,r,i)                   Installed capacities reporting vector (GW)
InstalledCapacities_total_rpt(t,i)               Installed capacities reporting vector (GW)
InstalledCapacities_type_rpt(t,r,type)           Installed capacities reporting vector (GW)
InstalledCapacities_total_type_rpt(t,type)       Installed capacities reporting vector (GW)
InstalledCapacities_xtype_rpt(t,r,tyrpt)         Installed capacities reporting vector (GW)
InstalledCapacities_total_xtype_rpt(t,tyrpt)     Installed capacities reporting vector (GW)
InstalledCapacities_GER_xtype_rpt(t,tyrpt)       Installed capacities reporting vector (GW)
;

installed(i,r,t)         = sum(ivrt(i,v,r,t), XC.L(i,v,r,t)) ;
installed_type(type,r,t) = sum(idef(i,type), installed(i,r,t)) ;

InstalledCapacities_rpt(t,r,i)                   = installed(i,r,t) ;
InstalledCapacities_total_rpt(t,i)                = sum(r, installed(i,r,t)) ;
InstalledCapacities_type_rpt(t,r,type)           = installed_type(type,r,t) ;
InstalledCapacities_total_type_rpt(t,type)       = sum(r, installed_type(type,r,t)) ;
InstalledCapacities_xtype_rpt(t,r,tyrpt)         = sum(xtyperpt(tyrpt,type), installed_type(type,r,t)) ;
InstalledCapacities_total_xtype_rpt(t,tyrpt)     = sum(r, sum(xtyperpt(tyrpt,type), installed_type(type,r,t))) + eps ;
InstalledCapacities_GER_xtype_rpt(t,tyrpt)       = sum(r$sameas(r,"Germany"), sum(xtyperpt(tyrpt,type), installed_type(type,r,t))) + eps ;

* * * Added capacities reporting
Parameters
added(i,r,t)                                     Added capacity by region (GW)
added_type(type,r,t)                             Added capacity by region and type (GW)
AddedCapacities_rpt(t,r,i)                       Added capacities reporting vector (GW)
AddedCapacities_total_rpt(t,i)                   Added capacities reporting vector (GW)
AddedCapacities_type_rpt(t,r,type)               Added capacities reporting vector (GW)
AddedCapacities_total_type_rpt(t,type)           Added capacities reporting vector (GW)
AddedCapacities_xtype_rpt(t,r,tyrpt)             Added capacities reporting vector (GW)
AddedCapacities_total_xtype_rpt(t,tyrpt)         Added capacities reporting vector (GW)
AddedCapacities_GER_xtype_rpt(t,tyrpt)           Added capacities reporting vector (GW)
;

added(i,r,t)         = IX.L(i,r,t) ;
added_type(type,r,t) = sum(idef(i,type), added(i,r,t)) ;

AddedCapacities_rpt(t,r,i)                      = added(i,r,t) ;
AddedCapacities_total_rpt(t,i)                  = sum(r, added(i,r,t)) ;
AddedCapacities_type_rpt(t,r,type)              = added_type(type,r,t) ;
AddedCapacities_total_type_rpt(t,type)          = sum(r, added_type(type,r,t)) ;
AddedCapacities_xtype_rpt(t,r,tyrpt)            = sum(xtyperpt(tyrpt,type), added_type(type,r,t)) ;
AddedCapacities_total_xtype_rpt(t,tyrpt)        = sum(r, sum(xtyperpt(tyrpt,type), added_type(type,r,t))) + eps ;
AddedCapacities_GER_xtype_rpt(t,tyrpt)          = sum(r$sameas(r,"Germany"), sum(xtyperpt(tyrpt,type), added_type(type,r,t))) + eps ;

* * * Retired capacities reporting
parameters
retired(i,r,t)                                   Retired capacity by region (GW)
retired_type(type,r,t)                           Retired capacity by region and type (GW)
RetiredCapacities_rpt(t,r,i)                       Retired capacities reporting vector (GW)
RetiredCapacities_total_rpt(t,i)                 Retired capacities reporting vector (GW)
RetiredCapacities_type_rpt(t,r,type)               Retired capacities reporting vector (GW)
RetiredCapacities_total_type_rpt(t,type)         Retired capacities reporting vector (GW)
RetiredCapacities_xtype_rpt(t,r,tyrpt)             Retired capacities reporting vector (GW)
RetiredCapacities_total_xtype_rpt(t,tyrpt)       Retired capacities reporting vector (GW)
;

retired(i,r,"2020")            = sum(ivrt(i,v,r,"2020"), XC.L(i,v,r,"2020") - cap(i,v,r)) ;
retired(i,r,t)$(t.val > 2020)  = sum(ivrt(i,v,r,t)$(t.val > v.val), XC.L(i,v,r,t-1) - XC.L(i,v,r,t)) ;
retired_type(type,r,t)         = sum(idef(i,type), retired(i,r,t)) ;

RetiredCapacities_rpt(t,r,i)               = retired(i,r,t) ;
RetiredCapacities_total_rpt(t,i)           = sum(r, retired(i,r,t)) ;
RetiredCapacities_type_rpt(t,r,type)       = retired_type(type,r,t) ;
RetiredCapacities_total_type_rpt(t,type)   = sum(r, retired_type(type,r,t)) ;
RetiredCapacities_xtype_rpt(t,r,tyrpt)     = sum(xtyperpt(tyrpt,type), retired_type(type,r,t)) ;
RetiredCapacities_total_xtype_rpt(t,tyrpt) = sum(r, sum(xtyperpt(tyrpt,type), retired_type(type,r,t))) + eps ;

* * * RetiredEarly capacities reporting
parameters
retiredearly(i,r,t)                                      RetiredEarly capacity by region (GW)
retiredearly_type(type,r,t)                              RetiredEarly capacity by region and type (GW)
RetiredEarlyCapacities_rpt(t,r,i)                        RetiredEarly capacities reporting vector (GW)
RetiredEarlyCapacities_total_rpt(t,i)                  RetiredEarly capacities reporting vector (GW)
RetiredEarlyCapacities_type_rpt(t,r,type)                RetiredEarly capacities reporting vector (GW)
RetiredEarlyCapacities_total_type_rpt(t,type)          RetiredEarly capacities reporting vector (GW)
RetiredEarlyCapacities_xtype_rpt(t,r,tyrpt)              RetiredEarly capacities reporting vector (GW)
RetiredEarlyCapacities_total_xtype_rpt(t,tyrpt)        RetiredEarly capacities reporting vector (GW)
;

retiredearly(i,r,"2020")            = sum(ivrt(i,v,r,"2020"), XC.L(i,v,r,"2020") - cap(i,v,r)) ;
retiredearly(i,r,t)$(t.val > 2020)  = sum(ivrt(i,v,r,t)$(t.val > v.val), (XC.L(i,v,r,t-1) - XC.L(i,v,r,t)) * lifetime(i,v,r,t)) ;
retiredearly_type(type,r,t)         = sum(idef(i,type), retiredearly(i,r,t)) ;

RetiredEarlyCapacities_rpt(t,r,i)                        = retiredearly(i,r,t) ;
RetiredEarlyCapacities_total_rpt(t,i)                  = sum(r, retiredearly(i,r,t)) ;
RetiredEarlyCapacities_type_rpt(t,r,type)                = retiredearly_type(type,r,t) ;
RetiredEarlyCapacities_total_type_rpt(t,type)          = sum(r, retiredearly_type(type,r,t)) ;
RetiredEarlyCapacities_xtype_rpt(t,r,tyrpt)              = sum(xtyperpt(tyrpt,type), retiredearly_type(type,r,t)) ;
RetiredEarlyCapacities_total_xtype_rpt(t,tyrpt)        = sum(r, sum(xtyperpt(tyrpt,type), retiredearly_type(type,r,t))) + eps ;

*$ontext
* * * Total system cost reporting
Parameters
inves_normal(r,t)        Annual investment cost (EUR billions)
inves_annui(r,t)         Annual investment cost (EUR billions)
inves_ccost(r,t)         Annual investment cost (EUR billions)
inves_normal_nodisc(r,t) Annual investment cost (EUR billions)
inves_annui_nodisc(r,t)  Annual investment cost (EUR billions)
inves_ccost_nodisc(r,t)  Annual investment cost (EUR billions)
fixed(r,t)               Annual fixed cost (EUR billions)
varia(r,t)               Annual dispatch cost(EUR billions)
Cost_rpt(t,r,*)          Cost reporting vector (EUR billions)
Cost_total_rpt(t,*)      Total cost reporting vector (EUR billions)
TotalSystemCost_rpt(t,r,*) Total cost reporting vector (EUR billions)
;

inves_normal(r,t) =    1e-3 * sum(new,                                        IX.L(new,r,t)             * sum(tv(t,v)$ivrt(new,v,r,t),         capcost(new,v,r)           *  modeldepr(new,v,r,t) ))        * dfact(t) / nyrs(t)
$if      set storage + 1e-3 * sum(newj,                                       IG.L(newj,r,t)            * sum(tv(t,v)$jvrt(newj,v,r,t),       gcapcost(newj,v,r)          * gmodeldepr(newj,v,r,t) ))       * dfact(t) / nyrs(t)
$if      set trans   + 1e-3 * sum((rr,k)$tmap(k,r,rr), IT.L(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t), tcapcost(k,r,rr) * tmodeldepr(k,v,r,t) )) * dfact(t) / nyrs(t)
;

inves_normal_nodisc(r,t) =    1e-3 * sum(new,                                        IX.L(new,r,t)             * sum(tv(t,v)$ivrt(new,v,r,t),         capcost(new,v,r)           *  modeldepr_nodisc(new,v,r,t) ))
$if      set storage        + 1e-3 * sum(newj,                                       IG.L(newj,r,t)            * sum(tv(t,v)$jvrt(newj,v,r,t),       gcapcost(newj,v,r)          * gmodeldepr_nodisc(newj,v,r,t) ))
$if      set trans          + 1e-3 * sum((rr,k)$tmap(k,r,rr), IT.L(k,r,rr,t) * sum(tv(t,v)$tvrt(k,v,r,t), tcapcost(k,r,rr) * tmodeldepr_nodisc(k,v,r,t) ))
;

inves_annui(r,t) =     1e-3 * sum(new,                                        sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(new,v,r,tt)),        IX.L(new,r,tt)            *  capcost(new,v,r)           *  deprtime(new,v,r,tt)        *  annuity(new,v)          * dfact(t) ))
$if      set storage + 1e-3 * sum(newj,                                       sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(newj,v,r,tt)),       IG.L(newj,r,tt)           * gcapcost(newj,v,r)          * gdeprtime(newj,v,r,tt)       * gannuity(newj,v)       * dfact(t) ))
$if      set trans   + 1e-3 * sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT.L(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * tannuity(k) * dfact(t) ))
;

inves_annui_nodisc(r,t) =     1e-3 * sum(new,                                        sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(new,v,r,tt)),        IX.L(new,r,tt)            *  capcost(new,v,r)           *  deprtime(new,v,r,tt)        *  annuity(new,v)          * nyrs(t) ))
$if      set storage        + 1e-3 * sum(newj,                                       sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(newj,v,r,tt)),       IG.L(newj,r,tt)           * gcapcost(newj,v,r)          * gdeprtime(newj,v,r,tt)       * gannuity(newj,v)       * nyrs(t) ))
$if      set trans          + 1e-3 * sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT.L(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * tannuity(k) * nyrs(t) ))
;

inves_ccost(r,t) =     1e-3 * sum(new,                                        sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(new,v,r,tt)),        IX.L(new,r,tt)            *  capcost(new,v,r)           *  deprtime(new,v,r,tt)        * drate * dfact(t) ))
$if      set storage + 1e-3 * sum(newj,                                       sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(newj,v,r,tt)),       IG.L(newj,r,tt)           * gcapcost(newj,v,r)          * gdeprtime(newj,v,r,tt)       * drate * dfact(t) ))
$if      set trans   + 1e-3 * sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT.L(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * drate * dfact(t) ))
;

inves_ccost_nodisc(r,t) =     1e-3 * sum(new,                                        sum((tt,v)$((tt.val le t.val) and tv(tt,v) and ivrt(new,v,r,tt)),        IX.L(new,r,tt)            *  capcost(new,v,r)           *  deprtime(new,v,r,tt)        * drate * nyrs(t) ))
$if      set storage        + 1e-3 * sum(newj,                                       sum((tt,v)$((tt.val le t.val) and tv(tt,v) and jvrt(newj,v,r,tt)),       IG.L(newj,r,tt)           * gcapcost(newj,v,r)          * gdeprtime(newj,v,r,tt)       * drate * nyrs(t) ))
$if      set trans          + 1e-3 * sum((rr,k)$tmap(k,r,rr), sum((tt,v)$((tt.val le t.val) and tv(tt,v) and tvrt(k,v,r,tt)), IT.L(k,r,rr,t) * tcapcost(k,r,rr) * tdeprtime(k,v,r,tt) * drate * nyrs(t) ))
;

fixed(r,t) =           1e-3 * sum(ivrt(i,v,r,t), XC.L(i,v,r,t) *  fomcost(i,v,r))
$if      set storage + 1e-3 * sum(jvrt(j,v,r,t), GC.L(j,v,r,t) * gfomcost(j,v,r))
$if      set trans   + 1e-3 * sum((rr,k)$tcap(k,r,rr), (tcap(k,r,rr) + TC.L(k,r,rr,t)) * tfomcost(k,r,rr) )
;

varia(r,t) =           1e-3 * sum(ivrt(i,v,r,t), XTWH.L(i,v,r,t) * discost(i,v,r,t))
$if      set storage + 1e-6 * sum(jvrt(j,v,r,t), sum(s, (G.L(s,j,v,r,t) + GD.L(s,j,v,r,t)) * hours(s)) * gvomcost(j,v,r))
$if      set trans   + 1e-6 * sum((rr,k)$tcap(k,r,rr), sum(s, E.L(s,k,r,rr,t)) * tvomcost(k,r,rr))
;

Cost_rpt(t,r,"Total cost normal")                = inves_normal(r,t)             + fixed(r,t) * dfact(t) + varia(r,t) * dfact(t) ;
Cost_rpt(t,r,"Total cost normal nodisc")         = inves_normal_nodisc(r,t)      + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t) ;
Cost_rpt(t,r,"Total cost annui")                 = inves_annui(r,t)              + fixed(r,t) * dfact(t) + varia(r,t) * dfact(t) ;
Cost_rpt(t,r,"Total cost annui nodisc")          = inves_annui_nodisc(r,t)       + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t) ;
Cost_rpt(t,r,"Total cost ccost")                 = inves_ccost(r,t)              + fixed(r,t) * dfact(t) + varia(r,t) * dfact(t) ;
Cost_rpt(t,r,"Total cost ccost nodisc")          = inves_ccost_nodisc(r,t)       + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t) ;
Cost_rpt(t,r,"Investment cost normal")           = inves_normal(r,t) ;
Cost_rpt(t,r,"Investment cost normal nodisc")    = inves_normal_nodisc(r,t) ;
Cost_rpt(t,r,"Investment cost annui")            = inves_annui(r,t) ;
Cost_rpt(t,r,"Investment cost annui nodisc")     = inves_annui_nodisc(r,t) ;
Cost_rpt(t,r,"Investment cost ccost")            = inves_ccost(r,t) ;
Cost_rpt(t,r,"Investment cost ccost nodisc")     = inves_ccost_nodisc(r,t) ;
Cost_rpt(t,r,"Fixed cost")                       = fixed(r,t) ;
Cost_rpt(t,r,"Variable cost")                    = varia(r,t) ;

*Cost_total_rpt(t,"Total cost normal")                = sum(r, inves_normal(r,t)             + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
Cost_total_rpt(t,"Total cost normal nodisc")         = sum(r, inves_normal_nodisc(r,t)      + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
*Cost_total_rpt(t,"Total cost annui")                 = sum(r, inves_annui(r,t)              + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
Cost_total_rpt(t,"Total cost annui nodisc")          = sum(r, inves_annui_nodisc(r,t)       + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
*Cost_total_rpt(t,"Total cost ccost")                 = sum(r, inves_ccost(r,t)              + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
Cost_total_rpt(t,"Total cost ccost nodisc")          = sum(r, inves_ccost_nodisc(r,t)       + fixed(r,t) * nyrs(t) + varia(r,t) * nyrs(t)) ;
*Cost_total_rpt(t,"Investment cost normal")           = sum(r, inves_normal(r,t)) ;
Cost_total_rpt(t,"Investment cost normal nodisc")    = sum(r, inves_normal_nodisc(r,t)) ;
*Cost_total_rpt(t,"Investment cost annui")            = sum(r, inves_annui(r,t)) ;
Cost_total_rpt(t,"Investment cost annui nodisc")     = sum(r, inves_annui_nodisc(r,t)) ;
*Cost_total_rpt(t,"Investment cost ccost")            = sum(r, inves_ccost(r,t)) ;
Cost_total_rpt(t,"Investment cost ccost nodisc")     = sum(r, inves_ccost_nodisc(r,t)) ;
Cost_total_rpt(t,"Fixed cost")                       = sum(r, fixed(r,t)) ;
Cost_total_rpt(t,"Variable cost")                    = sum(r, varia(r,t)) ;

TotalSystemCost_rpt(t,r,"System cost")           = Cost_rpt(t,r,"Total cost annui nodisc") + eps ;
TotalSystemCost_rpt(t,r,"System fixed cost")     = Cost_rpt(t,r,"Fixed cost") + eps ;
TotalSystemCost_rpt(t,r,"System variable cost")  = Cost_rpt(t,r,"Variable cost") + eps ;

parameters
EmissionsCost_rpt(t,*)
EmissionsCost_Accumulated_rpt(t,*)
;

EmissionsCost_rpt(t,"CO2 emissions (annual)")            = sum(r, co2emit(r,t)) ;
EmissionsCost_rpt(t,"CO2 emissions captured (annual)")   = sum(r, co2capt(r,t)) + eps ;
EmissionsCost_rpt(t,"CO2 price")                         = co2pr(t) ;
EmissionsCost_rpt(t,"CO2 emissions abated (annual)")     = sum(r, co2emit(r,"2020") - co2emit(r,t)) ;
EmissionsCost_rpt(t,"Cost (annual)")                     = sum(r, inves_annui_nodisc(r,t) / nyrs(t) + fixed(r,t) + varia(r,t)) ;
EmissionsCost_rpt(t,"Investment cost (annual)")          = sum(r, inves_annui_nodisc(r,t) / nyrs(t)) ;
EmissionsCost_rpt(t,"Fixed cost (annual)")               = sum(r, fixed(r,t)) ;
EmissionsCost_rpt(t,"Variable cost (annual)")            = sum(r, varia(r,t)) ;

EmissionsCost_Accumulated_rpt(t,"CO2 emissions")            = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, co2emit(r,tt))) ;
EmissionsCost_Accumulated_rpt(t,"CO2 emissions captured")   = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, co2capt(r,tt))) + eps ;
EmissionsCost_Accumulated_rpt(t,"CO2 price")                = co2pr(t) ;
EmissionsCost_Accumulated_rpt(t,"CO2 emissions abated")     = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, co2emit(r,"2020") - co2emit(r,tt))) ;
EmissionsCost_Accumulated_rpt(t,"Cost")                     = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, inves_annui_nodisc(r,tt) / nyrs(tt) + fixed(r,tt) + varia(r,tt))) ;
EmissionsCost_Accumulated_rpt(t,"Investment cost")          = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, inves_annui_nodisc(r,tt) / nyrs(tt))) ;
EmissionsCost_Accumulated_rpt(t,"Fixed cost")               = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, fixed(r,tt))) ;
EmissionsCost_Accumulated_rpt(t,"Variable cost")            = sum(tt$(tt.val le t.val), nyrs(tt) * sum(r, varia(r,tt))) ;
*$offtext

* * * Curtailment reporting (of intermittent renewable energies)
parameters
curtailment(i,r,t)                       Curtailment by technology (TWh)
curtailment_type(type,r,t)               Curtailment by type (TWh)
Curtailment_rpt(t,r,i)                   Curtailment reporting vector (TWh)
Curtailment_total_rpt(t,i)               Curtailment reporting vector (TWh)
Curtailment_type_rpt(t,r,type)           Curtailment reporting vector (TWh)
Curtailment_total_type_rpt(t,type)       Curtailment reporting vector (TWh)
Curtailment_xtype_rpt(t,r,tyrpt)         Curtailment reporting vector (TWh)
Curtailment_total_xtype_rpt(t,tyrpt)     Curtailment reporting vector (TWh)
;

curtailment(i,r,t)$sum((s,v), vrsc(s,i,v,r))   = 1e-3 * sum((s,ivrt(i,v,r,t)), XC.L(i,v,r,t) * hours(s) * (1 + (reliability(i,v,r)-1)$reliability(i,v,r)) * (1 + (af(s,i,v,r,t)-1)$af(s,i,v,r,t)) * (1 + (vrsc(s,i,v,r)-1)$vrsc(s,i,v,r))) - gen(i,r,t) ;
curtailment_type(type,r,t)               = sum(idef(i,type), curtailment(i,r,t)) ;

Curtailment_rpt(t,r,i)                   = curtailment(i,r,t) ;
Curtailment_type_rpt(t,r,type)           = curtailment_type(type,r,t) ;
Curtailment_xtype_rpt(t,r,tyrpt)         = sum(xtyperpt(tyrpt,type), curtailment_type(type,r,t)) ;
Curtailment_total_rpt(t,i)               = sum(r, curtailment(i,r,t)) ;
Curtailment_total_type_rpt(t,type)       = sum(r, curtailment_type(type,r,t)) ;
Curtailment_total_xtype_rpt(t,tyrpt)     = sum(r, sum(xtyperpt(tyrpt,type), curtailment_type(type,r,t))) + eps ;

* * * Full-load hours generation
Parameters
flh(i,r,t)                               Full-load hours by technology (h)
flh_type(type,r,t)                       Full load hours by type (h)
FlhGeneration_rpt(t,r,i)                 Full-load hours generation reporting vector (h)
FlhGeneration_type_rpt(t,r,type)         Full-load hours generation reporting vector (h)
FlhGeneration_xtype_rpt(t,r,tyrpt)       Full-load hours generation reporting vector (h)
FlhGeneration_total_rpt(t,i)             Full-load hours generation reporting vector (h)
FlhGeneration_total_type_rpt(t,type)     Full-load hours generation reporting vector (h)
FlhGeneration_total_xtype_rpt(t,tyrpt)   Full-load hours generation reporting vector (h)
;

flh(i,r,t)$(installed(i,r,t) > 0.1)                                                      = 1e+3 * gen(i,r,t)             / installed(i,r,t) ;
flh_type(type,r,t)$(installed_type(type,r,t) > 0.1)                                      = 1e+3 * gen_type(type,r,t)     / installed_type(type,r,t) ;

FlhGeneration_rpt(t,r,i)                 = flh(i,r,t) ;
FlhGeneration_type_rpt(t,r,type)         = flh_type(type,r,t) ;
FlhGeneration_xtype_rpt(t,r,tyrpt)$(sum(xtyperpt(tyrpt,type), installed_type(type,r,t)) > 0.1)                   = 1e+3 * sum(xtyperpt(tyrpt,type), gen_type(type,r,t)) / sum(xtyperpt(tyrpt,type), installed_type(type,r,t)) ;
FlhGeneration_total_rpt(t,i)$(sum(r, installed(i,r,t)) > 0.1)                                                    = 1e+3 * sum(r, gen(i,r,t)) / sum(r, installed(i,r,t)) ;
FlhGeneration_total_type_rpt(t,type)$(sum(r, installed_type(type,r,t)) > 0.1)                                    = 1e+3 * sum(r, gen_type(type,r,t)) / sum(r, installed_type(type,r,t)) ;
FlhGeneration_total_xtype_rpt(t,tyrpt)$(sum(r, sum(xtyperpt(tyrpt,type), installed_type(type,r,t))) > 0.1)       = 1e+3 * sum(r, sum(xtyperpt(tyrpt,type), gen_type(type,r,t))) / sum(r, sum(xtyperpt(tyrpt,type), installed_type(type,r,t))) + eps ;

* * * Transfers reporting
parameters
transfers(s,k,r,r,t)          Transfers by technology (TWh)
transfers_r(s,k,r,t)          Transfers by technology in one region (TWh)
transfers_ann(k,r,r,t)        Transfers by technology annual (TWh)
transfers_ann_r(k,r,t)        Transfers by technology annual in one region (TWh)
domexport(s,r,r,t)                       Transfers (TWh)
domexport_r(s,r,t)                       Transfers in one region (TWh)
domexport_ann(r,r,t)                     Transfers annual (TWh)
domexport_ann_r(r,t)                     Transfers annual in one region (TWh)
Transfers_rpt(t,r,r)                     Transfers reporting vector (TWh)
Transfers_r_rpt(t,r)                     Transfers reporting vector (TWh)
Transfers_total_rpt(t)                   Transfers reporting vector (TWh)
;

$if not  set trans      transfers(s,k,r,rr,t) = eps ;
$if      set trans      transfers(s,k,r,rr,t) = E.L(s,k,r,rr,t) * 1e-3 ;

transfers_r(s,k,r,t)    = sum(rr, transfers(s,k,r,rr,t)) ;
transfers_ann(k,r,rr,t) = sum(s,  transfers(s,k,r,rr,t) * hours(s)) ;
transfers_ann_r(k,r,t)  = sum(rr, transfers_ann(k,r,rr,t)) ;

domexport(s,r,rr,t)       = sum(k, transfers(s,k,r,rr,t)) ;
domexport_r(s,r,t)        = sum(k, transfers_r(s,k,r,t)) ;
domexport_ann(r,rr,t)     = sum(k, transfers_ann(k,r,rr,t)) ;
domexport_ann_r(r,t)      = sum(k, transfers_ann_r(k,r,t)) ;

Transfers_rpt(t,r,rr)     = domexport_ann(r,rr,t) ;
Transfers_r_rpt(t,r)      = domexport_ann_r(r,t) ;
Transfers_total_rpt(t)    = sum(r, domexport_ann_r(r,t)) + eps ;

* * * NTC reporting
parameters
ntc(k,r,r,t)                  NTC (GW)
ntc_r(k,r,t)                  NTC (GW)
ntc_rr(r,r,t)                            NTC (GW)
ntc_rrr(r,t)                             NTC (GW)
NTC_rpt(t,r,r)                           NTC (GW)
NTC_r_rpt(r,t)                           NTC (GW)
NTC_total_rpt(t)                         NTC (GW)
NTCTransfers_total_rpt(t,*)              NTC (GW)
;

$if not  set trans      ntc(k,r,rr,t) = eps ;
$if      set trans      ntc(k,r,rr,t) = TC.L(k,r,rr,t) + tcap(k,r,rr) ;

ntc_r(k,r,t)  = sum(rr, ntc(k,r,rr,t)) ;
ntc_rr(r,rr,t)           = sum(k, ntc(k,r,rr,t)) ;
ntc_rrr(r,t)             = sum((rr,k), ntc(k,r,rr,t)) ;

NTC_rpt(t,r,rr)          = ntc_rr(r,rr,t) ;
NTC_r_rpt(r,t)           = ntc_rrr(r,t) ;
NTC_total_rpt(t)         = sum(r, ntc_rrr(r,t)) + eps ;

NTCTransfers_total_rpt(t,"NTC (GW)") = NTC_total_rpt(t) ;
NTCTransfers_total_rpt(t,"Transfer (TWh)") = Transfers_total_rpt(t) ;

* * * Regional reporting
parameter
NTC_rrpt(t,rrpt,rrpt)                    NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
NTC_r_rrpt(rrpt,t)                       NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
NTC_total_rrpt(t)                        NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
Transfers_rrpt(t,rrpt,rrpt)              NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
Transfers_r_rrpt(rrpt,t)                 NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
Transfers_total_rrpt(t)                  NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
NTCTransfers_total_rrpt(t,*)             NTC (GW) and transfers (TWh) between 4 reporting regions without within region values
;

NTC_rrpt(t,rrpt,rrpt_)$(not sameas(rrpt,rrpt_)) = sum(xrrpt_(rrpt_,rr), sum(xrrpt(rrpt,r), ntc_rr(r,rr,t))) ;
NTC_r_rrpt(rrpt,t)     = sum(rrpt_, NTC_rrpt(t,rrpt,rrpt_)) ;
NTC_total_rrpt(t)      = sum(rrpt,  NTC_r_rrpt(rrpt,t)) ;

Transfers_rrpt(t,rrpt,rrpt_)$(not sameas(rrpt,rrpt_)) = sum(xrrpt_(rrpt_,rr), sum(xrrpt(rrpt,r), Transfers_rpt(t,r,rr))) ;
Transfers_r_rrpt(rrpt,t)     = sum(rrpt_,                               Transfers_rrpt(t,rrpt,rrpt_)) ;
Transfers_total_rrpt(t)      = sum(rrpt,                                Transfers_r_rrpt(rrpt,t) ) ;

NTCTransfers_total_rrpt(t,"NTC (GW)") = NTC_total_rrpt(t) ;
NTCTransfers_total_rrpt(t,"Transfer (TWh)") = Transfers_total_rrpt(t) ;

* * * Regional reporting
parameter
NTC_rrrpt(t,rrpt,rrpt)                   NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
NTC_r_rrrpt(rrpt,t)                      NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
NTC_total_rrrpt(t)                       NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
Transfers_rrrpt(t,rrpt,rrpt)             NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
Transfers_r_rrrpt(rrpt,t)                NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
Transfers_total_rrrpt(t)                 NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
NTCTransfers_total_rrrpt(t,*)            NTC (GW) and transfers (TWh) between 4 reporting regions with within region values
;

NTC_rrrpt(t,rrpt,rrpt_) = sum(xrrpt_(rrpt_,rr), sum(xrrpt(rrpt,r), ntc_rr(r,rr,t))) ;
NTC_r_rrrpt(rrpt,t)     = sum(rrpt_, NTC_rrpt(t,rrpt,rrpt_)) ;
NTC_total_rrrpt(t)      = sum(rrpt,  NTC_r_rrpt(rrpt,t)) ;

Transfers_rrrpt(t,rrpt,rrpt_) = sum(xrrpt_(rrpt_,rr), sum(xrrpt(rrpt,r), Transfers_rpt(t,r,rr))) ;
Transfers_r_rrrpt(rrpt,t)     = sum(rrpt_,                               Transfers_rrpt(t,rrpt,rrpt_)) ;
Transfers_total_rrrpt(t)      = sum(rrpt,                                Transfers_r_rrpt(rrpt,t) ) ;

NTCTransfers_total_rrrpt(t,"NTC (GW)") = NTC_total_rrpt(t) ;
NTCTransfers_total_rrrpt(t,"Transfer (TWh)") = Transfers_total_rrpt(t) ;

* * * NTC rents reporting
parameter
rent(k,r,r,t) NTC rent by technology (billion EUR)
rent_r(k,r,t) NTC rent by technology in one region (billion EUR)
rent_rr(r,r,t)           NTC rent (billion EUR)
rent_rrr(r,t)            NTC rent in one region (billion EUR)
Rent_rpt(t,r,r)          NTC rent reporting vector (billion EUR)
Rent_r_rpt(r,t)          NTC rent reporting vector (billion EUR)
Rent_total_rpt(t)        NTC rent reporting vector (billion EUR)
;

$if not  set trans      rent(k,r,rr,t) = eps ;
$if      set trans      rent(k,r,rr,t) = sum(s, E.L(s,k,r,rr,t) * hours(s) * (price(s,rr,t) - price(s,r,t))) * 1e-6 ;

rent_r(k,r,t)  = sum(rr, rent(k,r,rr,t)) ;
rent_rr(r,rr,t)           = sum(k, rent(k,r,rr,t)) ;
rent_rrr(r,t)             = sum((rr,k), rent(k,r,rr,t)) ;

Rent_rpt(t,r,rr)          = rent_rr(r,rr,t) ;
Rent_r_rpt(r,t)           = rent_rrr(r,t) ;
Rent_total_rpt(t)         = sum(r, rent_rrr(r,t)) + eps ;

* * * Full-load hours transmission reporting
Parameters
flh_transmission(r,r,t)      Full load hours per line (h)
flh_transmission_r(r,t)      Full load hours per region (h)
flh_transmission_total(t)    Full load hours of the system (h)
FlhTransmission_rpt(t,r,r)   Transmission flh reporting vector (h)
FlhTransmission_r_rpt(r,t)   Transmission flh reporting vector (h)
FlhTransmission_total_rpt(t) Transmission flh reporting vector (h)
;

flh_transmission(r,rr,t)$(ntc_rr(r,rr,t) > 0)    = domexport_ann(r,rr,t) / ntc_rr(r,rr,t) * 1e+3 ;
flh_transmission_r(r,t)$ntc_rrr(r,t)             = domexport_ann_r(r,t) / ntc_rrr(r,t) * 1e+3 ;
flh_transmission_total(t)$sum(r, ntc_rrr(r,t))   = sum(r, domexport_ann_r(r,t)) / sum(r, ntc_rrr(r,t)) * 1e+3 ;

FlhTransmission_rpt(t,r,rr)      = flh_transmission(r,rr,t) ;
FlhTransmission_r_rpt(r,t)       = flh_transmission_r(r,t) ;
FlhTransmission_total_rpt(t)     = flh_transmission_total(t) + eps ;

* * * Storage reporting
Parameter
ginstalled(r,j,t)                        Installed storage charge capacity by region (GW)
ginvestment(r,j,t)                       Investments in storage charge capacity by region (GW)
gretirement(r,j,t)                       Retirement of storage charge capacity by region (GW)
ginstalledc(r,j,t)                       Installed storage capacity by region (TWh)
ginvestmentc(r,j,t)                      Investments in storage capacity by region (TWh)
gretirementc(r,j,t)                      Retirement of storage capacity in GWh by region (TWh)
gavcharge(r,j,t)                         Average state of charging (% of reservoir capacity)
gflh(r,j,t)                              Storage FLH cycles (from reservoir capacity)
gstored(r,j,t)                           Accumulated stored energy (TWh)
GC_L(j,v,r,t)                            Interim capacity for "no storage" run
IG_L(j,r,t)                              Interim capacity for "no storage" run
GB_L(s,j,v,r,t)                          Interim capacity for "no storage" run
G_L(s,j,v,r,t)                           Interim capacity for "no storage" run
Storage_rpt(t,j,r,*)                     Storage reporting vector - all
Storage_total_rpt(t,j,*)                 Storage reporting vector - all in total
Storage_GenerationCapacity_rpt(t,j)      Storage reporting vector - Generation capacity (GW)
Storage_ReservoirCapacity_rpt(t,j)       Storage reporting vector - Reservoir capacity (TWh)
Storage_StoredEnergy_rpt(t,j)            Storage reporting vector - Stored energy (TWh)
;

* Interim calculations
GC_L(j,v,r,t)    = eps ;
IG_L(j,r,t)      = eps ;
GB_L(s,j,v,r,t)  = eps ;
G_L(s,j,v,r,t)   = eps ;

$if not set storage  GC.L(j,v,r,t) = eps ;
$if not set storage  IG.L(j,r,t) = eps ;
$if not set storage  GB.L(s,j,v,r,t) = eps ;
$if not set storage  G.L(s,j,v,r,t) = eps ;

$if set storage      GC_L(j,v,r,t)    = GC.L(j,v,r,t) ;
$if set storage      IG_L(j,r,t)      = IG.L(j,r,t)   ;
$if set storage      GB_L(s,j,v,r,t)  = GB.L(s,j,v,r,t) ;
$if set storage      G_L(s,j,v,r,t)   = G.L(s,j,v,r,t)  ;

* Variable calculations
ginstalled(r,j,t)        = sum(jvrt(j,v,r,t), GC_L(j,v,r,t)) ;
ginvestment(r,j,t)       = IG.L(j,r,t) ;

gretirement(r,j,t)       = eps ;
gretirement(r,j,t)$(t.val > 2020)       = sum(jvrt(j,v,r,t)$(gcap(j,v,r)), GC_L(j,v,r,t-1) - GC_L(j,v,r,t) ) ;

ginstalledc(r,j,t)       = sum(jvrt(j,v,r,t), GC_L(j,v,r,t) * ghours(j,v,r)) * 1e-3 ;
ginvestmentc(r,j,t)      = sum(jvrt(j,v,r,t)$(t.val eq v.val), IG_L(j,r,t) * ghours(j,v,r)) * 1e-3 ;

gretirementc(r,j,t)      = eps ;
gretirementc(r,j,t)$(t.val > 2020)      = sum(jvrt(j,v,r,t)$(gcap(j,v,r)), (GC_L(j,v,r,t-1) - GC_L(j,v,r,t) ) * ghours(j,v,r)) * 1e-3 ;

gavcharge(r,j,t)$(ginstalledc(r,j,t) > 0.001)  = sum((s,jvrt(j,v,r,t)), GB_L(s,j,v,r,t) * hours(s) ) / sum(s, hours(s) * sum(jvrt(j,v,r,t), GC_L(j,v,r,t) * ghours(j,v,r))) ;

gstored(r,j,t)           = sum((s,jvrt(j,v,r,t)), G_L(s,j,v,r,t) * hours(s) ) * 1e-3 ;

gflh(r,j,t)$(ginstalledc(r,j,t) > 0.001) = gstored(r,j,t) / ginstalledc(r,j,t) ;



* Reporting calculations
Storage_rpt(t,j,r,"inst-cap-p")               = ginstalled(r,j,t) ;
Storage_rpt(t,j,r,"new-inst-cap-p")           = ginvestment(r,j,t) ;
Storage_rpt(t,j,r,"retired-cap-p")            = gretirement(r,j,t) ;
Storage_rpt(t,j,r,"inst-cap-c")               = ginstalledc(r,j,t) ;
Storage_rpt(t,j,r,"new-inst-cap-c")           = ginvestmentc(r,j,t) ;
Storage_rpt(t,j,r,"retired-cap-c")            = gretirementc(r,j,t) ;
Storage_rpt(t,j,r,"avg-state-of-charge")      = gavcharge(r,j,t) ;
Storage_rpt(t,j,r,"full-load cycles")         = gflh(r,j,t) ;
Storage_rpt(t,j,r,"stored-energy")            = gstored(r,j,t) ;

Storage_total_rpt(t,j,"inst-cap-p")              = sum(r, ginstalled(r,j,t)) ;
Storage_total_rpt(t,j,"new-inst-cap-p")          = sum(r, ginvestment(r,j,t)) ;
Storage_total_rpt(t,j,"retired-cap-p")           = sum(r, gretirement(r,j,t)) ;
Storage_total_rpt(t,j,"inst-cap-c")              = sum(r, ginstalledc(r,j,t)) ;
Storage_total_rpt(t,j,"new-inst-cap-c")          = sum(r, ginvestmentc(r,j,t)) ;
Storage_total_rpt(t,j,"retired-cap-c")           = sum(r, gretirementc(r,j,t)) ;
Storage_total_rpt(t,j,"avg-state-of-charge")     = sum(r, gavcharge(r,j,t)) / sum(r, 1) ;
Storage_total_rpt(t,j,"full-load cycles")        = sum(r, gflh(r,j,t)) ;
Storage_total_rpt(t,j,"stored-energy")           = sum(r, gstored(r,j,t)) ;

Storage_GenerationCapacity_rpt(t,j)              = Storage_total_rpt(t,j,"inst-cap-p") + eps ;
Storage_ReservoirCapacity_rpt(t,j)               = Storage_total_rpt(t,j,"inst-cap-c") + eps ;
Storage_StoredEnergy_rpt(t,j)                    = Storage_total_rpt(t,j,"stored-energy") + eps ;

* * * Hourly prices reporting
Parameters
Price_s_rpt(t,s,r)         Price in segments (EUR per MWh)
Price_h_rpt(t,h,r)         Price in hours (EUR per MWh)
;

Price_s_rpt(t,s,r)  = price(s,r,t) ;
Price_h_rpt(t,h,r)  = sum(s$hmaps(h,s), price(s,r,t)) ;



* * * Social cost reporting
Parameters
ap_ivrt(ap,tyrpt,v,r,t)                      Air pollution by ivrt   (Mt)
ap_irt(ap,tyrpt,r,t)                         Air pollution by irt    (Mt)
ap_rt(ap,r,t)                            Air pollution by rt     (Mt)
ap_it(ap,tyrpt,t)                            Air pollution by it     (Mt)
ap_t(ap,t)                               Air pollution by t      (Mt)
ap_i_acc(ap,tyrpt)                           Air pollution acc by i  (Mt)
ap_r_acc(ap,r)                           Air pollution acc by r  (Mt)
ap_acc(ap)                               Air pollution acc       (Mt)

scap_impactap_ivrt(impactap,tyrpt,v,r,t)     Social cost of air pollution by ivrt (billion EUR)
scap_impactap_irt(impactap,tyrpt,r,t)        Social cost of air pollution by irt  (billion EUR)
scap_impactap_rt(impactap,r,t)           Social cost of air pollution by rt   (billion EUR)
scap_impactap_it(impactap,tyrpt,t)           Social cost of air pollution by it   (billion EUR)
scap_impactap_t(impactap,t)              Social cost of air pollution by t    (billion EUR)
scap_impactap_i_acc(impactap,tyrpt)          Social cost of air pollution acc by i(billion EUR)
scap_impactap_r_acc(impactap,r)          Social cost of air pollution acc by r(billion EUR)
scap_impactap_acc(impactap)              Social cost of air pollution acc     (billion EUR)

scap_ap_ivrt(ap,tyrpt,v,r,t)                 Social cost of air pollution by ivrt (billion EUR)
scap_ap_irt(ap,tyrpt,r,t)                    Social cost of air pollution by irt  (billion EUR)
scap_ap_rt(ap,r,t)                       Social cost of air pollution by rt   (billion EUR)
scap_ap_it(ap,tyrpt,t)                       Social cost of air pollution by it   (billion EUR)
scap_ap_t(ap,t)                          Social cost of air pollution by t    (billion EUR)
scap_ap_i_acc(ap,tyrpt)                      Social cost of air pollution acc by i(billion EUR)
scap_ap_r_acc(ap,r)                      Social cost of air pollution acc by r(billion EUR)
scap_ap_acc(ap)                          Social cost of air pollution acc     (billion EUR)

scap_ivrt(tyrpt,v,r,t)                       Social cost of air pollution by ivrt (billion EUR)
scap_irt(tyrpt,r,t)                          Social cost of air pollution by irt  (billion EUR)
scap_rt(r,t)                             Social cost of air pollution by rt   (billion EUR)
scap_it(tyrpt,t)                             Social cost of air pollution by it   (billion EUR)
scap_t(t)                                Social cost of air pollution by t    (billion EUR)
scap_i_acc(tyrpt)                            Social cost of air pollution acc by i(billion EUR)
scap_r_acc(r)                            Social cost of air pollution acc by r(billion EUR)
scap_acc                                 Social cost of air pollution acc     (billion EUR)
*scap_effect(ap,r,t)                      Effective social cost of air pollution (in model in EUR per t)

co2_ivrt(tyrpt,v,r,t)
co2_irt(tyrpt,r,t)
co2_rt(r,t)
co2_it(tyrpt,t)
co2_t(t)
co2_i_acc(tyrpt)
co2_r_acc(r)
co2_acc

scc_ivrt(tyrpt,v,r,t)
scc_irt(tyrpt,r,t)
scc_rt(r,t)
scc_it(tyrpt,t)
scc_t(t)
scc_i_acc(tyrpt)
scc_r_acc(r)
scc_acc
*scc_effect(t)                         Effective social cost of air pollution (in model in EUR per t)

Airpollution_rt_rpt(t,r,*)
Airpollution_it_rpt(t,tyrpt,*)
Airpollution_t_rpt(t,*)
Airpollution_r_acc_rpt(r,*)
Airpollution_i_acc_rpt(tyrpt,*)
Airpollution_acc_rpt(*)

Socialcost_rt_rpt(t,r,*)
Socialcost_it_rpt(t,tyrpt,*)
Socialcost_t_rpt(t,*)
Socialcost_r_acc_rpt(r,*)
Socialcost_i_acc_rpt(tyrpt,*)
Socialcost_acc_rpt(*)

Socialcost_impact_rt_rpt(t,r,*)
Socialcost_impact_it_rpt(t,tyrpt,*)
Socialcost_impact_t_rpt(t,*)
Socialcost_impact_r_acc_rpt(r,*)
Socialcost_impact_i_acc_rpt(tyrpt,*)
Socialcost_impact_acc_rpt(*)


SCCtot_rt_rpt(t,r)
SCCtot_it_rpt(t,tyrpt)
SCCspe_rt_rpt(t,r)
SCCspe_it_rpt(t,tyrpt)

SCAPtot_rt_rpt(t,r)
SCAPtot_it_rpt(t,tyrpt)
SCAPspe_rt_rpt(t,r)
SCAPspe_it_rpt(t,tyrpt)

Socialtotcost_rt_rpt(t,r)
Socialtotcost_it_rpt(t,tyrpt)
Socialspecost_rt_rpt(t,r)
Socialspecost_it_rpt(t,tyrpt)

SCCspe_t_rpt(t)
SCAPspe_t_rpt(t)
Socialspecost_t_rpt(t)

disc_scc_acc
disc_scap_acc 
;

* emitap in t per MWhel and XTWH in TWH = 10^6 t = Mt
ap_ivrt(ap,tyrpt,v,r,t)  = sum(xtyperpt(tyrpt,type), sum(idef(i,type), emitap(i,ap,v,r) * XTWH.L(i,v,r,t))) ;

ap_irt(ap,tyrpt,r,t)     = sum(v$(v.val le t.val),  ap_ivrt(ap,tyrpt,v,r,t)) ;
ap_rt(ap,r,t)            = sum(tyrpt,  ap_irt(ap,tyrpt,r,t)) ;
ap_it(ap,tyrpt,t)        = sum(r,  ap_irt(ap,tyrpt,r,t)) ;
ap_t(ap,t)               = sum(r,  ap_rt(ap,r,t)) ;
ap_i_acc(ap,tyrpt)       = sum(t$(t.val > 2020),  nyrs(t) * ap_it(ap,tyrpt,t)) ;
ap_r_acc(ap,r)           = sum(t$(t.val > 2020),  nyrs(t) * ap_rt(ap,r,t)) ;
ap_acc(ap)               = sum(t$(t.val > 2020),  nyrs(t) * ap_t(ap,t)) ;

* scap in EUR per t = 10^6 EUR
scap_impactap_ivrt(impactap,tyrpt,v,r,t) = sum(ap,            sum(xtyperpt(tyrpt,type), sum(idef(i,type), emitap(i,ap,v,r) * XTWH.L(i,v,r,t) * scap(ap,impactap,r,t)))) * 1e-3 ;
scap_ap_ivrt(ap,tyrpt,v,r,t)             = sum(impactap,      sum(xtyperpt(tyrpt,type), sum(idef(i,type), emitap(i,ap,v,r) * XTWH.L(i,v,r,t) * scap(ap,impactap,r,t)))) * 1e-3 ;
scap_ivrt(tyrpt,v,r,t)                   = sum((ap,impactap), sum(xtyperpt(tyrpt,type), sum(idef(i,type), emitap(i,ap,v,r) * XTWH.L(i,v,r,t) * scap(ap,impactap,r,t)))) * 1e-3 ;

scap_impactap_irt(impactap,tyrpt,r,t)    = sum(v$(v.val le t.val),       scap_impactap_ivrt(impactap,tyrpt,v,r,t)) ;
scap_ap_irt(ap,tyrpt,r,t)                = sum(v$(v.val le t.val),       scap_ap_ivrt(ap,tyrpt,v,r,t)) ;
scap_irt(tyrpt,r,t)                      = sum(v$(v.val le t.val),       scap_ivrt(tyrpt,v,r,t)) ;

scap_impactap_rt(impactap,r,t)           = sum(tyrpt,                    scap_impactap_irt(impactap,tyrpt,r,t)) ;
scap_ap_rt(ap,r,t)                       = sum(tyrpt,                    scap_ap_irt(ap,tyrpt,r,t) ) ;
scap_rt(r,t)                             = sum(tyrpt,                    scap_irt(tyrpt,r,t)) ;

scap_impactap_it(impactap,tyrpt,t)       = sum(r,                        scap_impactap_irt(impactap,tyrpt,r,t)) ;
scap_ap_it(ap,tyrpt,t)                   = sum(r,                        scap_ap_irt(ap,tyrpt,r,t)) ;
scap_it(tyrpt,t)                         = sum(r,                        scap_irt(tyrpt,r,t)) ;

scap_impactap_t(impactap,t)              = sum(tyrpt,                    scap_impactap_it(impactap,tyrpt,t)) ;
scap_ap_t(ap,t)                          = sum(tyrpt,                    scap_ap_it(ap,tyrpt,t)) ;
scap_t(t)                                = sum(tyrpt,                    scap_it(tyrpt,t)) ;

scap_impactap_i_acc(impactap,tyrpt)      = sum(t$(t.val > 2020), nyrs(t) *              scap_impactap_it(impactap,tyrpt,t)) ;
scap_ap_i_acc(ap,tyrpt)                  = sum(t$(t.val > 2020), nyrs(t) *              scap_ap_it(ap,tyrpt,t)) ;
scap_i_acc(tyrpt)                        = sum(t$(t.val > 2020), nyrs(t) *              scap_it(tyrpt,t)) ;

scap_impactap_r_acc(impactap,r)          = sum(t$(t.val > 2020), nyrs(t) *              scap_impactap_rt(impactap,r,t)) ;
scap_ap_r_acc(ap,r)                      = sum(t$(t.val > 2020), nyrs(t) *              scap_ap_rt(ap,r,t)) ;
scap_r_acc(r)                            = sum(t$(t.val > 2020), nyrs(t) *              scap_rt(r,t)) ;

scap_impactap_acc(impactap)              = sum(t$(t.val > 2020), nyrs(t) *              scap_impactap_t(impactap,t)) ;
scap_ap_acc(ap)                          = sum(t$(t.val > 2020), nyrs(t) *              scap_ap_t(ap,t)) ;
scap_acc                                 = sum(t$(t.val > 2020), nyrs(t) *              scap_t(t)) ;

co2_ivrt(tyrpt,v,r,t)                    = sum(xtyperpt(tyrpt,type), sum(idef(i,type), emit(i,v,r) * XTWH.L(i,v,r,t))) ;
co2_irt(tyrpt,r,t)                       = sum(v$(v.val le t.val),       co2_ivrt(tyrpt,v,r,t)) ;
co2_rt(r,t)                              = sum(tyrpt,                    co2_irt(tyrpt,r,t)) ;
co2_it(tyrpt,t)                          = sum(r,                        co2_irt(tyrpt,r,t)) ;
co2_t(t)                                 = sum(r,                        co2_rt(r,t)) ;
co2_i_acc(tyrpt)                         = sum(t$(t.val > 2020),  nyrs(t) *             co2_it(tyrpt,t)) ;
co2_r_acc(r)                             = sum(t$(t.val > 2020),  nyrs(t) *             co2_rt(r,t)) ;
co2_acc                                  = sum(t$(t.val > 2020),  nyrs(t) *             co2_t(t)) ;

scc_ivrt(tyrpt,v,r,t)                    =                               co2_ivrt(tyrpt,v,r,t) * scc_int(t) * 1e-3 ;
scc_irt(tyrpt,r,t)                       = sum(v$(v.val le t.val),       scc_ivrt(tyrpt,v,r,t)) ;
scc_rt(r,t)                              = sum(tyrpt,                    scc_irt(tyrpt,r,t)) ;
scc_it(tyrpt,t)                          = sum(r,                        scc_irt(tyrpt,r,t)) ;
scc_t(t)                                 = sum(r,                        scc_rt(r,t)) ;
scc_i_acc(tyrpt)                         = sum(t$(t.val > 2020),  nyrs(t) *             scc_it(tyrpt,t)) ;
scc_r_acc(r)                             = sum(t$(t.val > 2020),  nyrs(t) *             scc_rt(r,t)) ;
scc_acc                                  = sum(t$(t.val > 2020),  nyrs(t) *             scc_t(t)) ;

disc_scc_acc                             = sum(t$(t.val > 2020), dfact(t) *             scc_t(t)) ;
disc_scap_acc                            = sum(t$(t.val > 2020), dfact(t) *             scap_t(t)) ;

parameter
price_avg(t)
price_scc(t)
price_scap(t)
;

**
price_avg(t)  = 0 ;
price_scc(t)  = scc_t(t) * 1e+3 / (sum((s,r), dref(r,t) * load(s,r) * hours(s)) * 1e-3) ;
price_scap(t)  = scap_t(t) * 1e+3 / (sum((s,r), dref(r,t) * load(s,r) * hours(s)) * 1e-3) ;

parameter
PriceSCC_rpt(t,*)
PriceSCC_total_rpt(*)
;

PriceSCC_rpt(t,"Price-Avg") = price_avg(t) ;
PriceSCC_rpt(t,"Price-SCC") = price_scc(t) ;
PriceSCC_rpt(t,"Price-SCAP") = price_scap(t) ;


PriceSCC_total_rpt("CO2-ACC") = co2_acc ;
PriceSCC_total_rpt("AP-ACC") = sum(ap, ap_acc(ap)) ;
PriceSCC_total_rpt("SCC-ACC") = scc_acc ;
PriceSCC_total_rpt("SCAP-ACC") = scap_acc ;
PriceSCC_total_rpt("DISCSCC-ACC") = disc_scc_acc ;
PriceSCC_total_rpt("DISCSCAP-ACC") = disc_scap_acc ;

* Air pollution
Airpollution_rt_rpt(t,r,"CO2") = co2_rt(r,t) + eps ;
Airpollution_rt_rpt(t,r,"NH3") = ap_rt("NH3",r,t) + eps ;
Airpollution_rt_rpt(t,r,"NOX") = ap_rt("NOX",r,t) + eps ;
Airpollution_rt_rpt(t,r,"SO2") = ap_rt("SO2",r,t) + eps ;
Airpollution_rt_rpt(t,r,"PPM2.5") = ap_rt("PPM25",r,t) + eps ;
Airpollution_rt_rpt(t,r,"PPM10") = ap_rt("PPM10",r,t) + eps ;
Airpollution_rt_rpt(t,r,"NMVOC") = ap_rt("NMVOC",r,t) + eps ;

Airpollution_it_rpt(t,tyrpt,"CO2") = co2_it(tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"NH3") = ap_it("NH3",tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"NOX") = ap_it("NOX",tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"SO2") = ap_it("SO2",tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"PPM2.5") = ap_it("PPM25",tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"PPM10") = ap_it("PPM10",tyrpt,t) + eps ;
Airpollution_it_rpt(t,tyrpt,"NMVOC") = ap_it("NMVOC",tyrpt,t) + eps ;

Airpollution_t_rpt(t,"CO2") = co2_t(t) + eps ;
Airpollution_t_rpt(t,"NH3") = ap_t("NH3",t) + eps ;
Airpollution_t_rpt(t,"NOX") = ap_t("NOX",t) + eps ;
Airpollution_t_rpt(t,"SO2") = ap_t("SO2",t) + eps ;
Airpollution_t_rpt(t,"PPM2.5") = ap_t("PPM25",t) + eps ;
Airpollution_t_rpt(t,"PPM10") = ap_t("PPM10",t) + eps ;
Airpollution_t_rpt(t,"NMVOC") = ap_t("NMVOC",t) + eps ;

Airpollution_r_acc_rpt(r,"CO2") = co2_r_acc(r) + eps ;
Airpollution_r_acc_rpt(r,"NH3") = ap_r_acc("NH3",r) + eps ;
Airpollution_r_acc_rpt(r,"NOX") = ap_r_acc("NOX",r) + eps ;
Airpollution_r_acc_rpt(r,"SO2") = ap_r_acc("SO2",r) + eps ;
Airpollution_r_acc_rpt(r,"PPM2.5") = ap_r_acc("PPM25",r) + eps ;
Airpollution_r_acc_rpt(r,"PPM10") = ap_r_acc("PPM10",r) + eps ;
Airpollution_r_acc_rpt(r,"NMVOC") = ap_r_acc("NMVOC",r) + eps ;

Airpollution_i_acc_rpt(tyrpt,"CO2") = co2_i_acc(tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"NH3") = ap_i_acc("NH3",tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"NOX") = ap_i_acc("NOX",tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"SO2") = ap_i_acc("SO2",tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"PPM2.5") = ap_i_acc("PPM25",tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"PPM10") = ap_i_acc("PPM10",tyrpt) + eps ;
Airpollution_i_acc_rpt(tyrpt,"NMVOC") = ap_i_acc("NMVOC",tyrpt) + eps ;

Airpollution_acc_rpt("CO2") = co2_acc + eps ;
Airpollution_acc_rpt("NH3") = ap_acc("NH3") + eps ;
Airpollution_acc_rpt("NOX") = ap_acc("NOX") + eps ;
Airpollution_acc_rpt("SO2") = ap_acc("SO2") + eps ;
Airpollution_acc_rpt("PPM2.5") = ap_acc("PPM25") + eps ;
Airpollution_acc_rpt("PPM10") = ap_acc("PPM10") + eps ;
Airpollution_acc_rpt("NMVOC") = ap_acc("NMVOC") + eps ;

* Social cost by air pollutant
Socialcost_rt_rpt(t,r,"CO2") = scc_rt(r,t) + eps ;
Socialcost_rt_rpt(t,r,"NH3") = scap_ap_rt("NH3",r,t) + eps ;
Socialcost_rt_rpt(t,r,"NOX") = scap_ap_rt("NOX",r,t) + eps ;
Socialcost_rt_rpt(t,r,"SO2") = scap_ap_rt("SO2",r,t) + eps ;
Socialcost_rt_rpt(t,r,"PPM2.5") = scap_ap_rt("PPM25",r,t) + eps ;
Socialcost_rt_rpt(t,r,"PPM10") = scap_ap_rt("PPM10",r,t) + eps ;
Socialcost_rt_rpt(t,r,"NMVOC") = scap_ap_rt("NMVOC",r,t) ;

Socialcost_it_rpt(t,tyrpt,"CO2") = scc_it(tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"NH3") = scap_ap_it("NH3",tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"NOX") = scap_ap_it("NOX",tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"SO2") = scap_ap_it("SO2",tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"PPM2.5") = scap_ap_it("PPM25",tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"PPM10") = scap_ap_it("PPM10",tyrpt,t) + eps ;
Socialcost_it_rpt(t,tyrpt,"NMVOC") = scap_ap_it("NMVOC",tyrpt,t) + eps ;

Socialcost_t_rpt(t,"CO2") = scc_t(t) + eps ;
Socialcost_t_rpt(t,"NH3") = scap_ap_t("NH3",t) + eps ;
Socialcost_t_rpt(t,"NOX") = scap_ap_t("NOX",t) + eps ;
Socialcost_t_rpt(t,"SO2") = scap_ap_t("SO2",t) + eps ;
Socialcost_t_rpt(t,"PPM2.5") = scap_ap_t("PPM25",t) + eps ;
Socialcost_t_rpt(t,"PPM10") = scap_ap_t("PPM10",t) + eps ;
Socialcost_t_rpt(t,"NMVOC") = scap_ap_t("NMVOC",t) + eps ;

Socialcost_r_acc_rpt(r,"CO2") = scc_r_acc(r) + eps ;
Socialcost_r_acc_rpt(r,"NH3") = scap_ap_r_acc("NH3",r) + eps ;
Socialcost_r_acc_rpt(r,"NOX") = scap_ap_r_acc("NOX",r) + eps ;
Socialcost_r_acc_rpt(r,"SO2") = scap_ap_r_acc("SO2",r) + eps ;
Socialcost_r_acc_rpt(r,"PPM2.5") = scap_ap_r_acc("PPM25",r) + eps ;
Socialcost_r_acc_rpt(r,"PPM10") = scap_ap_r_acc("PPM10",r) + eps ;
Socialcost_r_acc_rpt(r,"NMVOC") = scap_ap_r_acc("NMVOC",r) + eps ;

Socialcost_i_acc_rpt(tyrpt,"CO2") = scc_i_acc(tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"NH3") = scap_ap_i_acc("NH3",tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"NOX") = scap_ap_i_acc("NOX",tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"SO2") = scap_ap_i_acc("SO2",tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"PPM2.5") = scap_ap_i_acc("PPM25",tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"PPM10") = scap_ap_i_acc("PPM10",tyrpt) + eps ;
Socialcost_i_acc_rpt(tyrpt,"NMVOC") = scap_ap_i_acc("NMVOC",tyrpt) + eps ;

Socialcost_acc_rpt("CO2") = scc_acc + eps ;
Socialcost_acc_rpt("NH3") = scap_ap_acc("NH3") + eps ;
Socialcost_acc_rpt("NOX") = scap_ap_acc("NOX") + eps ;
Socialcost_acc_rpt("SO2") = scap_ap_acc("SO2") + eps ;
Socialcost_acc_rpt("PPM2.5") = scap_ap_acc("PPM25") + eps ;
Socialcost_acc_rpt("PPM10") = scap_ap_acc("PPM10") + eps ;
Socialcost_acc_rpt("NMVOC") = scap_ap_acc("NMVOC") + eps ;

* Social cost by impact
Socialcost_impact_rt_rpt(t,r,"Health") = scap_impactap_rt("Health",r,t) + eps ;
Socialcost_impact_rt_rpt(t,r,"Crop") = scap_impactap_rt("Crop",r,t) + eps ;
Socialcost_impact_rt_rpt(t,r,"Biodiv") = scap_impactap_rt("Biodiv",r,t) + eps ;
Socialcost_impact_rt_rpt(t,r,"Materials") = scap_impactap_rt("Materials",r,t) + eps ;
Socialcost_impact_rt_rpt(t,r,"row") = scap_impactap_rt("row",r,t) + eps ;

Socialcost_impact_it_rpt(t,tyrpt,"Health") = scap_impactap_it("Health",tyrpt,t) + eps ;
Socialcost_impact_it_rpt(t,tyrpt,"Crop") = scap_impactap_it("Crop",tyrpt,t) + eps ;
Socialcost_impact_it_rpt(t,tyrpt,"Biodiv") = scap_impactap_it("Biodiv",tyrpt,t) + eps ;
Socialcost_impact_it_rpt(t,tyrpt,"Materials") = scap_impactap_it("Materials",tyrpt,t) + eps ;
Socialcost_impact_it_rpt(t,tyrpt,"row") = scap_impactap_it("row",tyrpt,t) + eps ;

Socialcost_impact_t_rpt(t,"Health") = scap_impactap_t("Health",t) + eps ;
Socialcost_impact_t_rpt(t,"Crop") = scap_impactap_t("Crop",t) + eps ;
Socialcost_impact_t_rpt(t,"Biodiv") = scap_impactap_t("Biodiv",t) + eps ;
Socialcost_impact_t_rpt(t,"Materials") = scap_impactap_t("Materials",t) + eps ;
Socialcost_impact_t_rpt(t,"row") = scap_impactap_t("row",t) + eps ;

Socialcost_impact_r_acc_rpt(r,"Health") = scap_impactap_r_acc("Health",r) + eps ;
Socialcost_impact_r_acc_rpt(r,"Crop") = scap_impactap_r_acc("Crop",r) + eps ;
Socialcost_impact_r_acc_rpt(r,"Biodiv") = scap_impactap_r_acc("Biodiv",r) + eps ;
Socialcost_impact_r_acc_rpt(r,"Materials") = scap_impactap_r_acc("Materials",r) + eps ;
Socialcost_impact_r_acc_rpt(r,"row") = scap_impactap_r_acc("row",r) + eps ;

Socialcost_impact_i_acc_rpt(tyrpt,"Health") = scap_impactap_i_acc("Health",tyrpt) + eps ;
Socialcost_impact_i_acc_rpt(tyrpt,"Crop") = scap_impactap_i_acc("Crop",tyrpt) + eps ;
Socialcost_impact_i_acc_rpt(tyrpt,"Biodiv") = scap_impactap_i_acc("Biodiv",tyrpt) + eps ;
Socialcost_impact_i_acc_rpt(tyrpt,"Materials") = scap_impactap_i_acc("Materials",tyrpt) + eps ;
Socialcost_impact_i_acc_rpt(tyrpt,"row") = scap_impactap_i_acc("row",tyrpt) + eps ;

Socialcost_impact_acc_rpt("Health") = scap_impactap_acc("Health") + eps ;
Socialcost_impact_acc_rpt("Crop") = scap_impactap_acc("Crop") + eps ;
Socialcost_impact_acc_rpt("Biodiv") = scap_impactap_acc("Biodiv") + eps ;
Socialcost_impact_acc_rpt("Materials") = scap_impactap_acc("Materials") + eps ;
Socialcost_impact_acc_rpt("row") = scap_impactap_acc("row") + eps ;

SCCtot_rt_rpt(t,r)                                               = scc_rt(r,t)           + eps ;
SCCtot_it_rpt(t,tyrpt)                                           = scc_it(tyrpt,t)       + eps ;
*  Billion (10^9) EUR by TWh (10^12) 10^9 EUR / 10^6 MWH = 10^3 EUR / MWh
SCCspe_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) > 0)        = scc_rt(r,t)           / sum(tyrpt, gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCCspe_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) > 0)        = scc_it(tyrpt,t)       / sum(r, gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCCspe_t_rpt(t)$(sum((r,tyrpt), gen_xtype(tyrpt,r,t)) > 0)       = scc_t(t)              / sum((r,tyrpt), gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCCspe_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) = 0)        = eps ;
SCCspe_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) = 0)        = eps ;
SCCspe_t_rpt(t)$(sum((r,tyrpt), gen_xtype(tyrpt,r,t)) = 0)       = eps ;

SCAPtot_rt_rpt(t,r)                                              = scap_rt(r,t)          + eps ;
SCAPtot_it_rpt(t,tyrpt)                                          = scap_it(tyrpt,t)      + eps ;
SCAPspe_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) > 0)       = scap_rt(r,t)          / sum(tyrpt, gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCAPspe_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) > 0)       = scap_it(tyrpt,t)      / sum(r, gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCAPspe_t_rpt(t)$(sum((r,tyrpt), gen_xtype(tyrpt,r,t)) > 0)      = scap_t(t)             / sum((r,tyrpt), gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
SCAPspe_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) = 0)       = eps ;
SCAPspe_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) = 0)       = eps ;
SCAPspe_t_rpt(t)$(sum((r,tyrpt), gen_xtype(tyrpt,r,t)) = 0)      = eps ;

Socialtotcost_rt_rpt(t,r)                                        = (scap_rt(r,t) + scc_rt(r,t))          + eps ;
Socialtotcost_it_rpt(t,tyrpt)                                    = (scap_it(tyrpt,t) + scc_it(tyrpt,t))  + eps ;
Socialspecost_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) > 0) = (scap_rt(r,t) + scc_rt(r,t))          / sum(tyrpt, gen_xtype(tyrpt,r,t)) * 1e+3 + eps ;
Socialspecost_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) > 0) = (scap_it(tyrpt,t) + scc_it(tyrpt,t))  / sum(r, gen_xtype(tyrpt,r,t))  * 1e+3 + eps ;
Socialspecost_t_rpt(t)$(sum((r,tyrpt),gen_xtype(tyrpt,r,t)) > 0) = (scc_t(t) + scap_t(t))                / sum((r,tyrpt), gen_xtype(tyrpt,r,t))  * 1e+3 + eps ;
Socialspecost_rt_rpt(t,r)$(sum(tyrpt, gen_xtype(tyrpt,r,t)) = 0) = eps ;
Socialspecost_it_rpt(t,tyrpt)$(sum(r, gen_xtype(tyrpt,r,t)) = 0) = eps ;
Socialspecost_t_rpt(t)$(sum((r,tyrpt),gen_xtype(tyrpt,r,t)) = 0) = eps ;

parameter
scapequalr(ap,impactap,t)
scapequalr_emit_impactap(impactap,i,v,t)
scapequalr_emit_ap(ap,i,v,t)
scapequalr_emit(i,v,t)
;

scapequalr(ap,impactap,t)                    = sum(r, daref(r,t) * scap_i(ap,impactap,r,t))                  / sum(r, daref(r,t)) ;
scapequalr_emit_impactap(impactap,i,v,t)     = sum(r, daref(r,t) * scap_emit_impactap_i(impactap,i,v,r,t))   / sum(r, daref(r,t)) ;
scapequalr_emit_ap(ap,i,v,t)                 = sum(r, daref(r,t) * scap_emit_ap_i(ap,i,v,r,t))               / sum(r, daref(r,t)) ;
scapequalr_emit(i,v,t)                       = sum(r, daref(r,t) * scap_emit_i(i,v,r,t))                     / sum(r, daref(r,t)) ;

* * * Set exogenous investment schock variables when running Ukrain Russian war scenarios
parameters
ixfx(i,r,t)
itfx(k,r,r,t)
igfx(j,r,t)
xcfx(i,v,r,t)
xfx(s,i,v,r,t)
;

ixfx(i,r,t)     = IX.L(i,r,t) ;
itfx(k,r,rr,t)  = IT.L(k,r,rr,t) ;
igfx(j,r,t)     = IG.L(j,r,t) ;
xcfx(i,v,r,t)   = XC.L(i,v,r,t) ;
xfx(s,i,v,r,t)  = X.L(s,i,v,r,t) ;

$if     set bauprice                        execute_unload 'limits\limits_%l%_bauprice.gdx', ixfx, itfx, igfx, xcfx, xfx ;
$if     set bauprice    $if not set banking execute_unload 'limits\limits_%l%_ban_bauprice.gdx', ixfx, itfx, igfx, xcfx, xfx ;
$if     set recovery                        execute_unload 'limits\limits_%l%_recovery.gdx', ixfx, itfx, igfx, xcfx, xfx ;
$if     set high                            execute_unload 'limits\limits_%l%_high.gdx',     ixfx, itfx, igfx, xcfx, xfx ;

* * * Set exogonous electriicty co2 emissions into the iterative file
parameter
co2elec_out(t) ;
;

co2elec_out(t) = Emissions_total_rpt(t,"Total CO2-emissions-elec") ;

$if      set co2iter    execute_unload   'euetsmsr\co2elec_%l%_%f%.gdx',            co2elec_out ;
$if      set co2iter    execute          'gdxxrw.exe euetsmsr\co2elec_%l%_%f%.gdx   o=euetsmsr\EUETS_MSR_CO2ITER_%f%_shortrun.xlsx   par=co2elec_out rng=co2elec_out!a1'

execute_unload'report_verysimple_%m%\%e%_rpt.gdx',               Emissions_total_rpt,
                                                                 Emissions_GER_rpt,
                                                                 Electricity_total_rpt,
                                                                 Electricity_GER_rpt,
                                                                 ElectricityGeneration_total_xtype_rpt,
                                                                 ElectricityGeneration_GER_xtype_rpt,
                                                                 InstalledCapacities_total_xtype_rpt,
                                                                 InstalledCapacities_GER_xtype_rpt,
                                                                 AddedCapacities_total_xtype_rpt,
                                                                 AddedCapacities_GER_xtype_rpt,
                                                                 Storage_GenerationCapacity_rpt, Storage_ReservoirCapacity_rpt, Storage_StoredEnergy_rpt,
                                                                 NTCTransfers_total_rpt, NTCTransfers_total_rrpt, NTCTransfers_total_rrrpt
                                                                 gasuse, gasuseeu
                                                                 ;
                                                                 
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=Emissions_total_rpt rng=Emissions!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=Emissions_GER_rpt rng=Emissions_GER!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=Electricity_total_rpt rng=Electricity!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=Electricity_GER_rpt rng=Electricity_GER!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=ElectricityGeneration_total_xtype_rpt rng=Generation!a1 par=AddedCapacities_total_xtype_rpt rng=Added!a1 par=InstalledCapacities_total_xtype_rpt rng=Installed!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=ElectricityGeneration_GER_xtype_rpt rng=Generation_GER!a1 par=AddedCapacities_GER_xtype_rpt rng=Added_GER!a1 par=InstalledCapacities_GER_xtype_rpt rng=Installed_GER!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=Storage_GenerationCapacity_rpt rng=Storage_GenCap!a1 par=Storage_ReservoirCapacity_rpt rng=Storage_ResCap!a1 par=Storage_StoredEnergy_rpt rng=Storage_StoEng!a1'
$if      set excelsimple       execute 'gdxxrw.exe report_verysimple_%m%\%e%_rpt.gdx o=excel_%m%\%e%.xlsx par=NTCTransfers_total_rpt rng=NTCTransfers!a1 par=NTCTransfers_total_rrpt rng=NTCTransfers_rrpt!a1'


execute_unload 'report_detail_%m%\%e%_detail_rpt.gdx', Emissions_rpt, Emissions_total_rpt, Emissions_ByFuel_rpt, Emissions_total_ByFuel_rpt,
                                         Electricity_rpt, Electricity_total_rpt,
                                         ElectricityGeneration_rpt, ElectricityGeneration_type_rpt, ElectricityGeneration_xtype_rpt, ElectricityGeneration_total_rpt, ElectricityGeneration_total_type_rpt, ElectricityGeneration_total_xtype_rpt,
                                         InstalledCapacities_rpt, InstalledCapacities_type_rpt, InstalledCapacities_xtype_rpt, InstalledCapacities_total_rpt, InstalledCapacities_total_type_rpt, InstalledCapacities_total_xtype_rpt,
                                         AddedCapacities_rpt, AddedCapacities_type_rpt, AddedCapacities_xtype_rpt, AddedCapacities_total_rpt, AddedCapacities_total_type_rpt, AddedCapacities_total_xtype_rpt,
                                         RetiredCapacities_rpt, RetiredCapacities_type_rpt, RetiredCapacities_xtype_rpt, RetiredCapacities_total_rpt, RetiredCapacities_total_type_rpt, RetiredCapacities_total_xtype_rpt,
                                         RetiredEarlyCapacities_rpt, RetiredEarlyCapacities_type_rpt, RetiredEarlyCapacities_xtype_rpt, RetiredEarlyCapacities_total_rpt, RetiredEarlyCapacities_total_type_rpt, RetiredEarlyCapacities_total_xtype_rpt,
                                         Curtailment_rpt, Curtailment_type_rpt, Curtailment_xtype_rpt, Curtailment_total_rpt, Curtailment_total_type_rpt, Curtailment_total_xtype_rpt,
                                         FlhGeneration_rpt, FlhGeneration_type_rpt, FlhGeneration_xtype_rpt, FlhGeneration_total_rpt, FlhGeneration_total_type_rpt, FlhGeneration_total_xtype_rpt,
                                         Cost_rpt, Cost_total_rpt, TotalSystemCost_rpt
                                         Transfers_rpt, Transfers_r_rpt, Transfers_total_rpt,
                                         Transfers_rrpt, Transfers_r_rrpt, Transfers_total_rrpt,
                                         Transfers_rrrpt, Transfers_r_rrrpt, Transfers_total_rrrpt,
                                         NTC_rpt, NTC_r_rpt, NTC_total_rpt,
                                         NTC_rrpt, NTC_r_rrpt, NTC_total_rrpt,
                                         NTC_rrrpt, NTC_r_rrrpt, NTC_total_rrrpt,
                                         Rent_rpt, Rent_r_rpt, Rent_total_rpt,
                                         FlhTransmission_rpt, FlhTransmission_r_rpt, FlhTransmission_total_rpt,
                                         Storage_rpt, Storage_total_rpt,
                                         Price_s_rpt, Price_h_rpt
                                         ;

$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=Emissions_rpt rng=Emissions!a1 par=Emissions_ByFuel_rpt rng=Emissions_by_fuel!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=TotalSystemCost_rpt rng=Total_system_costs!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=Electricity_rpt rng=Electricity!a1 par=ElectricityGeneration_xtype_rpt rng=Electricity_generation!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=InstalledCapacities_xtype_rpt rng=Installed_capacities!a1 par=AddedCapacities_xtype_rpt rng=Added_capacities!a1  par=RetiredCapacities_xtype_rpt rng=Capacities_retired!a1 par=RetiredEarlyCapacities_xtype_rpt rng=Capacities_retired_before_EOL!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=Curtailment_xtype_rpt rng=Curtailment!a1 par=FlhGeneration_xtype_rpt rng=Full-load_hours_generation!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=Transfers_rpt rng=Transfers!a1 par=NTC_rpt rng=NTC!a1 par=Transfers_rrpt rng=Transfers_rrpt!a1 par=NTC_rrpt rng=NTC_rrpt!a1 par=Rent_rpt rng=NTC_rents!a1 par=FlhTransmission_rpt rng=Full-load_hours_transmission!a1'
$if      set exceldetail execute 'gdxxrw.exe report_detail_%m%\%e%_rpt.gdx o=excel_detail_%m%\%e%.xlsx par=Storage_rpt rng=Storage!a1'



* * * Corona reporting
* Set EU ETS / MSR variables
* MM (todo): not touched yet
Parameter
CoronaCap_rpt(t,i)     Installed capacities reporting vector
CoronaGen_rpt(t,i)     Generation reporting vector
CoronaPri_rpt(t,*)     Prices reporting vector
CoronaEmi_rpt(t,*)     Emissions reporting vector
CoronaMSR_rpt(t,*)     Emissions reporting vector
Corona2050_rpt(*)      Accumulated reporting vector by year
nbc_rpt(t)
cbc_rpt(t)
co2elec_rpt(t)
co2ind_rpt(t)
;

$if not  set corona      CoronaCap_rpt(t,i)      = eps ;
$if not  set corona      CoronaGen_rpt(t,i)      = eps ;
$if not  set corona      CoronaPri_rpt(t,"all")  = eps ;
$if not  set corona      CoronaEmi_rpt(t,"all")  = eps ;
$if not  set corona      CoronaMSR_rpt(t,"all")  = eps ;
$if not  set corona      Corona2050_rpt("all")   = eps ;
$if not  set corona      nbc_rpt(t)              = eps ;
$if not  set corona      cbc_rpt(t)              = eps ;
$if not  set corona      co2elec_rpt(t)          = eps ;
$if not  set corona      co2ind_rpt(t)           = eps ;

$if set corona           nbc_rpt(t) = NBC.l(t) + eps ;
$if set corona           cbc_rpt(t) = CBC.l(t) + eps ;
$if set corona           co2elec_rpt(t) = CO2ELEC.l(t) + eps ;
$if set corona           co2ind_rpt(t) = CO2IND.l(t) + eps ;

$if set corona           CoronaEmi_rpt(t,"CO2 price (EUR/MWh)")                           = pco2euets(t) + eps ;
$if set corona           CoronaEmi_rpt("2020","CO2 price (EUR/MWh)")                      = pco2("2020") + eps ;
$if set corona           CoronaEmi_rpt(t,"CO2 supply (average per year) (Mt)")            = CO2_supply(t) - (NBC.l(t) + msr_cancel(t))/nyrs(t) + eps ;
$if set corona           CoronaEmi_rpt(t,"CO2 emissions elec (Mt)")                       = CO2ELEC.l(t) + eps ;
$if set corona           CoronaEmi_rpt(t,"CO2 emissions ind (Mt)")                        = CO2IND.l(t) + eps ;
$if set corona           CoronaEmi_rpt(t,"CO2 total")                                     = CO2ELEC.l(t) + CO2IND.l(t) + eps ;
$if set corona           CoronaEmi_rpt(t,"Cumulative bank (end) (Mt)")                    = CBC.l(t) + eps ;
$if set corona           CoronaEmi_rpt(t,"Net banking (Mt)")                              = NBC.l(t) + eps ;

$if set corona           CoronaMSR_rpt(t,"MSR into (Mt)")                                 = msr(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"MSR cancel (Mt)")                               = msr_cancel(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"MSR level (end of trading period)  (Mt)")       = msr_level(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"Excess supply (end of trading period) (Mt)")    = excess(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"TNAC (end of trading period)  (Mt)")            = tnac(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"Banked from prior period (Mt)")                 = bc(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"Cumulative bank (end) (Mt)")                    = CBC.l(t) + eps ;
$if set corona           CoronaMSR_rpt(t,"Net banking (Mt)")                              = NBC.l(t) + eps ;

$if set corona           Corona2050_rpt("CO2 emissions elec (Mt)")                = sum(t, nyrs(t) * CO2ELEC.l(t) ) + eps ;
$if set corona           Corona2050_rpt("CO2 emissions ind (Mt)")                 = sum(t, nyrs(t) * CO2IND.l(t)  ) + eps ;
$if set corona           Corona2050_rpt("CO2 emissions total (Mt)")               = sum(t, nyrs(t) * (CO2ELEC.l(t) + CO2IND.l(t)) ) + eps ;


$if set corona           CoronaPri_rpt(t,"CO2 price (EUR/MWh)")                   = pco2euets(t) + eps ;
$if set corona           CoronaPri_rpt("2020","CO2 price (EUR/MWh)")              = pco2("2020") + eps ;
$if set corona           CoronaPri_rpt(t,"Oil price (EUR/MWh)")                   = sum(r, pft(r,t,"Oil")  * (1 + price_fuel_scale(t,"Oil"))  ) / sum(r, 1) + eps ;
$if set corona           CoronaPri_rpt(t,"Natural gas price (EUR/MWh)")           = sum(r, pft(r,t,"Gas")  * (1 + price_fuel_scale(t,"Gas"))  ) / sum(r, 1) + eps ;
$if set corona           CoronaPri_rpt(t,"Coal price (EUR/MWh)")                  = sum(r, pft(r,t,"Coal") * (1 + price_fuel_scale(t,"Coal")) ) / sum(r, 1) + eps ;

$if set corona           CoronaCap_rpt(t,i) = sum(r, installed_r(r,i,t)) + eps ;
$if set corona           CoronaGen_rpt(t,i) = sum(r, gen_i(i,r,t)) + eps ;

$if set corona           execute_unload 'report\Corona_%i%_%d%_rpt.gdx',    CoronaEmi_rpt, CoronaMSR_rpt, CoronaPri_rpt, CoronaCap_rpt, CoronaGen_rpt, Corona2050_rpt ;

$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=CoronaEmi_rpt rng=Emi_%dum%!a1'
$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=CoronaMSR_rpt rng=MSR_%dum%!a1'
$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=CoronaPri_rpt rng=Pri_%dum%!a1'
$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=CoronaCap_rpt rng=Cap_%dum%!a1'
$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=CoronaGen_rpt rng=Gen_%dum%!a1'
$if set corona           execute 'gdxxrw.exe report\Corona_%run%_%dum%_rpt.gdx o=excel\Corona_init.xlsx par=Corona2050_rpt rng=2050_%dum%!a1'

$if set corona           execute_unload 'corona_%i%_%d%.gdx',    nbc_rpt, cbc_rpt, CO2elec_rpt, CO2ind_rpt ;

$if set corona           execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_%d%.xlsx par=nbc_rpt      rng=nbc!a1'
$if set corona           execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_%d%.xlsx par=cbc_rpt      rng=cbc!a1'
$if set corona           execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_%d%.xlsx par=CO2elec_rpt  rng=co2elec!a1'
$if set corona           execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_%d%.xlsx par=CO2ind_rpt   rng=co2ind!a1'

$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce1.xlsx par=co2ind_rpt   rng=co2ind_sce0!a1'
$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce2.xlsx par=co2ind_rpt   rng=co2ind_sce0!a1'
$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce3.xlsx par=co2ind_rpt   rng=co2ind_sce0!a1'

$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce1.xlsx par=co2elec_rpt   rng=co2elec!a1'
$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce2.xlsx par=co2elec_rpt   rng=co2elec!a1'
$if set corona_sce0      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce3.xlsx par=co2elec_rpt   rng=co2elec!a1'

$if set corona_sce1      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce2.xlsx par=co2elec_rpt  rng=co2elec!a1'
$if set corona_sce1      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce3.xlsx par=co2elec_rpt  rng=co2elec!a1'

$if set corona_sce2      execute 'gdxxrw.exe corona_%i%_%d%.gdx o=corona_calibration_%i%_sce3.xlsx par=co2elec_rpt  rng=co2elec!a1'


* * * Fixing variables for static/myopic runs
parameters
$if not  set myopic      dummy_myopic /0/
$if      set myopic      dd_myopic_int(r,t)
$if      set myopic      bs_myopic_int(s,r,t)
$if      set myopic      x_myopic_int(s,i,v,r,t)
$if      set myopic      xc_myopic_int(i,v,r,t)
$if      set myopic      ix_myopic_int(i,r,t)
$if      set myopic      xcs_myopic_int(s,i,v,r,t)
$if      set myopic      xtwh_myopic_int(i,v,r,t)
$if      set myopic      e_myopic_int(s,k,r,r,t)
$if      set myopic      it_myopic_int(k,r,r,t)
$if      set myopic      g_myopic_int(s,j,v,r,t)
$if      set myopic      gd_myopic_int(s,j,v,r,t)
$if      set myopic      gc_myopic_int(j,v,r,t)
$if      set myopic      ig_myopic_int(j,r,t)
$if      set myopic      gb_myopic_int(s,j,v,r,t)
$if      set myopic      sc_myopic_int(r,t)
$if      set myopic      da_myopic_int(r,t)
$if      set myopic      tc_myopic_int(k,r,r,t)
;

* Debugging numerics by neglecting negative slack values
$if      set myopic      dd_myopic_int(r,t)$(DD.L(r,t) < 0)                                      = 0 ;
$if      set myopic      bs_myopic_int(s,r,t)$(BS.L(s,r,t) < 0)                                  = 0 ;
$if      set myopic      x_myopic_int(s,i,v,r,t)$(X.L(s,i,v,r,t) < 0)                            = 0 ;
$if      set myopic      xc_myopic_int(i,v,r,t)$(XC.L(i,v,r,t) < 0)                              = 0 ;
$if      set myopic      ix_myopic_int(i,r,t)$(IX.L(i,r,t) < 0)                                  = 0 ;
$if      set myopic      xcs_myopic_int(s,i,v,r,t)$(XCS.L(s,i,v,r,t) < 0)                        = 0 ;
$if      set myopic      xtwh_myopic_int(i,v,r,t)$(XTWH.L(i,v,r,t) < 0)                          = 0 ;
$if      set myopic      e_myopic_int(s,k,r,rr,t)$(E.L(s,k,r,rr,t) < 0)    = 0 ;
$if      set myopic      it_myopic_int(k,r,rr,t)$(IT.L(k,r,rr,t) < 0)      = 0 ;
$if      set myopic      g_myopic_int(s,j,v,r,t)$(G.L(s,j,v,r,t) < 0)                            = 0 ;
$if      set myopic      gd_myopic_int(s,j,v,r,t)$(GD.L(s,j,v,r,t) < 0)                          = 0 ;
$if      set myopic      gc_myopic_int(j,v,r,t)$(GC.L(j,v,r,t) < 0)                              = 0 ;
$if      set myopic      ig_myopic_int(j,r,t)$(IG.L(j,r,t) < 0)                                  = 0 ;
$if      set myopic      gb_myopic_int(s,j,v,r,t)$(GB.L(s,j,v,r,t) < 0)                          = 0 ;
$if      set myopic      sc_myopic_int(r,t)$(SC.L(r,t) < 0)                                      = 0 ;
$if      set myopic      da_myopic_int(r,t)$(DA.L(r,t) < 0)                                      = 0 ;

* Debugging numerics by reducing complexitiy by rounding values (can be adjusted from 5 to higher values)
$if      set myopic      dd_myopic_int(r,t)$(DD.L(r,t) >= 0)                                     = round(DD.L(r,t),5);
$if      set myopic      bs_myopic_int(s,r,t)$(BS.L(s,r,t) >= 0)                                 = round(BS.L(s,r,t),5);
$if      set myopic      x_myopic_int(s,i,v,r,t)$(X.L(s,i,v,r,t) >= 0)                           = round(X.L(s,i,v,r,t),5);
$if      set myopic      xc_myopic_int(i,v,r,t)$(XC.L(i,v,r,t) >= 0)                             = round(XC.L(i,v,r,t),5);
$if      set myopic      ix_myopic_int(i,r,t)$(IX.L(i,r,t) >= 0)                                 = round(IX.L(i,r,t),5);
$if      set myopic      xcs_myopic_int(s,i,v,r,t)$(XCS.L(s,i,v,r,t) >= 0)                       = round(XCS.L(s,i,v,r,t),5);
$if      set myopic      xtwh_myopic_int(i,v,r,t)$(XTWH.L(i,v,r,t) >= 0)                         = round(XTWH.L(i,v,r,t),8);
$if      set myopic      e_myopic_int(s,k,r,rr,t)$(E.L(s,k,r,rr,t) >= 0)   = round(E.L(s,k,r,rr,t),5);
$if      set myopic      it_myopic_int(k,r,rr,t)$(IT.L(k,r,rr,t) >= 0)     = round(IT.L(k,r,rr,t),5);
$if      set myopic      g_myopic_int(s,j,v,r,t)$(G.L(s,j,v,r,t) >= 0)                           = round(G.L(s,j,v,r,t),5);
$if      set myopic      gd_myopic_int(s,j,v,r,t)$(GD.L(s,j,v,r,t) >= 0)                         = round(GD.L(s,j,v,r,t),5);
$if      set myopic      gc_myopic_int(j,v,r,t)$(GC.L(j,v,r,t) >= 0)                             = round(GC.L(j,v,r,t),5);
$if      set myopic      ig_myopic_int(j,r,t)$(IG.L(j,r,t) >= 0)                                 = round(IG.L(j,r,t),5);
$if      set myopic      gb_myopic_int(s,j,v,r,t)$(GB.L(s,j,v,r,t) >= 0)                         = round(GB.L(s,j,v,r,t),5);
$if      set myopic      sc_myopic_int(r,t)$(SC.L(r,t) >= 0)                                     = round(SC.L(r,t),5);
$if      set myopic      da_myopic_int(r,t)$(DA.L(r,t) >= 0)                                     = round(DA.L(r,t),5);

* TC can be negative (decommissioning of transmission lines)
$if      set myopic      tc_myopic_int(k,r,rr,t)                                      = round(TC.L(k,r,rr,t),5);

$if      set myopic      execute_unload 'limits_%m%\%e%_limits.gdx',     dd_myopic_int, bs_myopic_int, x_myopic_int, xc_myopic_int, ix_myopic_int, xcs_myopic_int, xtwh_myopic_int, e_myopic_int, it_myopic_int, g_myopic_int, gd_myopic_int,
$if      set myopic                                                      gc_myopic_int, ig_myopic_int, gb_myopic_int, sc_myopic_int, da_myopic_int, tc_myopic_int ;
