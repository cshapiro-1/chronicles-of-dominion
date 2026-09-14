import unreal

def assemble_masterwork_citadel():
    print("==========================================================")
    print("   ASSEMBLING MASTERWORK MESOPOTAMIAN CITADEL LEVEL")
    print("==========================================================")
    
    world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/TopDown/Lvl_TopDown")
    if not world:
        print("Error: Could not load /Game/TopDown/Lvl_TopDown")
        return

    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    editor_asset_lib = unreal.EditorAssetLibrary

    # 1. Clear out all non-lighting actors
    all_actors = actor_subsystem.get_all_level_actors()
    retain_classes = ["DirectionalLight", "SkyLight", "SkyAtmosphere", "ExponentialHeightFog", "PostProcessVolume", "PlayerStart", "WorldDataLayers"]
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in retain_classes:
            actor_subsystem.destroy_actor(a)

    print("Cleared previous geometry.")

    # 2. Load authentic Ancient Ruins (SM_ISOA - SM_ISOZ) and Ancient Pillars (SM_Pillars_01 - 08)
    ruins = {}
    for c in range(ord('A'), ord('Z')+1):
        letter = chr(c)
        mesh = editor_asset_lib.load_asset(f"/Game/Ancient_Ruins/Meshes/SM_ISO{letter}")
        ruins[letter] = mesh

    pillars = [
        editor_asset_lib.load_asset(f"/Game/Ancient_Pillars/Meshes/Joined/SM_Pillars_0{i}") for i in range(1, 9)
    ]

    def place_mesh(mesh, loc, rot=unreal.Rotator(0,0,0), scale=unreal.Vector(1,1,1), label="Citadel_Element"):
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

    # 3. Ground Terrain Foundation (Interlocking large masonry paving slabs)
    for gx in range(-3, 4):
        for gy in range(-3, 4):
            place_mesh(ruins['C'], unreal.Vector(gx * 800, gy * 800, -10), unreal.Rotator(0, (gx*90)%360, 0), unreal.Vector(8.5, 8.5, 0.3), f"Ground_Slab_{gx}_{gy}")

    # 4. Outer Fortified Curtain Walls
    # East Rampart Wall
    for i in range(-5, 6):
        m = ruins['D'] if i % 2 == 0 else ruins['I']
        place_mesh(m, unreal.Vector(2500, i * 400, 0), unreal.Rotator(0, 90, 0), unreal.Vector(4.2, 4.2, 4.2), f"Wall_East_{i}")

    # West Rampart Wall
    for i in range(-5, 6):
        m = ruins['L'] if i % 2 == 0 else ruins['P']
        place_mesh(m, unreal.Vector(-2500, i * 400, 0), unreal.Rotator(0, -90, 0), unreal.Vector(4.2, 4.2, 4.2), f"Wall_West_{i}")

    # North Rear Rampart Wall
    for i in range(-5, 6):
        m = ruins['S'] if i % 2 == 0 else ruins['T']
        place_mesh(m, unreal.Vector(i * 400, 2400, 0), unreal.Rotator(0, 180, 0), unreal.Vector(4.2, 4.2, 4.2), f"Wall_North_{i}")

    # South Front Wall (flanking the gate)
    for i in [-5, -4, -3, -2, 2, 3, 4, 5]:
        m = ruins['V'] if i % 2 == 0 else ruins['X']
        place_mesh(m, unreal.Vector(i * 400, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(4.2, 4.2, 4.2), f"Wall_South_{i}")

    # 5. Monumental South Gatehouse (Twin Bastions + Entry Arches)
    place_mesh(ruins['E'], unreal.Vector(-500, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(5.5, 5.5, 5.5), "Gatehouse_Bastion_Left")
    place_mesh(ruins['F'], unreal.Vector(500, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(5.5, 5.5, 5.5), "Gatehouse_Bastion_Right")
    place_mesh(ruins['G'], unreal.Vector(-250, -2400, 80), unreal.Rotator(0, 0, 0), unreal.Vector(4.5, 4.5, 4.5), "Gatehouse_Arch_Left")
    place_mesh(ruins['H'], unreal.Vector(250, -2400, 80), unreal.Rotator(0, 0, 0), unreal.Vector(4.5, 4.5, 4.5), "Gatehouse_Arch_Right")

    # 6. Corner Bastion Towers (4 Massive Fortified Corners)
    place_mesh(ruins['A'], unreal.Vector(2500, 2400, 0), unreal.Rotator(0, 45, 0), unreal.Vector(6.5, 6.5, 6.5), "Bastion_Corner_NE")
    place_mesh(ruins['B'], unreal.Vector(-2500, 2400, 0), unreal.Rotator(0, -45, 0), unreal.Vector(6.5, 6.5, 6.5), "Bastion_Corner_NW")
    place_mesh(ruins['A'], unreal.Vector(2500, -2400, 0), unreal.Rotator(0, 135, 0), unreal.Vector(6.5, 6.5, 6.5), "Bastion_Corner_SE")
    place_mesh(ruins['B'], unreal.Vector(-2500, -2400, 0), unreal.Rotator(0, -135, 0), unreal.Vector(6.5, 6.5, 6.5), "Bastion_Corner_SW")

    # 7. Processional Colonnade of the God-Kings (Ancient Pillars)
    for y_idx, y_pos in enumerate(range(-1900, 400, 320)):
        p_left = pillars[y_idx % len(pillars)]
        p_right = pillars[(y_idx + 2) % len(pillars)]
        place_mesh(p_left, unreal.Vector(-450, y_pos, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.4, 1.4, 1.4), f"Colonnade_Pillar_L_{y_idx}")
        place_mesh(p_right, unreal.Vector(450, y_pos, 0), unreal.Rotator(0, 180, 0), unreal.Vector(1.4, 1.4, 1.4), f"Colonnade_Pillar_R_{y_idx}")

    # 8. High Terraced Ziggurat Sanctuary Complex (North Apex)
    # Tier 1 (Grand Base Podium)
    place_mesh(ruins['M'], unreal.Vector(0, 1500, 0), unreal.Rotator(0, 0, 0), unreal.Vector(12.0, 12.0, 3.5), "Ziggurat_Tier1_Base")
    # Tier 2 (Middle Terrace)
    place_mesh(ruins['N'], unreal.Vector(0, 1500, 160), unreal.Rotator(0, 0, 0), unreal.Vector(8.5, 8.5, 3.5), "Ziggurat_Tier2_Terrace")
    # Tier 3 (High Altar Cella Shrine)
    place_mesh(ruins['O'], unreal.Vector(0, 1500, 320), unreal.Rotator(0, 0, 0), unreal.Vector(5.5, 5.5, 4.5), "Ziggurat_Tier3_HighAltar")
    # Flanking Guardian Colonnades
    place_mesh(pillars[2], unreal.Vector(-700, 1200, 0), unreal.Rotator(0, 0, 0), unreal.Vector(2.0, 2.0, 2.0), "Ziggurat_Guardian_Column_FL")
    place_mesh(pillars[2], unreal.Vector(700, 1200, 0), unreal.Rotator(0, 0, 0), unreal.Vector(2.0, 2.0, 2.0), "Ziggurat_Guardian_Column_FR")
    place_mesh(pillars[6], unreal.Vector(-700, 1800, 0), unreal.Rotator(0, 0, 0), unreal.Vector(2.0, 2.0, 2.0), "Ziggurat_Guardian_Column_BL")
    place_mesh(pillars[6], unreal.Vector(700, 1800, 0), unreal.Rotator(0, 0, 0), unreal.Vector(2.0, 2.0, 2.0), "Ziggurat_Guardian_Column_BR")

    # 9. East Wing: War Forge & Foundry Precinct
    place_mesh(ruins['Q'], unreal.Vector(1400, 0, 0), unreal.Rotator(0, 0, 0), unreal.Vector(7.0, 7.0, 3.5), "WarForge_Plaza")
    place_mesh(ruins['R'], unreal.Vector(1400, 450, 0), unreal.Rotator(0, 90, 0), unreal.Vector(5.0, 5.0, 5.0), "WarForge_RearWall")
    place_mesh(pillars[0], unreal.Vector(1150, 250, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.3, 1.3, 1.3), "WarForge_Column_1")
    place_mesh(pillars[1], unreal.Vector(1650, 250, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.3, 1.3, 1.3), "WarForge_Column_2")

    # 10. West Wing: Granary Vault Precinct
    place_mesh(ruins['U'], unreal.Vector(-1400, 0, 0), unreal.Rotator(0, 0, 0), unreal.Vector(7.0, 7.0, 3.5), "GranaryVault_Plaza")
    place_mesh(ruins['W'], unreal.Vector(-1400, 450, 0), unreal.Rotator(0, -90, 0), unreal.Vector(5.0, 5.0, 5.0), "GranaryVault_RearWall")
    place_mesh(pillars[3], unreal.Vector(-1150, 250, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.3, 1.3, 1.3), "GranaryVault_Column_1")
    place_mesh(pillars[4], unreal.Vector(-1650, 250, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.3, 1.3, 1.3), "GranaryVault_Column_2")

    # 11. Courtyard Ceremonial Shrines & Altars
    place_mesh(ruins['J'], unreal.Vector(-950, -900, 0), unreal.Rotator(0, 30, 0), unreal.Vector(4.0, 4.0, 4.0), "Courtyard_Monument_West")
    place_mesh(ruins['K'], unreal.Vector(950, -900, 0), unreal.Rotator(0, -30, 0), unreal.Vector(4.0, 4.0, 4.0), "Courtyard_Monument_East")
    place_mesh(ruins['Y'], unreal.Vector(-750, -1650, 0), unreal.Rotator(0, 45, 0), unreal.Vector(3.5, 3.5, 3.5), "Courtyard_Altar_SW")
    place_mesh(ruins['Z'], unreal.Vector(750, -1650, 0), unreal.Rotator(0, -45, 0), unreal.Vector(3.5, 3.5, 3.5), "Courtyard_Altar_SE")

    # Save level
    unreal.EditorLoadingAndSavingUtils.save_map(world, "/Game/TopDown/Lvl_TopDown")
    print("SUCCESS: Masterwork Mesopotamian Citadel Level Assembled & Saved with Authentic Textured PBR Assets!")

assemble_masterwork_citadel()
