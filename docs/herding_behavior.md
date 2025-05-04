# Understanding the Sheep Herding Behavior

This document explains how the sheep herding behavior works in this simulation. The system models realistic flocking and herding dynamics through several interconnected components.

## Core Components of the Herding System

### 1. Sheep States

Sheep exist in one of three states, each with distinct behaviors:

- **Grazing**: The default, relaxed state when no dog is nearby (beyond `ALERT_RANGE` of 500 pixels)
- **Alert**: An intermediate state when a dog is detected but not too close (between `ALERT_RANGE` and `FLEE_RANGE`)
- **Fleeing**: An active escape state when the dog gets very close (within `FLEE_RANGE` of 380 pixels)

### 2. Force-Based Movement

The movement system uses a sophisticated force-based approach where multiple forces influence each sheep:

- **Separation**: Keeps sheep from crowding each other
- **Alignment**: Makes sheep move in the same direction as nearby sheep
- **Cohesion**: Keeps the flock together
- **Flee**: Directs sheep away from the dog
- **Herd**: Encourages fleeing sheep to move in the same direction as other fleeing sheep
- **Drift**: Provides a global movement direction for the entire flock
- **Seek**: Helps isolated sheep rejoin the flock

### 3. Dynamic Force Weighting

What makes this system sophisticated is how these forces are weighted differently based on the sheep's state:

- **Grazing sheep** prioritize cohesion (3.0) and alignment (1.5) with some drift (1.0)
- **Alert sheep** increase flee response (5.0) and alignment (2.0) while reducing drift (0.5)
- **Fleeing sheep** heavily prioritize the flee force (25.0) and increase herd behavior (1.5) while nearly eliminating cohesion (0.5)

## How Herding Works

The herding effect emerges from the interaction between the dog and sheep through these key mechanisms:

### 1. Proximity-Based State Changes

When the dog approaches:
1. Sheep within `ALERT_RANGE` (500 pixels) become alert, increasing their speed and stress level
2. Sheep within `FLEE_RANGE` (380 pixels) begin fleeing, with maximum stress and speed
3. As the dog moves away, sheep gradually return to grazing with decreasing stress levels

### 2. Flee Response Mechanics

The flee response has several sophisticated components:
- **Distance-based intensity**: The flee force increases with inverse square relationship to distance (controlled by `FLEE_INTENSITY_CURVE` of 2.8)
- **Immediate velocity push**: When the dog gets very close (within `PUSH_RANGE` of 300 pixels), sheep get an immediate velocity boost away from the dog
- **Speed scaling**: Maximum speed increases dramatically when fleeing (from 30 to 300 pixels per second)

### 3. Emergent Group Behavior

The herding effect emerges from:
- **Flee alignment**: Fleeing sheep align their movement with other fleeing sheep (the "herd" force)
- **Reduced cohesion**: Fleeing sheep reduce their desire to stay close to others
- **Leader influence**: Some sheep (5%) are designated as "leaders" and have more influence on the movement direction of nearby sheep
- **Global herd direction**: The flock maintains a slowly changing global drift direction that influences non-fleeing sheep

### 4. Return to Normal

As the dog moves away:
- Stress levels gradually decrease
- Sheep transition from fleeing to alert to grazing
- Cohesion forces increase, bringing the flock back together
- The global drift direction guides the reassembled flock

## Dog Control and Influence

The dog in the simulation:
- Has a large radius of influence (500 pixels)
- Is controllable by the player using arrow keys
- Can be toggled on/off with the space key
- Affects sheep through its position, not direct interaction

## How to Effectively Herd the Sheep

Based on the code, effective herding techniques would include:
1. Positioning the dog strategically behind sheep to make them flee in desired direction
2. Maintaining optimal distance (between alert and flee range) to guide without scattering
3. Using the "push" mechanic (getting very close) for quick direction changes
4. Leveraging the natural tendency of sheep to follow leaders and maintain flock cohesion

The simulation creates emergent behavior where simple rules at the individual sheep level create complex, realistic flock movements when influenced by the dog's presence.

## Technical Implementation Details

### Force Calculation Process

1. Each sheep's state is determined based on distance to the dog
2. Forces are calculated based on:
   - Interactions with other sheep (separation, alignment, cohesion)
   - Response to the dog (flee)
   - Global flock behavior (herd direction, drift)
   - Special cases (seeking back when isolated)
3. Forces are weighted based on the sheep's current state
4. Resultant forces are applied as velocity changes
5. Speed is limited based on state and dog proximity

### Leadership Dynamics

The system includes a leadership mechanism where:
- 5% of sheep are randomly designated as leaders
- Leaders follow the global direction more strongly (1.5× multiplier)
- Other sheep give more weight to the movement of leader sheep
- This creates natural-looking flock movement with frontrunners
