'Compiler version 11.0.50709.17929 for Microsoft (R) .NET Framework 4.5

Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text.RegularExpressions

Namespace AccBalance
    Public Module Program
        Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
		Dim currentbalance As Decimal = 0D
		Dim sum As Decimal = TextBoxA.Text
		Dim check As Decimal = TextBoxA.Text
		Dim mainbalance As Decimal = TextBoxB.Text

		Try
			balance = Decimal.Parse(TextBoxA.Text)

			If RadioButton1.Checked Then
				currentbalance = CDec(TextBoxA.Text)
				mainbalance = balance
			ElseIf RadioButton2.Checked Then
				currentbalance = currentbalance - sum
				grandbalance = grandbalance + balance
			ElseIf RadioButton3.Checked Then
				currentbalance = mainbalance - 10D
				mainbalance = mainbalance + currentbalance
			End If


			If mainbalance <> 0 Then
				mainbalance = currentbalance

				TextBoxB.Refresh()
				TextBoxB.Text = mainbalance.ToString("c")

			End If
		Catch ex As Exception
			MessageBox.Show("Only numeric text allowed", "Input error", _
							MessageBoxButtons.OK, MessageBoxIcon.Exclamation)

		End Try
	End Sub

    End Module
End Namespace