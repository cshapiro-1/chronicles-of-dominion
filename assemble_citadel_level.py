import unreal

def assemble_citadel_level():
    world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/TopDown/Lvl_TopDown")
    if not world:
        print("Error: Could not load /Game/TopDown/Lvl_TopDown")
        return

    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    all_actors = actor_subsystem.get_all_level_actors()

    # Retain lighting and essential setup
    retain_classes = ["DirectionalLight", "SkyLight", "SkyAtmosphere", "ExponentialHeightFog", "PostProcessVolume", "PlayerStart", "WorldDataLayers"]
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in retain_classes:
            actor_subsystem.destroy_actor(a)

    print("Existing scene geometry cleared. Assembling Authentic Fab Marketplace Citadel...")

    # Load Static Mesh Assets
    pillar_assets = [
        unreal.EditorAssetLibrary.load_asset(f"/Game/Ancient_Pillars/Meshes/Joined/SM_Pillars_0{i}") for i in range(1, 9)
    ]
    ruins_assets = {}
    for c in range(ord('A'), ord('Z')+1):
        letter = chr(c)
        ruins_assets[letter] = unreal.EditorAssetLibrary.load_asset(f"/Game/Ancient_Ruins/Meshes/SM_ISO{letter}")

    # Helper function to spawn static mesh actor
    def spawn_mesh(mesh, loc, rot=unreal.Rotator(0, 0, 0), scale=unreal.Vector(1, 1, 1), label="Citadel_Element"):
        if not mesh:
            return None
        act = actor_subsystem.spawn_actor_from_class(unreal.StaticMeshActor, loc, rot)
        if act:
            smc = act.static_mesh_component
            smc.set_static_mesh(mesh)
            smc.set_world_scale3d(scale)
            smc.set_mobility(unreal.ComponentMobility.STATIC)
            smc.set_collision_profile_name("BlockAll")
            act.set_actor_label(label)
        return act

    # 1. Colossal Ground Plaza Foundation (Tiered Stone Slabs)
    spawn_mesh(ruins_assets['C'], unreal.Vector(0, 0, -20), unreal.Rotator(0, 0, 0), unreal.Vector(40, 40, 0.4), "Foundation_GrandPlaza")

    # 2. Outer Perimeter Fortified Ramparts
    # East Wall
    for i in range(-5, 6):
        m_letter = 'D' if i % 2 == 0 else 'I'
        spawn_mesh(ruins_assets[m_letter], unreal.Vector(2500, i * 400, 0), unreal.Rotator(0, 90, 0), unreal.Vector(4.0, 4.0, 4.0), f"Rampart_East_{i}")

    # West Wall
    for i in range(-5, 6):
        m_letter = 'L' if i % 2 == 0 else 'P'
        spawn_mesh(ruins_assets[m_letter], unreal.Vector(-2500, i * 400, 0), unreal.Rotator(0, 90, 0), unreal.Vector(4.0, 4.0, 4.0), f"Rampart_West_{i}")

    # North Wall (High Citadel Rear)
    for i in range(-6, 7):
        m_letter = 'S' if i % 2 == 0 else 'T'
        spawn_mesh(ruins_assets[m_letter], unreal.Vector(i * 380, 2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(4.0, 4.0, 4.0), f"Rampart_North_{i}")

    # South Wall with Grand Gate Portal
    for i in [-6, -5, -4, -3, -2, 2, 3, 4, 5, 6]:
        m_letter = 'V' if i % 2 == 0 else 'X'
        spawn_mesh(ruins_assets[m_letter], unreal.Vector(i * 380, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(4.0, 4.0, 4.0), f"Rampart_South_{i}")

    # 3. Monumental Gatehouse Bastions & Archways (South Entrance)
    spawn_mesh(ruins_assets['E'], unreal.Vector(-500, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(5.0, 5.0, 5.0), "Gatehouse_Bastion_Left")
    spawn_mesh(ruins_assets['F'], unreal.Vector(500, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(5.0, 5.0, 5.0), "Gatehouse_Bastion_Right")
    spawn_mesh(ruins_assets['G'], unreal.Vector(-250, -2400, 100), unreal.Rotator(0, 0, 0), unreal.Vector(4.5, 4.5, 4.5), "Gatehouse_Arch_Left")
    spawn_mesh(ruins_assets['H'], unreal.Vector(250, -2400, 100), unreal.Rotator(0, 0, 0), unreal.Vector(4.5, 4.5, 4.5), "Gatehouse_Arch_Right")

    # Corner Bastion Towers (4 Quads)
    spawn_mesh(ruins_assets['A'], unreal.Vector(2500, 2400, 0), unreal.Rotator(0, 45, 0), unreal.Vector(6.0, 6.0, 6.0), "Bastion_Corner_NE")
    spawn_mesh(ruins_assets['B'], unreal.Vector(-2500, 2400, 0), unreal.Rotator(0, -45, 0), unreal.Vector(6.0, 6.0, 6.0), "Bastion_Corner_NW")
    spawn_mesh(ruins_assets['A'], unreal.Vector(2500, -2400, 0), unreal.Rotator(0, 135, 0), unreal.Vector(6.0, 6.0, 6.0), "Bastion_Corner_SE")
    spawn_mesh(ruins_assets['B'], unreal.Vector(-2500, -2400, 0), unreal.Rotator(0, -135, 0), unreal.Vector(6.0, 6.0, 6.0), "Bastion_Corner_SW")

    # 4. Processional Colonnade of the God-Kings (Ancient Pillars along central axis)
    for y_idx, y_pos in enumerate(range(-1800, 800, 350)):
        pillar_mesh_l = pillar_assets[y_idx % len(pillar_assets)]
        pillar_mesh_r = pillar_assets[(y_idx + 1) % len(pillar_assets)]
        spawn_mesh(pillar_mesh_l, unreal.Vector(-450, y_pos, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.4, 1.4, 1.4), f"Colonnade_Pillar_L_{y_idx}")
        spawn_mesh(pillar_mesh_r, unreal.Vector(450, y_pos, 0), unreal.Rotator(0, 180, 0), unreal.Vector(1.4, 1.4, 1.4), f"Colonnade_Pillar_R_{y_idx}")

    # 5. Inner Courtyard & Terraced Sanctuary Complex
    # Step 1: Lower Platform
    spawn_mesh(ruins_assets['M'], unreal.Vector(0, 1400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(10.0, 10.0, 3.0), "Sanctuary_Tier1_Base")
    # Step 2: Middle Terrace
    spawn_mesh(ruins_assets['N'], unreal.Vector(0, 1400, 150), unreal.Rotator(0, 0, 0), unreal.Vector(7.5, 7.5, 3.0), "Sanctuary_Tier2_Terrace")
    # Step 3: High Altar Cella
    spawn_mesh(ruins_assets['O'], unreal.Vector(0, 1400, 300), unreal.Rotator(0, 0, 0), unreal.Vector(5.0, 5.0, 4.0), "Sanctuary_Tier3_HighAltar")

    # Sanctuary Flanking Guardian Columns
    spawn_mesh(pillar_assets[2], unreal.Vector(-600, 1100, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.8, 1.8, 1.8), "Sanctuary_Guardian_Column_L")
    spawn_mesh(pillar_assets[2], unreal.Vector(600, 1100, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.8, 1.8, 1.8), "Sanctuary_Guardian_Column_R")
    spawn_mesh(pillar_assets[6], unreal.Vector(-600, 1700, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.8, 1.8, 1.8), "Sanctuary_Guardian_Column_BackL")
    spawn_mesh(pillar_assets[6], unreal.Vector(600, 1700, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.8, 1.8, 1.8), "Sanctuary_Guardian_Column_BackR")

    # 6. Wing Plazas: War Forges (East) & Grain Granary Vaults (West)
    # War Forge Precinct
    spawn_mesh(ruins_assets['Q'], unreal.Vector(1400, 200, 0), unreal.Rotator(0, 0, 0), unreal.Vector(6.0, 6.0, 3.5), "WarForge_Foundation")
    spawn_mesh(pillar_assets[0], unreal.Vector(1150, 450, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), "WarForge_Col_1")
    spawn_mesh(pillar_assets[1], unreal.Vector(1650, 450, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), "WarForge_Col_2")
    spawn_mesh(ruins_assets['R'], unreal.Vector(1400, 600, 0), unreal.Rotator(0, 90, 0), unreal.Vector(4.0, 4.0, 4.0), "WarForge_RearWall")

    # Grain Granary Vault Precinct
    spawn_mesh(ruins_assets['U'], unreal.Vector(-1400, 200, 0), unreal.Rotator(0, 0, 0), unreal.Vector(6.0, 6.0, 3.5), "GranaryVault_Foundation")
    spawn_mesh(pillar_assets[3], unreal.Vector(-1150, 450, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), "GranaryVault_Col_1")
    spawn_mesh(pillar_assets[4], unreal.Vector(-1650, 450, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), "GranaryVault_Col_2")
    spawn_mesh(ruins_assets['W'], unreal.Vector(-1400, 600, 0), unreal.Rotator(0, -90, 0), unreal.Vector(4.0, 4.0, 4.0), "GranaryVault_RearWall")

    # 7. Courtyard Symmetrical Monuments & Paved Walkways
    spawn_mesh(ruins_assets['J'], unreal.Vector(-1000, -800, 0), unreal.Rotator(0, 30, 0), unreal.Vector(3.5, 3.5, 3.5), "Courtyard_Monument_West")
    spawn_mesh(ruins_assets['K'], unreal.Vector(1000, -800, 0), unreal.Rotator(0, -30, 0), unreal.Vector(3.5, 3.5, 3.5), "Courtyard_Monument_East")
    spawn_mesh(ruins_assets['Y'], unreal.Vector(-800, -1600, 0), unreal.Rotator(0, 45, 0), unreal.Vector(3.0, 3.0, 3.0), "Courtyard_Altar_SW")
    spawn_mesh(ruins_assets['Z'], unreal.Vector(800, -1600, 0), unreal.Rotator(0, -45, 0), unreal.Vector(3.0, 3.0, 3.0), "Courtyard_Altar_SE")

    # Save the level
    unreal.EditorLoadingAndSavingUtils.save_map(world, "/Game/TopDown/Lvl_TopDown")
    print("SUCCESS: Mesopotamian Citadel Level Assembled and Saved successfully!")

assemble_citadel_level()
