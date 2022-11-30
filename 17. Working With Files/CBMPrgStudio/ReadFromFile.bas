!- File Types
!- PRG = Program (*.prg)
!- SEQ = Sequential (*.seq)
!- REL = Relative (*.rel)
!- USR = User (*.usr)
!- DEL = Deleted (*.del)
5 input "mount drive";a
90 REM Require a file number
91 REM Require a filename 
92 REM open 1,8,2,"setup,seq,read"
100 open 15,8,15
110 open 1,8,2,"setup,s,r"
115 gosub 500
116 if en=62 then close1:print"no such file":end
120 input#1,a$:rem if a$="-1"then 140
122 rem if peek(144) and 64 = 64 then 140
123 if st and 64 then 140
125 print a$:goto 120
130 rem input#1,b$:print b$
135 rem get#1,a$:if a$=""then 140
138 rem print a$:goto135
140 close 1
150 close15
160 end
170 
500 REM Read Status Of Drive
510 input#15, en,dr$,t,s
520 return

