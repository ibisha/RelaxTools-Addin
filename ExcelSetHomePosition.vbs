'-------------------------------------------------------------------------------
' Excel�t�@�C���̃J�[�\�����z�[���|�W�V�����ɐݒ�
' 
' ExcelSetHomePosition.vbs
' Version 1.0.0
' 
' Copyright (c) 2015 Y.Watanabe
' 
' This software is released under the MIT License.
' http://opensource.org/licenses/mit-license.php
'-------------------------------------------------------------------------------
' ����m�F : Windows 7 + Excel 2010 / Windows 8 + Excel 2013
'-------------------------------------------------------------------------------
' for Used
' (1) �z�[���|�W�V�����ݒ肷��Excel�t�@�C���̃t�H���_�ɂ��̃X�N���v�g��z�u����B
' (2) �X�N���v�g�́u�g���q�v�u�ǂݎ��p�X���[�h�v��K�v�ɉ����ď���������B
' (3) �X�N���v�g�����s����B
' (4) ���ʂ��e�L�X�g�t�@�C���ŕ\������B
' 
'-------------------------------------------------------------------------------
    Option Explicit

    Dim objFs, strMsg, SH
    Dim objDic, XL, WB, FL, LogName
    dim varPatterns, strKey, varPass, p
    Dim IE
    Dim strTitle
    
    strTitle = "�z�[���|�W�V�����ݒ�"
    
    If MsgBox("���t�H���_�ȉ���Excel�t�@�C�����z�[���|�W�V�����ݒ肵�܂��B" & vbCrLf & "��낵���ł����H" & VbCrLf & VbCrLf & "�����񑩁�" & vbCrLf & "Excel�t�@�C���͎��O�Ƀo�b�N�A�b�v���Ă��������B", vbYesNo + vbQuestion, strTitle) = vbNo Then 
        WScript.Quit 
    End IF

    Set IE = WScript.CreateObject("InternetExplorer.Application")
 
    IE.Navigate "about:blank"
    Do While IE.busy
        WScript.Sleep(100)
    Loop
    Do While IE.Document.readyState <> "complete"
        WScript.Sleep(100)
    Loop
    IE.Document.body.innerHTML = "<b id=""msg"">�z�[���|�W�V�����ݒ蒆�ł�<br>���΂炭���҂�������...</b>"
    IE.AddressBar = False
    IE.ToolBar = False
    IE.StatusBar = False
    IE.Height = 120
    IE.Width = 300
    IE.Left = 0
    IE.Top = 0
    IE.Document.Title = strTitle
    IE.Visible = True
    
    On Error Resume Next

    Set objFs =  WScript.CreateObject("Scripting.FileSystemObject")
    Set objDic = WScript.CreateObject("Scripting.Dictionary")
    
    '--------------------------------------------------------------
    ' �������s���g���q�𐳋K�\���ŋL�q
    '--------------------------------------------------------------
    varPatterns = Array("\.xls$", "\.xlsx$", "\.xlsm$")
    
    '--------------------------------------------------------------
    ' �ǂݎ��p�X���[�h������ꍇ�͂����ɋL�q(�����w���)
    '--------------------------------------------------------------
    varPass = Array("", "", "")
    
    FileSearch objFs, objFs.GetParentFolderName(WScript.ScriptFullName), varPatterns, objDic

    LogName = objFs.GetBaseName(WScript.ScriptFullName) & ".txt"
    Set FL = objFs.CreateTextFile(LogName)

    FL.WriteLine "��=�z�[���|�W�V�����ݒ� �J�n(" & Now() & ")��="
    FL.WriteLine "�����t�@�C����:" & objDic.Count

    If objDic.Count > 0 Then
        
        Set XL = WScript.CreateObject("Excel.Application")

        For Each strKey In objDic.Keys
        
            '�p�X���[�h�w��̏ꍇ
            For Each p In varPass
                Err.Clear
                Set WB = XL.WorkBooks.Open(objDic(strKey),,False,,p,"",True,,,False)
                If Err.Number = 0 Then
                    Exit For
                End If
            Next
            
            Select Case True
                Case Err.Number <> 0
                    FL.WriteLine "�G���[ => " & objDic(strKey)
                    FL.WriteLine "          " & Err.Description
                    
                Case WB.ReadOnly 
  	                FL.WriteLine "�G���[ => " & objDic(strKey)
                    FL.WriteLine "          �u�b�N���ǂݎ���p�ł�"
                    
                Case Else
                    setAllA1 WB

                    XL.DisplayAlerts = False
                    WB.Save
                
                    If Err.Number <> 0 Or WB.Saved = False Then
                        FL.WriteLine "�G���[ => " & objDic(strKey)
                        FL.WriteLine "          " & Err.Description
                    Else
                        FL.WriteLine "������ => " & objDic(strKey)
                    End If
                
                    XL.DisplayAlerts = True
            End Select
            
            '�C���X�^���X������� Close
            If Not IsNothing(WB) Then
                WB.Close
                Set WB = Nothing
            End If
        Next

        XL.Quit

        Set XL = Nothing

    End If

    FL.WriteLine "��=�z�[���|�W�V�����ݒ� �I��(" & Now() & ")��="
    FL.Close
    Set FL = Nothing

    Set objDic = Nothing
    Set objFs =  Nothing

    With CreateObject("Shell.Application")
        .ShellExecute(LogName)
    End With

    IE.Quit
    'MsgBox "�������������܂����B", vbInformation + VbOkOnly, strTitle

'--------------------------------------------------------------
'�@���ׂẴV�[�g�̑I���ʒu���`�P�ɃZ�b�g
'--------------------------------------------------------------
Sub setAllA1(WB)

    Dim WS
    Dim WD

    For Each WS In WB.Worksheets
        If WS.visible Then
            WS.Activate
            WS.Range("A1").Activate
            WB.Windows(1).ScrollRow = 1
            WB.Windows(1).ScrollColumn = 1
            WB.Windows(1).Zoom = 100
        End If
    Next

    '�\�����̂P���ڂɂ���B
    For Each WS In WB.Worksheets
        If WS.visible  Then
            WS.Select
            Exit For
        End If
    Next

End Sub

'--------------------------------------------------------------
'�@�T�u�t�H���_����
'--------------------------------------------------------------
Private Sub FileSearch(objFs, strPath, varPatterns, objDic)

    Dim objfld
    Dim objfl
    Dim objSub
    Dim f, objRegx
    
    Set objfld = objFs.GetFolder(strPath)

    '�t�@�C�����擾
    For Each objfl In objfld.files
    
        Dim blnFind
        blnFind = False

	    Set objRegx = CreateObject("VBScript.RegExp")
        For Each f In varPatterns
            objRegx.Pattern = f
            If objRegx.Test(objfl.name) Then
                blnFind = True
                Exit For
            End If
        Next
	    Set objRegx = Nothing
        
        If blnFind Then
            objDic.Add objFs.BuildPath(objfl.ParentFolder.Path, objfl.name), objFs.BuildPath(objfl.ParentFolder.Path, objfl.name)
        End If
    Next
    
    '�T�u�t�H���_��������
    For Each objSub In objfld.SubFolders
        FileSearch objFs, objSub.Path, varPatterns, objDic
    Next

End Sub
