--For all omsTrapNotificationClear, change the IP for the Name or the SPO where available in latest /etc/hosts
grep AC_ER hosts | awk '{print $1","$2}' > spos_ips.txt 
for line in $(cat spos_ips.txt);do 
   name=$(echo $line | cut -d',' -f2);
   ip=$(echo $line | cut -d',' -f1);
   echo "UPDATE plugin_camm_snmptt_201410 SET formatline=concat('"$name"',' ',formatline) WHERE eventname='omsTrapAlarmNotificationClear' AND formatline LIKE '"$ip"%'" |mysql -v -uroot -pascb8308 events
done
UPDATE plugin_camm_snmptt_201410 SET formatline=concat('AC_ER_SP10_NR_CUA_1',' ',formatline) WHERE eventname='omsTrapAlarmNotificationClear' AND formatline LIKE '172.16.53.163%'
--Add a column st_town to group equipments in the same site
alter table events.plugin_camm_snmptt_201410 add column st_town char(6);
update events.plugin_camm_snmptt_201410 set st_town=substring(hostname, 12, 6);
update events.plugin_camm_snmptt_201410 set st_town=substring(formatline, 12, 6) where hostname='192.168.168.1';
update events.plugin_camm_snmptt_201410 set st_town='' where length(st_town)!=6;
create index ix_st_town on events.plugin_camm_snmptt_201410(st_town);
--Get rid of the following alarms
delete from plugin_camm_snmptt_201410 where eventname IN ('swVersionsCompatibleClear','timeClockSet','tnPmBinsRolledOverNotif');
delete from plugin_camm_snmptt_201410 where eventname IN ('mv36AlarmNotification');
--On all the alarms incorrectly taken as hostname 192.168.168.1 (SPO) change that hostname for the proper SPO name
UPDATE events.plugin_camm_snmptt_201410 SET hostname = LEFT(formatline,20) WHERE  eventname in  ('omsTrapAlarmNotificationClear') AND LEFT(formatline,3)!='172';

--Create 3 relevant bindings
alter table events.plugin_camm_snmptt_201410 add vBind1 varchar(150), add vBind2 varchar(150), add vBind3 varchar(150);
--Adjust the criticity of the alarms and separe relevant alarms
UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2), vBind2=substring(substring(formatline,locate(' ', formatline)+1),locate(' ',substring(formatline,locate(' ', formatline)+1))+2) where eventname='alarmController1proginputTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmController1proginputTrap' AND vBind1=1
UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2), vBind2=substring(substring(formatline,locate(' ', formatline)+1),locate(' ',substring(formatline,locate(' ', formatline)+1))+2) where eventname='alarmIoUnit1proginputTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmIoUnit1proginputTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmACmainsTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmACmainsTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmMinorBatteryHighTempTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmMinorBatteryHighTempTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmMinorRectifierTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmMinorRectifierTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmBatteryBoostmodeEnteredTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmBatteryBoostmodeEnteredTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmBatteryBreakerOpenTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmBatteryBreakerOpenTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmBatteryDisconnectOpenTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmBatteryDisconnectOpenTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname IN ('alarmBatteryTestmodeEnteredTrap','alarmDistributionBreakerOpenTrap','alarmIoUnitDeltaFanSpeed1Trap','alarmLVD1openTrap','alarmMajorBatteryHighTempTrap''alarmMajorBatterySymmetryTrap','alarmMajorHighBattVoltTrap','alarmMajorLowBattVoltTrap','alarmMajorRectifierTrap','alarmMinorBatteryHighTempTrap','alarmMinorBatterySymmetryTrap','alarmMinorHighBattVoltTrap','alarmMinorLowBattVoltTrap','alarmMinorRectifierTrap');
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname IN ('alarmBatteryTestmodeEnteredTrap','alarmDistributionBreakerOpenTrap','alarmIoUnitDeltaFanSpeed1Trap','alarmLVD1openTrap','alarmMajorBatteryHighTempTrap''alarmMajorBatterySymmetryTrap','alarmMajorHighBattVoltTrap','alarmMajorLowBattVoltTrap','alarmMajorRectifierTrap','alarmMinorBatteryHighTempTrap','alarmMinorBatterySymmetryTrap','alarmMinorHighBattVoltTrap','alarmMinorLowBattVoltTrap','alarmMinorRectifierTrap') AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmMajorBatteryHighTempTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmMajorBatteryHighTempTrap' AND vBind1=1;

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=substring(formatline,1,2) WHERE eventname='alarmMajorBatterySymmetryTrap';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='alarmMajorBatterySymmetryTrap' AND vBind1=1;


UPDATE events.plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('Value: ', formatline)+7),1,locate(' ',substring(formatline,locate('Value: ', formatline)+7))) ,vbind2=substring(formatline,locate('Name: ', formatline)+6) where hostname LIKE 'RC_DT%' and eventname='systemUrgentAlarm'
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='systemUrgentAlarm' AND vBind1!=1;

UPDATE events.plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('Value: ', formatline)+7),1,locate(' ',substring(formatline,locate('Value: ', formatline)+7))) ,vbind2=substring(formatline,locate('Name: ', formatline)+6) where hostname LIKE 'RC_DT%' and eventname='systemNonUrgentAlarm';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='systemNonUrgentAlarm' AND vBind1!=1;

UPDATE events.plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('Value: ', formatline)+7),1,locate(' ',substring(formatline,locate('Value: ', formatline)+7))) ,vbind2=substring(formatline,locate('Name: ', formatline)+6) where hostname LIKE 'RC_DT%' and eventname='systemCriticalAlarm';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='systemNonUrgentAlarm' AND vBind1!=1;
UPDATE events.plugin_camm_snmptt_201410 SET severity='Normal' WHERE eventname='systemNonUrgentAlarm' AND vBind1=1;

--omsTrapAlarmNotificationClear
UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate(' 7:',formatline)+3),1,locate(' 8:',substring(formatline,locate(' 7:',formatline)+3))),
 vbind2=substring(substring(formatline,locate(' 5:',formatline)+3),1,locate(' 6:',substring(formatline,locate(' 5:',formatline)+3))),
 vbind3=substring(substring(formatline,locate(' 9:',formatline)+3),1,locate(' 10:',substring(formatline,locate(' 9:',formatline)+3)))  WHERE eventname='omsTrapAlarmNotificationClear'

UPDATE events.plugin_camm_snmptt_201410 SET vBind1=triM(vBind1) WHERE eventname='omsTrapAlarmNotificationClear';
UPDATE events.plugin_camm_snmptt_201410 SET vBind3=triM(vBind3) WHERE eventname='omsTrapAlarmNotificationClear';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Normal' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='1';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Critical' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='2';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Major' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='3';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Minor' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='4';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Warning' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='5';
UPDATE events.plugin_camm_snmptt_201410 SET severity='Normal' WHERE eventname='omsTrapAlarmNotificationClear' AND vBind1='6';


--omsTrapEventNotification
select substring(substring(formatline,locate(' 2: ',formatline)+4),1,locate(' 3:',substring(formatline,locate(' 2: ',formatline)+4))) as nId,
substring(substring(formatline,locate(' 4: ',formatline)+4),1,locate(' 5:',substring(formatline,locate(' 4: ',formatline)+4))) as addText,
substring(substring(formatline,locate(' 5:',formatline)+3),1,locate(' 6: ',substring(formatline,locate(' 5:',formatline)+3))) AS objectId,
substring(substring(formatline,locate(' 7:',formatline)+3),1,locate(' 8:',substring(formatline,locate(' 7:',formatline)+3))) AS evType,
substring(substring(formatline,locate(' 8:',formatline)+3),1,locate(' 9:',substring(formatline,locate(' 8:',formatline)+3))) AS evCause,
substring(substring(formatline,locate(' 9:',formatline)+3),1,locate(' 10:',substring(formatline,locate(' 9:',formatline)+3))) AS card,
substring(formatline,locate(' 10: ',formatline)+5) AS spo,
formatline from events.plugin_camm_snmptt_201410 where eventname='omsTrapEventNotification'

UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate(' 7:',formatline)+3),1,locate(' 8:',substring(formatline,locate(' 7:',formatline)+3))), vbind2=substring(substring(formatline,locate(' 4: ',formatline)+4),1,locate(' 5:',substring(formatline,locate(' 4: ',formatline)+4))), vbind3=substring(substring(formatline,locate(' 9:',formatline)+3),1,locate(' 10:',substring(formatline,locate(' 9:',formatline)+3))) where eventname='omsTrapEventNotification'

--LinkDown on SmartEdges
select substring(substring(formatline,locate('in ',formatline)+3),1,locate(' ',substring(formatline,locate('in ',formatline)+3))) ifId,
substring(substring(substring(formatline,locate('in ',formatline)+3),locate(' ',substring(formatline,locate('in ',formatline)+3))+1),1,locate(' ',substring(substring(formatline,locate('in ',formatline)+3),locate(' ',substring(formatline,locate('in ',formatline)+3))+1))) adminStatus,
reverse(substring(reverse(substring(formatline,locate('in ',formatline)+3)),1,locate(' ',reverse(substring(formatline,locate('in ',formatline)+3))))) oper,formatline from events.plugin_camm_snmptt_201410 where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%acting %'

select substring(substring(formatline,locate('interface ',formatline)+10),1,locate('.',substring(formatline,locate('interface ',formatline)+10))-1) ifId,
substring(substring(formatline,locate('Admin state: ',formatline)+13),1,locate('.',substring(formatline,locate('Admin state: ',formatline)+13))-1) as admin,
substring(formatline,locate('Operational state: ',formatline)+19) as oper,formatline from events.plugin_camm_snmptt_201410 where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%on %'

select substring(substring(formatline,locate(', ',formatline)+2),1,locate(' ',substring(formatline,locate(', ',formatline)+2))) ifId,
substring(substring(substring(formatline,locate(', ',formatline)+2),locate(' ',substring(formatline,locate(', ',formatline)+2))+1),1,locate(' ',substring(substring(formatline,locate(', ',formatline)+2),locate(' ',substring(formatline,locate(', ',formatline)+2))+1))) admin,
reverse(substring(reverse(formatline),1,locate(' ',reverse(formatline)))) oper
 from events.plugin_camm_snmptt_201410 where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%entity%' and formatline not like '%acting%'

UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('in ',formatline)+3),1,locate(' ',substring(formatline,locate('in ',formatline)+3))),
vbind2=substring(substring(substring(formatline,locate('in ',formatline)+3),locate(' ',substring(formatline,locate('in ',formatline)+3))+1),1,locate(' ',substring(substring(formatline,locate('in ',formatline)+3),locate(' ',substring(formatline,locate('in ',formatline)+3))+1))),
vbind3=reverse(substring(reverse(substring(formatline,locate('in ',formatline)+3)),1,locate(' ',reverse(substring(formatline,locate('in ',formatline)+3))))) where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') and formatline like '%acting %'

UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('interface ',formatline)+10),1,locate('.',substring(formatline,locate('interface ',formatline)+10))-1),
vbind2=substring(substring(formatline,locate('Admin state: ',formatline)+13),1,locate('.',substring(formatline,locate('Admin state: ',formatline)+13))-1),
vbind3=substring(formatline,locate('Operational state: ',formatline)+19) where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%on %'

UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate(', ',formatline)+2),1,locate(' ',substring(formatline,locate(', ',formatline)+2))),
vbind2=substring(substring(substring(formatline,locate(', ',formatline)+2),locate(' ',substring(formatline,locate(', ',formatline)+2))+1),1,locate(' ',substring(substring(formatline,locate(', ',formatline)+2),locate(' ',substring(formatline,locate(', ',formatline)+2))+1))),
vbind3=reverse(substring(reverse(formatline),1,locate(' ',reverse(formatline)))) where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%entity%' and formatline not like '%acting%'

UPDATE plugin_camm_snmptt_201410 SET vbind1=substring(substring(formatline,locate('an ',formatline)+3),1,locate(' ',substring(formatline,locate('an ',formatline)+3))),
vbind2=substring(substring(substring(formatline,locate('an ',formatline)+3),locate(' ',substring(formatline,locate('an ',formatline)+3))+1),1,locate(' ',substring(substring(formatline,locate('an ',formatline)+3),locate(' ',substring(formatline,locate('an ',formatline)+3))+1))),vbind3=
reverse(substring(reverse(substring(formatline,locate('an ',formatline)+3)),1,locate(' ',reverse(substring(formatline,locate('an ',formatline)+3))))) where hostname LIKE '%_ER_SE%' and eventname IN ('linkdown','linkup') 
and formatline like '%acting in an%'
--sdpBind
update events.plugin_camm_snmptt_201410 set vbind1=substring(formatline,locate('notification',formatline)+14) WHERE eventname='sdpBindSdpStateChangeProcessed'
update events.plugin_camm_snmptt_201410 set vbind1=substring(substring(formatline,locate('generated',formatline)+10),1,locate(' ',substring(formatline,locate('generated',formatline)+10))) WHERE eventname='sdpStatusChanged'

--tnChangeNotif 1830
select substring(substring(formatline, locate('object: ',formatline)+8),1,locate(' ',substring(formatline, locate('object: ',formatline)+8))) object,
substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1))) name,
reverse(substring(reverse(trim(substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1))))),1,locate(' ',reverse(trim(substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1)))))))) id,
substring(formatline,locate('type: ',formatline)+6) as object_type,
substring(substring(formatline,locate('desc: ',formatline)+6),1,locate(' data:',substring(formatline,locate('desc: ',formatline)+6))) as descr,
substring(substring(formatline,locate('data: ',formatline)+6),1,locate(' changed:',substring(formatline,locate('data: ',formatline)+6))) data,
substring(substring(formatline,locate('changed: ',formatline)+9),1,locate(' type:',substring(formatline,locate('changed: ',formatline)+9))) changed,
formatline from events.plugin_camm_snmptt_201410 where eventname='tnChangeNotif'

UPDATE plugin_camm_snmptt_201410 SET vBind1=substring(substring(formatline, locate('object: ',formatline)+8),1,locate(' ',substring(formatline, locate('object: ',formatline)+8))),
vBind2=substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1))),
vBind3=reverse(substring(reverse(trim(substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1))))),1,locate(' ',reverse(trim(substring(substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))),1,locate('cat:',substring(formatline, locate(substring_index(formatline,' ',2),formatline)+length(substring_index(formatline,' ',2))+1)))))))),
vbind4=substring(formatline,locate('type: ',formatline)+6),
vBind5=substring(substring(formatline,locate('desc: ',formatline)+6),1,locate(' data:',substring(formatline,locate('desc: ',formatline)+6))),
vBind6=substring(substring(formatline,locate('data: ',formatline)+6),1,locate(' changed:',substring(formatline,locate('data: ',formatline)+6))),
vBind7=substring(substring(formatline,locate('changed: ',formatline)+9),1,locate(' type:',substring(formatline,locate('changed: ',formatline)+9))) WHERE eventname='tnChangeNotif'

optimize table plugin_camm_snmptt_201410;
