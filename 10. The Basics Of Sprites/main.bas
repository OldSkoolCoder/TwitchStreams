10 V = 53248
20 SO = V + 21
25 REM ONLY USING SPRITE 0
30 SX = V : SM = V + 16
40 SY = V + 1
50 SC = V + 39 : II = 5
60 SP = 2040 : BS=12288
70 REM 12288 / 64 = 192
80 FOR I = 0 TO (3*64) : READ B : POKE BS + I,B : NEXT
90 REM  00000000
100 REM .......^
110 POKE SO,PEEK(SO) OR 1
120 POKE SX,60
130 POKE SY,60
140 POKE SP,192
150 POKE SC,7
160 X = 60 : Y = 60 : C = 7
170 J = 31 - (PEEK(56320) AND 31) : ?J : IF J = 0 THEN 170
180 IF (J AND 1) = 1 THEN Y = Y - II
190 IF (J AND 2) = 2 THEN Y = Y + II
200 IF (J AND 4) = 4 THEN X = X - II
210 IF (J AND 8) = 8 THEN X = X + II
215 IF (J AND 16) = 16 THEN C = C + 1
220 POKE SX,(X AND 255)
225 IF X > 255 THEN POKE SM,PEEK(SM) OR 1
228 IF X < 256 THEN POKE SM,PEEK(SM) AND 254
230 POKE SY,Y
240 POKE SC,C
250 GOTO 170






1000 REM 
1010 DATA 0,0,0
1020 DATA 0,24,0
1030 DATA 0,60,0
1040 DATA 0,102,0
1050 DATA 0,67,0
1060 DATA 0,193,0
1070 DATA 0,129,128
1080 DATA 1,128,128
1090 DATA 1,0,192
1100 DATA 3,0,64
1110 DATA 2,0,96
1120 DATA 6,0,32
1130 DATA 4,7,32
1140 DATA 4,28,176
1150 DATA 12,112,80
1160 DATA 8,192,80
1170 DATA 25,128,32
1180 DATA 19,0,0
1190 DATA 22,0,0
1200 DATA 20,0,0
1210 DATA 8,0,0
1220 DATA 0
1230 REM 
1240 DATA 8,0,0
1250 DATA 20,0,0
1260 DATA 22,0,0
1270 DATA 19,0,0
1280 DATA 25,128,32
1290 DATA 8,192,80
1300 DATA 12,112,80
1310 DATA 4,28,176
1320 DATA 4,7,32
1330 DATA 6,0,32
1340 DATA 2,0,96
1350 DATA 3,0,64
1360 DATA 1,0,192
1370 DATA 1,128,128
1380 DATA 0,129,128
1390 DATA 0,193,0
1400 DATA 0,67,0
1410 DATA 0,102,0
1420 DATA 0,60,0
1430 DATA 0,24,0
1440 DATA 0,0,0
1450 DATA 0
1460 REM 
1470 DATA 0,0,0
1480 DATA 0,0,0
1490 DATA 15,0,0
1500 DATA 17,192,0
1510 DATA 12,120,0
1520 DATA 6,14,0
1530 DATA 3,3,128
1540 DATA 1,128,224
1550 DATA 0,192,56
1560 DATA 0,64,12
1570 DATA 0,96,6
1580 DATA 0,32,6
1590 DATA 0,48,12
1600 DATA 0,16,24
1610 DATA 0,16,112
1620 DATA 0,33,192
1630 DATA 0,199,0
1640 DATA 1,60,0
1650 DATA 0,224,0
1660 DATA 0,0,0
1670 DATA 0,0,0
1680 DATA 0
1690 REM 
1700 DATA 0,0,0
1710 DATA 0,0,0
1720 DATA 0,7,0
1730 DATA 0,60,128
1740 DATA 0,227,0
1750 DATA 3,132,0
1760 DATA 14,8,0
1770 DATA 24,8,0
1780 DATA 48,12,0
1790 DATA 96,4,0
1800 DATA 96,6,0
1810 DATA 48,2,0
1820 DATA 28,3,0
1830 DATA 7,1,128
1840 DATA 1,192,192
1850 DATA 0,112,96
1860 DATA 0,30,48
1870 DATA 0,3,136
1880 DATA 0,0,240
1890 DATA 0,0,0
1900 DATA 0,0,0
1910 DATA 0