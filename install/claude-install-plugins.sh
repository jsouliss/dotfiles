#!/bin/bash
# claude/install-plugins.sh - run after stow on a new machine

OFFICIAL_PLUGINS=(
  context7 superpowers code-review feature-dev commit-commands
  claude-md-management pr-review-toolkit hookify firecrawl
  learning-output-style discord firebase supabase linear
  terraform vercel security-guidance code-simplifier
  explanatory-output-style frontend-design ralph-loop
  # LSP plugins
  typescript-lsp pyright-lsp gopls-lsp rust-analyzer-lsp
  clangd-lsp csharp-lsp php-lsp jdtls-lsp swift-lsp lua-lsp
)

TRAILOFBITS_PLUGINS=(
  agentic-actions-auditor ask-questions-if-underspecified
  second-opinion insecure-defaults supply-chain-risk-auditor
  gh-cli git-cleanup modern-python property-based-testing
  sharp-edges skill-improver testing-handbook-skills
  variant-analysis differential-review entry-point-analyzer
  workflow-skill-design
)

OTHER_PLUGINS=(
  "thedotmack/claude-mem"
  "anthropic-cybersecurity-skills/cybersecurity-skills"
)

echo "Installing official plugins..."
for p in "${OFFICIAL_PLUGINS[@]}"; do
  claude plugin add "$p" 2>/dev/null
done

echo "Installing Trail of Bits plugins..."
for p in "${TRAILOFBITS_PLUGINS[@]}"; do
  claude plugin add "$p" 2>/dev/null
done

echo "Installing official plugins..."
for p in "${OTHER_PLUGINS[@]}"; do
   claude plugin add "$p" 2>/dev/null
done

echo "[+] Done."
