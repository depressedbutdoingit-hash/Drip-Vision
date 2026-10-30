---
name: cinematic-swarm-conductor
description: "Orchestrate multiple specialized agents and skills for collaborative DripVision cinematic production. Use when coordinating character consistency, shot planning, continuity checks, preference learning, and video generation across a swarm of agents."
type: orchestrator
lifecycle: active
---

# Cinematic Swarm Conductor

Coordinate a swarm of specialized skills and agents to produce consistent cinematic content. Distribute tasks such as character DNA matching, continuity detection, shot planning, preference adaptation, and video generation. Maintain shared meta-knowledge and resolve conflicts.

## Core Workflow

1. **Receive request**: Parse user intent (e.g., generate scene, check continuity, adapt style).
2. **Decompose tasks**: Assign subtasks to appropriate agents (Character DNA, Continuity Detective, Shot Planner, Preference Learner, Video Generator).
3. **Execute in parallel or sequence**: Use MAML-style fast adaptation for few-shot character matching or preference updates.
4. **Aggregate results**: Combine outputs, run Continuity Health Score, apply cost optimization.
5. **Persist**: Write results to Eternal Universe Manager and update Director's Brain.
6. **Explain and override**: Provide decision rationale and accept human overrides.

## Agent Roles

| Agent | Responsibility | Trigger Keywords |
|-------|----------------|------------------|
| Character DNA | Maintain and match character identity across shots | "character consistency", "DNA profile" |
| Continuity Detective | Compare scenes against Director's Bible | "continuity check", "health score" |
| Shot Planner | Build genre-aware shot sequences | "plan shots", "cinematography" |
| Preference Learner | Extract permanent/project/temporary style preferences | "one-shot learning", "creative DNA" |
| Video Generator | Call external video APIs with adapted prompts | "generate video", "render scene" |
| Cost Optimizer | Select cheapest reliable method | "optimize cost", "budget" |

## Executable Tools

Use these scripts for deterministic operations:

| Script | Purpose | Command |
|--------|---------|---------|
| `scripts/continuity_score.py` | Compute Continuity Health Score | `python3 scripts/continuity_score.py` |
| `scripts/preference_adapter.py` | One-shot preference update (MAML-style) | `python3 scripts/preference_adapter.py` |
| `scripts/shot_planner.py` | Generate genre-aware shot plan | `python3 scripts/shot_planner.py` |

Always run Continuity Score after generation and before accepting a result.
