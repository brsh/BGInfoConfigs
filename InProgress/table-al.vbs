Option Explicit
'Output table
Dim bColMarkOn 
bColMarkOn = True

Dim tTab, rR, cC
Set tTab = New Table
Set rR = tTab.NewRow
Set cC = rR.NewCol
cC.Data = ""
cC.Pad = "L"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Free"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Free"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Total"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Format"
cC.Pad = "C"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Label"
cC.Pad = "L"
rR.AddCol(cC)
rR.BorderBottom = True
rR.BorderTop = True
tTab.AddRow(rR)

Set rR = tTab.NewRow
Set cC = rR.NewCol
cC.Data = "C:"
cC.Pad = "L"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "162gb"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "54%"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "298gb"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "NTFS"
cC.Pad = "C"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Primary"
cC.Pad = "L"
rR.AddCol(cC)
tTab.AddRow(rR)

Set rR = tTab.NewRow
Set cC = rR.NewCol
cC.Data = "E:"
cC.Pad = "L"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "170gb"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "57%"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "298gb"
cC.Pad = "R"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "NTFS"
cC.Pad = "C"
rR.AddCol(cC)
Set cC = rR.NewCol
cC.Data = "Trav"
cC.Pad = "L"
rR.AddCol(cC)
rR.BorderBottom = True
rR.BorderTop = False

tTab.AddRow(rR)

Output tTab

'WScript.quit

Sub Output(oTable)
	Dim sTemp, rRow, cColumn, sOut, iWidth
	sOut = ""

	For Each rRow In oTable.alRows
		For Each cColumn In rRow.alColumns
			Select Case cColumn.Pad
				Case "L"
					sTemp = PadLeft(cColumn.Data, tTab.ColWidth(cColumn.ColNumber))	
				Case "C"
					sTemp = PadCenter(cColumn.Data, tTab.ColWidth(cColumn.ColNumber))	
				Case "R"
					sTemp = PadRight(cColumn.Data, tTab.ColWidth(cColumn.ColNumber))	
				End Select
			sOut = sOut & ColMark & sTemp
			sTemp = ""
		Next
		If rRow.RowNumber = 1 Then iWidth = Len(sOut) + 1
		If bColMarkOn Then
			If rRow.RowNumber = 1 Then 
				If ((oTable.BorderTop) Or (rRow.BorderTop)) Then sOut = DrawRowBorder(iWidth, 0) & vbCrLf & sOut
			Else
				If rRow.BorderTop Then sOut = DrawRowBorder(iWidth, rRow.RowNumber) & vbCrLf & sOut
			End If
		End If
		sOut = sOut & ColMark
		If bColMarkOn Then
			If rRow.RowNumber = tTab.alRows.Count Then
				If ((oTable.BorderBottom) Or (rRow.BorderBottom)) Then
					sOut = sOut & vbCrLf & DrawRowBorder(iWidth, "END")
				Else
					If rRow.BorderBottom Then sOut = sOut & vbCrLf & DrawRowBorder(iWidth, rRow.RowNumber)
				End If
			Else
				If rRow.BorderBottom Then sOut = sOut & vbCrLf & DrawRowBorder(iWidth, rRow.RowNumber)
			End If
		End If
		WScript.Echo sOut
		sOut = ""
	Next
End Sub

Function DrawRowBorder(iWidth, iRowNum)
	Dim sStart, sEnd
	Select Case iRowNum
		Case "0"
			sStart = " ┌"
			sEnd = "┐"
		Case "END"
			sStart = " └"
			sEnd = "┘"
		Case Else
			sStart = " ├"
			sEnd = "┤"
	End Select
	DrawRowBorder = sStart & String(iWidth - 2, "─") & sEnd
End Function

Function PadRight(sOrig, iLength)
	'right justify a column of text so "123" becomese "   123"
	Dim sRet
	sRet = String(iLength - Len(sOrig), " ") & sOrig
	PadRight = sRet
End Function

Function PadLeft(sOrig, iLength)
	'left justify a column of text so "123" becomese "123   "
	Dim sRet
	sRet = sOrig & String(iLength - Len(sOrig), " ")
	PadLeft = sRet
End Function

Function PadCenter(sOrig, iLength)
	'Center justify a column of text so "123" becomese " 123 "
	Dim sRet
	sRet = String((iLength - Len(sOrig))/2, " ") & sOrig & String((iLength - Len(sOrig))/2, " ")
	PadCenter = sRet
End Function


Function ColMark()
	Dim sRet
	If bColMarkOn Then
		sRet = " │ "
	Else
		sRet = ""
	End If	
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
	Private int_length
	Private int_data

	Public Pad
	Public ColNumber
	Public BorderLeft
	Public BorderRight

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
	
	Private Sub Class_Initialize
  		BorderLeft = "|"
  		BorderRight = "|"
  		Pad = "L"
	End Sub
End Class

Class Row
	Public alColumns
	Public RowNumber
	Public BorderTop
	Public BorderBottom
	
	Public Function NewCol
		Set NewCol = New Column
	End Function
	
	Public Sub AddCol(cCol)
		cCol.ColNumber = alColumns.Count + 1
		alColumns.Add(cCol)
	End Sub

	Private Sub Class_Initialize
		Set alColumns = CreateObject("System.Collections.ArrayList")
		BorderTop = False
		BorderBottom = False

	End Sub
End Class

Class Table
	Public alRows
	Private dicColWidths
	Public BorderTop
	Public BorderBottom
	
	Public Property Get ColWidth(colNumber)
		Dim iHold
		iHold = dicColWidths(colNumber)
		If (iHold / 2) <> Roundit(iHold / 2, 0) Then iHold = iHold + 1
		ColWidth = iHold
	End Property

	Public Function NewRow
		Set NewRow = New Row
	End Function
	
	Public Sub AddRow(cRow)
		Dim cCol, i
		cRow.RowNumber = alRows.Count + 1
		For each cCol in cRow.alColumns
			If dicColWidths.Exists(cCol.ColNumber) Then
				If cCol.Length > CInt(dicColWidths.Item(cCol.ColNumber)) Then 
					dicColWidths.Item(cCol.ColNumber) = cCol.Length
				End If
			Else
				dicColWidths.Add cCol.ColNumber, cCol.Length
			End If
		Next
		alRows.Add(cRow)
	End Sub

	Private Sub Class_Initialize
		Set alRows = CreateObject("System.Collections.ArrayList")
		Set dicColWidths = CreateObject("Scripting.Dictionary")
		BorderTop = False
		BorderBottom = False
	End Sub
End Class

'End Classes
'*****************************************************************
