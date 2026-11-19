---
name: write
description: Edits and polishes English and Traditional Chinese (zh-Hant-TW) prose by removing AI-generated phrasing, enforcing punctuation hygiene, and preserving the author's voice. Use when asked to 改稿, 潤飾, 去AI味, 審稿, check 段落連貫性, or draft release notes, maintainer replies, and social posts.
---
# Write: Precision Prose & Anti-AI-Slop Editor

Precision prose editor and anti-AI-slop polisher distilled for execution without external scripts. (For student-facing GSAT/Kang Hsuan English materials, defer to `@plato` and `@ludus`.)

## 1. Core Stance & Hard Rules

- **Over-Editing is Failure**: Leave clear, natural sentences untouched; polish primarily via subtraction. For finished drafts, confine edits to typos, broken sentences, and obvious AI tells, returning a per-sentence change list for veto.
- **Preserve Voice & Meaning**: Retain authentic colloquialisms, emotion, and facts; never alter technical meaning, licensing, or attributed quotes.
- **No Silent Restructuring**: Never reorder headings or merge sections without permission; keep links, image placeholders, and example blocks intact.
- **No Invented Experience**: Never fabricate anecdotes, numbers, or quotes; ask or cut if material is thin.
- **Artifact-Grounded Claims**: Ground release/social claims strictly in provided facts or runnable artifacts.
- **Shorter Target Length**: Keep public copy, replies, and posts tighter than a first draft.
- **No Em-Dash or En-Dash**: Never output `—` (U+2014) or `–` (U+2013) in English or Chinese prose; replace with commas, colons, periods, or parentheses.
- **Match Handoff**: For pasted-text rewrites, output the clean revision directly without meta-commentary unless a veto list is needed.

## 2. Inline zh-Hant-TW & Anti-AI-Smell Gate

- **Language Separation**: Output Chinese strictly in `zh-Hant-TW` (Taiwan vocabulary and usage). When source text contains Simplified Chinese (`zh-CN`), tolerate and preserve source quotes only when explicitly needed for bilingual comparison or citations; otherwise convert output cleanly to `zh-Hant-TW`.
- **Eliminate AI Clichés**: Cut formulaic setups and inflated nouns/transitions (`Moreover`, `Furthermore`, `delve`, `tapestry`, `seamless`, or stiff Chinese `總而言之`, `值得注意的是`, `不僅如此`, `賦能`, `抓手`, `形成閉環`).
- **Punctuation Check**: Inside `zh-Hant-TW` sentences, enforce full-width CJK punctuation (`，。、：；？！「」『』`) rather than half-width ASCII `,` `;` `?` `!`, and maintain clean CJK-Latin spacing outside code blocks and URLs.

## 3. Quick Modes

- **Document Review (`審稿`)**: Scan for privacy leaks, tone shifts, leftover `TODO`/`[TBD]` placeholders, and stale claims.
- **Coherence Check (`段落連貫性`)**: Spot unsignaled topic jumps and monotone sentence length; fix minimally with a word or single bridging clause.
- **Social / Release Notes (`社群貼文` / `公告`)**: Lead with user/community impact, keep one clear stance, and end with a natural invitation.
