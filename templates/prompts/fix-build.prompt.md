---
mode: agent
description: "Diagnose and fix build failures for {{PROJECT_NAME}}"
---

You are helping diagnose and fix a build failure in {{PROJECT_NAME}}.

## Step 1: Identify the error

Run the build and capture the output:
```bash
{{BUILD_COMMAND}} 2>&1 | tail -100
```

## Step 2: Common .NET failure categories

### Missing SDK / runtime
- **Symptom:** `NETSDK1045`, `MSB4236`, or framework version mismatch
- **Fix:** Check `global.json` for required SDK version, install it

### Missing NuGet packages
- **Symptom:** `NU1101`, `CS0246` (type or namespace not found)
- **Fix:** `dotnet restore` then rebuild

### Format/style errors
- **Symptom:** `IDE0055`, `CS8600`, or other warnings treated as errors
- **Fix:** `dotnet format` on the affected project, then rebuild

### Native dependency errors
- **Symptom:** `DllNotFoundException`, missing `.so` / `.dylib` / `.dll`
- **Fix:** {{NATIVE_DEP_FIX}}

### First-build errors
- **Symptom:** `dotnet build` fails on individual project with missing refs
- **Fix:** Run the full build (`{{BUILD_COMMAND}}`) from repo root first

### Target framework errors
- **Symptom:** Tests fail with `net48` errors on Linux/macOS
- **Fix:** `net48` targets are Windows-only. Use `net8.0` or `net9.0`

## Step 3: Rebuild and verify

After applying the fix:
```bash
{{BUILD_COMMAND}}
dotnet build src/{{PROJECT_PREFIX}}.Foo/
```

Confirm the build passes before reporting success.
