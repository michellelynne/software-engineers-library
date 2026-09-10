# Skills

Downloadable AI skills from *The Missing Cipher*. Each one turns a place where the book tells
you to use AI into something you can actually run, with the book's cautions built in.

The worksheets stay the source of truth. These fill them in faster and show their work while
doing it.

## Installing

Every skill is a directory containing a `SKILL.md`. The directory name matches the `name` in
that file's frontmatter, which is what the assistant matches on, so keep the directory intact
rather than copying the `SKILL.md` out on its own.

Copy the ones you want into your assistant's skills folder. For Claude Code that is
`~/.claude/skills/` for personal use, or `.claude/skills/` inside a project:

```bash
cp -r skills/job-alert-query-builder ~/.claude/skills/
```

All of them at once:

```bash
cp -r skills/*/ ~/.claude/skills/
```

Then start a new session and describe your task in your own words. Skills load based on what
you are doing, not by name, so there is nothing to memorize.

## What is here

| Skill | Chapter | What it does |
|---|---|---|
| `interest-to-company-research` | 1 | Turns one interest into a wide table of real companies across the industry, plus an alphabetized list |
| `regional-benefit-benchmarking` | 1 | Market ranges for a single benefit by region and years of experience, with a two-region comparison |
| `company-list-filtering` | 1 | Applies your filters one at a time, showing which companies drop off at each pass and why |
| `job-alert-query-builder` | 1 | Maps "Senior Software Engineer" to each company's real level name, then writes one alert query per company |
| `ai-job-tool-scout` | 1 | Surveys current job search tools with community reputation and a recency stamp |
| `time-saved-tracker` | any | Estimates the manual time before you start, times the assisted run, reports net time saved |

`time-saved-tracker` is built to wrap any of the others. It is the only skill here that is
allowed to tell you the AI was slower than doing the task yourself.

## Status

Chapter 1 is complete. The rest are being added a chapter at a time.

## If you are adding a skill

Every `SKILL.md` here follows the same shape:

- **Frontmatter** with `name` (lowercase, hyphenated, matching the directory) and a
  `description` covering both what the skill does and when to use it. The description decides
  whether the skill triggers, so it carries the phrases a reader would actually type.
- **When to load this skill**, in plain terms.
- **How to run it**, as numbered steps.
- **A prompt you can run directly**, so the skill is useful even without installing it.
  Prompts address the AI in the second person, never the first.
- **What to tell the reader**, carrying the book's cautions: verify what the AI could not
  source, never paste secrets or proprietary code into a public model, review before using.
- **What this skill does not do**, so the edges are honest.

House style follows the manuscript: no em dashes, no Latin abbreviations, American English,
and the reader is always the mid-level engineer working toward senior.
