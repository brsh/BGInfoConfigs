Option Explicit
'Output table
Dim sOut
Dim bColMarkOn
Dim iCol1, iCol2, iCol3, iCol4
Dim aRow(), aColWidth()
Dim iCol, iRow, x, y
Dim alColumns, alRows, i, cNet()

i = 0

Set alColumns = CreateObject("System.Collections.ArrayList")
Set alRows = CreateObject("System.Collections.ArrayList")
'Set cNet(i) = New Column

bColMarkOn = True

iRow = 3
iCol = 3

ReDim Preserve aRow(iRow, iCol)

aRow(0,0) = "Header1"
aRow(0,1) = "Header2"
aRow(0,2) = "Header3"
aRow(0,3) = "Header4"
aRow(1,0) = "Item 1"
aRow(1,1) = "Item 2"
aRow(1,2) = "Item 3"
aRow(1,3) = "Item 4"
aRow(1,0) = "Item One"
aRow(1,1) = "Item Two"
aRow(1,2) = "Item Three"
aRow(1,3) = "Item Four"
aRow(2,0) = "Item 2,One"
aRow(2,1) = "Item 2,Two"
aRow(2,2) = "Item 2,Three"
aRow(2,3) = "Item 2,Four"
aRow(3,0) = "Item Three,One"
aRow(3,1) = "Item Three,Two"
aRow(3,2) = "Item Three,Three"
aRow(3,3) = "Item Three,Four"

'
'
'
'
'

'Get MaxColWidths
ReDim aColWidth(iCol)
For x = 0 To iRow
	For y = 0 To iCol
		If Len(aRow(x, y)) > aColWidth(y) Then aColWidth(y) = Len(aRow(x,y))
		'If aColWidth(y) / 2 <> Roundit(aColWidth(y) / 2, 0) Then aColWidth(y) = aColWidth(y) + 1
	Next	
Next
sOut = ""
For x = 0 To iRow
	For y = 0 To iCol
		sOut = sOut & ColMark & PadRight(aRow(x, y), aColWidth(y))
	Next	
	sOut = sOut & ColMark & vbCrLf
Next


WScript.echo sOut




Function PadRight(sOrig, iLength)
	'right justify a column of text so "123" becomese "   123"
	Dim sRet
	'If iLength < Len(sOrig)+1 Then iLength = Len(sOrig) + 2
	'If iLength / 2 <> Roundit(iLength / 2, 0) Then iLength = iLength + 1
	sRet = String(iLength - Len(sOrig), " ") & sOrig
	PadRight = sRet
End Function

Function PadLeft(sOrig, iLength)
	'left justify a column of text so "123" becomese "123   "
	Dim sRet
	'If iLength < Len(sOrig) Then iLength = Len(sOrig) 
	sRet = sOrig & String(iLength - Len(sOrig), " ")
	PadLeft = sRet
End Function

Function PadCenter(sOrig, iLength)
	'Center justify a column of text so "123" becomese " 123 "
	Dim sRet
	'If iLength < Len(sOrig)+1 Then iLength = Len(sOrig) + 2
	'If iLength / 2 <> Roundit(iLength / 2, 0) Then iLength = iLength + 1
	sRet = String((iLength - Len(sOrig))/2, " ") & sOrig & String((iLength - Len(sOrig))/2, " ")
	PadCenter = sRet
End Function


Function ColMark()
	Dim sRet
	If bColMarkOn Then
		sRet = " | "
	Else
		sRet = " "
	End if	
	ColMark = sRet
End Function

Function Roundit(number,DecPlaces) 
	decPlaces=10^decplaces 
	number=number*decplaces     
	if int(number)+.5>number then     'Round down 
    	number=int(number)     
    else     'Round up     
    	number=int(number)+1 
    end If 
	Roundit=number/DecPlaces 
End Function




'*****************************************************************
'Classes
Class Column
	Public Pad
	Private int_length
	Private int_data
	Public Property Get Data
		Data = int_data
	End Property
	Public Property Let Data (ByVal statIn)
		int_data = statIn
		int_length = Len(statIn)
	End Property
	Public Property Get Length
		Length = int_length
	End Property
End Class

Class Row
	
End Class

'End Classes
'*****************************************************************
