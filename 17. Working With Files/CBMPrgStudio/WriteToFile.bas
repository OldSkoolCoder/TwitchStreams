!- File Types
!- PRG = Program (*.prg)
!- SEQ = Sequential (*.seq)
!- REL = Relative (*.rel)
!- USR = User (*.usr)
!- DEL = Deleted (*.del)
5 input "mount drive";a
90 REM Require a file number
91 REM Require a filename 
92 REM open 1,8,2,"setup,seq,write"
100 open 15,8,15
110 open 1,8,2,"setup,s,w"
115 gosub 500
116 if en=63 then close1:print#15,"s:setup":goto110
120 print#1, "john is great"
130 print#1, "andy is a pain"
135 print#1, "-1"
140 close 1
150 close15
160 end

500 REM Read Status Of Drive
510 input#15, en,b$,t,s
520 return

