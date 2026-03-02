#!/bin/bash
# Copilot pre-commit hook — validates code quality before committing
# Install: cp this file to .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# Or reference from .github/hooks/ in your CI config

set -e

echo "Running pre-commit checks..."

# Get list of staged .cs files
STAGED_CS_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.cs$' || true)

if [ -z "$STAGED_CS_FILES" ]; then
    echo "No C# files staged — skipping checks."
    exit 0
fi

# 1. Format check on staged C# files
echo "Checking code formatting..."
dotnet format --verify-no-changes --include $STAGED_CS_FILES 2>/dev/null || {
    echo "❌ Code formatting issues detected. Run 'dotnet format' to fix."
    exit 1
}

# 2. Check for potential secrets patterns
echo "Scanning for secrets..."
SECRETS_PATTERN='(password|secret|api[_-]?key|token|connectionstring)\s*=\s*"[^"]+'
for file in $STAGED_CS_FILES; do
    if grep -iEn "$SECRETS_PATTERN" "$file" 2>/dev/null; then
        echo "❌ Potential secret detected in $file. Use environment variables or secure configuration."
        exit 1
    fi
done

# 3. Check for Console.WriteLine (should use proper logging)
echo "Checking for Console.WriteLine..."
for file in $STAGED_CS_FILES; do
    if grep -n "Console\.Write" "$file" 2>/dev/null | grep -v "//.*Console" | grep -v "test/" > /dev/null; then
        echo "⚠️  Console.Write found in $file — consider using the project's logging framework."
    fi
done

echo "✅ Pre-commit checks passed."
