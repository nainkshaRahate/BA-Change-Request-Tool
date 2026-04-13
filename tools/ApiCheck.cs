// Quick API inspection
using System;
using System.Reflection;
using System.Linq;

var dllPath = "/Users/dhammadeepborkar/.nuget/packages/microsoft.powerplatform.formulas.tools/0.8.27.35.117-preview/lib/net8.0/Microsoft.PowerPlatform.Formulas.Tools.dll";
var asm = Assembly.LoadFrom(dllPath);

Console.WriteLine("=== Types in Microsoft.PowerPlatform.Formulas.Tools ===");
foreach (var t in asm.GetExportedTypes())
{
    Console.WriteLine($"\n--- {t.FullName} ---");
    foreach (var m in t.GetMethods(BindingFlags.Public | BindingFlags.Static | BindingFlags.Instance).Where(m => !m.Name.StartsWith("get_") && !m.Name.StartsWith("set_")))
    {
        Console.WriteLine($"  {m.Name}({string.Join(", ", m.GetParameters().Select(p => p.ParameterType.Name))})");
    }
}
