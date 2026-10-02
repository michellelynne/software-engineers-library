---
name: legacy-migration-planner
description: Plan the first step of migrating a legacy system, in order - explain what the system actually does, rank which feature to extract first, write the user-outcome test plan before any code, then package the decisions as a reusable skill so every engineer on the migration works the same way. Use whenever someone inherits an old system, is deciding whether to break up a monolith, is choosing a pilot service to extract, or wants AI help on a migration, even if they only ask about one of these steps.
---

# SKILL: Legacy Migration Planner

**From:** Migrating a Legacy System

## When to load this skill

Load this skill when the reader is facing a system they did not build and is considering
moving part of it into a new service. Also load it earlier, when they are still deciding
whether modernizing is worth it at all. The stages run in order; do not skip ahead.

## Before anything: should you?

The real question is not "can I?" but "should I?" Ask the reader for data on four things:

1. How much use does the system get?
2. How much time is spent supporting it?
3. How hard is it to onboard new engineers to support it?
4. Which wanted features does the tech debt block?

Heavy use, heavy support, and hard onboarding together justify the work. If the honest answer
is that the reader wants to work on something modern, say so and stop. Plenty of legacy
products are worth leaving alone.

## Stage 1: Explain the system

**Explain first, suggest nothing.** Describe what exists before anyone argues about what should
replace it. For the system and each meaningful section: what it does in plain language, its
inputs, its outputs, what it writes to, what calls it, and its business use case.

**Open questions, not guesses.** Anything that cannot be determined becomes a question the reader
can take to whoever has been there longest. That list is the most valuable output of this stage.

The reader checks the explanation against their own knowledge and support history. Where the two
conflict, the reader is probably right.

## Stage 2: Rank the first feature

Pick one small feature that can be pulled out cleanly and used as the template for every service
that follows. For each candidate the reader names:

| | |
|---|---|
| **How cleanly it comes out** | And what holds it in |
| **What it still needs** | From the old system afterward |
| **What could go wrong** | Concretely |
| **Risk to the old system** | If the extraction fails |
| **Complexity** | Including how much is unknown |

Rank by risk and complexity together, least of both first. The winner is usually the boring one.
State what you would need to know to be more confident.

## Stage 3: Write the test plan first

The old system is the specification, which makes this the ideal case for test-driven
development. Write the test plan before any implementation: the happy path, the failure cases
the reader names, edge cases and unexpected data, and anything else that would make the service
more resilient.

**Every test states, in one line, the user-facing outcome it protects.** A test that cannot
answer that is testing an implementation detail.

## Stage 4: Package the plan

Once the reader settles the design, turn the decisions into a skill or harness: the conventions,
the messaging and deployment choices, the test standards, and the open questions still being
answered. Every engineer who joins the migration then starts from the same context.

## Prompts the reader can run directly

> You are a senior engineer onboarding onto this codebase. Read this repo and any referenced
> documentation. Explain what it does in plain language: its inputs, its outputs, what it writes
> to, and what calls it. Explain its business use case. If you can access anything it reads or
> writes, pull that as well to get a bigger picture of how it works. List anything you are unsure
> about as an open question rather than guessing. Do not suggest changes yet.

> You are a staff engineer helping me plan a migration. Here is a description of my system and the
> four features I am considering extracting first. For each one, tell me how cleanly it could be
> pulled out, what it would still need from the old system, and what could go wrong. Rank them
> based on risk (to monolith) and complexity. The top should be least risky and least complex. Say
> what you would need to know to be more confident.

> You are a test engineer. Here is the behavior this feature must produce, described from the
> user's point of view. Write the test case plan before any implementation. Cover the happy path
> and the failure cases I listed. For each test, state in one line what user-facing outcome it
> protects. Then make a plan for edge cases and unexpected data or failures. Suggest any other
> tests that would make this more resilient. Make it clear which test case is for which scenario.

## What to tell the reader

- **The migration estimate leaves out the bridge.** Even one feature needs the old system updated
  to talk to the new one, and possibly middleware.
- **Check the AI's work against your support history.** The incidents are the ground truth.
- **Before launch, run the production readiness review** (see `production-readiness-review`).

## What this skill does not do

It does not decide whether to migrate on the reader's behalf, write the implementation, or assess
production readiness.