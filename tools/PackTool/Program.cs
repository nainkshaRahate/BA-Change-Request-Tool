// Power Apps Canvas App Pack Tool
using System;
using System.Reflection;
using Microsoft.PowerPlatform.Formulas.Tools;

var cmdArgs = Environment.GetCommandLineArgs();

Console.WriteLine($"Args count: {cmdArgs.Length}");
for (int i = 0; i < cmdArgs.Length; i++)
    Console.WriteLine($"  [{i}]: {cmdArgs[i]}");

if (cmdArgs.Length < 6)
{
    Console.WriteLine("Usage: dotnet PackTool.dll pack -i <source_dir> -o <output.msapp>");
    Environment.Exit(1);
}

var sourceDir = Path.GetFullPath(cmdArgs[3]);
var outputPath = Path.GetFullPath(cmdArgs[5]);

Console.WriteLine($"Loading sources from: {sourceDir}");

var dllPath = "/Users/dhammadeepborkar/.nuget/packages/microsoft.powerplatform.formulas.tools/0.8.2733.113-preview/lib/net8.0/Microsoft.PowerPlatform.Formulas.Tools.dll";
var asm = Assembly.LoadFrom(dllPath);

var canvasDocType = asm.GetType("Microsoft.PowerPlatform.Formulas.Tools.CanvasDocument");
var loadMethod = canvasDocType.GetMethod("LoadFromSources", new[] { typeof(string) });
var saveMethod = canvasDocType.GetMethod("SaveToMsApp", new[] { typeof(string) });

// Load from sources
Console.WriteLine("Loading canvas document from sources...");
var loadResult = loadMethod.Invoke(null, new object[] { sourceDir });
var loadTuple = ((CanvasDocument, ErrorContainer))loadResult;

var document = loadTuple.Item1;
var errors = loadTuple.Item2;

if (document == null)
{
    Console.WriteLine("Failed to load document:");
    Console.WriteLine(errors?.ToString() ?? "Unknown error");
    Environment.Exit(1);
}

Console.WriteLine("Document loaded successfully.");
Console.Out.Flush();

try
{
    // Save to msapp - use dynamic to get better exception info
    Console.Error.WriteLine($"Saving to: {outputPath}");
    Console.Error.Flush();

    dynamic doc = document;
    Console.Error.WriteLine("About to call SaveToMsApp...");
    Console.Error.Flush();
    ErrorContainer? saveResult = doc.SaveToMsApp(outputPath);
    Console.WriteLine("SaveToMsApp completed!");

    // Check if file was created
    if (!File.Exists(outputPath))
    {
        Console.WriteLine("ERROR: msapp file was not created");
        if (saveResult != null && saveResult.Count > 0)
        {
            using var sw = new StringWriter();
            saveResult.Write(sw);
            Console.WriteLine("Errors from SaveToMsApp:");
            Console.WriteLine(sw.ToString());
        }
        Environment.Exit(1);
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Exception during save: {ex.GetType().Name}");
    Console.WriteLine($"Message: {ex.Message}");
    Console.WriteLine(ex.StackTrace);
    if (ex.InnerException != null)
    {
        Console.WriteLine($"Inner: {ex.InnerException.Message}");
    }
    Environment.Exit(1);
}

// Check if file exists
if (!File.Exists(outputPath))
{
    Console.WriteLine("ERROR: msapp file was not created");
    Environment.Exit(1);
}

var fileInfo = new System.IO.FileInfo(outputPath);
Console.WriteLine($"SUCCESS! Created: {outputPath} ({fileInfo.Length} bytes)");