On Error Resume Next

Dim installPath 
Dim addInName 
Dim addInFileName 
Dim objExcel 
Dim objAddin

'�A�h�C������ݒ� 
addInName = "RelaxTools Addin" 
addInFileName = "Relaxtools.xlam"

Set objWshShell = CreateObject("WScript.Shell") 
Set objFileSys = CreateObject("Scripting.FileSystemObject")

IF Not objFileSys.FileExists(addInFileName) THEN
   MsgBox "Zip�t�@�C�����𓀂��Ă�����s���Ă��������B", vbExclamation, addInName 
   WScript.Quit 
END IF

IF MsgBox(addInName & " ���C���X�g�[�����܂����H", vbYesNo + vbQuestion, addInName) = vbNo Then 
  WScript.Quit 
End IF


'�C���X�g�[����p�X�̍쐬 
'(ex)C:\Users\[User]\AppData\Roaming\Microsoft\AddIns\[addInFileName] 
installPath = objWshShell.SpecialFolders("Appdata") & "\Microsoft\Addins\" & addInFileName

'�t�@�C���R�s�[(�㏑��) 
objFileSys.CopyFile  addInFileName ,installPath , True

Set objFileSys = Nothing

'Excel �C���X�^���X�� 
Set objExcel = CreateObject("Excel.Application") 
objExcel.Workbooks.Add

'�A�h�C���o�^ 
Set objAddin = objExcel.AddIns.Add(installPath, True) 
objAddin.Installed = True

'Excel �I�� 
objExcel.Quit
Set objAddin = Nothing 
Set objExcel = Nothing

IF Err.Number = 0 THEN 
   MsgBox "�A�h�C���̃C���X�g�[�����I�����܂����B", vbInformation, addInName 
ELSE 
   MsgBox "�G���[���������܂����B" & vbCrLF & "Excel���N�����Ă���ꍇ�͏I�����Ă��������B", vbExclamation, addInName 
End IF
Set objWshShell = Nothing 
