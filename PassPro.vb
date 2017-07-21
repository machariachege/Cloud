'Compiler version 11.0.50709.17929 for Microsoft (R) .NET Framework 4.5

Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text.RegularExpressions

Namespace Pass
     Public Class PassPro
  
	Dim totalCost As Decimal
  	Dim passcost As Decimal

Private Sub cboPassType_SelectedIndexChanged(ByVal user As System.Object, ByVal e As System.EventArgs)
    Me.lstPassType.Items.Clear()

 
    Me.lblCostDisplay.Visible = True
   Me.lstPassType.Visible = True
   Me.btnClean.Visible = True
    Me.btnCalculate.Visible = True
   End Sub

Sub PassCost()
    Dim passType As Integer
    'Add List Items
    Me.lstPassType.Items.Add("Children Under 5 Free")
    Me.lstPassType.Items.Add("Seniors (60+) and Students $32.50")
    Me.lstPassType.Items.Add("Adults under 60 $43.25")
    Me.lstPassType.Items.Add("Pets $12")
    Me.lstPassType.Items.Add("Parking $10")

    If lstPassType.SelectedItem = "Children Under 5 Free" Then
      passType = 0
    End If

    If lstPassType.SelectedItem = "Seniors (60+) and Students $32.50" Then
      passType = 1
    End If

    If lstPassType.SelectedItem = "Adults under 60 $43.25" Then
      passType = 2
    End If

    If lstPassType.SelectedItem = "Pets $12" Then
      passType = 3
    End If

If lstPassType.SelectedItem = "Parking $10" Then
      passType = 4
    End If
  End Sub

 Private Function TicketCost(ByVal passType As Integer, ByVal passNum As Integer)
    totalCost = passNum * cost
    'Price Items for Ticket
    If passType = 0 Then
      passcost = 0D
    End If

    If passType = 1 Then
      passcost = 32.50D
    End If

    If passType = 2 Then
      passcost = 43.25D
    End If

    If passType = 3 Then
      passcost = 12D
    End If

If passType = 4 Then
      passcost = 10D
    End If

    Return totalCost
  End Function
End Class

End Namespace