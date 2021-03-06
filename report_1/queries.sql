--SUMMARIZING COUNTS
SELECT 'Total Alarms',COUNT(*)
FROM plugin_camm_snmptt_201410
UNION ALL
SELECT 'Alarm Types', COUNT(DISTINCT eventName)
FROM plugin_camm_snmptt_201410
UNION ALL
SELECT 'Host Names', COUNT(DISTINCT hostName)
FROM plugin_camm_snmptt_201410
UNION ALL
SELECT 'Host-Alarm', COUNT(DISTINCT hostName, eventName)
FROM plugin_camm_snmptt_201410

--Nummber of minutes in the dataset
select count(*)AS numMins from (SELECT month(traptime),day(traptime),hour(traptime),minute(traptime) FROM events.plugin_camm_snmptt_201410 group by 1,2,3,4) T1;
+---------+
| numMins |
+---------+
|   44592 |
+---------+

--FIRST SCENARIO: ALU AC Rectifier Alarm. Whenever there is an AC energy outage, the rectifier will send an AC Outage Alarm. If the site has equipments without DC PoE (Power over ethernet) then the SW ports will see a Link Down on the ports connected to them.

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |    12160 | 0.0000 |
| 1            |     8191 | 0.1837 |
| 2            |     1329 | 0.0298 |
| 3            |      230 | 0.0052 |
| 4            |       58 | 0.0013 |
| 5            |       32 | 0.0007 |
| 6            |       18 | 0.0004 |
| 7            |       12 | 0.0003 |
| 8            |        2 | 0.0000 |
| 10           |        1 | 0.0000 |
| 11           |        1 | 0.0000 |
| NULL         |     9874 | 0.2214 |
+--------------+----------+--------+
P(aT)               9874   0.2214


SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'linkDown' AND substring(hostname, 1, 10) = 'AC_AL_SA30'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'linkDown' AND substring(hostname, 1, 10) = 'AC_AL_SA30' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |   146970 | 0.0000 |
| 6            |    12650 | 0.2837 |
| 12           |     3201 | 0.0718 |
| 18           |      905 | 0.0203 |
| 24           |      333 | 0.0075 |
| 30           |      137 | 0.0031 |
| 36           |       50 | 0.0011 |
| 42           |       27 | 0.0006 |
| 48           |       12 | 0.0003 |
| 54           |        5 | 0.0001 |
| 60           |        2 | 0.0000 |
| 66           |        1 | 0.0000 |
| 72           |        2 | 0.0000 |
| 78           |        2 | 0.0000 |
| NULL         |    17327 | 0.3886 |
+--------------+----------+--------+
P(a1)                       0.3886

SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM 
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,
    T1.formatline,
    T2.formatline fl2
FROM
    (SELECT
        id, 
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        hostname LIKE 'RC%'
            AND eventname = 'alarmACmainsTrap'
            AND formatline LIKE '1%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime, INTERVAL 60 SECOND) AND T2.eventname = 'linkDown'
        AND substring(T2.hostname, 1, 10) = 'AC_AL_SA30'
        AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at) = 0.11

CR_ROB
MT_FTO
--SECOND SCENARIO: ALU AC Rectifier Alarm. Whenever there is an AC energy recovery, the rectifier will send an AC Recovery Alarm. If the site has equipments without DC PoE (Power over ethernet) then the SW ports will see a Link Up on the ports connected to them.
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '0%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '0%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |    10598 | 0.0000 |
| 1            |     7488 | 0.1679 |
| 2            |     1137 | 0.0255 |
| 3            |      182 | 0.0041 |
| 4            |       51 | 0.0011 |
| 5            |       11 | 0.0002 |
| 6            |        4 | 0.0001 |
| 7            |        1 | 0.0000 |
| NULL         |     8874 | 0.1990 |
+--------------+----------+--------+

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'linkUp' AND substring(hostname, 1, 10) = 'AC_AL_SA30'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'linkUp' AND substring(hostname, 1, 10) = 'AC_AL_SA30' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |    43764 | 0.0000 |
| 6            |     4212 | 0.0945 |
| 12           |      938 | 0.0210 |
| 18           |      190 | 0.0043 |
| 24           |       85 | 0.0019 |
| 30           |       18 | 0.0004 |
| 36           |       20 | 0.0004 |
| 42           |        7 | 0.0002 |
| 48           |        1 | 0.0000 |
| 54           |        2 | 0.0000 |
| 66           |        1 | 0.0000 |
| NULL         |     5474 | 0.1228 |
+--------------+----------+--------+

SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM 
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,
    T1.formatline,
    T2.formatline fl2
FROM
    (SELECT
        id, 
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        hostname LIKE 'RC%'
            AND eventname = 'alarmACmainsTrap'
            AND formatline LIKE '0%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime, INTERVAL 60 SECOND) AND T2.eventname = 'linkUp'
        AND substring(T2.hostname, 1, 10) = 'AC_AL_SA30'
        AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at) = 0.117

--THIRD SCENARIO: ERICSSON AC Rectifier Alarm. Whenever there is an AC energy outage, the rectifier will send an AC Outage Alarm. If the site has equipments without DC PoE (Power over ethernet) then the SW ports will see a Link Down on the ports connected to them.
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline NOT LIKE '%Value: 1%' 
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |     2801 | 0.0000 |
| 1            |     1361 | 0.0305 |
| 2            |      327 | 0.0073 |
| 3            |       92 | 0.0021 |
| 4            |       53 | 0.0012 |
| 5            |       14 | 0.0003 |
| 6            |        9 | 0.0002 |
| 7            |        5 | 0.0001 |
| 8            |        9 | 0.0002 |
| 9            |        3 | 0.0001 |
| 10           |        4 | 0.0001 |
| NULL         |     1877 | 0.0421 |
+--------------+----------+--------+
SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%'  AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline NOT LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%' AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline NOT LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |    88204 | 0.0000 |
| 1            |    10817 | 0.2426 |
| 2            |     6890 | 0.1545 |
| 3            |     4061 | 0.0911 |
| 4            |     2460 | 0.0552 |
| 5            |     1659 | 0.0372 |
| 6            |     1230 | 0.0276 |
| 7            |      845 | 0.0189 |
| 8            |      659 | 0.0148 |
| 9            |      419 | 0.0094 |
| 10           |      260 | 0.0058 |
| 11           |      159 | 0.0036 |
| 12           |      113 | 0.0025 |
| 13           |       84 | 0.0019 |
| 14           |       56 | 0.0013 |
| 15           |       46 | 0.0010 |
| 16           |       34 | 0.0008 |
| 17           |       15 | 0.0003 |
| 18           |       17 | 0.0004 |
| 19           |       16 | 0.0004 |
| 20           |       12 | 0.0003 |
| 21           |       15 | 0.0003 |
| 22           |        7 | 0.0002 |
| 23           |        5 | 0.0001 |
| 24           |        4 | 0.0001 |
| 25           |        2 | 0.0000 |
| 26           |        2 | 0.0000 |
| 27           |        3 | 0.0001 |
| 28           |        1 | 0.0000 |
| 29           |        2 | 0.0000 |
| 41           |        2 | 0.0000 |
| NULL         |    29895 | 0.6704 |
+--------------+----------+--------+

SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM 
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,    
    T2.formatline fl2,
    T1.formatline
FROM
    (SELECT 
        id,
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline NOT LIKE '%Value: 1%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime,
        INTERVAL 60 SECOND) AND T2.eventname = 'omsTrapAlarmNotificationClear' AND T2.formatline LIKE '%Link Down%' AND T2.formatline NOT LIKE '% 7:6%' AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at)	0.4075652637

--FOURTH SCENARIO: Ericsson AC Rectifier Alarm. Whenever there is an AC energy recovery, the rectifier will send an AC Recovery Alarm. If the site has equipments without DC PoE (Power over ethernet) then the SW ports will see a Link Up on the ports connected to them.
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline LIKE '%Value: 1%' 
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |     2785 | 0.0000 |
| 1            |     1499 | 0.0336 |
| 2            |      309 | 0.0069 |
| 3            |       77 | 0.0017 |
| 4            |       50 | 0.0011 |
| 5            |       22 | 0.0005 |
| 6            |        8 | 0.0002 |
| 7            |        4 | 0.0001 |
| 8            |        4 | 0.0001 |
| 9            |        1 | 0.0000 |
| 10           |        1 | 0.0000 |
| NULL         |     1975 | 0.0443 |
+--------------+----------+--------+
SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%'  AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%' AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |    90214 | 0.0000 |
| 1            |    10662 | 0.2391 |
| 2            |     6706 | 0.1504 |
| 3            |     3935 | 0.0882 |
| 4            |     2374 | 0.0532 |
| 5            |     1659 | 0.0372 |
| 6            |     1205 | 0.0270 |
| 7            |      893 | 0.0200 |
| 8            |      690 | 0.0155 |
| 9            |      484 | 0.0109 |
| 10           |      306 | 0.0069 |
| 11           |      195 | 0.0044 |
| 12           |      117 | 0.0026 |
| 13           |       96 | 0.0022 |
| 14           |       73 | 0.0016 |
| 15           |       57 | 0.0013 |
| 16           |       46 | 0.0010 |
| 17           |       29 | 0.0007 |
| 18           |       25 | 0.0006 |
| 19           |       20 | 0.0004 |
| 20           |       17 | 0.0004 |
| 21           |       11 | 0.0002 |
| 22           |       10 | 0.0002 |
| 23           |        7 | 0.0002 |
| 24           |        5 | 0.0001 |
| 25           |        1 | 0.0000 |
| 26           |        3 | 0.0001 |
| 27           |        3 | 0.0001 |
| 29           |        1 | 0.0000 |
| 36           |        2 | 0.0000 |
| 37           |        1 | 0.0000 |
| NULL         |    29633 | 0.6645 |
+--------------+----------+--------+

SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM 
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,    
    T2.formatline fl2,
    T1.formatline
FROM
    (SELECT 
        id,
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline LIKE '%Value: 1%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime,
        INTERVAL 60 SECOND) AND T2.eventname = 'omsTrapAlarmNotificationClear' AND T2.formatline LIKE '%Link Down%' AND T2.formatline LIKE '% 7:6%' AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at)	0.3665822785

--FIFTH SCENARIO: When there is a LAG DOWN A SPO, it might be a fiber cut and others will present the same behavior. Specially, the aggregator node would see the alarm
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE formatline LIKE '%LAG%' AND formatline like '%Link down%' AND substring(formatline, 1, 10)='AC_ER_SP10' AND formatline NOT LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE formatline LIKE '%LAG%' AND formatline like '%Link down%' AND substring(formatline, 1, 10)='AC_ER_SP10' AND formatline NOT LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |      480 | 0.0000 |
| 1            |      400 | 0.0090 |
| 2            |       34 | 0.0008 |
| 3            |        4 | 0.0001 |
| NULL         |      438 | 0.0098 |
+--------------+----------+--------+

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%'  AND substring(formatline, 1, 10) ='AG_ER_SP60' AND formatline NOT LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%' AND substring(formatline, 1, 10) ='AG_ER_SP60' AND formatline NOT LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |     4896 | 0.0000 |
| 1            |     1047 | 0.0235 |
| 2            |      431 | 0.0097 |
| 3            |      350 | 0.0078 |
| 4            |      273 | 0.0061 |
| 5            |      108 | 0.0024 |
| 6            |       35 | 0.0008 |
| 7            |        6 | 0.0001 |
| 8            |        3 | 0.0001 |
| 9            |        1 | 0.0000 |
| 10           |        2 | 0.0000 |
| NULL         |     2256 | 0.0506 |
+--------------+----------+--------+
SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM 
    (
SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,    
    T2.formatline fl2,
    T1.formatline
FROM
    (SELECT 
        id,
        eventname,
substring(formatline, 1, 17) as hostname,
            st_town,
            substring(formatline, 12, 2) as st_state,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE formatline LIKE '%LAG%' AND formatline like '%Link down%' AND substring(formatline, 1, 10)='AC_ER_SP10' AND formatline NOT LIKE '% 7:6%') AS T1
LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime,
        INTERVAL 60 SECOND) AND T2.eventname = 'omsTrapAlarmNotificationClear' AND T2.formatline LIKE '%Link Down%' AND T2.formatline LIKE 'AG_ER_SP60%' AND T2.formatline NOT LIKE '% 7:6%' AND substring(T2.formatline, 12, 2)=st_state)
) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1
+----------+----------------+----------+
| alarmsAC | alarmsLinkDown | COUNT(*) |
+----------+----------------+----------+
|        1 |              0 |      376 |
|        2 |              0 |       31 |
|        3 |              0 |        4 |
|        1 |              1 |        8 |
|        2 |              1 |        1 |
|        1 |              2 |        3 |
|        2 |              2 |        1 |
|        1 |              3 |        6 |
|        2 |              3 |        1 |
|        1 |              4 |        2 |
|        1 |              7 |        4 |
|        1 |              9 |        1 |
+----------+----------------+----------+


--SIXTH SCENARIO: Breaker Fuse Alarms. When the breaker opens (jump) in a node, all the radios supported by the breaker will shutdown and there will be link down alarms
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE eventname='systemUrgentAlarm' and hostname LIKE 'RC%' and formatline LIKE '%Fusible%' AND formatline NOT LIKE '%Value: 1%' 
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname='systemUrgentAlarm' and hostname LIKE 'RC%' and formatline LIKE '%Fusible%' AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |     1346 | 0.0000 |
| 1            |     1100 | 0.0247 |
| 2            |       99 | 0.0022 |
| 3            |       16 | 0.0004 |
| NULL         |     1215 | 0.0272 |
+--------------+----------+--------+

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%'  AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline NOT LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%' AND substring(formatline, 1, 10) IN ('AC_ER_SP10','AG_ER_SP60') AND formatline NOT LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%'  AND substring(formatline, 1, 10) ='AG_ER_SP60' AND formatline NOT LIKE '% 7:6%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname = 'omsTrapAlarmNotificationClear' AND formatline LIKE '%Link Down%' AND substring(formatline, 1, 10) ='AG_ER_SP60' AND formatline NOT LIKE '% 7:6%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | P      |
+--------------+----------+--------+
| Total Alarms |    88204 | 0.0000 |
| 1            |    10817 | 0.2426 |
| 2            |     6890 | 0.1545 |
| 3            |     4061 | 0.0911 |
| 4            |     2460 | 0.0552 |
| 5            |     1659 | 0.0372 |
| 6            |     1230 | 0.0276 |
| 7            |      845 | 0.0189 |
| 8            |      659 | 0.0148 |
| 9            |      419 | 0.0094 |
| 10           |      260 | 0.0058 |
| 11           |      159 | 0.0036 |
| 12           |      113 | 0.0025 |
| 13           |       84 | 0.0019 |
| 14           |       56 | 0.0013 |
| 15           |       46 | 0.0010 |
| 16           |       34 | 0.0008 |
| 17           |       15 | 0.0003 |
| 18           |       17 | 0.0004 |
| 19           |       16 | 0.0004 |
| 20           |       12 | 0.0003 |
| 21           |       15 | 0.0003 |
| 22           |        7 | 0.0002 |
| 23           |        5 | 0.0001 |
| 24           |        4 | 0.0001 |
| 25           |        2 | 0.0000 |
| 26           |        2 | 0.0000 |
| 27           |        3 | 0.0001 |
| 28           |        1 | 0.0000 |
| 29           |        2 | 0.0000 |
| 41           |        2 | 0.0000 |
| NULL         |    29895 | 0.6704 |
+--------------+----------+--------+


SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM 
    (
SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,    
    T2.formatline fl2,
    T1.formatline
FROM
(SELECT 
      id,
      eventname,
            hostname,
            substring(hostname, 12, 6) as st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE eventname='systemUrgentAlarm' and hostname LIKE 'RC%' and hostname LIKE 'RC%' and formatline LIKE '%Fusible%' AND formatline NOT LIKE '%Value: 1%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime,
        INTERVAL 60 SECOND)  AND T2.eventname = 'omsTrapAlarmNotificationClear' AND T2.formatline LIKE '%Link Down%' AND T2.formatline NOT LIKE '% 7:6%' AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at)	0.0271604938

--OPTIMIZING DB
mysql> SELECT eventname,count(*) FROM plugin_camm_snmptt_201410 GROUP BY 1 order by 2 desc LIMIT 10;
+-------------------------------+----------+
| eventname                     | count(*) |
+-------------------------------+----------+
| swVersionsCompatibleClear     |  1207393 |
| omsTrapAlarmNotificationClear |   719770 |
| linkDown                      |   410304 |
| linkUp                        |   371871 |
| mv36AlarmNotification         |   156809 |
| changeOccured                 |    89712 |
| timeClockSet                  |    86312 |
| systemNonUrgentAlarm          |    80888 |
| mv36NeNotification            |    58691 |
| tnPmBinsRolledOverNotif       |    51187 |
+-------------------------------+----------+

-- host=192.168.168.1 '172.16.53.163 ClearTrap 1: 1412947424 2: 141 3: 4917 4:  5:LANXPort:slot=3;port=2 6:  7:6 8:141 9: Link down 10: 87'


--Repeat the same for AG_ER_SP
grep AC_ER hosts | awk '{print $1","$2}' > spos_ips.txt 
for line in $(cat spos_ips.txt);do 
name=$(echo $line | cut -d',' -f2);
ip=$(echo $line | cut -d',' -f1);
echo "UPDATE plugin_camm_snmptt_201410 SET formatline=concat('"$name"',' ',formatline) WHERE eventname='omsTrapAlarmNotificationClear' AND formatline LIKE '"$ip"%'" |mysql -v -uroot -pascb8308 events
done
UPDATE plugin_camm_snmptt_201410 SET formatline=concat('AC_ER_SP10_NR_CUA_1',' ',formatline) WHERE eventname='omsTrapAlarmNotificationClear' AND formatline LIKE '172.16.53.163%'
alter table events.plugin_camm_snmptt_201410 add column st_town char(6);
update events.plugin_camm_snmptt_201410 set st_town=substring(hostname, 12, 6);
update events.plugin_camm_snmptt_201410 set st_town=substring(formatline, 12, 6) where hostname='192.168.168.1';
create index ix_st_town on events.plugin_camm_snmptt_201410(st_town);
optimize table plugin_camm_snmptt_201410;

----------------------------------------
--MORE CASES
-----------------------------------------
--SEVENTH SCENARIO
SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE eventname IN ('alarmController1proginputTrap','alarmMajorLowBattVoltTrap','alarmDistributionBreakerOpenTrap','alarmBatteryBreakerOpenTrap') AND formatline LIKE '1%' AND (eventname!='alarmController1proginputTrap' OR formatline LIKE '%DPS%')
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname IN ('alarmController1proginputTrap','alarmMajorLowBattVoltTrap','alarmDistributionBreakerOpenTrap','alarmBatteryBreakerOpenTrap') AND formatline LIKE '1%' AND (eventname!='alarmController1proginputTrap' OR formatline LIKE '%DPS%') GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |      265 | 0.0000 |
| 1            |      261 | 0.0059 |
| 2            |        2 | 0.0000 |
| NULL         |      263 | 0.0059 |
+--------------+----------+--------+


SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM 
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,
    T1.formatline,
    T2.formatline fl2
FROM
    (SELECT
        id, 
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        eventname IN ('alarmController1proginputTrap','alarmMajorLowBattVoltTrap','alarmDistributionBreakerOpenTrap','alarmBatteryBreakerOpenTrap') AND formatline LIKE '1%' AND (eventname!='alarmController1proginputTrap' OR formatline LIKE '%DPS%')) AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime, INTERVAL 60 SECOND) AND T2.eventname = 'linkDown'
        AND substring(T2.hostname, 1, 10) = 'AC_AL_SA30'
        AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a1|at)	0.7186311787

--------------------
--EIGHT

SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemUrgentAlarm' AND (formatline LIKE '%Fus%' OR formatline like '%Ua low%') AND formatline NOT LIKE '%Value: 1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemUrgentAlarm' AND (formatline LIKE '%Fus%' OR formatline like '%Ua low%') AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP
+--------------+----------+--------+
| Total Alarms | COUNT(*) | 0      |
+--------------+----------+--------+
| Total Alarms |     1561 | 0.0000 |
| 1            |     1281 | 0.0287 |
| 2            |      116 | 0.0026 |
| 3            |       16 | 0.0004 |
| NULL         |     1413 | 0.0317 |
+--------------+----------+--------+


SELECT alarmsAC, alarmsLinkDown,COUNT(*)
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(DISTINCT id) AS alarmsAC, count(DISTINCT i2) AS alarmsLinkDown
FROM 
(SELECT 
    T1.id,
    T1.eventname,
    T1.hostname,
    T1.traptime,
    T2.id as i2,
    T2.eventname e2,
    T2.hostname h2,
    T2.traptime t2,    
    T2.formatline fl2,
    T1.formatline
FROM
    (SELECT 
        id,
        eventname,
            hostname,
            st_town,
            traptime,
            formatline
    FROM
        events.plugin_camm_snmptt_201410
    WHERE
        hostname LIKE 'RC%' AND eventname = 'systemUrgentAlarm' AND (formatline LIKE '%Fus%' OR formatline like 'Ua low') AND formatline NOT LIKE '%Value: 1%') AS T1
        LEFT OUTER JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 60 SECOND) AND date_add(T1.traptime,
        INTERVAL 60 SECOND) AND T2.eventname = 'omsTrapAlarmNotificationClear' AND T2.formatline LIKE '%Link Down%' AND T2.formatline NOT LIKE '% 7:6%' AND T2.st_town = T1.st_town)) t1
GROUP BY 1,2,3,4) AS TT
GROUP BY 1,2
ORDER BY 2,1

P(a2|at)	0.8771358828



SELECT 
    T1.vbind2,T1.vbind3, T2.eventname, T2.vbind1, T2.vbind3, count(*),count(distinct T2.hostname)
FROM
    (SELECT 
        vbind2,vbind3,eventname,traptime,st_town,FLOOR(1+RAND()*id) rid
    FROM
        events.plugin_camm_snmptt_201410
    where
        eventname = 'omsTrapAlarmNotificationClear'
            and hostname != '192.168.168.1'
            and severity = 'Major'
            and vBind3 = 'Optical receiver Power Low' ORDER BY rid LIMIT 1000) T1
        JOIN
    events.plugin_camm_snmptt_201410 T2 ON (T2.traptime BETWEEN date_add(T1.traptime,
        INTERVAL - 30 SECOND) AND date_add(T1.traptime,
        INTERVAL 30 SECOND))
GROUP BY 1,2,3,4 order by 6 desc
--optimize table plugin_camm_snmptt_201410;

--------------------------------------------------------------------
--Bayesian Reasoning

SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%'
UNION ALL
SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE (hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%') AND ((eventname = 'alarmACmainsTrap' AND formatline LIKE '1%') OR (eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline NOT LIKE '%Value: 1%'))


SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmMajorLowBattVoltTrap' AND formatline LIKE '1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemUrgentAlarm' AND formatline LIKE '%Ua Low%' AND formatline NOT LIKE '%Value: 1%' 
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'systemCriticalAlarm' AND formatline LIKE '%Mainsfailure' AND formatline LIKE '%Id: 19%' AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmDistributionBreakerOpenTrap' AND formatline LIKE '1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname IN ('alarmController1proginputTrap','alarmBatteryBreakerOpenTrap') AND formatline LIKE '1%' AND (eventname!='alarmController1proginputTrap' OR formatline LIKE '%DPS%') GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname='systemUrgentAlarm' and hostname LIKE 'RC%' and formatline LIKE '%Fusible%' AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE eventname='alarmController1proginputTrap' AND (formatline like '%Puerta%' OR formatline like '%Porta%') AND formatline LIKE '1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP

SELECT 'Total Alarms',COUNT(*),0 AS P FROM events.plugin_camm_snmptt_201410 WHERE hostname LIKE 'RC%' AND eventname = 'alarmACmainsTrap' AND formatline LIKE '1%'
UNION ALL
SELECT alarms,COUNT(*),COUNT(*)/44592 AS P
FROM
(SELECT month(traptime),day(traptime),hour(traptime),minute(traptime),COUNT(*) AS alarms FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' AND (formatline like '%Puerta%' OR formatline like '%Porta%') AND formatline NOT LIKE '%Value: 1%' GROUP BY 1,2,3,4) T1
GROUP BY 1
WITH ROLLUP




SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%'
UNION ALL
SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE (hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%') AND ((eventname='alarmMajorLowBattVoltTrap' AND formatline LIKE '1%') OR (eventname = 'systemUrgentAlarm' AND formatline like '%Ua low%' AND formatline NOT LIKE '%Value: 1%'))

SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%'
UNION ALL
SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE (hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%') AND (eventname='alarmDistributionBreakerOpenTrap' AND formatline LIKE '1%')


SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%'
UNION ALL
SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE (hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%') AND ((eventname IN ('alarmController1proginputTrap','alarmBatteryBreakerOpenTrap') AND formatline LIKE '1%' AND (eventname!='alarmController1proginputTrap' OR formatline LIKE '%DPS%')) OR (eventname='systemUrgentAlarm' and hostname LIKE 'RC%' and formatline LIKE '%Fusible%' AND formatline NOT LIKE '%Value: 1%'))  

SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%'
UNION ALL
SELECT COUNT(distinct hostname) FROM events.plugin_camm_snmptt_201410 WHERE (hostname like 'RC_DT%' OR hostname LIKE 'RC_EV%') AND ((eventname='alarmController1proginputTrap' AND (formatline like '%Puerta%' OR formatline like '%Porta%') AND formatline LIKE '1%')) OR (hostname like 'RC_DT%' AND (formatline like '%Puerta%' OR formatline like '%Porta%') AND formatline NOT LIKE '%Value: 1%'))  

--RULES CUT PERCENTAGE
--sdpStatusChanged + sdpChangeProcessed ALU
SELECT count(*)
FROM events.plugin_camm_snmptt_201410
WHERE eventname IN ('sdpStatusChanged','sdpBindSdpStateChangeProcessed')

10696

SELECT count(*),sum(t1.numAlarms+t2.numAlarms) 
FROM
(SELECT traptime,hostname, eventname, vbind1,count(*) as numAlarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname = 'sdpBindSdpStateChangeProcessed'
group by traptime,hostname, eventname, vbind1) t1
LEFT OUTER JOIN
(SELECT traptime,hostname, eventname, vbind1,count(*) as numAlarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname = 'sdpStatusChanged' group by traptime,hostname,eventname, vbind1) t2
 ON t2.traptime BETWEEN date_add(t1.traptime, INTERVAL -6 SECOND) AND date_add(t1.traptime, INTERVAL 2 SECOND) AND t1.vbind1=t2.vbind1 AND t1.hostname=t2.hostname

2175

--"tmnxStateChange"+"svcStatusChanged"+"sdpStatusChanged"
SELECT count(*)
FROM events.plugin_camm_snmptt_201410
WHERE eventname IN ('svcStatusChanged','tmnxStateChange','sdpStatusChanged','sdpBindStatusChanged')

34408

SELECT hostname, traptime,eventname,count(*) as alarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname='svcStatusChanged'
GROUP BY traptime,eventname,hostname
UNION ALL 
SELECT hostname, traptime,eventname,count(*) as alarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname='tmnxStateChange'
GROUP BY traptime,eventname,hostname
UNION ALL 
SELECT hostname, traptime,eventname,count(*) as alarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname='sdpStatusChanged'
UNION ALL 
SELECT hostname, traptime,eventname,count(*) as alarms
FROM events.plugin_camm_snmptt_201410
WHERE eventname='sdpBindStatusChanged'
GROUP BY traptime,eventname,hostname
ORDER BY hostname,traptime


--AC_ER_SP10_ST_VCH_1+AG_ER_SP60_ST_ZAP_1
SELECT *
FROM events.plugin_camm_snmptt_201410
WHERE eventname IN ('omsTrapAlarmNotificationClear')
AND hostname='AC_ER_SP10_ST_VCH_1' AND (vBind2='LANXPort:slot=4;port=11' OR vBind2='LANXPort:slot=3;port=11')
UNION ALL
SELECT * 
FROM events.plugin_camm_snmptt_201410
WHERE eventname IN ('omsTrapAlarmNotificationClear')
AND hostname='AG_ER_SP60_ST_ZAP_1' AND (vBind2='LANXPort:slot=7;port=1' OR vBind2='LANXPort:slot=12;port=1')
ORDER BY traptime

--HSU SYNC UNSYNC
select id,eventname,hostname,traptime,formatline 
from events.plugin_camm_snmptt_201410 
where eventname iN ('hbsUnregisteredUnsynchronizedHsu','hbsUnregisteredSynchronizedHsu')
order by hostname,traptime


SELECT t1.id,t1.hostname,t1.traptime,t1.eventname,count(t2.id)
FROM events.plugin_camm_snmptt_201410 t1 JOIN events.plugin_camm_snmptt_201410 t2 ON (t1.hostname=t2.hostname AND t2.traptime>t1.traptime AND t2.traptime<date_add(t1.traptime, INTERVAL 10 SECOND))
WHERE t1.hostname='AG_AL_SR50_CU_NEM_1' AND t1.traptime between '2014-10-27 00:00:00' and '2014-10-27 23:59:59'
GROUP BY t1.id
order by t1.hostname,t1.traptime

--LinkUp - RbnLinkUp
select eventname,count(*)
FROM
(select distinct traptime,hostname, eventname,vbind1,vbind2,vbind3 from events.plugin_camm_snmptt_201410 where eventname in ('rbnNElinkUp','linkUp') AND hostname LIKE '%ER_SE%') t1
group by 1

--LinkDown - RbnLinkDown
select eventname,count(*)
FROM
(select distinct traptime,hostname, eventname,vbind1,vbind2,vbind3 from events.plugin_camm_snmptt_201410 where eventname in ('rbnNElinkDown','linkDown') AND hostname LIKE '%ER_SE%') t1
group by 1


