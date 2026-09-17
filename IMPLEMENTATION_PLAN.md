# Implementation Plan: Chronicles of Dominion (Godot 4.3+ GDScript Pivot)

Transitioning *Chronicles of Dominion: Bronze to Steam* from Unreal Engine C++ to **Godot 4.3+ (GDScript)**. Godot provides rapid iteration, clean node/scene composition, first-class CanvasLayer/Control UI, and built-in navigation and signal architecture.

## User Review Required

> [!IMPORTANT]
> - **Engine Version**: Godot 4.3 Stable (Windows 64-bit standalone binary).
> - **Project Directory**: `C:\Users\Collin\Documents\GodotProjects\ChroniclesOfDominion` (or `C:\Users\Collin\.gemini\antigravity\scratch\ChroniclesOfDominion`).
> - **Primary Language**: GDScript (fast, agent-friendly, hot-reloading).

---

## Architecture & System Overview

```
Main (Main.tscn)
├── World (Node3D)
│   ├── DirectionalLight3D & WorldEnvironment (Warm Mesopotamian sunlight)
│   ├── Terrain (GridMap / MeshInstance3D terrain + NavigationRegion3D)
│   ├── Rivers (Meshes with animated UV water shader)
│   ├── Buildings (Node3D container for Ziggurat, Farmlands, Granaries)
│   ├── Units (Node3D container for Spearmen, Slingers, Chariots, Raiders)
│   ├── Effects (Node3D for combat particles, dust trails)
│   └── CameraRig (RTS Camera with edge pan, orbital tilt, zoom, and damping)
├── UI (CanvasLayer)
│   ├── HUD (Top resource ledger, Hope/Discontent bars, Estate dials)
│   ├── CommandPanel (Unit actions, recruitment, stance toggles)
│   ├── CrisisPopup (Frostpunk-style paused dilemma popups with choices)
│   ├── Minimap (Control with camera frustum and unit radar blips)
│   ├── Tooltip (Dynamic rich parchment lore overlay)
│   └── SelectionBox (Custom 2D marquee drag selection box)
└── Autoloads (Singletons)
    ├── EventBus.gd (Central decoupled signal hub)
    ├── GameManager.gd (State: Playing, Paused, Crisis, Victory, Defeat)
    ├── EconomyManager.gd (Grain, Clay, Bronze, Timber, Gold + tickers)
    ├── PopulationManager.gd (Demographics, Housing, Manpower ratios)
    ├── FormationManager.gd (Phalanx, Wedge, Skirmish, Line slot math)
    ├── MilitaryManager.gd (Selection, Orders, Combat resolution, Morale)
    ├── SupplyManager.gd (Baggage trains, Granary range, Attrition)
    ├── PoliticsManager.gd (Estates: Priesthood, Nobility, Commoners)
    ├── ReligionManager.gd (Divine favor, Temple rituals, Omens)
    ├── CrisisManager.gd (Frostpunk dilemma queue & resolution)
    └── SaveManager.gd (JSON / Resource serialization)
```

---

## Proposed Changes & File Layout

### 1. Project Initialization & Configuration
#### [NEW] `project.godot`
- Configures Godot 4.3 project settings:
  - Application name: `Chronicles of Dominion`
  - Main scene: `res://scenes/Main.tscn`
  - Window size: $1920 \times 1080$, stretch mode `canvas_items`, aspect `expand`
  - All 11 Autoload singletons registered in `[autoload]`
  - Input map bindings: RTS camera keys (`WASD`, `Q/E` rotate, `Scroll` zoom), Marquee selection (Mouse Left), Move/Attack orders (Mouse Right), Action keys (`Q`, `W`, `E`, `R`, `T`).

---

### 2. Autoload Singletons (`scripts/systems/`)

#### [NEW] [`EventBus.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/EventBus.gd)
- Decoupled signal dispatch for economy ticks, unit selection, crisis triggers, estate shifts, and combat events.

#### [NEW] [`GameManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/GameManager.gd)
- Manages game state (`PLAYING`, `PAUSED`, `CRISIS_PAUSED`, `GAME_OVER`), time scale controls ($1\times, 2\times, 3\times$), and victory/defeat evaluations.

#### [NEW] [`EconomyManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/EconomyManager.gd)
- Tracks Grain, Timber, Clay/Stone, Bronze, Gold, and Food Consumption rate.
- 1.0s tick accumulator for farm harvest yields, granary storage caps, and recruitment costs.

#### [NEW] [`PopulationManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/PopulationManager.gd)
- Tracks total citizens, conscription manpower pool, housing occupancy, Hope ($0-100\%$), and Discontent ($0-100\%$).

#### [NEW] [`FormationManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/FormationManager.gd)
- Computes tactical slot coordinate arrays for Phalanx (tight rectangular shield wall), Wedge (shock assault), Skirmish (dispersed loose line), and Column march.

#### [NEW] [`MilitaryManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/MilitaryManager.gd)
- Manages selected unit sets, marquee box raycasting, formation move dispatch, attack-move targeting, melee/ranged combat calculations, and morale break routing.

#### [NEW] [`SupplyManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/SupplyManager.gd)
- Calculates distance from active field regiments to nearest Granary / Baggage Train; applies progressive hunger debuffs and starvation attrition.

#### [NEW] [`PoliticsManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/PoliticsManager.gd)
- Tracks loyalty and influence of the 3 Political Estates: Priesthood (Altar), Nobility (Throne), and Commoners (Masses); handles faction demands and coups.

#### [NEW] [`ReligionManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/ReligionManager.gd)
- Manages Divine Favor, temple sacrifices, omens, and priesthood tithes.

#### [NEW] [`CrisisManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/CrisisManager.gd)
- Frostpunk-style crisis engine: triggers modal dilemma popups with choices that permanently affect Hope, Discontent, Estate Loyalty, and Resource Stocks.

#### [NEW] [`SaveManager.gd`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scripts/systems/SaveManager.gd)
- Serializes and deserializes the entire simulation state to JSON.

---

### 3. Data Resources (`scripts/resources/` & `data/`)

#### [NEW] `UnitData.gd` & `.tres` (Spearman, Slinger, Chariot, Raider, BaggageTrain)
- Stats: Health, Armor, Damage, Range, Speed, GrainUpkeep, ManpowerCost, FormationType.

#### [NEW] `BuildingData.gd` & `.tres` (Ziggurat, FarmPlot, Granary, Barracks, Watchtower)
- Stats: ConstructionCost, Footprint, ProductionYield, HousingCap, StorageCap.

#### [NEW] `CrisisData.gd` & `.tres` (e.g., *Locust Swarm on Euphrates*, *Noble Grain Hoarding*, *Temple Blood Eclipse*)
- Context, Narrative, Option choices, Stat modifiers.

---

### 4. Core Scenes & Components (`scenes/`)

#### [NEW] [`Main.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/Main.tscn)
- Root orchestrator connecting `World` (3D), `UI` (CanvasLayer), and input handling.

#### [NEW] [`CameraRig.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/camera/CameraRig.tscn)
- Smooth RTS Camera: WASD/Edge-pan movement, mouse wheel zoom with exponential pitch tilt, middle-mouse rotation, collision clamping.

#### [NEW] [`Unit.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/units/Unit.tscn)
- `CharacterBody3D` with selection ring, floating health/morale bars, navigation agent (`NavigationAgent3D`), and combat state machine (`IDLE`, `MOVE`, `ATTACK`, `ROUTING`).

#### [NEW] [`Building.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/buildings/Building.tscn)
- `StaticBody3D` base for all structures with construction queue, health, and worker assignment.

#### [NEW] [`Ziggurat.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/buildings/Ziggurat.tscn) & [`FarmPlot.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/buildings/FarmPlot.tscn)
- Starting Monumental Ziggurat HQ + visible agricultural farmland grid.

#### [NEW] [`HUD.tscn`](file:///C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/scenes/ui/HUD.tscn)
- High-fidelity Mesopotamian themed UI built with Godot `Control` nodes:
  - **Top Bar**: 6 live resource counters + 3 animated brass Estate Chronometer dials + Hope/Discontent meters.
  - **Command Panel**: 5 action buttons with hotkeys `[Q]`, `[W]`, `[E]`, `[R]`, `[T]` for unit training and stances.
  - **Crisis Popup**: Fullscreen paused narrative modal with choice buttons.
  - **Minimap**: SubViewport / TextureRect radar with interactive click-to-pan.
  - **Selection Box**: Custom 2D CanvasItem marquee box.

---

## Phase 1 Implementation Plan (Vertical Slice)

1. **Engine Setup**: Download and place Godot 4.3 Stable standalone executable.
2. **Project Initialization**: Generate `project.godot`, folder structure, and register Autoloads.
3. **World & RTS Camera**: Build `Main.tscn`, `World.tscn`, warm desert environment, and `CameraRig.tscn`.
4. **Unit System & Formations**: Build `Unit.tscn`, `Spearman.tres`, `Slinger.tres`, marquee box selection, and Phalanx formation positioning.
5. **Base Building & Economy**: Place starting `Ziggurat.tscn`, visible `FarmPlot.tscn`, and wire `EconomyManager` resource tickers.
6. **Tactical Combat**: Implement hostile Raider wave spawning, attack orders, damage calculations, and combat animations.
7. **Clean Godot CanvasLayer HUD**: Build the top bar ledger, estate dials, action ribbon, and unit info card using Godot Control nodes.

---

## Verification Plan

### Automated / Headless Verification
- Run Godot in headless/script mode to test Autoload initialization, resource tickers, formation slot calculations, and combat damage math:
  ```powershell
  & "C:\Godot\godot.exe" --headless --path "C:\Users\Collin\Documents\GodotProjects\ChroniclesOfDominion" --script "res://tests/test_systems.gd"
  ```

### Interactive Verification
- Launch the Godot 4.3 project window:
  ```powershell
  & "C:\Godot\godot.exe" --path "C:\Users\Collin\Documents\GodotProjects\ChroniclesOfDominion"
  ```
- Test RTS Camera edge pan, zoom, marquee box selection of spearmen cohorts, clicking right-mouse button to march in formation, pressing `[Q]` to recruit from the Ziggurat, and triggering a crisis popup.
