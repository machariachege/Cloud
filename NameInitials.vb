'Compiler version 11.0.50709.17929 for Microsoft (R) .NET Framework 4.5

Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text.RegularExpressions

Namespace NameIntitials
  Sub Main()
    
Dim initials1 initials2 initials3 initials4 initials5 As String
Dim name1 name2 name3 name4 name5 As String

console.write(“write name1: “) 
name1 = console.readline()
console.write(“write name2: “) 
name2 = console.readline()
console.write(“write name3: “) 
name3 = console.readline()
console.write(“write name4: “) 
name4 = console.readline()
console.write(“write name5: “) 
name6 = console.readline()
   
initials1 = name1.Substring(0, 1) & name1.Split(" ")(1).Substring(0, 1)
End Sub
initials2 = name2.Substring(0, 1) & name2.Split(" ")(1).Substring(0, 1)
End Sub
initials3 = name3.Substring(0, 1) & name3.Split(" ")(1).Substring(0, 1)
End Sub
initials4 = name4.Substring(0, 1) & name4.Split(" ")(1).Substring(0, 1)
End Sub
initials5 = name5.Substring(0, 1) & name5.Split(" ")(1).Substring(0, 1)


console.writeline(initials1 & vbnewline)
console.writeline(initials2 & vbnewline)
console.writeline(initials3 & vbnewline)
console.writeline(initials4 & vbnewline)
console.writeline(initials5 & vbnewline)

End Sub


End Namespace