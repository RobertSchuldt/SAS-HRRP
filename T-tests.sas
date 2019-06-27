libname hrrp 'Z:\DATA\HRRP\Chen';

%let filepath = \DATA\HRRP\Chen;
%let set = hrrp.hrrp_19;

proc contents data = &set  noprint out = data_info
(keep = name varnum);
run;
proc sort data = &set;
by Peer_Group_Assignment;
run;


%Macro ttest(measure);

ods output Statistics = stats0;
proc ttest data = hrrp.Hrrp_19;
by Peer_Group_Assignment;
class delta;
var &measure;
title 'TTEST of &measure Between Delta and Non-Delta';
run;
ods output close;


ods output Statistics = Statistics1 Ttests=Ttests
Equality=Equality;
proc ttest data = hrrp.Hrrp_19;
by Peer_Group_Assignment;
class delta;
var &measure;
run;
ods output close;


proc append base = Statistics1 data = stats0 force; run;

%mend ttest;

%ttest(penalty)
%ttest(fp)
%ttest(gov)
%ttest(maj_teach)
%ttest(min_teach)
%ttest(pcp)
%ttest(st_hospbeds)
%ttest(lt_hospbeds)
%ttest(snf_certibeds)
%ttest(nh_certibeds)
%ttest(p_black)
%ttest(P_poverty)

proc sql;
create table statistics as select *,
1 as testorder, 
monotonic() as order, 
case when probf < .05 then "Satterthwaite" else "Pooled" end as method length = 15
from Statistics1, 
(select probf from EQUALITY);
quit;

proc sql;
create table statsandtests as select a.*, tvalue, df, probt from statistics a
	left join (select * from TTests) b
	on a.variable = b.variable and a.method = b.method;
quit;
