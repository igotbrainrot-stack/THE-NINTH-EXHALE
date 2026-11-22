# Build 09.2 full-campaign playtest

## Purpose

The 09.2 package workflow is a startup/import and regression check. It is not campaign acceptance. This workflow runs the existing real-scene playbot for the full 420-second window under both policies and preserves rendered frames, route logs and ending evidence.

## Run

GitHub Actions: `.github/workflows/full-campaign-playtest-092.yml`

- `BOT_POLICY=combat`: engages visible enemies.
- `BOT_POLICY=pacifist`: attacks only enemies already hostile.
- 420 seconds of bot time per policy.
- Both jobs upload `log.txt`, screenshots, grid diagnostics and log hash even when the acceptance step fails.

## Pass conditions

1. The bot reaches a `VESPER /` ending docket before the 420-second window expires.
2. The log summary reports that same ending.
3. No witness records are missing living witness IDs.
4. The output captures and logs are retained as an artifact for review.

## What this does not prove

- It is a scripted navigation/dialogue policy, not human play.
- Reaching an ending does not prove all optional quests, NPC arcs, endings or accessibility paths work.
- The workflow does not test audio through a real device or measure user-machine frame times.
- Weapon animation captures and anchor alignment remain separate review tasks.

## Status

Pending the workflow run on the completion-QA branch. Record each policy's conclusion, ending, route anomalies and capture review here after CI finishes. Do not mark the full game complete solely because the bot reaches an ending.
