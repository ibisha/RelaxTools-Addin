Attribute VB_Name = "basMacro"
'-----------------------------------------------------------------------------------------------------
'
' [RelaxTools-Addin] v4
'
' Copyright (c) 2009 Yasuhiro Watanabe
' https://github.com/RelaxTools/RelaxTools-Addin
' author:relaxtools@opensquare.net
'
' The MIT License (MIT)
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in all
' copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
' SOFTWARE.
'
'-----------------------------------------------------------------------------------------------------
Option Explicit
Option Private Module


'--------------------------------------------------------------
'�@�L�[���s���b�p�[
'--------------------------------------------------------------
Sub execOnKey(ByVal strMacro As String, ByVal strLabel As String)

    On Error Resume Next

    '�J�n���O
    Logger.LogBegin strMacro
    
    Application.Run strMacro
    
    If CBool(GetSetting(C_TITLE, "Option", "OnRepeat", True)) Then
        Application.OnRepeat strLabel, strMacro
    End If
    
    '�I�����O
    Logger.LogFinish strMacro
    
End Sub
'--------------------------------------------------------------
'�@�Í����o�b�t�@�G���A
'--------------------------------------------------------------
'Private mbytBuf() As Byte

Sub saveWorkSheets()
        
    Dim b As Workbook
    Dim o As Object
    Dim vntFileName As Variant
    
    On Error GoTo ErrHandle
        
    vntFileName = Application.GetSaveAsFilename(InitialFileName:="", FileFilter:="Excel �u�b�N(*.xlsx),*.xlsx,Excel �}�N���L���u�b�N(*.xlsm),*.xlsm,Excel 97-2003�u�b�N(*.xls),*.xls", Title:="�u�b�N�̕ۑ�")
    
    If vntFileName <> False Then
    
        For Each b In Workbooks
            If UCase(b.Name) = UCase(rlxGetFullpathFromFileName(vntFileName)) Then
                MsgBox "���݊J���Ă���u�b�N�Ɠ������O�͎w��ł��܂���B", vbOKOnly + vbExclamation, C_TITLE
                Exit Sub
            End If
        Next
        
        If rlxIsFileExists(vntFileName) Then
            If MsgBox("���łɓ����̃u�b�N�����݂����܂��B�㏑�����܂����H", vbOKCancel + vbQuestion, C_TITLE) <> vbOK Then
                Exit Sub
            End If
        End If
    
        Application.DisplayAlerts = False
        ActiveWorkbook.Windows(1).SelectedSheets.Copy
        Set b = Application.Workbooks(Application.Workbooks.count)
        Select Case LCase(Mid$(vntFileName, InStr(vntFileName, ".") + 1))
            Case "xls"
                b.SaveAs filename:=vntFileName, FileFormat:=xlExcel8, local:=True
            Case "xlsm"
                b.SaveAs filename:=vntFileName, FileFormat:=xlOpenXMLWorkbookMacroEnabled, local:=True
            Case Else
                b.SaveAs filename:=vntFileName, local:=True
        End Select
        b.Close
        Set b = Nothing
        Application.DisplayAlerts = True
        MsgBox "�ۑ����܂����B", vbOKOnly + vbInformation, C_TITLE
    End If
     
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�s�R�s�[
'--------------------------------------------------------------
Sub lineCopy()

    If rlxCheckSelectRange = False Then
        Exit Sub
    End If

    If ActiveCell Is Nothing Then
        Exit Sub
    End If

    Dim f As Long
    Dim t As Long
    
    f = Selection(1, 1).Row
    t = f + Selection.Rows.count - 1
    
    On Error Resume Next
    Application.ScreenUpdating = False
    
    ThisWorkbook.Worksheets("Undo").Cells.Clear
    
    Set mUndo.sourceRange = Rows(f & ":" & t)
    Set mUndo.destRange = Nothing
    
    Rows(f & ":" & t).Copy
    Rows(f & ":" & t).Insert Shift:=xlDown
    Application.CutCopyMode = False
    
    SelectionShiftCell Selection.Rows.count, 0
    
    Application.ScreenUpdating = True
    
    'Undo
    Application.OnUndo "�s�ǉ�", "execInsUndo"
    
    
End Sub
'--------------------------------------------------------------
'�@�s�}��
'--------------------------------------------------------------
Sub lineInsert()
    
    If rlxCheckSelectRange = False Then
        Exit Sub
    End If
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If

    Dim f As Long
    Dim t As Long
    
    f = Selection(1, 1).Row
    t = f + Selection.Rows.count - 1
    
    On Error Resume Next
    Application.ScreenUpdating = False
    
    ThisWorkbook.Worksheets("Undo").Cells.Clear
    
    Set mUndo.sourceRange = Rows(f & ":" & t)
    Set mUndo.destRange = Nothing
    
    Rows(f & ":" & t).Insert Shift:=xlUp
    Application.CutCopyMode = False
    
    Set mUndo.sourceRange = Rows(f & ":" & t)
    
    SelectionShiftCell Selection.Rows.count, 0
    
    Application.ScreenUpdating = True
    
    'Undo
    Application.OnUndo "�s�ǉ�", "execInsUndo"
    
End Sub
'--------------------------------------------------------------
'�@�s�폜
'--------------------------------------------------------------
Sub lineDel()

    If rlxCheckSelectRange = False Then
        Exit Sub
    End If
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If

    Dim f As Long
    Dim t As Long
    
    f = Selection(1, 1).Row
    t = f + Selection.Rows.count - 1
    
    On Error Resume Next
    Application.ScreenUpdating = False
    
    ThisWorkbook.Worksheets("Undo").Cells.Clear
    
    Set mUndo.sourceRange = Intersect(Range(Cells(f, 1), Cells(t, Columns.count - 1)), ActiveSheet.UsedRange)
    Set mUndo.destRange = ThisWorkbook.Worksheets("Undo").Range(mUndo.sourceRange.Address)
    
    mUndo.sourceRange.Copy mUndo.destRange
    
    Rows(f & ":" & t).Delete xlUp
    
    Set mUndo.sourceRange = Intersect(Range(Cells(f, 1), Cells(t, Columns.count - 1)), ActiveSheet.UsedRange)
    
    Application.CutCopyMode = False
    Application.ScreenUpdating = True
    
    Selection.Select
    
    'Undo
    Application.OnUndo "�s�폜", "execDelUndo"
    
    
End Sub
'--------------------------------------------------------------
'�@�����s�R�s�[
'--------------------------------------------------------------
Sub lineNCopy()

    Dim lngBuf As Long
    Dim lngDest As Long
    Dim lngCnt As Long
    Dim f As Long
    Dim t As Long
    
    If rlxCheckSelectRange = False Then
        Exit Sub
    End If
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If

    lngBuf = frmInputLength.Start("�s���R�s�[���鐔����͂��Ă��������B" & vbCrLf & "���(1000)")
    If lngBuf = 0 Then
        Exit Sub
    End If

    If lngBuf > 1000 Then
        Exit Sub
    End If

'    lngDest = ActiveCell.row + Val(strbuf) - 1
    lngDest = lngBuf

    f = Selection(1, 1).Row
    t = f + Selection.Rows.count - 1

    On Error Resume Next
    Application.ScreenUpdating = False
    For lngCnt = 1 To lngDest
        Rows(f & ":" & t).Copy
        Rows(f & ":" & t).Insert Shift:=xlDown
    Next
    Application.CutCopyMode = False
    Application.ScreenUpdating = True
    
End Sub
'--------------------------------------------------------------
'�@Range���擾�ł��邩�ǂ����`�F�b�N����
'--------------------------------------------------------------
Function rlxCheckSelectRange() As Boolean
Attribute rlxCheckSelectRange.VB_Description = "���[�N�V�[�g�֐��Ƃ��Ďg�p�ł��܂���B"
Attribute rlxCheckSelectRange.VB_ProcData.VB_Invoke_Func = " \n19"
    
    On Error GoTo ErrHandle
    
    rlxCheckSelectRange = False
    
    Select Case True
        Case ActiveWorkbook Is Nothing
            Exit Function
        Case ActiveCell Is Nothing
            Exit Function
        Case Selection Is Nothing
            Exit Function
        Case TypeOf Selection Is Range
            'OK
        Case Else
            Exit Function
    End Select

    rlxCheckSelectRange = True

    Exit Function
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Function
'--------------------------------------------------------------
'�@�N���b�v�{�[�h�\��t��
'--------------------------------------------------------------
Public Sub putClipboard(ByVal strBuf As String)
    On Error GoTo ErrHandle


    SetClipText strBuf
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�g�p����Ă���G���A�̑I��
'--------------------------------------------------------------
Sub usedRangeSelect()
    On Error GoTo ErrHandle
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    ActiveSheet.UsedRange.Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�J�[�\���̂���G���A�̑I��
'--------------------------------------------------------------
Sub currentRegionSelect()
    On Error GoTo ErrHandle

    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    ActiveCell.CurrentRegion.Select

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@���j���[�ݒu�l�o�́i�f�o�b�O�@�\�j
'--------------------------------------------------------------
Sub commandList()

    Dim c As CommandBar
    Dim D As CommandBarControl
    
    Dim lngCnt As Long
    
    On Error GoTo ErrHandle
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    If MsgBox("���݂̃V�[�g�Ƀ��j���[�ݒ�l���o�͂��܂��B��낵���ł����H", vbQuestion + vbOKCancel, C_TITLE) <> vbOK Then
        Exit Sub
    End If
    
    lngCnt = 1

    For Each c In CommandBars

        For Each D In c.Controls

            Cells(lngCnt, 1) = c.Name
            Cells(lngCnt, 2) = c.NameLocal
        
            Cells(lngCnt, 3) = D.Caption
            Cells(lngCnt, 4) = D.id
            
            lngCnt = lngCnt + 1
        Next
    Next
    Exit Sub
ErrHandle:
    MsgBox "�G���["
End Sub
'--------------------------------------------------------------
'�@���O��S�폜
'--------------------------------------------------------------
Sub delnamae()

    On Error GoTo ErrHandle
    
    '�ϐ��錾
    Dim namae As Name '���O
    Dim namae_del As String '���ł������O���X�g
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    If MsgBox("�u�b�N���̑S�Ă̖��O���폜���܂�(�uPrint_�v�Ŏn�܂���̈ȊO)�B��낵���ł����H", vbQuestion + vbOKCancel, C_TITLE) <> vbOK Then
        Exit Sub
    End If
        namae_del = ""
    
    '���O����
    For Each namae In ActiveWorkbook.Names
        If InStr(namae.Name, "Print_") > 0 Then
        Else
            namae_del = namae_del & vbCrLf & namae.Name
            namae.Delete
        End If
    Next
    
    '���ʕ�
    If Len(namae_del) = 0 Then
        MsgBox "���O������܂���ł����B", vbExclamation, C_TITLE
    Else
        MsgBox "�ȉ��̖��O�����ł����܂����B" & namae_del, vbInformation, C_TITLE
    End If

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@���ׂẴV�[�g�̑I���ʒu���`�P�ɃZ�b�g
'--------------------------------------------------------------
Sub setAllA1()

    On Error Resume Next
    Dim WS As Worksheet
    Dim WD As Window
    Dim sw As Boolean
    Dim WB As Workbook
    Dim blnRatio As Boolean
    Dim lngPercent As Long
    Dim blnView As Boolean
 
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    blnRatio = GetSetting(C_TITLE, "A1Setting", "ratio", False)
    blnView = GetSetting(C_TITLE, "A1Setting", "ViewEnable", 0)
    lngPercent = Val(GetSetting(C_TITLE, "A1Setting", "percent", "100"))
    If lngPercent = 0 Then
        lngPercent = 100
    End If
    
    sw = False
    If Application.ScreenUpdating Then
        sw = True
    End If
    
    If sw Then
        Application.ScreenUpdating = False
    End If
  
    Set WB = ActiveWorkbook
  
    For Each WS In WB.Worksheets
        If WS.visible = xlSheetVisible Then
            WS.Activate
            WS.Range("A1").Activate
            WB.Windows(1).ScrollRow = 1
            WB.Windows(1).ScrollColumn = 1
            
            If blnView Then
                Select Case Val(GetSetting(C_TITLE, "A1Setting", "View", "0"))
                    Case 0
                        WB.Windows(1).View = xlNormalView
                    Case 1
                        WB.Windows(1).View = xlPageLayoutView
                    Case 2
                        WB.Windows(1).View = xlPageBreakPreview
                End Select
            End If
            
            If blnRatio Then
                WB.Windows(1).Zoom = lngPercent
            End If
        End If
    Next

    '��\���̂P���ڂ�I�����āu�͂��H�v��Ԃ������̂ŕ\�����̂P���ڂɂ���B
    'ActiveWorkbook.Worksheets(1).Select
    For Each WS In WB.Worksheets
        If WS.visible = xlSheetVisible Then
            WS.Select
            Exit For
        End If
    Next
    
    Set WB = Nothing
    
    If sw Then
        Application.ScreenUpdating = True
    End If
    
End Sub

'--------------------------------------------------------------
'�@���ׂẴV�[�g�̑I���ʒu���`�P�ɃZ�b�g���ĕۑ�
'--------------------------------------------------------------
Sub setAllA1save()

    Dim fname As String
    Dim varRet As Variant

    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If

    Application.ScreenUpdating = False
    
    Call setAllA1
    
    On Error Resume Next
    
    mA1Save = True
    
    If ActiveWorkbook.ReadOnly Then
        MsgBox "�ǂݎ���p�u�b�N�̂��ߕۑ��ł��܂���B", vbOKOnly + vbCritical, C_TITLE
        GoTo pass
    End If
    
    If rlxIsFileExists(ActiveWorkbook.FullName) Then
    Else
        MsgBox "�܂���x���ۑ����Ă��Ȃ��t�@�C���ł��B��xExcel�ŕۑ����s���Ă��������B", vbOKOnly + vbExclamation, C_TITLE
        GoTo pass
    End If
    
    varRet = getAttr(ActiveWorkbook.FullName)
    If Err.Number > 0 Then
        MsgBox "���݂̃t�@�C���ɃA�N�Z�X�ł��܂���ł����B�ۑ��ł��܂���ł����B", vbOKOnly + vbExclamation, C_TITLE
        GoTo pass
    End If
    
    If (varRet And vbReadOnly) > 0 Then
        MsgBox "�w�肳�ꂽ�t�@�C���͓ǂݎ���p�ł��B�ۑ��ł��܂���ł����B", vbOKOnly + vbExclamation, C_TITLE
        GoTo pass
    End If
    
    
    ActiveWorkbook.Save

    
pass:
    mA1Save = False
    
    Application.ScreenUpdating = True

End Sub
'--------------------------------------------------------------
'�@�V�[�g�����N���b�v�{�[�h�ɓ\��t��
'--------------------------------------------------------------
Sub getSheetName()

    Dim WS As Object
    Dim strBuf As String
  
    On Error GoTo ErrHandle
  
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
  
    strBuf = ""
    For Each WS In Sheets
            
        strBuf = strBuf & WS.Name & vbCrLf

    Next

    '�N���b�v�{�[�h�\��t��
    putClipboard strBuf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub

'-----------------------------------------------------------------------
'�@�J���Ă��郏�[�N�u�b�N���i�u�b�N���̂݁j���N���b�v�{�[�h�ɓ\��t��
'------------------------------------------------------------------------
Sub getBookName()

    Dim WB As Workbook
    Dim strBuf As String
    
    On Error GoTo ErrHandle
  
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    strBuf = ""
    For Each WB In Workbooks
        strBuf = strBuf & WB.Name & vbCrLf
    Next
    
    '�N���b�v�{�[�h�\��t��
    putClipboard strBuf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub

'------------------------------------------------------------------
'�@�J���Ă��郏�[�N�u�b�N���i�t���p�X�j���N���b�v�{�[�h�ɓ\��t��
'------------------------------------------------------------------
Sub getBookFullName()

    Dim WB As Workbook
    Dim strBuf As String
    
    On Error GoTo ErrHandle
  
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    strBuf = ""
    For Each WB In Workbooks
        strBuf = strBuf & rlxDriveToUNC(WB.FullName) & vbCrLf
    Next
    
    '�N���b�v�{�[�h�\��t��
    putClipboard strBuf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub

'--------------------------------------------------------------
'�@���݂̃��[�N�u�b�N���i�t���p�X�j���N���b�v�{�[�h�ɓ\��t��
'--------------------------------------------------------------
Sub getCurrentBookFullName()
    
    On Error GoTo ErrHandle

    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    '�N���b�v�{�[�h�\��t��
    putClipboard rlxDriveToUNC(ActiveWorkbook.FullName) '& vbCrLf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub
'--------------------------------------------------------------
'�@���݂̃��[�N�u�b�N���i�t���p�X�j���N���b�v�{�[�h�ɓ\��t��
'--------------------------------------------------------------
Sub getCurrentBookFullNameDrv()
    
    On Error GoTo ErrHandle

    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    '�N���b�v�{�[�h�\��t��
    putClipboard ActiveWorkbook.FullName '& vbCrLf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub
'--------------------------------------------------------------
'�@���݂̃��[�N�u�b�N���i�t���p�X�j���N���b�v�{�[�h�ɓ\��t��
'--------------------------------------------------------------
Sub getCurrentBookName()

    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    '�N���b�v�{�[�h�\��t��
    putClipboard rlxDriveToUNC(ActiveWorkbook.Name) '& vbCrLf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub

'--------------------------------------------------------------
'�@���݂̃��[�N�u�b�N���i�t���p�X�j�̃t�H���_���J��
'--------------------------------------------------------------
Sub openDocumentPath()
    
    Dim WSH As Object
    Dim wExec As Object
    
    On Error Resume Next

    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
   
    Set WSH = CreateObject("WScript.Shell")
    
    WSH.Run ("""" & rlxGetFullpathFromPathName(rlxDriveToUNC(ActiveWorkbook.FullName)) & """")
    
    Set wExec = Nothing
    Set WSH = Nothing
    
End Sub
'--------------------------------------------------------------
'�@���[�N�u�b�N�̕���
'--------------------------------------------------------------
Sub divideWorkBook()

    Dim strWorkPath As String
    Dim WS As Worksheet
    Dim W2 As Worksheet
    Dim motoWB As Workbook
    Dim WB As Workbook
    Dim WSH As Object
    
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    If MsgBox("���݂̃u�b�N�̍�ƃt�H���_�Ɂu�u�b�N��_�V�[�g���v�ŃV�[�g���ɕ������܂��B" & vbCrLf & "��낵���ł����H(��\���V�[�g�͏������܂���)", vbOKCancel + vbQuestion, C_TITLE) <> vbOK Then
        Exit Sub
    End If
    
    '���݂̃��[�N�u�b�N��ΏۂƂ���B
    Set motoWB = ActiveWorkbook
    
    If motoWB Is Nothing Then
        Exit Sub
    End If
    
    strWorkPath = motoWB.Path
    If strWorkPath = "" Then
        MsgBox "���u�b�N�̃p�X���擾�ł��܂���B�ۑ����Ă���ēx���s���Ă��������B", vbExclamation, C_TITLE
        Exit Sub
    End If

    For Each WS In motoWB.Worksheets
    
        If WS.visible = xlSheetVisible Then

            '���݂̃V�[�g���R�s�[���ĐV�K�̃��[�N�u�b�N���쐬����B
            WS.Copy
            
            Set WB = Application.Workbooks(Application.Workbooks.count)
            
            '�V�K�쐬�������[�N�u�b�N��ۑ�����B�t�H�[�}�b�g�͐e�Ɠ���
            Application.DisplayAlerts = False
            WB.SaveAs filename:=rlxAddFileSeparator(strWorkPath) & rlxGetFullpathFromExt(motoWB.Name) & "_" & WS.Name, FileFormat:=motoWB.FileFormat, local:=True
            Application.DisplayAlerts = True
            WB.Close
    
            Set WB = Nothing
            
        End If
    Next

    '���������t�H���_���J��
    On Error Resume Next

    Set WSH = CreateObject("WScript.Shell")
    
    WSH.Run ("""" & rlxGetFullpathFromPathName(rlxDriveToUNC(motoWB.FullName)) & """")
    
    Set WSH = Nothing
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub
'--------------------------------------------------------------
'�@���[�N�u�b�N�̃}�[�W
'--------------------------------------------------------------
Sub mergeWorkBook()

    Dim strWorkPath As String
    Dim WS As Worksheet
    Dim W2 As Worksheet
    Dim motoWB As Workbook
    Dim WB As Workbook
    
    Dim blnFirst As Boolean
    
    On Error GoTo ErrHandle
    
    
    '���[�N�u�b�N���Q�����̏ꍇ�A�����s�v
    If Workbooks.count < 2 Then
        Exit Sub
    End If
    
    blnFirst = True
    
    For Each WB In Workbooks

        For Each WS In WB.Worksheets
            If blnFirst Then
                WS.Copy
                Set motoWB = Application.Workbooks(Application.Workbooks.count)
                blnFirst = False
            Else
                WS.Copy , motoWB.Worksheets(motoWB.Worksheets.count)
            End If
        Next
        
    Next
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub

'--------------------------------------------------------------
'�@�I��͈͂̉摜�ϊ�
'--------------------------------------------------------------
Sub execSelectionPictureCopy()

    Dim blnFillVisible As Boolean
    Dim lngFillColor As Long
    Dim blnLine As Boolean
    Dim blnB As Boolean

    Call getCopyScreenSetting(blnFillVisible, lngFillColor, blnLine)
    
    blnB = ActiveWindow.DisplayGridlines
    ActiveWindow.DisplayGridlines = blnLine

    On Error GoTo ErrHandle

    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    Selection.CopyPicture Appearance:=xlScreen, Format:=xlPicture
    Call CopyClipboardSleep
    ActiveSheet.Paste
    
    ActiveWindow.DisplayGridlines = blnB
    
    Selection.ShapeRange.Fill.ForeColor.RGB = lngFillColor
    
    If blnFillVisible Then
        Selection.ShapeRange.Fill.visible = msoFalse
    Else
        Selection.ShapeRange.Fill.visible = msoTrue
    End If
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�t�@�C���̓�ǉ�
'�@�o�b�t�@�ǂݍ��ݑΉ�(2GB�ȉ�)
'--------------------------------------------------------------
Sub encryptionFileEx()

    Dim strFile As String
    Dim intIn As Integer
    Dim intOut As Integer
    Dim lngsize As Long
    Dim i As Long
    Dim bytBuf() As Byte
    
    Dim lngRead As Long
    
    Const key As Byte = &H44
    Const C_BUFFER_SIZE = 10485760 '10MB
    Const C_TEMP_FILE_EXT As String = ".tmp"
    
    On Error GoTo ErrHandle
    
    strFile = Application.GetOpenFilename(, , "�t�@�C���̓�ǉ�", , False)
    If strFile = "False" Then
        '�t�@�C�������w�肳��Ȃ������ꍇ
        Exit Sub
    End If
    
    '�t�@�C���̑��݃`�F�b�N
    If rlxIsFileExists(strFile) Then
    Else
        MsgBox "�t�@�C�������݂��܂���B", vbExclamation, C_TITLE
        Exit Sub
    End If

    intIn = FreeFile()
    Open strFile For Binary As intIn
    
    intOut = FreeFile()
    Open strFile & C_TEMP_FILE_EXT For Binary As intOut
    
    lngsize = LOF(intIn)
    
    Do While lngsize > 0
    
        If lngsize < C_BUFFER_SIZE Then
            lngRead = lngsize
        Else
            lngRead = C_BUFFER_SIZE
        End If
    
        '�ő��10MB�̃��������m�ہB
        ReDim bytBuf(0 To lngRead - 1)
    
        '�m�ۂ����o�C�g�����ǂݍ���
        Get intIn, , bytBuf
        
        '�Ȃ񂿂���ĈÍ���
        For i = 0 To lngRead - 1
            bytBuf(i) = bytBuf(i) Xor key
        Next
        
        '���ʂ���������
        Put intOut, , bytBuf

        lngsize = lngsize - lngRead
    Loop

    Close intIn
    Close intOut
    
    Kill strFile
    Name strFile & C_TEMP_FILE_EXT As strFile

    MsgBox "��ǉ��^���������������܂����B", vbInformation, C_TITLE
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE


End Sub
'--------------------------------------------------------------
'�@�N���b�v�{�[�h�ɂ���b�r�u�f�[�^��
'�@���݂̃V�[�g�ɕ�����Ƃ��ē\��t���܂��B
'--------------------------------------------------------------
Sub pasteCSV()

    Dim cb As New DataObject
    Dim strBuf As String
    Dim varRow As Variant
    Const STANDARD_DATA As Long = 1
    
    On Error GoTo ErrHandle
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    With cb
        .GetFromClipboard
        If .GetFormat(STANDARD_DATA) = False Then
            Exit Sub
        End If
        
        strBuf = .getText
        
    End With
    
    'CRLF����؂�Ƃ��čs�P�ʂɕ���
    Dim strCsv() As String
    Select Case True
        Case InStr(strBuf, vbCrLf) > 0
            strCsv = Split(strBuf, vbCrLf)
        Case InStr(strBuf, vbLf) > 0
            strCsv = Split(strBuf, vbLf)
        Case Else
            strCsv = Split(strBuf, vbCr)
    End Select

    Dim lngCount As Long
    lngCount = UBound(strCsv) + 1
    If lngCount < 1 Then
        Exit Sub
    End If
    
    Dim i As Long
    Dim Col As Collection
    Dim lngCol As Long
    Dim lngRow As Long
    Dim r As Range
    
    lngRow = ActiveCell.Row
    For i = 0 To lngCount - 1
    
        '�J���}��؂�ŕ������s���i�_�u���R�[�e�[�V�������J���}�Ή��j
        varRow = rlxCsvPart(strCsv(i))
        
        lngCol = ActiveCell.Column
        
        '�ŏ��̂P���
        If i = 0 Then
            '���ڐ��̕��A��̑I�������A������`���ɂ���B
            Set r = Range(Columns(lngCol), Columns(lngCol + UBound(varRow) - 1))
            r.NumberFormatLocal = "@"
        End If
        
        '�s�P�ʂɓ\��t��
        Range(Cells(lngRow, lngCol), Cells(lngRow, lngCol + UBound(varRow) - 1)).Value = varRow
    
        lngRow = lngRow + 1
    Next

    '���ׂē\��t�������Ԋu�𒲐�
    If r Is Nothing Then
    Else
        r.AutoFit
        Set r = Nothing
    End If
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE


End Sub
'--------------------------------------------------------------
'�@������̕����i�J���}�j
'--------------------------------------------------------------
Public Function rlxCsvPart(ByVal strBuf As String) As Variant
Attribute rlxCsvPart.VB_Description = "���[�N�V�[�g�֐��Ƃ��Ďg�p�ł��܂���B"
Attribute rlxCsvPart.VB_ProcData.VB_Invoke_Func = " \n19"

    Dim lngLen As Long
    Dim lngCnt As Long
    Dim i As Long
    Dim strCol As String
    
    Dim blnSw As Boolean
    
    Const C_QUAT As String = """"
    Const C_COMA As String = ","
    
    Dim Result() As Variant
    
    On Error GoTo ErrHandle
    
    lngLen = Len(strBuf)
    blnSw = False
    strCol = ""
    lngCnt = 0
    
    For i = 1 To lngLen
    
        Dim strChar As String
        strChar = Mid$(strBuf, i, 1)
        
        Select Case strChar
            Case C_QUAT
                If blnSw Then
                    blnSw = False
                Else
                    blnSw = True
                End If
            Case C_COMA
                If blnSw Then
                    strCol = strCol & strChar
                Else
                    lngCnt = lngCnt + 1
                    ReDim Preserve Result(1 To lngCnt)
                    Result(lngCnt) = strCol
                    strCol = ""
                End If
            Case Else
                strCol = strCol & strChar
        End Select

    Next
    
    lngCnt = lngCnt + 1
    ReDim Preserve Result(1 To lngCnt)
    Result(lngCnt) = strCol

    rlxCsvPart = Result
    
    Exit Function
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Function
'--------------------------------------------------------------
'�@���L�u�b�N�̃��[�U���擾
'--------------------------------------------------------------
Sub getShareUsers()

    Dim Users As Variant
    Dim strBuf As String
    Dim i As Long
    
    On Error GoTo er
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    Users = ActiveWorkbook.UserStatus
    
    strBuf = "���݂���Book��ҏW���Ă��郆�[�U�F" & vbCrLf & vbCrLf
    For i = LBound(Users) To UBound(Users)
        strBuf = strBuf & rlxAscLeft(Users(i, 1) & Space(16), 16) & vbTab & Format(Users(i, 2), "yyyy/mm/dd hh:nn:ss") & vbTab
        Select Case Users(i, 3)
            Case 1
                strBuf = strBuf & "�r��"
            Case 2
                strBuf = strBuf & "���L"
        End Select
        strBuf = strBuf & vbCrLf
        
    Next i
    
    MsgBox strBuf, vbInformation, C_TITLE

    Exit Sub
er:
    MsgBox "���݂̃u�b�N�͔r���g�p�ł��B", vbExclamation, C_TITLE

End Sub

'--------------------------------------------------------------
'�@�P�[�f�[�^�捞�V�[�g�ďo(&T)
'--------------------------------------------------------------
Sub callTanpyo()
    On Error GoTo ErrHandle

    ThisWorkbook.Worksheets("�P�[�`���t�@�C���Ǎ���`�V�[�g").Copy
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�w���v�V�[�g�ďo(&T)
'--------------------------------------------------------------
Sub callHelp()
    On Error GoTo ErrHandle

    ThisWorkbook.Worksheets("HELP").Copy
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̍��V�t�g
'--------------------------------------------------------------
Sub ShiftLeft()
    On Error GoTo ErrHandle
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    SelectionShiftCell 0, -1
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̉E�V�t�g
'--------------------------------------------------------------
Sub ShiftRight()
    On Error GoTo ErrHandle
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    SelectionShiftCell 0, 1
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̏�V�t�g
'--------------------------------------------------------------
Sub ShiftUp()
    On Error GoTo ErrHandle
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    SelectionShiftCell -1, 0
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̉��V�t�g
'--------------------------------------------------------------
Sub ShiftDown()

    On Error GoTo ErrHandle
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    SelectionShiftCell 1, 0
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈̓V�t�g
'--------------------------------------------------------------
Private Sub SelectionShiftCell(ByVal lngRow As Long, ByVal lngCol As Long)
    
    Dim r As Range
    Dim c As Range
    
    On Error GoTo ErrHandle
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    For Each r In Selection.Areas
    
        Err.Clear
        On Error Resume Next
        If c Is Nothing Then
            If r.Offset(lngRow, lngCol) Is Nothing Then
                Exit Sub
            Else
                Set c = r.Offset(lngRow, lngCol)
            End If
        Else
            If r.Offset(lngRow, lngCol) Is Nothing Then
                Exit Sub
            Else
                Set c = Union(c, r.Offset(lngRow, lngCol))
            End If
        End If
    
    Next

    If c Is Nothing Then
    Else
        c.Select
    End If

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�Q�Ɨp���[�N�u�b�N�\��
'--------------------------------------------------------------
Public Sub createReferenceBook()

    Dim strActBook As String
    Dim strTmpBook As String

    Dim FS As Object
    Dim WB As Workbook
    Dim XL As Excel.Application

    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If
    
    
    If ActiveWorkbook.Path = "" Then
        MsgBox "���u�b�N�̃p�X���擾�ł��܂���B�ۑ����Ă���ēx���s���Ă��������B", vbExclamation, C_TITLE
        Exit Sub
    End If

    Dim blnResult As Boolean
    If frmReference.Start(blnResult) = vbCancel Then
        Exit Sub
    End If


    Set FS = CreateObject("Scripting.FileSystemObject")

    strActBook = ActiveWorkbook.FullName
    strTmpBook = rlxGetTempFolder() & C_REF_TEXT & FS.getFileName(ActiveWorkbook.Name)

    FS.copyfile strActBook, strTmpBook

    If blnResult Then
        Set XL = New Excel.Application
        
        XL.visible = True
        
        Set WB = XL.Workbooks.Open(filename:=strTmpBook, ReadOnly:=True)
        AppActivate XL.Caption
    Else
        Set WB = Workbooks.Open(filename:=strTmpBook, ReadOnly:=True)
        AppActivate Application.Caption
    
    End If
    
    Set FS = Nothing

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@���݂̃u�b�N��ǂݎ���p�ŊJ���Ȃ���
'--------------------------------------------------------------
Public Sub changeReferenceBook()

    Dim strActBook As String
    Dim strTmpBook As String

    Dim FS As Object
    Dim WB As Workbook
    Dim XL As Excel.Application

    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If
    
    If ActiveWorkbook.Path = "" Then
        MsgBox "���u�b�N�̃p�X���擾�ł��܂���B�ۑ����Ă���ēx���s���Ă��������B", vbExclamation, C_TITLE
        Exit Sub
    End If

    Set FS = CreateObject("Scripting.FileSystemObject")

    If Left$(FS.getFileName(ActiveWorkbook.Name), 5) = C_REF_TEXT Then
        MsgBox "���łɎQ�Ɨp�̃u�b�N���J����Ă��܂��B", vbExclamation, C_TITLE
        Exit Sub
    End If
    
    Set WB = ActiveWorkbook

    strActBook = ActiveWorkbook.FullName
    strTmpBook = rlxGetTempFolder() & C_REF_TEXT & FS.getFileName(ActiveWorkbook.Name)

    FS.copyfile strActBook, strTmpBook

    WB.Close

    Workbooks.Open filename:=strTmpBook, ReadOnly:=True
    AppActivate Application.Caption
    
    Set FS = Nothing
    Set WB = Nothing
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�Q�Ɨp���[�N�u�b�N�\��
'--------------------------------------------------------------
Public Sub OpenReferenceBook()

    Dim strActBook As String
    Dim strTmpBook As String
    Dim strFile As String
    
    On Error GoTo ErrHandle
    
    SetMyDocument
    strFile = Application.GetOpenFilename(, , "�Q�ƃ��[�N�u�b�N�I��", , False)
    If strFile = "False" Then
        '�t�@�C�������w�肳��Ȃ������ꍇ
        Exit Sub
    End If
    
    '�t�@�C���̑��݃`�F�b�N
    If rlxIsFileExists(strFile) Then
    Else
        MsgBox "�t�@�C�������݂��܂���B", vbExclamation, C_TITLE
        Exit Sub
    End If

    Dim blnResult As Boolean
    If frmReference.Start(blnResult) = vbCancel Then
        Exit Sub
    End If


    Dim FS As Object
    Dim WB As Workbook
    Dim XL As Excel.Application

    Set FS = CreateObject("Scripting.FileSystemObject")

    strActBook = strFile
    strTmpBook = rlxGetTempFolder() & C_REF_TEXT & FS.getFileName(strFile)

    FS.copyfile strActBook, strTmpBook

    If blnResult Then
        Set XL = New Excel.Application
        
        XL.visible = True
        
        Set WB = XL.Workbooks.Open(filename:=strTmpBook, ReadOnly:=True)
        AppActivate XL.Caption
    Else
        Set WB = Workbooks.Open(filename:=strTmpBook, ReadOnly:=True)
        AppActivate Application.Caption
    End If
    
    
    Set FS = Nothing

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub
'--------------------------------------------------------------
'�@2003�݊��F(�w�i�F)
'--------------------------------------------------------------
Sub LegacyBackColor()

    Dim lngColor As Long
    
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    lngColor = Selection.Interior.Color
    If frmColor.Start(lngColor) = vbCancel Then
        Exit Sub
    End If
    
    Selection.Interior.Color = lngColor
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@2003�݊��F(�����F)
'--------------------------------------------------------------
Sub LegacyFontColor()

    Dim lngColor As Long
    
    On Error GoTo ErrHandle
    
    If checkInit() <> vbOK Then
        Exit Sub
    End If
  
    lngColor = Selection.Font.Color
    If frmColor.Start(lngColor) = vbCancel Then
        Exit Sub
    End If
    
    Selection.Font.Color = lngColor
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
Private Function checkInit() As Long

    On Error GoTo ErrHandle

    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        checkInit = vbCancel
        Exit Function
    End If
    
    checkInit = vbOK
    
    Exit Function
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Function
'--------------------------------------------------------------
'�@����v���r���[
'--------------------------------------------------------------
Sub execPreview()
    On Error Resume Next
    ActiveWindow.SelectedSheets.PrintOut preview:=True
End Sub
Sub verticalLine()

    Dim e As SelectionFormatBoader
    
    Set e = New SelectionFormatBoader
    
    e.BoadersIndex = xlInsideVertical
    e.LineStyle = xlContinuous
    e.Weight = xlThin
    
    e.Run
    
    Set e = Nothing
    
End Sub
'--------------------------------------------------------------
'�@�������g�O��
'--------------------------------------------------------------
Sub verticalLineToggle()
    On Error Resume Next
    setLineStyle Selection.Borders(xlInsideVertical)
End Sub
'--------------------------------------------------------------
'�@�g���g�O��
'--------------------------------------------------------------
Sub aroundLineToggle()

    Dim ret As Long
    On Error Resume Next
    With Selection.Borders(xlEdgeTop)
        Select Case True
            Case .LineStyle = xlLineStyleNone
                ret = 0
            Case .LineStyle = xlContinuous And .Weight = xlThin
                ret = 1
            Case Else
                ret = 2
        End Select
        
        ret = ret + 1
        If ret > 2 Then
            ret = 0
        End If
        
    End With
    
    With Selection.Borders(xlEdgeTop)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case 1
                .LineStyle = xlContinuous
                .Weight = xlThin
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlMedium
        End Select
    End With
    With Selection.Borders(xlEdgeLeft)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case 1
                .LineStyle = xlContinuous
                .Weight = xlThin
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlMedium
        End Select
    End With
    With Selection.Borders(xlEdgeRight)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case 1
                .LineStyle = xlContinuous
                .Weight = xlThin
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlMedium
        End Select
    End With
    With Selection.Borders(xlEdgeBottom)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case 1
                .LineStyle = xlContinuous
                .Weight = xlThin
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlMedium
        End Select
    End With
    
End Sub
'--------------------------------------------------------------
'�@�g���g�O��
'--------------------------------------------------------------
Sub tableLineToggle()

    Dim ret As Long
    On Error Resume Next
    With Selection.Borders(xlEdgeTop)
        Select Case True
            Case .LineStyle = xlLineStyleNone
                ret = 0
            Case Else
                ret = 1
        End Select
        
        ret = ret + 1
        If ret > 1 Then
            ret = 0
        End If
        
    End With
    
    With Selection.Borders(xlEdgeTop)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeLeft)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeRight)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeBottom)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlInsideHorizontal)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
End Sub
'--------------------------------------------------------------
'�@�g���g�O��
'--------------------------------------------------------------
Sub winLineToggle()
    Dim ret As Long
    On Error Resume Next
    With Selection.Borders(xlEdgeTop)
        Select Case True
            Case .LineStyle = xlLineStyleNone
                ret = 0
            Case Else
                ret = 1
        End Select
        
        ret = ret + 1
        If ret > 1 Then
            ret = 0
        End If
        
    End With
    
    With Selection.Borders(xlEdgeTop)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeLeft)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeRight)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlEdgeBottom)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlInsideHorizontal)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    With Selection.Borders(xlInsideVertical)
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
End Sub
'--------------------------------------------------------------
'�@����������
'--------------------------------------------------------------
Sub verticalNoLine()

    Dim e As SelectionFormatBoader
    
    Set e = New SelectionFormatBoader
    
    e.BoadersIndex = xlInsideVertical
    e.LineStyle = xlNone
    
    e.Run
    
    Set e = Nothing
    
End Sub
'--------------------------------------------------------------
'�@��������
'--------------------------------------------------------------
Sub HorizontalLine()
    
    Dim e As SelectionFormatBoader
    
    Set e = New SelectionFormatBoader
    
    e.BoadersIndex = xlInsideHorizontal
    e.LineStyle = xlContinuous
    e.Weight = xlThin
    
    e.Run
    
    Set e = Nothing
    
End Sub
'--------------------------------------------------------------
'�@�������g�O��
'--------------------------------------------------------------
Sub HorizontalLineToggle()
    On Error Resume Next
    setLineStyle Selection.Borders(xlInsideHorizontal)
End Sub
'--------------------------------------------------------------
'�@����������
'--------------------------------------------------------------
Sub HorizontalNoLine()
    
    Dim e As SelectionFormatBoader
    
    Set e = New SelectionFormatBoader
    
    e.BoadersIndex = xlInsideHorizontal
    e.LineStyle = xlNone
    
    e.Run
    
    Set e = Nothing
    
End Sub
Private Sub setLineStyle(ByRef r As Border)

    Dim ret As Long

    On Error GoTo ErrHandle
    
    With r
        Select Case True
            Case .LineStyle = xlLineStyleNone
                ret = 0
            Case .LineStyle = xlContinuous And .Weight = xlHairline
                ret = 1
            Case Else
                ret = 2
        End Select
        
        ret = ret + 1
        If ret > 2 Then
            ret = 0
        End If
        
        Select Case ret
            Case 0
                .LineStyle = xlLineStyleNone
            Case 1
                .LineStyle = xlContinuous
                .Weight = xlHairline
            Case Else
                .LineStyle = xlContinuous
                .Weight = xlThin
        End Select
    End With
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�l�r�S�V�b�N�X�|�C���g������
'--------------------------------------------------------------
Sub documentSheet()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    r.NumberFormatLocal = "@"
    
    With r.Font
        .Name = "�l�r �S�V�b�N"
        .FontStyle = "�W��"
        .Size = 9
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ThemeColor = xlThemeColorLight1
        .TintAndShade = 0
        .ThemeFont = xlThemeFontNone
    End With
    
End Sub
'--------------------------------------------------------------
'�@���C���I�X�|�C���g������
'--------------------------------------------------------------
Sub documentSheetMeiryo()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    r.NumberFormatLocal = "@"
    
    With r.Font
        .Name = "���C���I"
        .FontStyle = "�W��"
        .Size = 9
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ThemeColor = xlThemeColorLight1
        .TintAndShade = 0
        .ThemeFont = xlThemeFontNone
    End With
    
End Sub
'--------------------------------------------------------------
'�@Meiryo UI �X�|�C���g������
'--------------------------------------------------------------
Sub documentSheetMeiryoUI()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    r.NumberFormatLocal = "@"
    
    With r.Font
        .Name = "Meiryo UI"
        .FontStyle = "�W��"
        .Size = 9
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ThemeColor = xlThemeColorLight1
        .TintAndShade = 0
        .ThemeFont = xlThemeFontNone
    End With
    
End Sub
'--------------------------------------------------------------
'�@���ᎆ���Q
'--------------------------------------------------------------
Sub documentSheetHogan2()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells
    r.NumberFormatLocal = "@"
    r.ColumnWidth = 2
    
End Sub
'--------------------------------------------------------------
'�@�l�r�S�V�b�N�X�|�C���g���ᎆ���Q
'--------------------------------------------------------------
Sub documentSheetHogan2Gothic9()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells
    r.NumberFormatLocal = "@"
    r.ColumnWidth = 2
    
    With r.Font
        .Name = "�l�r �S�V�b�N"
        .FontStyle = "�W��"
        .Size = 9
    End With
    
End Sub
'--------------------------------------------------------------
'�@�l�r�S�V�b�N�X�|�C���g��������ᎆ���Q
'--------------------------------------------------------------
Sub documentSheetHogan2Gothic9Str()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    r.NumberFormatLocal = "@"
    r.ColumnWidth = 2
    
    With r.Font
        .Name = "�l�r �S�V�b�N"
        .FontStyle = "�W��"
        .Size = 9
    End With
    
End Sub
'--------------------------------------------------------------
'�@�l�r�S�V�b�N�P�P�|�C���g���ᎆ���Q
'--------------------------------------------------------------
Sub documentSheetHogan2Gothic11()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells
    r.NumberFormatLocal = "@"
    r.ColumnWidth = 2
    
    With r.Font
        .Name = "�l�r �S�V�b�N"
        .FontStyle = "�W��"
        .Size = 11
    End With
    
End Sub
'--------------------------------------------------------------
'�@�l�r�S�V�b�N�P�P�|�C���g��������ᎆ���Q
'--------------------------------------------------------------
Sub documentSheetHogan2Gothic11Str()

    Dim r As Range
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    r.NumberFormatLocal = "@"
    r.ColumnWidth = 2
    
    With r.Font
        .Name = "�l�r �S�V�b�N"
        .FontStyle = "�W��"
        .Size = 11
    End With
    
End Sub
'--------------------------------------------------------------
'�@���[�U��`���ᎆ
'--------------------------------------------------------------
Sub documentSheetUser()

    Dim r As Range
    Dim strFont As String
    Dim strPoint As String
    Dim strCol As String
    Dim strRow As String
    Dim blnBunrui As Boolean
    
    On Error Resume Next
    
    Set r = ActiveSheet.Cells

    blnBunrui = GetSetting(C_TITLE, "FormatCell", "Bunrui", False)
    strFont = GetSetting(C_TITLE, "FormatCell", "Font", "�l�r �S�V�b�N")
    strPoint = GetSetting(C_TITLE, "FormatCell", "Point", "9")
    strCol = GetSetting(C_TITLE, "FormatCell", "Col", "8.5")
    strRow = GetSetting(C_TITLE, "FormatCell", "Row", "14.25")

    If blnBunrui Then
        r.NumberFormatLocal = "G/�W��"
    Else
        r.NumberFormatLocal = "@"
    End If
    
    If GetSetting(C_TITLE, "FormatCell", "Size", False) Then
        r.ColumnWidth = Val(strCol)
    End If
    If GetSetting(C_TITLE, "FormatCell", "Height", False) Then
        r.RowHeight = Val(strRow)
    End If
        
    
    With r.Font
        .Name = strFont
        .FontStyle = "�W��"
        .Size = Val(strPoint)
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ThemeColor = xlThemeColorLight1
        .TintAndShade = 0
        .ThemeFont = xlThemeFontNone
    End With
    
End Sub
'--------------------------------------------------------------
' �s��̓���ւ�
'--------------------------------------------------------------
Sub selTranspose()

    Dim sourceRange As Range
    Dim destRange As Range
    Dim rr As Range
    Dim sel As Range

    On Error GoTo e

    Application.ScreenUpdating = False

    ThisWorkbook.Worksheets("Undo").Cells.Clear
    
    Set sourceRange = Selection
    Set destRange = ThisWorkbook.Worksheets("Undo").Range(Selection.Address)
    
    For Each rr In sourceRange.Areas
        rr.Copy destRange.Worksheet.Range(rr.Address)
    Next

    sourceRange.Clear

    For Each rr In destRange.Areas
        rr.Copy
        Dim lngPos As Long
        Dim s As String
        
        lngPos = InStr(rr.Address, ":")
        If lngPos = 0 Then
            s = rr.Address
        Else
            s = Mid(rr.Address, 1, lngPos - 1)
        End If
        sourceRange.Worksheet.Range(s).PasteSpecial Paste:=xlPasteAll, Operation:=xlNone, SkipBlanks:=False, Transpose:=True
        If sel Is Nothing Then
            Set sel = Selection
        Else
            Set sel = Union(sel, Selection)
        End If
    Next
    
    sel.Select
    Application.CutCopyMode = False
e:
    Application.ScreenUpdating = True

End Sub

'--------------------------------------------------------------
'�@�V�[�g����A1�Z���ɓ\��t��
'--------------------------------------------------------------
Sub setA1SheetName()

    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
            
    If ActiveSheet Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃV�[�g��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
    
    ActiveSheet.Cells(1, 1).Value = ActiveSheet.Name

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�V�[�g����A1�Z���ɓ\��t��(ALL)
'--------------------------------------------------------------
Sub setA1SheetAll()

    Dim WS As Worksheet
    Dim strBuf As String
  
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "�A�N�e�B�u�ȃu�b�N��������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If
  
    strBuf = ""
    For Each WS In Worksheets
            
        If WS.visible = xlSheetVisible Then
            WS.Cells(1, 1).Value = WS.Name
        End If
    Next

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@��I��
'--------------------------------------------------------------
Sub selectionTop()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlUp)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@���I��
'--------------------------------------------------------------
Sub selectionLeft()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlToLeft)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�E�I��
'--------------------------------------------------------------
Sub selectionRight()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlToRight)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@���I��
'--------------------------------------------------------------
Sub selectionDown()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlDown)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@����I��
'--------------------------------------------------------------
Sub selectionLeftTop()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlUp)).Select
    Range(Selection, Selection.End(xlToLeft)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�E���I��
'--------------------------------------------------------------
Sub selectionRightDown()
    On Error GoTo ErrHandle
    Range(Selection, Selection.End(xlToRight)).Select
    Range(Selection, Selection.End(xlDown)).Select
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�^�O�W�����v�i�J�[�\���ʒu�̏�񂩂�Excel���J���Z����I���j
'--------------------------------------------------------------
Sub tagJump()

    Const C_SEARCH_NO As Long = 1
    Const C_SEARCH_BOOK As Long = 2
    Const C_SEARCH_SHEET As Long = 3
    Const C_SEARCH_ADDRESS As Long = 4
    Const C_SEARCH_STR As Long = 5

    Dim WB As Workbook
    Dim WS As Worksheet
    Dim strBook As String
    Dim strSheet As String
    Dim strAddress As String

    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If

    strBook = Cells(ActiveCell.Row, C_SEARCH_BOOK).Value
    If Len(strBook) = 0 Then
        Exit Sub
    End If
    strSheet = Cells(ActiveCell.Row, C_SEARCH_SHEET).Value
    If Len(strSheet) = 0 Then
        Exit Sub
    End If
    strAddress = Cells(ActiveCell.Row, C_SEARCH_ADDRESS).Value
    If Len(strAddress) = 0 Then
        Exit Sub
    End If

    On Error Resume Next
    Set WB = Workbooks.Open(filename:=strBook)
    AppActivate Application.Caption

    Set WS = WB.Worksheets(strSheet)
    WS.Select
    
    WS.Range(strAddress).Select
    WS.Shapes.Range(strAddress).Select

    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̕���
'--------------------------------------------------------------
Sub saveRange()

    Dim strBuf As String
    Dim strBuf2 As String
    
    Dim strRange() As String
    Dim strSaveRange As String
    Dim lngCount As Long
    Dim i As Long
    
    On Error GoTo ErrHandle
    
    strSaveRange = Selection.Address(RowAbsolute:=False, ColumnAbsolute:=False)
    strBuf = strSaveRange
    
    strBuf2 = GetSetting(C_TITLE, "ReSelect", "Range", "")
    strRange = Split(strBuf2, vbTab)
    
    lngCount = 1
    For i = LBound(strRange) To UBound(strRange)
        If strRange(i) <> strSaveRange Then
            strBuf = strBuf & vbTab & strRange(i)
            lngCount = lngCount + 1
            '���X�g�͍ő�P�O
            If lngCount >= 10 Then
                Exit For
            End If
        End If
    Next
    SaveSetting C_TITLE, "ReSelect", "Range", strBuf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@���C�ɓ���̒ǉ�
'--------------------------------------------------------------
Sub addFavorite()

    Dim strBuf As String
    
    Dim strBooks() As String
    Dim strBook As String
    Dim lngCount As Long
    Dim i As Long
    
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If
    
    strBook = ActiveWorkbook.FullName
    
    If Not rlxIsFileExists(strBook) Then
        MsgBox "�u�b�N�����݂��܂���B�ۑ����Ă��珈�����s���Ă��������B", vbOKOnly + vbExclamation, C_TITLE
        Exit Sub
    End If

    strBuf = GetSetting(C_TITLE, "Favirite", "FileList", "")
    strBooks = Split(strBuf, vbVerticalTab)
    
    For i = LBound(strBooks) To UBound(strBooks)
        If LCase(Split(strBooks(i), vbTab)(0)) = LCase(strBook) Then
            MsgBox "���łɓo�^����Ă��܂��B", vbOKOnly + vbExclamation, C_TITLE
            Exit Sub
        End If
    Next
    
    If Len(strBuf) = 0 Then
        strBuf = strBook
    Else
        strBuf = strBuf & vbVerticalTab & strBook
    End If
    
    SaveSetting C_TITLE, "Favirite", "FileList", strBuf
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
    
End Sub
'--------------------------------------------------------------
'�@�����[�N�V�[�g�\��
'--------------------------------------------------------------
Sub nextWorksheet()

    Dim i As Long
    
    On Error GoTo ErrHandle
    
    If ActiveSheet Is Nothing Then
        Exit Sub
    End If
    
    For i = ActiveSheet.Index + 1 To ActiveWorkbook.Sheets.count
        If ActiveWorkbook.Sheets(i).visible = xlSheetVisible Then
            ActiveWorkbook.Sheets(i).Select
            Exit For
        End If
    Next
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�O���[�N�V�[�g�\��
'--------------------------------------------------------------
Sub prevWorksheet()
    
    Dim i As Long
    
    On Error GoTo ErrHandle
    
    If ActiveSheet Is Nothing Then
        Exit Sub
    End If
    For i = ActiveSheet.Index - 1 To 1 Step -1
        If ActiveWorkbook.Sheets(i).visible = xlSheetVisible Then
            ActiveWorkbook.Sheets(i).Select
            Exit For
        End If
    Next
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�����[�N�u�b�N�\��
'--------------------------------------------------------------
Sub nextWorkbook()

    Dim i As Long
    Dim blnFind As Boolean
    
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If
    
    blnFind = False
    
    For i = 1 To Workbooks.count
        If blnFind Then
            Workbooks(i).Activate
            Exit For
        End If
        If UCase(ActiveWorkbook.Name) = UCase(Workbooks(i).Name) Then
            blnFind = True
        End If
    Next
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�O���[�N�u�b�N�\��
'--------------------------------------------------------------
Sub prevWorkbook()

    Dim i As Long
    Dim blnFind As Boolean
    
    On Error GoTo ErrHandle
    
    If ActiveWorkbook Is Nothing Then
        Exit Sub
    End If
    
    blnFind = False
    
    For i = Workbooks.count To 1 Step -1
        If blnFind Then
            Workbooks(i).Activate
            Exit For
        End If
        If UCase(ActiveWorkbook.Name) = UCase(Workbooks(i).Name) Then
            blnFind = True
        End If
    Next
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�ڎ��쐬
'--------------------------------------------------------------
Sub createContentsEx()

    Const C_NAME As String = "�ڎ�"
    Const C_NO As Long = 1
    Const C_SHEET_NAME As Long = 2
    Const C_PAPER_SIZE As Long = 3
    Const C_PAGES As Long = 4
    Const C_HEAD_ROW = 2
    Const C_START_ROW = 3

    Dim WB As Workbook
    Dim WS As Worksheet
    Dim s As Worksheet
    Dim lngCount As Long

    Set WB = ActiveWorkbook
    
    '�V�[�g�̑��݃`�F�b�N
    For Each s In WB.Worksheets
        If s.Name = C_NAME Then
            If MsgBox("�u" & C_NAME & "�v�V�[�g�����ɑ��݂��܂��B�폜���Ă����ł����H", vbOKCancel + vbQuestion, C_TITLE) <> vbOK Then
                Exit Sub
            Else
                '���݂���ꍇ�͍폜
                Application.DisplayAlerts = False
                s.Delete
                Application.DisplayAlerts = True
            End If
        End If
    Next
    
    On Error GoTo e
    
    Application.ScreenUpdating = False
    Set WS = WB.Worksheets.Add(WB.Worksheets(1))
    WS.Name = C_NAME
    
    WS.Cells(1, 1).Value = "�u�b�N��:" & WB.Name
    
    lngCount = C_START_ROW
    WS.Cells(lngCount, C_NO).Value = "No."
    WS.Cells(lngCount, C_SHEET_NAME).Value = "�V�[�g��"
    WS.Cells(lngCount, C_PAPER_SIZE).Value = "�p��"
    WS.Cells(lngCount, C_PAGES).Value = "�y�[�W��"
    
    lngCount = lngCount + 1
    
    For Each s In WB.Worksheets
    
        If s.Name <> C_NAME Then
        
            If s.visible = xlSheetVisible Then
        
                WS.Cells(lngCount, C_NO).Value = lngCount - C_START_ROW
                WS.Cells(lngCount, C_SHEET_NAME).Value = s.Name
                
                WS.Hyperlinks.Add _
                    Anchor:=WS.Cells(lngCount, C_SHEET_NAME), _
                    Address:="", _
                    SubAddress:="'" & s.Name & "'!" & s.Cells(1, 1).Address, _
                    TextToDisplay:=s.Name
                
                Select Case s.PageSetup.PaperSize
                    Case xlPaperA3
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "A3"
                    Case xlPaperA4
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "A4"
                    Case xlPaperA5
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "A5"
                    Case xlPaperB4
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "B4"
                    Case xlPaperB5
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "B5"
                    Case Else
                        WS.Cells(lngCount, C_PAPER_SIZE).Value = "���̑�"
                End Select
                WS.Cells(lngCount, C_PAGES).Value = s.PageSetup.Pages.count
            
                lngCount = lngCount + 1
            End If
        End If
    Next

    WS.Columns("A").ColumnWidth = 5
    WS.Columns("B:D").AutoFit
    Dim r As Range
    Set r = WS.Cells(C_START_ROW, 1).CurrentRegion
    
    r.VerticalAlignment = xlTop
    r.Select
    
    execSelectionRowDrawGrid
    
    WS.Cells(lngCount, C_PAPER_SIZE).Value = "���v"
    WS.Cells(lngCount, C_PAGES).Value = "=SUM(D" & C_START_ROW + 1 & ":D" & lngCount - 1 & ")"

e:
    Application.ScreenUpdating = True
    Set r = Nothing

    Set WS = Nothing
    Set WB = Nothing

End Sub
'--------------------------------------------------------------
'�@�O���G�f�B�^�ҏW
'--------------------------------------------------------------
Sub cellEditExt()

    Dim strFileName As String
    Dim bytBuf() As Byte
    Const C_FF As Byte = &HFF
    Const C_FE As Byte = &HFE
    Dim strBuf As String
    Dim fp As Integer
    Dim lngsize As Long
    Dim WSH As Object
    Dim FS As Object
    Dim strBefore As String
    Dim strAfter As String
    Dim blnBOM As Boolean
    Dim strEditor As String
    Dim r As Range
    
    Dim strEncode As String
    
    Dim blnFormura As Boolean
    
    On Error GoTo e
    
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
'    If selection.count > 1 And selection.count <> selection(1, 1).MergeArea.count Then
    If Selection.CountLarge > 1 And Selection.CountLarge <> Selection(1, 1).MergeArea.count Then
        MsgBox "�����Z���I������Ă��܂��B�Z���͂P�̂ݑI�����Ă��������B", vbExclamation + vbOKOnly, C_TITLE
        Exit Sub
    End If
    
    frmInformation.Message = "�O���G�f�B�^�N�����ł��B��Ƃ��p������ꍇ�ɂ͊O���G�f�B�^���I�����Ă��������B"
    frmInformation.Show
    
    Set r = ActiveCell
    
    Dim strNotepad As String

    Set FS = CreateObject("Scripting.FileSystemObject")
    strNotepad = rlxAddFileSeparator(FS.GetSpecialFolder(0)) & "notepad.exe"
    
    strEditor = GetSetting(C_TITLE, "EditEx", "Editor", strNotepad)
    strEncode = GetSetting(C_TITLE, "EditEx", "Encode", C_SJIS)
    blnBOM = GetSetting(C_TITLE, "EditEx", "BOM", False)
    
    Dim utf8 As UTF8Encoding
    
    blnFormura = r.HasFormula
    If blnFormura Then
        strBuf = Replace(Replace(r.Formula, vbCrLf, vbLf), vbLf, vbCrLf)
    Else
        strBuf = Replace(Replace(r.Value, vbCrLf, vbLf), vbLf, vbCrLf)
    End If
    
    Select Case strEncode
        Case C_UTF16
            bytBuf = strBuf
        Case C_UTF8
            Set utf8 = New UTF8Encoding
            bytBuf = utf8.getBytes(strBuf)
        Case Else
            bytBuf = StrConv(strBuf, vbFromUnicode)
    End Select
    
    
    strFileName = rlxGetTempFolder() & "ActiveCell.tmp"
    
    fp = FreeFile()
    Open strFileName For Output As #fp
    Close fp
    
    fp = FreeFile()
    Open strFileName For Binary As #fp
    If blnBOM Then
        Put fp, , C_FF
        Put fp, , C_FE
    End If
    Put fp, , bytBuf
    Close fp
    
    strBefore = FS.GetFile(strFileName).DateLastModified
 
    Set WSH = CreateObject("WScript.Shell")
    
    On Error Resume Next
    Call WSH.Run("""" & strEditor & """ " & """" & strFileName & """", 1, True)
    If Err.Number <> 0 Then
        MsgBox "�G�f�B�^�̋N���Ɏ��s���܂����B�ݒ���m�F���Ă��������B", vbOKOnly + vbExclamation, C_TITLE
        GoTo e
    End If
    
    On Error GoTo e
    
    Set WSH = Nothing

    strAfter = FS.GetFile(strFileName).DateLastModified

    '�ύX����Ă���ꍇ
    If strBefore <> strAfter Then

        fp = FreeFile()
        Open strFileName For Binary As #fp
        
        lngsize = LOF(fp)
        
        If lngsize <> 0 Then
        
            ReDim bytBuf(0 To lngsize - 1)
            Get fp, , bytBuf
            
            If UBound(bytBuf) - LBound(bytBuf) + 1 >= 2 Then
                'BOM���܂܂�Ă���ꍇ�폜
                If bytBuf(0) = C_FF And bytBuf(1) = C_FE Then
                    bytBuf = MidB(bytBuf, 3)
                End If
            End If
            
            Select Case strEncode
                Case C_UTF16
                    strBuf = bytBuf
                Case C_UTF8
                    strBuf = utf8.GetString(bytBuf)
                Case Else
                    strBuf = StrConv(bytBuf, vbUnicode)
            End Select
            
            On Error Resume Next
            Err.Clear
            
            If Len(r.PrefixCharacter) > 0 Then
                r.Value = r.PrefixCharacter & Replace(strBuf, vbCrLf, vbLf)
            Else
                r.Value = Replace(strBuf, vbCrLf, vbLf)
            End If
            
            If Err.Number <> 0 Then
                MsgBox "���̐ݒ�Ɏ��s���܂����B�����������Ȃ��\��������܂��B", vbOKOnly + vbExclamation, C_TITLE
            End If
        Else
            r.Value = ""
        End If
        Close fp
    
    End If
    
e:
    On Error Resume Next
    Close
    
    Set FS = Nothing
    Set utf8 = Nothing
    
    Kill strFileName
    
    Unload frmInformation
    
End Sub
'--------------------------------------------------------------
'�@�I���摜�̕ۑ�
'--------------------------------------------------------------
Public Sub saveImage()

    Dim m_Width As Double, m_Height As Double
    Dim m_SavePath As String
    Dim argSavePath As String
    Dim strExt As String
    
    On Error GoTo ErrHandle
    
    If LCase(TypeName(Selection)) <> "picture" Then
        MsgBox "�摜���P�I�����Ă��������B", vbOKOnly + vbExclamation, C_TITLE
        Exit Sub
    End If
    
    argSavePath = Application.GetSaveAsFilename(, "PNG�t�@�C��(*.png), *.png,JPEG�t�@�C��(*.jpg), *.jpg,GIF�t�@�C��(*.gif), *.gif")
    If argSavePath = "False" Then
        Exit Sub
    End If
    
    If Len(argSavePath) > 0 Then
        Application.ScreenUpdating = False
        
        Selection.CopyPicture xlScreen, xlBitmap
        Call CopyClipboardSleep
        ActiveSheet.Paste
        With Selection
            m_Width = .width: m_Height = .Height
            .CopyPicture xlScreen, xlBitmap
            Call CopyClipboardSleep
            .Delete
        End With
        
        On Error Resume Next
        With ActiveSheet.ChartObjects.Add(0, 0, m_Width, m_Height).Chart
            .Paste
            .ChartArea.Border.LineStyle = 0
            .Export argSavePath, UCase(Right$(argSavePath, 3))
            .Parent.Delete
        End With
        On Error GoTo 0
        
        Application.ScreenUpdating = True
    End If
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�I��͈͂̌���
'--------------------------------------------------------------
Sub swapAreas()

    '�ϐ��錾
    Dim r As Range
    Dim blnRange As Boolean
    
    blnRange = False
    Select Case True
        Case ActiveWorkbook Is Nothing
        Case ActiveCell Is Nothing
        Case Selection Is Nothing
        Case TypeOf Selection Is Range
            blnRange = True
        Case Else
    End Select
    If blnRange Then
    Else
        MsgBox "�I��͈͂�������܂���B", vbCritical, C_TITLE
        Exit Sub
    End If

    If Selection.CountLarge > C_MAX_CELLS Then
        MsgBox "��ʂ̃Z�����I������Ă��܂��B " & C_MAX_CELLS & "�ȉ��ɂ��Ă��������B", vbExclamation + vbOKOnly, C_TITLE
        Exit Sub
    End If
    
    If Selection.Areas.count <> 2 Then
        MsgBox "�Q�͈̔͂�I�����Ă��������B", vbExclamation + vbOKOnly, C_TITLE
        Exit Sub
    End If
    
    If Selection.Areas(1).Rows.count <> Selection.Areas(2).Rows.count Or _
       Selection.Areas(1).Columns.count <> Selection.Areas(2).Columns.count Then
        MsgBox "�Q�͈̔͂̏c���T�C�Y�͓����ɂ��Ă��������B", vbExclamation + vbOKOnly, C_TITLE
        Exit Sub
    End If
    

    Dim strAddress As String
    
    strAddress = Selection.Address
    
    ThisWorkbook.Worksheets("Undo").Cells.Clear
    
    Set mUndo.sourceRange = Selection
    Set mUndo.destRange = ThisWorkbook.Worksheets("Undo").Range(Selection.Address)
    
    Dim rr As Range
    For Each rr In mUndo.sourceRange.Areas
        rr.Copy mUndo.destRange.Worksheet.Range(rr.Address)
    Next
    
    On Error Resume Next
    
    Application.ScreenUpdating = False
    
    '�G���A����������B
    mUndo.destRange.Worksheet.Range(mUndo.sourceRange.Areas(2).Address).Copy mUndo.sourceRange.Areas(1)
    mUndo.destRange.Worksheet.Range(mUndo.sourceRange.Areas(1).Address).Copy mUndo.sourceRange.Areas(2)
    
    Application.ScreenUpdating = True
    
    ActiveSheet.Range(strAddress).Select
    
    'Undo
    Application.OnUndo "Undo", "execUndo"
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'  �������Ȃ��֐�(�L�[�����p)
'--------------------------------------------------------------
Sub nop()

End Sub
'--------------------------------------------------------------
'�@�V���[�g�J�b�g�L�[�����ݒ�
'--------------------------------------------------------------
Sub setShortCutKey()
    
    Dim strList() As String
    Dim strKey() As String
    Dim strResult As String
    Dim lngMax As Long
    Dim i As Long
    
    Const C_ON As String = "1"
    
    On Error GoTo ErrHandle
    
    strResult = GetSetting(C_TITLE, "ShortCut", "KeyList", "")
    strList = Split(strResult, vbVerticalTab)

    lngMax = UBound(strList)

    For i = 0 To lngMax
        strKey = Split(strList(i) & vbTab & C_ON, vbTab)
        If strKey(6) = C_ON Then
            If InStr(strKey(5), "RunMso") > 0 Then
                Application.OnKey strKey(2), strKey(5)
            Else
                Application.OnKey strKey(2), "'execOnKey """ & strKey(5) & """,""" & strKey(4) & """'"
            End If
        End If
    Next
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE
End Sub
'--------------------------------------------------------------
'�@�V���[�g�J�b�g�L�[�̍폜
'--------------------------------------------------------------
Sub removeShortCutKey()

    Dim strList() As String
    Dim strKey() As String
    Dim strResult As String
    Dim lngMax As Long
    Dim i As Long
    
    On Error Resume Next

'    '�L�[���̍폜
    strResult = GetSetting(C_TITLE, "ShortCut", "KeyList", "")
    strList = Split(strResult, vbVerticalTab)

    lngMax = UBound(strList)

    For i = 0 To lngMax
        strKey = Split(strList(i), vbTab)
        Application.OnKey strKey(2)
    Next

End Sub
'--------------------------------------------------------------
'�@���y�[�W�̒ǉ�
'--------------------------------------------------------------
Sub addPageBreak()

    On Error Resume Next

    ActiveWindow.SelectedSheets.HPageBreaks.Add Before:=ActiveCell

End Sub
'--------------------------------------------------------------
'�@���y�[�W�̑S�폜
'--------------------------------------------------------------
Sub resetPageBreak()

    On Error Resume Next

    ActiveSheet.ResetAllPageBreaks

End Sub
'--------------------------------------------------------------
'�@���y�[�W�̍폜
'--------------------------------------------------------------
Sub removePageBreak()

    On Error Resume Next

    Dim p As HPageBreak
    
    For Each p In ActiveWindow.SelectedSheets.HPageBreaks
        If p.Location.Row = ActiveCell.Row Then
            p.Delete
            Exit For
        End If
    Next
    
End Sub
'--------------------------------------------------------------
'�@�N���b�v�{�[�h����t�@�C�����̓\��t��
'--------------------------------------------------------------
Sub getFileNameFromClipboard()

    Dim files As Variant
    Dim strBuf As String
    
    On Error GoTo ErrHandle
  
    If ActiveCell Is Nothing Then
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    
    strBuf = rlxGetFileNameFromCli()
    
    If strBuf = "" Then
        Exit Sub
    End If
    
    files = Split(strBuf, vbTab)
    
    Dim i As Long
    For i = LBound(files) To UBound(files) Step 1
        ActiveCell.Offset(i, 0).Value = files(i)
    Next
    
    Application.ScreenUpdating = True
    Exit Sub
ErrHandle:
    Application.ScreenUpdating = True
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@�N���b�v�{�[�h��Excel�t�@�C�����J��
'--------------------------------------------------------------
Sub openFileNameFromClipboard()

    Dim strActBook As String
    Dim strTmpBook As String

    Dim FS As Object
    Dim WB As Workbooks
    Dim XL As Excel.Application

    On Error GoTo ErrHandle
    Dim files As Variant
    Dim strBuf As String
    Dim f As Variant
    
    On Error GoTo ErrHandle
  
    strBuf = rlxGetFileNameFromCli()
    
    If strBuf = "" Then
        Exit Sub
    End If
    
    files = Split(strBuf, vbTab)
    
    If IsEmpty(files) Then
        Exit Sub
    End If
    
    If UBound(files) + 1 > 10 Then
        If MsgBox(UBound(files) + 1 & "�t�@�C���w�肳��Ă��܂��B���s���܂����H", vbOKCancel + vbQuestion, C_TITLE) <> vbOK Then
            Exit Sub
        End If
    End If
    
    Dim blnResult As Boolean
    If frmReference.Start(blnResult) = vbCancel Then
        Exit Sub
    End If
        
    If blnResult Then
        Set XL = New Excel.Application
        XL.visible = True
        Set WB = XL.Workbooks
    Else
        Set WB = Workbooks
    End If
    
    Set FS = CreateObject("Scripting.FileSystemObject")
    
    For Each f In files
    
        If Not FS.FileExists(f) Then
            GoTo pass
        End If
            
        If Not rlxIsExcelFile(f) Then
            GoTo pass
        End If
            
        strTmpBook = rlxGetTempFolder() & C_REF_TEXT & FS.getFileName(f)
    
        FS.copyfile f, strTmpBook
    
        WB.Open filename:=strTmpBook, ReadOnly:=True
pass:
    Next
    
    Set FS = Nothing
    
    Exit Sub
ErrHandle:
    MsgBox "�G���[���������܂����B", vbOKOnly, C_TITLE

End Sub
'--------------------------------------------------------------
'�@���݂�Excel�t�@�C�����N���b�v�{�[�h�ɓ\��t��
'--------------------------------------------------------------
Sub copyCurrentExcel()

    Dim strFiles() As String
    Dim strFile As String
    
    strFile = ActiveWorkbook.FullName

    If (Not rlxIsFileExists(strFile)) Then
        MsgBox "�u�b�N���ۑ�����Ă��Ȃ��悤�ł��B" & vbCrLf & "�N���b�v�{�[�h�ւ̃R�s�[�𒆒f���܂����B", vbOKOnly + vbExclamation, C_TITLE
        Exit Sub
    End If
    
    If ActiveWorkbook.Saved = False Then
        If MsgBox("�u�b�N�ɕύX������܂��B�ۑ����܂����H", vbYesNo + vbQuestion, C_TITLE) = vbYes Then
            ActiveWorkbook.Save
        End If
    End If
        
    strFiles = Split(strFile, vbTab)
    SetCopyClipText strFiles
    
    MsgBox ActiveWorkbook.Name & "���N���b�v�{�[�h�ɃR�s�[���܂����B", vbOKOnly + vbInformation, C_TITLE

End Sub
'--------------------------------------------------------------
' ���΁̐�ΎQ�Ɣ���
'--------------------------------------------------------------
Function rlxGetFomuraRefType() As XlReferenceType

    Dim r As Range
    Dim lngExistRow As Long
    Dim lngExistCol As Long
    Dim strForm As String
    Dim i As Long
    
    '�s���̏ꍇ�Ƃ肠�����A���ΎQ��
    rlxGetFomuraRefType = xlRelative
    
    On Error Resume Next
    
    For Each r In Selection

        If r.Rows.Hidden = False And r.Columns.Hidden = False Then

            Select Case Left(r.FormulaLocal, 1)
                '���̏ꍇ
                Case "=", "+"
                    strForm = r.FormulaLocal
                    
                    Dim blnSw As Boolean
                    Dim blnFind As Boolean
                    blnSw = False
                    blnFind = False
                    
                    For i = 1 To Len(strForm)
                
                        Dim strChr As String
                        
                        strChr = Mid$(strForm, i, 1)
                        Select Case strChr
                            Case """"
                                If blnSw Then
                                    blnSw = False
                                Else
                                    blnSw = True
                                End If
                                
                                blnFind = False
                            Case "$"
                                blnFind = True
                            Case Else
                                If blnFind Then
                                    Select Case strChr
                                        Case "A" To "Z"
                                            lngExistCol = lngExistCol + 1
                                        Case "0" To "9"
                                            lngExistRow = lngExistRow + 1
                                    End Select
                                End If
                            
                                blnFind = False
                        End Select
                
                    Next
                    
                    Select Case True
                        Case lngExistCol > 0 And lngExistRow > 0
                            rlxGetFomuraRefType = xlAbsolute
                        Case lngExistCol > 0
                            rlxGetFomuraRefType = xlRelRowAbsColumn
                        Case lngExistRow > 0
                            rlxGetFomuraRefType = xlAbsRowRelColumn
                        Case Else
                            rlxGetFomuraRefType = xlRelative
                    End Select
                    
                    Exit Function
                Case Else
            End Select
            
        End If
    Next
                    
End Function
'--------------------------------------------------------------
' ���΁̐�΃g�O��
'--------------------------------------------------------------
Sub toggleAbsoluteFomura()

    Dim ref As XlReferenceType

    On Error Resume Next

    ref = rlxGetFomuraRefType()

    Select Case ref
        Case xlAbsolute
            execSelectionToAbsRowRelColumn
        Case xlRelRowAbsColumn
            execSelectionToRelative
        Case xlAbsRowRelColumn
            execSelectionToRelRowAbsColumn
        Case xlRelative
            execSelectionToAbsolute
    End Select

End Sub
'--------------------------------------------------------------
' A1��R1C1�g�O��
'--------------------------------------------------------------
Sub toggleReferenceStyle()

    On Error Resume Next

    If Application.ReferenceStyle = xlA1 Then
        Application.ReferenceStyle = xlR1C1
    Else
        Application.ReferenceStyle = xlA1
    End If

End Sub
'--------------------------------------------------------------
' ���O�̕\��
'--------------------------------------------------------------
Public Sub VisibleNames()

    Dim n As Object
    
    For Each n In ActiveWorkbook.Names
        If n.visible = False Then
            n.visible = True
        End If
    Next
    
    MsgBox "���ׂĂ̖��O�̒�`��\�����܂����B", vbOKOnly + vbInformation, C_TITLE

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�P
'--------------------------------------------------------------
Sub execMatome01()

    execMatome "1"

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�Q
'--------------------------------------------------------------
Sub execMatome02()

    execMatome "2"

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�R
'--------------------------------------------------------------
Sub execMatome03()

    execMatome "3"

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�S
'--------------------------------------------------------------
Sub execMatome04()

    execMatome "4"

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�T
'--------------------------------------------------------------
Sub execMatome05()

    execMatome "5"

End Sub
'--------------------------------------------------------------
' �܂Ƃߎ��s�{��
'--------------------------------------------------------------
Private Sub execMatome(ByVal strNo As String)
    
    Dim strResult As String
    Dim varLine As Variant
    Dim varCol As Variant
    Dim i As Long
    
    strResult = GetSetting(C_TITLE, "Combo", "ComboList" & strNo, "")
        
    varLine = Split(strResult, vbVerticalTab)
        
    For i = LBound(varLine) To UBound(varLine)
        varCol = Split(varLine(i), vbTab)
        Application.Run varCol(3)
    Next

End Sub
'--------------------------------------------------------------
' Excel�@�\���s
'--------------------------------------------------------------
Sub RunMso(ByVal strMso As String)

    On Error Resume Next
    
    Application.CommandBars.ExecuteMso strMso

End Sub
'--------------------------------------------------------------
' ���W�X�g����Export
'--------------------------------------------------------------
Sub RegExport()

    Dim strDat As String
    Const C_FF As Byte = &HFF
    Const C_FE As Byte = &HFE
    Dim filename As Variant
    Dim strReg As String
    
    Dim Reg, Locator, Service, SubKey, RegName, RegType
    Dim i As Long, j As Long, buf As String, RegData As String
    
    Dim fp As Integer
    
    SetMyDocument
    
    filename = Application.GetSaveAsFilename(InitialFileName:="RelaxTools-Addin.reg", FileFilter:="�o�^�t�@�C��,*.reg")
    If filename = False Then
        Exit Sub
    End If
    
    On Error GoTo err_Handle

    strReg = "HKEY_CURRENT_USER\SOFTWARE\VB and VBA Program Settings\RelaxTools-Addin"

    Set Locator = CreateObject("WbemScripting.SWbemLocator")
    Set Service = Locator.ConnectServer(vbNullString, "root\default")
    Set Reg = Service.Get("StdRegProv")
    
    Const HKEY_CURRENT_USER = &H80000001
    
    Const ROOT = "HKEY_CURRENT_USER\"
    Const key = "SOFTWARE\VB and VBA Program Settings\RelaxTools-Addin"
    
    Reg.EnumKey HKEY_CURRENT_USER, key, SubKey
    
    fp = FreeFile()
    Open filename For Output As fp
    Close fp
    
    fp = FreeFile()
    Open filename For Binary As fp
    
    Dim strBuf() As Byte
    
    Put fp, , C_FF
    Put fp, , C_FE
    
    strBuf = "Windows Registry Editor Version 5.00" & vbCrLf & vbCrLf
    Put fp, , strBuf
    
    strBuf = "[" & ROOT & key & "]" & vbCrLf
    Put fp, , strBuf
    
    For i = 0 To UBound(SubKey)
        
        Reg.EnumValues HKEY_CURRENT_USER, key & "\" & SubKey(i), RegName, RegType
            
        strBuf = vbCrLf & "[" & ROOT & key & "\" & SubKey(i) & "]" & vbCrLf
        Put fp, , strBuf
        
        For j = 0 To UBound(RegName)
        
            Select Case RegType(j)
                Case 1
                    Reg.GetStringValue HKEY_CURRENT_USER, key & "\" & SubKey(i), RegName(j), RegData
                Case Else
                    Reg.GetMultiStringValue HKEY_CURRENT_USER, key & "\" & SubKey(i), RegName(j), RegData
                
            End Select
        
            strDat = Replace(RegData, "\", "\\")
            
            strBuf = """" & RegName(j) & """=""" & strDat & """" & vbCrLf
            
            Put fp, , strBuf
        
        Next j
        
    Next i
    strBuf = vbCrLf
    Put fp, , strBuf
    Close fp
    
    Set Reg = Nothing
    Set Service = Nothing
    Set Locator = Nothing
    
    MsgBox "�o�^�t�@�C����ۑ����܂����B" & vbCrLf & "�ڍs��œo�^�t�@�C�������s����ƃ��W�X�g���ɔ��f����܂��B", vbOKOnly + vbInformation, C_TITLE
    Exit Sub
err_Handle:
    MsgBox "�o�^�t�@�C���̕ۑ��Ɏ��s���܂����B", vbOKOnly + vbInformation, C_TITLE
    
End Sub


