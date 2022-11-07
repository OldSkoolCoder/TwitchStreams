!- Twitch Lesson 15 : Simulating Acceleration and Momentum
10 for i = 0 to 63 : poke (192*64)+i,255 :next i
20 poke 2040,192 : poke 53248,80 : poke 53249,80 : poke 53287,0
30 poke 53264,0 : poke 53269,1
!- Variables :  V = Sprite Velocity
!-              A = Acceleration
!-              F = Friction
!- 1/2, 1/4
40 f = 1 : a = f * 1.25 : v = 0 : x = 80 : y = 80
!- 1.25 = 1&1/4 = 00000001 01000000
50 k = peek(197)
60 if k = 64 and v <= 0 then v = 0 : goto 50
70 if k = 64 and v > 0 then v = v - f : goto 200
80 if k = 60 then v = v + a : goto 200
90 goto 50
200 x = x + v : x = x and 255
210 poke 53248,x
220 goto 50

