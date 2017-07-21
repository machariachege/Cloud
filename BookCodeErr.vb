'Compiler version 11.0.50709.17929 for Microsoft (R) .NET Framework 4.5

Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text.RegularExpressions

Namespace BookCodeErr
  Sub Main()

Dim bookcode as string
Dim no1 no2 no3 as integer
Dim extensioncode as integer = no1 + no2 + no3
Dim errorcode as string

console.write(“enter book code: “)
bookcode = concsole.readline()

no1 = val(mid(bookcode, 3, 1))
no2 = val(mid(bookcode, 4, 1))
no3 = val(mid(bookcode, 5, 1))

errorcode = bookcode + “.” + str(extensioncode)

End sub

End Namespace