using System;
using var ms = System.IO.File.OpenRead("/Users/dhammadeepborkar/.nuget/packages/microsoft.powerplatform.formulas.tools/0.8.2735.117-preview/lib/net8.0/Microsoft.PowerPlatform.Formulas.Tools.dll");
var asm = System.Reflection.Assembly.LoadFrom("/Users/dhammadeepborkar/.nuget/packages/microsoft.powerplatform.formulas.tools/0.8.2735.117-preview/lib/net8.0/Microsoft.PowerPlatform.Formulas.Tools.dll");
foreach (var type in asm.GetExportedTypes().Take(30)) {
    Console.WriteLine(type.FullName);
}
