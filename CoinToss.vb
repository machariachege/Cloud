'Compiler version 11.0.50709.17929 for Microsoft (R) .NET Framework 4.5

Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text.RegularExpressions

Namespace CoinToss
    Public Class FlipCoin

  		Dim randomObject As New Random()
		Dim headcount As Integer
		Dim tailcount As Integer
  		Dim head As Integer
		Dim tail As Integer
		Dim count As Integer
		Dim toss As Integer
		Dim intrandomGen As New Random

  			head = 0
 			tail = 0
			tailcount = 0
			headcount = 0
	Private Sub flipButton_Click(ByVal sender As System.Object, ByVal e As 	System.EventArgs) Handles flipButton.Click

     		toss = intrandomGen.Next(0, 2)

  		If toss = 0 Then
			tailcount += tails + 1
			flipResultLabel.Text = "False"
		Else
			headcount += heads + 1
			flipResultLabel.Text = "True"
		End If

		count = count + 1

		headsTotalLabel.Text += CStr(headcount)
		tailsTotalLabel.Text += CStr(tailcount)

	End Sub
	End Class
End Namespace