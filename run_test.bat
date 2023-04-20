REM Standard/specific features
set standardone=--trans=yes --storage=yes --lostload=yes --rsa=yes --biolim=yes --biolimhalf=yes --bioliminterpol=yes --bioneutral=yes --biosub=yes --sclim10=yes --sclim=yes --corr_full=yes --storspec=yes --storage_absweights=yes --ccs=yes --windoff40=yes --windoffcap=yes
set standardtwo=--scc3=yes --emfapmid=yes --scap3=yes --mixed=yes --opt1=yes --chp=yes --newhydrotimeseries=yes --longrun=yes --spatialhighest=yes --excelsimple=yes --co2mark=yes --bauprice=yes --frnucnormal=yes --hydronormal=yes --simpmip=yes --learningcal=yes
REM --banking=yes
REM set standardthree=--noccsfrictions=yes --nobiofrictions=yes --noinvfrictions=yes --notinvfrictions=yes --noginvfrictions=yes --noinvbiofrictions=yes --noinvccsfrictions=yes --noinvnucfrictions=yes


REM Database name
set reg=28R
set cho=v1111_4d_1d
set hor=longrun
set horr=longrun_simpmip
set nam=%reg%_%cho%_%horr%

REM Price scenario name
set sce=bauprice

REM Modus name
set mod=dynamic

REM EU ETS name (scenario name added later)
set spe=co2mark
set ind=indfix
set pmi=%ind%_%hor%
set pol=%spe%_%ind%_%hor%

REM Limits name when bauprice for recovery and bauprice (scenario name added later)
set lim=%spe%_%ind%_%horr%

REM Fixbudget variations
set sce=bauprice
set add=benchmark
set specific=--writelimits=yes --fixbudget=yes --budget_it=yes --flhbenchmark=yes
set exl=%nam%_%spe%_%ind%_%sce%_%add%

gams euregen2020_v27   o=list_%mod%\%exl%.lst gdx=output_%mod%\%exl%.gdx s=restart_%mod%\%exl% %standardone% %standardtwo% %standardthree% %specific% --n=%nam% --m=%mod% --e=%exl% --l=%lim% --p=%pol% --pm=%pmi% --s=%sce% --a=%add%
gams euregen_rpt_v21   r=restart_%mod%\%exl% o=list_%mod%\%exl%_rpt.lst                        %standardone% %standardtwo% %standardthree% %specific% --n=%nam% --m=%mod% --e=%exl% --l=%lim% --p=%pol% --pm=%pmi% --s=%sce% --a=%add%
