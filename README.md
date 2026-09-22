# 🏛️ Chronicles of Dominion (Godot 4.3 RTS)

> **Grand Strategy & Real-Time Tactical RTS Simulation**  
> Built with **Godot Engine 4.3 (Forward+ Vulkan)** on Windows (NVIDIA RTX).

---

## 🌟 Overview

*Chronicles of Dominion* combines deep grand strategy empire management with precision real-time tactical RTS combat and city building in ancient Mesopotamia. 

All legacy C++ and Unreal Engine 5 dependencies have been deprecated in favor of a clean, lightweight, highly responsive, and deterministic **Godot 4.3** engine architecture.

---

## 🎮 Core Subsystems

### 1. ⚔️ Tactical RTS Armies & Formations
- **Mass Unit Controls**: Marquee box drag selection, right-click moves, and dynamic facing line orientation (`_issue_facing_move_order`).
- **Deterministic 3D Navigation**: Native `NavigationServer3D.map_get_path()` with crowd flocking separation forces (capped at $\le 18\%$ speed) and collision-stuck recovery.
- **Formation Orders**:
  - **Phalanx (`[4]`)**: 3-column tight combat ranks for infantry bracing.
  - **Wedge**: Arrowhead spearhead for cavalry shock charges.
  - **Skirmish**: Wide firing line minimizing missile vulnerabilities.

### 2. 🏰 3D Building & City Architecture
- **Complete Construction Lifecycle**: `GHOST` $\rightarrow$ `UNDER_CONSTRUCTION` (scaffolding active) $\rightarrow$ `COMPLETED` (full PBR mesh & outputs) $\rightarrow$ `DAMAGED` $\rightarrow$ `DESTROYED`.
- **5 Core Archetypes**:
  - **Military Barracks (`[B]`)**: Musters Spearmen, Slingers, and Archers with automated rally point delivery.
  - **Royal Granary (`[N]`)**: Generates $+15\text{ Grain/s}$ and acts as famine reserve.
  - **Mudbrick Tenement (`[H]`)**: Provides $+35\text{ Housing}$ and expands urban population capacity.
  - **Grand Bazaar (`[M]`)**: Generates $+25\text{ Gold/s}$ through marketplace trade.
  - **War Chariot Foundry (`[F]`)**: Heavy vehicle smithy for War Chariots and Baggage Trains.
- **Dynamic NavMesh Re-Baking**: Newly erected structures automatically register with `NavigationRegion3D`, prompting real-time NavMesh updates so armies path seamlessly around player-built cities.

### 3. ⚖️ Causal Crisis Engine (Zero Spontaneous Timers)
- **100% Player-Action Driven**: Crises are direct consequences of player decisions rather than random interval timers:
  - *Excessive Urban Housing Density* $\rightarrow$ Triggers **Pestilence in the Mudbrick Quarters**.
  - *Aggressive Temple Tithes* $\rightarrow$ Triggers **Theocratic Dominance & Clerical Overreach**.
  - *Granary Deficits During War* $\rightarrow$ Triggers **Urban Bread Riots**.

### 4. 📿 Basalt & Bronze Modular HUD
- **3 Estate Dials**: Barometer dials monitoring the **Altar** (Priesthood), **Throne** (Nobility), and **Masses** (Commoners).
- **Resource Tray**: Modular resource badges tracking Grain, Timber, Stone, Bronze, Gold, and Population with live delta indicators.
- **Province Inspector Card**: Real-time inspection of selected battalions, structures, fortress integrity, and realm stability.
- **Tactical Command Dock**: Quick-action tablets for unit recruitment, battle formations, and imperial decrees.

---

## ⌨️ Controls & Keybindings

| Key | Action |
| :--- | :--- |
| **LMB Drag** | Box Marquee Selection (Units & Battalions) |
| **LMB Click** | Select individual Unit or Structure |
| **RMB Click** | Issue Tactical Move / Attack Order |
| **RMB Drag** | Set Battalion Heading & Facing Line |
| **[B]** | Place Military Barracks |
| **[N]** | Place Royal Granary |
| **[H]** | Place Mudbrick Tenement |
| **[M]** | Place Grand Bazaar |
| **[F]** | Place War Chariot Foundry |
| **[ESC]** | Cancel Structure Placement Ghost |
| **[1] - [3]** | Train Unit / Recruit from Selected Barracks |
| **[4]** | Cycle Tactical Formations (*Phalanx / Wedge / Skirmish*) |
| **[5]** | Summon Imperial Council |
| **[Ctrl + 1-9]** | Assign Control Groups |
| **[1-9]** | Select Assigned Control Group |
| **[G]** | Spawn Desert Raider Incursion (Debug) |

---

## 🧪 Automated Testing

The project includes an automated test suite runnable via headless Godot:

```bash
# Run complete Building & Structure Subsystem test
godot.exe --headless -s res://tests/test_building_system.gd

# Run Multi-Unit Ziggurat Navigation Avoidance test
godot.exe --headless -s res://tests/test_multi_unit_ziggurat.gd

# Run Action-Driven Crisis Engine test
godot.exe --headless -s res://tests/test_action_crises.gd

# Run Area Marquee Selection test
godot.exe --headless -s res://tests/test_area_selection.gd
```

---

## 🚀 Launching the Game

Open Godot 4.3 and import `project.godot`, or execute:

```cmd
Launch_Chronicles_Of_Dominion.bat
```

---

## 📜 License
MIT License. Developed for *Chronicles of Dominion*.
