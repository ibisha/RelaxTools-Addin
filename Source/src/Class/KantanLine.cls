VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "KantanLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'名前
Public Text As String

'外周
'Public OutSideLine As New rlxBorder
Public OutSideLine As Long

'行ヘッダの行数
Public HHeadLineCount As Long

'行ヘッダと行の間の線
'Public HHeadBorderLine As New rlxBorder
Public HHeadBorderLine As Long

'行ヘッダの色
Public HeadColor As Long

'明細色設定
Public EnableEvenColor As Boolean

'明細色
Public EvenColor As Long
'
'列ヘッダの行数
Public VHeadLineCount As Long

'列ヘッダの列の間の線
'Public VHeadBorderLine As New rlxBorder
Public VHeadBorderLine As Long

'縦中線
'Public VInsideLine As New rlxBorder
Public VInsideLine As Long

'横中線
'Public HInsideLine As New rlxBorder
Public HInsideLine As Long

'方眼紙設定
Public EnableHogan As Boolean

'行ヘッダ線の繰り返し
Public EnableHRepeat As Boolean

'列ヘッダ線の繰り返し
Public EnableVRepeat As Boolean

'方眼紙行自動設定
Public AuthoHogan As Boolean

'方眼紙判定行
Public HoganJudgeLineCount As Long


