# Book-to-Skill Converter

Transforms technical books (PDF/EPUB) into structured Claude Code skills by extracting frameworks, principles, techniques, and anti-patterns.

## Three Operating Modes

1. **Full Conversion** — Complete skill generation (default when user provides a PDF path)
2. **Analyze Only** — Extract and review frameworks without generating skill files
3. **Generate from Analysis** — Create skill files using previously gathered analysis notes

## Workflow (Steps 0–10)

### Validation & Preparation
- **Step 0**: Verify input is a PDF or EPUB path
- **Step 1**: Confirm file existence and format
- **Step 1.5**: Ask user about book type (technical vs. text-heavy) to choose extraction method
- **Step 2**: Extract text using appropriate tool (Docling for technical; pdftotext for text)
- **Step 2.5**: Present token cost estimate and wait for user confirmation before proceeding

### Analysis & Planning
- **Step 3**: Analyze structure (title, author, chapters, themes)
  - If "analyze only" mode: produce extraction report and stop
- **Step 4**: Ask purpose (apply frameworks, think with models, reference chapters, or all)
- **Step 5**: Determine skill name (author-concept or title-based format)

### Generation
- **Step 6**: Create skill directory structure
- **Step 7**: Generate chapter summaries (800–1,200 tokens each)
  - Adapt emphasis: technical books prioritize code/tables; text-heavy books emphasize frameworks
- **Step 8**: Generate supporting files
  - `glossary.md` (~1,500 tokens)
  - `patterns.md` (~2,000 tokens)
  - `cheatsheet.md` (~1,000 tokens)
- **Step 9**: Generate master SKILL.md (~4,000 tokens max)
  - Core frameworks first (front-load critical content)
  - Chapter and topic indices
  - Links to supporting files

### Cleanup
- **Step 10**: Remove temporary files and provide completion report

## Key Design Principles

**Extract structure, not summaries** — capture named frameworks and exact formulations, not chapter recaps.

**Preserve precision** — use the author's terminology unchanged; "The 5 Whys" differs meaningfully from "ask why repeatedly."

**Density over completeness** — prioritize signal; synthesize rather than excerpt.

**On-demand loading** — chapter files don't consume skill budget until accessed; only SKILL.md is always loaded.

**Practitioner voice** — write actionable guidance ("Use X when Y") rather than passive description.

## Token Budget Rules

- Chapter files: 800–1,200 tokens each (tight, dense)
- SKILL.md: max 4,000 tokens (truncation starts at end, preserving core frameworks first)
- Glossary: max 1,500 tokens
- Patterns: max 2,000 tokens
- Cheatsheet: max 1,000 tokens

## Output Structure

```
~/.claude/skills/<skill_name>/
├── SKILL.md                 (core frameworks + indices)
├── chapters/
│   ├── ch01-<slug>.md
│   ├── ch02-<slug>.md
│   └── ...
├── glossary.md
├── patterns.md
└── cheatsheet.md
```

## Usage

When the user provides a PDF/EPUB path, follow the 11-step workflow above. Always confirm token cost before proceeding (Step 2.5). Default to full conversion unless the user specifies "analyze only" or "generate from analysis".
