# .NET Stack Detection Reference

Quick reference for mapping discovered repo artifacts to template values.

## Test Framework Detection

| Found in `*.csproj` | Framework | Attributes | Assertions | Constructor |
|---------------------|-----------|------------|------------|-------------|
| `xunit` | xUnit | `[Fact]`, `[Theory]`+`[InlineData]` | `Assert.Equal`, `Assert.True`, `Assert.Throws<T>` | `(ITestOutputHelper output) : base(output)` |
| `NUnit` | NUnit | `[Test]`, `[TestCase]` | `Assert.That(x, Is.EqualTo(y))` | `[SetUp]` method or parameterless |
| `MSTest.TestFramework` | MSTest | `[TestMethod]`, `[DataTestMethod]`+`[DataRow]` | `Assert.AreEqual`, `Assert.IsTrue` | `public TestContext TestContext { get; set; }` |
| `FluentAssertions` | (addon) | (same as framework) | `x.Should().Be(y)` | (same as framework) |

## Validation Pattern Detection

| Found in `*.cs` | Pattern | Example |
|-----------------|---------|---------|
| `Contracts.Check` | ML.NET Contracts | `Contracts.CheckValue(data, nameof(data));` |
| `Guard.Against` | Ardalis.GuardClauses | `Guard.Against.Null(request, nameof(request));` |
| `ArgumentNullException.ThrowIfNull` | .NET 6+ built-in | `ArgumentNullException.ThrowIfNull(value);` |
| `FluentValidation` | FluentValidation | `new FooValidator().ValidateAndThrow(foo);` |
| Raw `if (x == null) throw` | Manual | (suggest upgrading to one of the above) |

## Logging Detection

| Found in `*.cs` or `*.csproj` | Logger | Example |
|-------------------------------|--------|---------|
| `ILogger<T>` or `Microsoft.Extensions.Logging` | Microsoft.Extensions.Logging | `_logger.LogInformation("msg");` |
| `IChannel` or `IHost` (ML.NET) | ML.NET channels | `ch.Info("msg");` |
| `Serilog` | Serilog | `Log.Information("msg");` |
| `NLog` | NLog | `_logger.Info("msg");` |
| `Console.WriteLine` only | None (flag this) | Recommend adding a logger |

## Security Surface Detection

| Project Type | Key Threats | CWEs |
|-------------|------------|------|
| ASP.NET Web API | XSS, CSRF, SQLi, auth bypass, IDOR, SSRF | CWE-79, CWE-352, CWE-89, CWE-287, CWE-639, CWE-918 |
| Class library | Deserialization, path traversal, resource exhaustion | CWE-502, CWE-22, CWE-400 |
| ML/AI project | Model deserialization, data poisoning, PII leakage, native interop | CWE-502, CWE-20, CWE-200, CWE-120 |
| Desktop (WPF/MAUI) | DLL hijacking, clipboard, local file access, IPC | CWE-427, CWE-200, CWE-22, CWE-502 |
| Console tool | Command injection, path traversal, argument parsing | CWE-78, CWE-22, CWE-88 |
| Blazor (WASM) | XSS, insecure API calls, client-side secrets | CWE-79, CWE-319, CWE-798 |

## Build Command Detection

| Found | Build Command |
|-------|--------------|
| `build.sh` / `build.cmd` | `./build.sh` (Linux/macOS) or `build.cmd` (Windows) |
| `Makefile` with dotnet targets | `make build` |
| `Nuke.Build` project | `./build.sh` or `dotnet nuke` |
| `Cake` (build.cake) | `dotnet cake` |
| None of the above | `dotnet build` |
