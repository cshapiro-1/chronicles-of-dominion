import unreal

def build_masterpiece_citadel():
    print("==================================================================")
    print("   BUILDING MASTERWORK MESOPOTAMIAN CITADEL LEVEL (Lvl_TopDown)   ")
    print("==================================================================")
    
    editor_asset_lib = unreal.EditorAssetLibrary
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    
    world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/TopDown/Lvl_TopDown")
    if not world:
        print("[!] Error loading map /Game/TopDown/Lvl_TopDown")
        return

    # 1. Clean out all existing level actors completely
    all_actors = actor_subsystem.get_all_level_actors()
    print(f"[*] Removing {len(all_actors)} legacy/fragmented actors...")
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in ["WorldDataLayers"]:
            actor_subsystem.destroy_actor(a)
            
    # Load Key Materials
    mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Alluvial_Terrain")
    if not mat_terrain:
        mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_mudbrick = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_ziggurat = editor_asset_lib.load_asset("/Game/Materials/MI_Citadel_Ziggurat")
    mat_basalt = editor_asset_lib.load_asset("/Game/Materials/MI_Dark_Basalt")
    mat_bronze = editor_asset_lib.load_asset("/Game/Materials/MI_Patina_Bronze")
    
    # Load Key Meshes
    mesh_cube = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cube")
    mesh_zig = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Monumental_Ziggurat")
    mesh_wall = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Rampart_Wall")
    mesh_bastion = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Corner_Bastion")
    mesh_gate = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Imperial_Gatehouse")
    mesh_pillar_dae = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Processional_Pillar")
    mesh_pillar_01 = editor_asset_lib.load_asset("/Game/Ancient_Pillars/Meshes/SM_Pillars_01")
    mesh_pillar_02 = editor_asset_lib.load_asset("/Game/Ancient_Pillars/Meshes/SM_Pillars_02")
    mesh_granary = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Granary_Vault")
    mesh_forge = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_WarForge_Barracks")
    mesh_altar = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Courtyard_Altar")

    def spawn_mesh(mesh, loc, rot=unreal.Rotator(0, 0, 0), scale=unreal.Vector(1, 1, 1), mat=None, label="Actor"):
        if not mesh:
            return None
        act = actor_subsystem.spawn_actor_from_class(unreal.StaticMeshActor, loc, rot)
        if act:
            smc = act.static_mesh_component
            smc.set_static_mesh(mesh)
            smc.set_world_scale3d(scale)
            smc.set_mobility(unreal.ComponentMobility.STATIC)
            smc.set_collision_profile_name("BlockAll")
            if mat:
                smc.set_material(0, mat)
            act.set_actor_label(label)
        return act

    # -------------------------------------------------------------
    # 2. ATMOSPHERIC LIGHTING & SKY (Golden Bronze Age Desert Sun)
    # -------------------------------------------------------------
    print("[*] Setting up Bronze-Age desert sun and atmosphere...")
    
    # Directional Sun Light
    sun_rot = unreal.Rotator(-40.0, 45.0, 0.0) # Pitched down 40 deg, Yaw 45 deg for dramatic shadows
    sun_actor = actor_subsystem.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0, 0, 2000), sun_rot)
    if sun_actor:
        sun_comp = sun_actor.light_component
        sun_comp.set_intensity(6.0)
        sun_comp.set_light_color(unreal.LinearColor(1.0, 0.92, 0.78, 1.0)) # Warm golden sunlight
        sun_comp.set_atmosphere_sun_light(True)
        sun_comp.set_atmosphere_sun_light_index(0)
        sun_comp.set_cast_shadows(True)
        sun_actor.set_actor_label("Sun_DirectionalLight")

    # Sky Atmosphere
    sky_atmo = actor_subsystem.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if sky_atmo:
        sky_atmo.set_actor_label("SkyAtmosphere")

    # Sky Light
    sky_light = actor_subsystem.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0, 0, 1000), unreal.Rotator(0, 0, 0))
    if sky_light:
        sl_comp = sky_light.light_component
        sl_comp.set_intensity(1.2)
        sl_comp.set_real_time_capture_enabled(True)
        sky_light.set_actor_label("SkyLight_RealTime")

    # Exponential Height Fog
    fog_actor = actor_subsystem.spawn_actor_from_class(unreal.ExponentialHeightFog, unreal.Vector(0, 0, -200), unreal.Rotator(0, 0, 0))
    if fog_actor:
        fog_comp = fog_actor.component
        fog_comp.set_fog_density(0.004)
        fog_comp.set_fog_inscattering_color(unreal.LinearColor(0.85, 0.75, 0.6, 1.0))
        fog_actor.set_actor_label("Desert_Atmospheric_Fog")

    # Post Process Volume
    pp_actor = actor_subsystem.spawn_actor_from_class(unreal.PostProcessVolume, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if pp_actor:
        pp_actor.unbound = True
        pp_actor.settings.auto_exposure_min_brightness = 1.0
        pp_actor.settings.auto_exposure_max_brightness = 1.0
        pp_actor.set_actor_label("PostProcessVolume_Global")

    # -------------------------------------------------------------
    # 3. SOLID CONTINUOUS GROUND FOUNDATION (Zero Holes / Zero Gaps)
    # -------------------------------------------------------------
    print("[*] Laying down solid mudbrick & alluvial terrain foundations...")
    
    # 3A. Massive Global Desert Terrain (200m x 200m solid slab)
    spawn_mesh(mesh_cube, unreal.Vector(0, 0, -100), unreal.Rotator(0, 0, 0), unreal.Vector(200, 200, 2), mat_terrain, "Terrain_Global_Desert_Slab")
    
    # 3B. Raised Citadel Paved Courtyard Platform (80m x 80m stone & brick plaza)
    spawn_mesh(mesh_cube, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0), unreal.Vector(64, 64, 0.4), mat_mudbrick, "Citadel_Courtyard_Plaza_Slab")

    # 3C. Processional Sacred Way Paved Causeway
    spawn_mesh(mesh_cube, unreal.Vector(0, -900, 5), unreal.Rotator(0, 0, 0), unreal.Vector(12, 34, 0.5), mat_basalt, "Avenue_Sacred_Way_Paving")

    # -------------------------------------------------------------
    # 4. MONUMENTAL ARCHITECTURE (Ziggurat, Walls, Gate, Bastions)
    # -------------------------------------------------------------
    print("[*] Erecting Monumental Citadel Architecture...")

    # 4A. Monumental 3-Tier Ziggurat Citadel (North Sector)
    spawn_mesh(mesh_zig, unreal.Vector(0, 1700, 20), unreal.Rotator(0, 0, 0), unreal.Vector(1.0, 1.0, 1.0), mat_ziggurat, "Monumental_Ziggurat_Citadel")

    # 4B. Fortified Perimeter Curtain Walls (East, West, North, South)
    # East Curtain Wall
    for i in range(-5, 6):
        spawn_mesh(mesh_wall, unreal.Vector(2800, i * 400, 20), unreal.Rotator(0, 90, 0), unreal.Vector(1.0, 1.0, 1.0), mat_mudbrick, f"Wall_East_{i+5}")
    # West Curtain Wall
    for i in range(-5, 6):
        spawn_mesh(mesh_wall, unreal.Vector(-2800, i * 400, 20), unreal.Rotator(0, -90, 0), unreal.Vector(1.0, 1.0, 1.0), mat_mudbrick, f"Wall_West_{i+5}")
    # North Curtain Wall
    for i in range(-6, 7):
        spawn_mesh(mesh_wall, unreal.Vector(i * 400, 2600, 20), unreal.Rotator(0, 180, 0), unreal.Vector(1.0, 1.0, 1.0), mat_mudbrick, f"Wall_North_{i+6}")
    # South Curtain Wall (flanking gatehouse portal)
    for i in [-6, -5, -4, -3, -2, 2, 3, 4, 5, 6]:
        spawn_mesh(mesh_wall, unreal.Vector(i * 400, -2600, 20), unreal.Rotator(0, 0, 0), unreal.Vector(1.0, 1.0, 1.0), mat_mudbrick, f"Wall_South_{i}")

    # 4C. Imperial Gatehouse (South Portal)
    spawn_mesh(mesh_gate, unreal.Vector(0, -2600, 20), unreal.Rotator(0, 0, 0), unreal.Vector(1.3, 1.3, 1.3), mat_mudbrick, "Imperial_Gatehouse_Portal")

    # 4D. 4 Fortified Corner Bastion Towers
    spawn_mesh(mesh_bastion, unreal.Vector(2800, 2600, 20), unreal.Rotator(0, 45, 0), unreal.Vector(1.5, 1.5, 1.5), mat_mudbrick, "Bastion_Corner_NE")
    spawn_mesh(mesh_bastion, unreal.Vector(-2800, 2600, 20), unreal.Rotator(0, -45, 0), unreal.Vector(1.5, 1.5, 1.5), mat_mudbrick, "Bastion_Corner_NW")
    spawn_mesh(mesh_bastion, unreal.Vector(2800, -2600, 20), unreal.Rotator(0, 135, 0), unreal.Vector(1.5, 1.5, 1.5), mat_mudbrick, "Bastion_Corner_SE")
    spawn_mesh(mesh_bastion, unreal.Vector(-2800, -2600, 20), unreal.Rotator(0, -135, 0), unreal.Vector(1.5, 1.5, 1.5), mat_mudbrick, "Bastion_Corner_SW")

    # -------------------------------------------------------------
    # 5. PROCESSIONAL COLONNADE & SACRED DISTRICTS
    # -------------------------------------------------------------
    print("[*] Placing Colonnade Avenue & Civic Districts...")

    # Processional Colonnade Avenue of Pillars (Flanking Central Sacred Way)
    pillar_mesh_to_use = mesh_pillar_01 if mesh_pillar_01 else mesh_pillar_dae
    pillar_scale = unreal.Vector(1.0, 1.0, 1.0) if mesh_pillar_01 else unreal.Vector(1.2, 1.2, 1.2)
    for idx, y_pos in enumerate(range(-2200, 400, 320)):
        spawn_mesh(pillar_mesh_to_use, unreal.Vector(-450, y_pos, 20), unreal.Rotator(0, 0, 0), pillar_scale, None, f"Colonnade_Pillar_L_{idx}")
        spawn_mesh(pillar_mesh_to_use, unreal.Vector(450, y_pos, 20), unreal.Rotator(0, 0, 0), pillar_scale, None, f"Colonnade_Pillar_R_{idx}")

    # East District: War Forge Barracks & Foundry
    spawn_mesh(mesh_forge, unreal.Vector(1500, -500, 20), unreal.Rotator(0, -90, 0), unreal.Vector(1.1, 1.1, 1.1), mat_mudbrick, "WarForge_Barracks_Foundry")

    # West District: Granary Silo Vaults
    spawn_mesh(mesh_granary, unreal.Vector(-1500, -500, 20), unreal.Rotator(0, 90, 0), unreal.Vector(1.1, 1.1, 1.1), mat_mudbrick, "Granary_Vault_Silos")

    # Courtyard Ceremonial Altars
    spawn_mesh(mesh_altar, unreal.Vector(-850, -1500, 20), unreal.Rotator(0, 45, 0), unreal.Vector(1.4, 1.4, 1.4), mat_bronze, "Altar_Sacred_West")
    spawn_mesh(mesh_altar, unreal.Vector(850, -1500, 20), unreal.Rotator(0, -45, 0), unreal.Vector(1.4, 1.4, 1.4), mat_bronze, "Altar_Sacred_East")

    # -------------------------------------------------------------
    # 6. PLAYER START & SPAWN POSITIONING
    # -------------------------------------------------------------
    player_start = actor_subsystem.spawn_actor_from_class(unreal.PlayerStart, unreal.Vector(0, -1800, 100), unreal.Rotator(0, 90, 0))
    if player_start:
        player_start.set_actor_label("PlayerStart_Courtyard")

    # Save level
    unreal.EditorLoadingAndSavingUtils.save_map(world, "/Game/TopDown/Lvl_TopDown")
    print("==================================================================")
    print("   MASTERWORK CITADEL REBUILT & SAVED CLEANLY TO Lvl_TopDown!    ")
    print("==================================================================")

build_masterpiece_citadel()
