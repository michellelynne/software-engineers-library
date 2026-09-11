---
name: wind-down-knowledge-transfer
description: Turn scattered notes, docs and code comments from a product entering maintenance mode into a structured knowledge-transfer summary, with every claim marked for verification because nobody will be left to fact-check it later. Use when a product is being wound down, when a team is dispersing, or when someone needs to capture what only lives in people's heads before they move on.
---

# SKILL: Wind-Down Knowledge Transfer

**From:** How to make the transition?

## When to load this skill

Load this skill when a product is entering maintenance mode and the people who know it are about
to move to other teams. The window is short and it closes quietly.

## What makes this different from ordinary documentation

**Nobody will be able to fact-check it later.** That single fact changes how the work should be
done.

Under normal circumstances a documentation error gets caught eventually, because someone who knows
better reads it. Here the people who would catch it are leaving. An invented detail in a
wind-down summary becomes permanent, and it will be read years later by someone with no way to
check it, usually at the worst possible moment.

So every claim is marked with where it came from, and anything that cannot be sourced is marked as
unverified rather than smoothed into the text.

## What to capture

The priority is **what only lives in people's heads**. The documented parts are already documented.

- **The manual workarounds.** The steps someone does by hand that were never automated.
- **The fragile dependencies.** What breaks this that nobody would guess from the code.
- **Who to call.** When payments break, when the vendor integration fails, when the nightly job
  does not run. Names, teams, and what each person actually knows.
- **The things everyone knows and nobody wrote down.** The quirk, the workaround, the reason that
  one setting must never be changed.

Structured, roughly:

| Section | Content |
|---|---|
| **Architecture overview** | What it is and how the pieces connect |
| **Known issues** | What is broken and being lived with, and why |
| **Manual processes** | Every step still done by hand, with how often |
| **Dependencies** | What it needs and what needs it, including vendors |
| **Who to ask** | By topic, with what each person knows |
| **Do not touch** | Anything with a non-obvious reason to leave alone |

## Do not optimize for tidiness

This is explicitly not the time to worry about well-organized or clean documentation. If the
software is still running a year from now, anyone looking at it will be glad that anything exists
at all. Completeness beats polish, and a rough note with a name attached beats a tidy paragraph
with the detail sanded off.

## Mark every line

Three states, visibly:

- **Sourced.** Where it came from.
- **Inferred.** Assembled from code or docs rather than stated by a person. Needs a human pass.
- **Unverified.** Someone said it, nobody confirmed it, and there may be no one left who can.

Then a list at the top of what could not be sourced from the input at all, so the reader knows
what to go and ask while people are still reachable.

## Prompt the reader can run directly

> You are producing a knowledge-transfer document for [PRODUCT], which is entering maintenance
> mode. Here is everything I have: scattered notes, documentation, code comments, and chat
> excerpts: [PASTE].
>
> Produce a structured summary covering architecture, known issues, manual processes,
> dependencies, who to ask by topic, and anything that should not be touched.
>
> Mark every single claim as sourced, inferred, or unverified. Do not smooth over gaps. Where
> something is missing, say what is missing rather than filling it.
>
> At the top, list what you could not determine at all, so I can go and ask while the team is
> still here.

## What to tell the reader

- **Verify every line.** This is the one warning the book repeats twice, and the reason is that
  nobody will be left to fact-check it.
- **Do this before the team disperses.** After they scatter, the unverified items stay unverified
  forever.
- **The exit interview is worth doing too.** What did the product teach us about our stakeholders,
  do they need a different solution or a technical refresh, and what should we avoid next time.
- **Then have the celebration.** When maintenance mode is actually in place, and invite everyone
  who worked on it. The gap to full retirement can be long, and the moment does not come back.

## What this skill does not do

It does not verify anything, interview anyone, or decide what matters. It structures what exists
and is explicit about what it could not confirm.
