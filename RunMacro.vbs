' -------------------------------------------------------------------------------
' RelaxTools-Addin �ʃv���Z�X���s Ver.1.0.0
' -------------------------------------------------------------------------------
' �C��
'   1.0.0 �V�K�쐬
' -------------------------------------------------------------------------------
On Error Resume Next
With CreateObject("Excel.Application")
    .Workbooks.Open CreateObject("WScript.Shell").SpecialFolders("Appdata") & "\Microsoft\Addins\Relaxtools.xlam"
    IF Wscript.Arguments.Count > 0 THEN
        .Run Wscript.Arguments(0)
    ELSE
        .Quit
    END IF
End With

