# Level 2 Chicken→Cow Chain — Diagnosis Findings

**Date:** 2026-08-20  
**Branch:** `feature/chicken`  
**Device:** Modern iPhone (user repro; overlay enabled via `DEBUG_DRAW_BOUNDING_BOXES`)

## Primary cause

**`trajectory`**

## Overlay evidence

After the kicked hen knocks down the first cow, the hen’s collision box **stops overlapping** later cow boxes — the flight arc no longer sweeps the rest of the row.

## Task 4 path

- **Do Task 4B** (retune kicked-hen flight: magnitude / angle / gravity).
- **Skip Task 4A** unless 4B alone cannot restore multi-cow hits.
