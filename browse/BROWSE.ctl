@ $2000 start
@ $2000 equ=BORDCR=$5c48
@ $2000 org
c $2000
c $2017
c $203F
c $205A
c $20E5
c $2105
s $2128
c $2129
T $2145,16
@ $2145 label=browseName
b $2155
@ $2155 label=fileHandle
b $2156
@ $2156 label=BORDCR_SAVE
@ $2157 label=fileInfo
B $2157,11
b $2162
b $2163
@ $2163 label=startDir
w $2263
@ $2263 label=stackSave
b $2265
i $22A5
