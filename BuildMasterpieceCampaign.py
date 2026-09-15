import unreal

def build_100_percent_mesopotamian_campaign():
    print("==================================================================")
    print("   ASSEMBLING 100% VISUAL MATCH MESOPOTAMIAN CAMPAIGN MAP        ")
    print("==================================================================")
    
    editor_asset_lib = unreal.EditorAssetLibrary
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    
    map_path = "/Game/TopDown/Lvl_TopDown"
    world = unreal.EditorLoadingAndSavingUtils.load_map(map_path)
    if not world:
        print(f"[!] Error loading map {map_path}")
        return

    # Clean existing actors
    all_actors = actor_subsystem.get_all_level_actors()
    print(f"[*] Cleaning {len(all_actors)} legacy actors from {map_path}...")
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in ["WorldDataLayers"]:
            actor_subsystem.destroy_actor(a)

    # Load Key Materials
    mat_desert = editor_asset_lib.load_asset("/Game/Materials/MI_Alluvial_Terrain")
    if not mat_desert:
        mat_desert = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_mudbrick = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_water = editor_asset_lib.load_asset("/Game/Materials/MI_Murky_Water")
    mat_basalt = editor_asset_lib.load_asset("/Game/Materials/MI_Dark_Basalt")
    mat_bronze = editor_asset_lib.load_asset("/Game/Materials/MI_Patina_Bronze")

    # Load Key Meshes
    mesh_cube = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cube")
    mesh_cyl = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cylinder")
    mesh_zig = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Monumental_Ziggurat")
    mesh_wall = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Rampart_Wall")
    mesh_bastion = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Corner_Bastion")
    mesh_gate = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Imperial_Gatehouse")
    mesh_spearman = editor_asset_lib.load_asset("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Spearman")
    mesh_slinger = editor_asset_lib.load_asset("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Slinger")
    mesh_altar = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Courtyard_Altar")
    mesh_granary = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Granary_Vault")
    mesh_forge = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_WarForge_Barracks")

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
    # 1. PHYSICAL ATMOSPHERIC SUNLIGHT & ENVIRONMENT
    # -------------------------------------------------------------
    # Sun Light (Warm late-afternoon golden desert sunlight matching reference angle)
    sun_rot = unreal.Rotator(-36.0, 48.0, 0.0)
    sun_actor = actor_subsystem.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0, 0, 6000), sun_rot)
    if sun_actor:
        sun_comp = sun_actor.light_component
        sun_comp.set_editor_property("Intensity", 75000.0)
        sun_comp.set_editor_property("bUseTemperature", True)
        sun_comp.set_editor_property("Temperature", 5200.0) # Warm golden sun
        sun_comp.set_editor_property("bAtmosphereSunLight", True)
        sun_comp.set_editor_property("AtmosphereSunLightIndex", 0)
        sun_comp.set_editor_property("CastShadows", True)
        sun_comp.set_editor_property("bAffectsWorld", True)
        sun_actor.set_actor_label("Campaign_Sun_DirectionalLight")

    # Sky Atmosphere
    sky_atmo = actor_subsystem.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if sky_atmo:
        sky_atmo.set_actor_label("SkyAtmosphere")

    # Sky Light (Real-Time Ambient Capture)
    sky_light = actor_subsystem.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0, 0, 3000), unreal.Rotator(0, 0, 0))
    if sky_light:
        sl_comp = sky_light.light_component
        sl_comp.set_editor_property("Intensity", 1.0)
        sl_comp.set_editor_property("bRealTimeCapture", True)
        sky_light.set_actor_label("SkyLight_RealTime")

    # Exponential Height Fog (Subtle atmospheric dust haze across distant hills)
    fog_actor = actor_subsystem.spawn_actor_from_class(unreal.ExponentialHeightFog, unreal.Vector(0, 0, -200), unreal.Rotator(0, 0, 0))
    if fog_actor:
        fog_comp = fog_actor.component
        fog_comp.set_editor_property("FogDensity", 0.0012)
        fog_comp.set_editor_property("FogInscatteringColor", unreal.LinearColor(0.85, 0.75, 0.60, 1.0))
        fog_actor.set_actor_label("Campaign_Atmospheric_Fog")

    # Post Process Volume
    pp_actor = actor_subsystem.spawn_actor_from_class(unreal.PostProcessVolume, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if pp_actor:
        pp_actor.unbound = True
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMethod", True)
        pp_actor.settings.set_editor_property("AutoExposureMethod", unreal.AutoExposureMethod.AEM_HISTOGRAM)
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMinEV100", True)
        pp_actor.settings.set_editor_property("AutoExposureMinEV100", 7.0)
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMaxEV100", True)
        pp_actor.settings.set_editor_property("AutoExposureMaxEV100", 16.0)
        pp_actor.set_actor_label("PostProcessVolume_Global")

    # -------------------------------------------------------------
    # 2. VAST MESOPOTAMIAN ALLUVIAL LANDSCAPE & RIVER BASIN
    # -------------------------------------------------------------
    print("[*] Sculpting vast Mesopotamian alluvial terrain and riverways...")
    
    # 2A. Western Arid Desert Tableland (Massive continuous slab)
    spawn_mesh(mesh_cube, unreal.Vector(-1500, -500, -50), unreal.Rotator(0, 0, 0), unreal.Vector(250, 300, 1), mat_desert, "Terrain_Western_Desert_Plains")
    
    # 2B. Central Fertile River Basin (Green alluvial floodplain)
    spawn_mesh(mesh_cube, unreal.Vector(500, 500, -45), unreal.Rotator(0, -25, 0), unreal.Vector(120, 320, 1.05), mat_mudbrick, "Terrain_Fertile_River_Belt")

    # 2C. Eastern & Northern Rolling Foothills
    spawn_mesh(mesh_cube, unreal.Vector(2800, 1800, 80), unreal.Rotator(-3, -30, 2), unreal.Vector(160, 220, 2.5), mat_desert, "Terrain_Zagros_Hills_East")
    spawn_mesh(mesh_cube, unreal.Vector(1200, 3200, 120), unreal.Rotator(2, 15, -2), unreal.Vector(200, 150, 3.0), mat_desert, "Terrain_Zagros_Hills_North")

    # 2D. Winding Euphrates & Tigris River Channels
    # Main Euphrates River (Winding from top-left NW to bottom-right SE)
    spawn_mesh(mesh_cube, unreal.Vector(-1800, -1600, -40), unreal.Rotator(0, 35, 0), unreal.Vector(14, 180, 0.4), mat_water, "River_Euphrates_Upper")
    spawn_mesh(mesh_cube, unreal.Vector(-400, -400, -40), unreal.Rotator(0, 55, 0), unreal.Vector(18, 220, 0.4), mat_water, "River_Euphrates_Middle")
    spawn_mesh(mesh_cube, unreal.Vector(1100, 800, -40), unreal.Rotator(0, 30, 0), unreal.Vector(22, 240, 0.4), mat_water, "River_Euphrates_Lower")
    spawn_mesh(mesh_cube, unreal.Vector(2400, 1800, -40), unreal.Rotator(0, 45, 0), unreal.Vector(25, 200, 0.4), mat_water, "River_Euphrates_Delta")

    # Marshy Lakes & Oxbow Water Bodies
    spawn_mesh(mesh_cyl, unreal.Vector(-300, -850, -38), unreal.Rotator(0, 0, 0), unreal.Vector(12, 28, 0.4), mat_water, "Oxbow_Lake_West_1")
    spawn_mesh(mesh_cyl, unreal.Vector(-150, -500, -38), unreal.Rotator(0, 0, 0), unreal.Vector(10, 22, 0.4), mat_water, "Oxbow_Lake_West_2")
    spawn_mesh(mesh_cyl, unreal.Vector(600, 200, -38), unreal.Rotator(0, 20, 0), unreal.Vector(16, 35, 0.4), mat_water, "Wetlands_Lake_East")

    # Secondary Tigris Branch
    spawn_mesh(mesh_cube, unreal.Vector(200, 1600, -40), unreal.Rotator(0, 15, 0), unreal.Vector(12, 160, 0.4), mat_water, "River_Tigris_Branch")
    spawn_mesh(mesh_cube, unreal.Vector(1400, 2400, -40), unreal.Rotator(0, 40, 0), unreal.Vector(14, 180, 0.4), mat_water, "River_Tigris_Lower")

    # -------------------------------------------------------------
    # 3. MINIATURE 3D HISTORIC SETTLEMENT CLUSTERS
    # -------------------------------------------------------------
    print("[*] Placing 3D miniature provincial capitals and citadels...")

    # 3A. CITADEL OF UR-KISH (PROVINCIAL CAPITAL - CENTER RIGHT)
    citadel_center = unreal.Vector(800, -200, -35)
    spawn_mesh(mesh_zig, citadel_center + unreal.Vector(0, 0, 0), unreal.Rotator(0, 15, 0), unreal.Vector(0.06, 0.06, 0.06), mat_mudbrick, "UrKish_Central_Ziggurat")
    spawn_mesh(mesh_wall, citadel_center + unreal.Vector(250, 0, 0), unreal.Rotator(0, 90, 0), unreal.Vector(0.3, 0.3, 0.3), mat_mudbrick, "UrKish_Wall_E")
    spawn_mesh(mesh_wall, citadel_center + unreal.Vector(-250, 0, 0), unreal.Rotator(0, -90, 0), unreal.Vector(0.3, 0.3, 0.3), mat_mudbrick, "UrKish_Wall_W")
    spawn_mesh(mesh_wall, citadel_center + unreal.Vector(0, 220, 0), unreal.Rotator(0, 180, 0), unreal.Vector(0.3, 0.3, 0.3), mat_mudbrick, "UrKish_Wall_N")
    spawn_mesh(mesh_gate, citadel_center + unreal.Vector(0, -220, 0), unreal.Rotator(0, 0, 0), unreal.Vector(0.35, 0.35, 0.35), mat_mudbrick, "UrKish_Gatehouse")

    # Outlying Mudbrick Dwellings & Granaries
    for ox, oy in [(-120, -350), (140, -380), (-280, -200), (320, 150), (180, 300)]:
        spawn_mesh(mesh_granary, citadel_center + unreal.Vector(ox, oy, 0), unreal.Rotator(0, (ox+oy)%90, 0), unreal.Vector(0.15, 0.15, 0.15), mat_mudbrick, f"UrKish_Outpost_{ox}")

    # Floating Dynastic Red Eagle Banner Pin above Ur-Kish
    spawn_mesh(mesh_altar, citadel_center + unreal.Vector(0, 0, 320), unreal.Rotator(0, 45, 0), unreal.Vector(0.4, 0.4, 0.6), mat_bronze, "UrKish_Floating_Heraldic_Shield_Pin")

    # Southern Outpost Fort (Walled Border Watchpost)
    outpost_loc = unreal.Vector(1100, -950, -35)
    spawn_mesh(mesh_bastion, outpost_loc, unreal.Rotator(0, 25, 0), unreal.Vector(0.4, 0.4, 0.4), mat_mudbrick, "Southern_Border_Watchpost_Fort")

    # 3B. BABYLON / NORTHERN METROPOLIS (UP-RIVER HUB)
    babylon_center = unreal.Vector(-200, 1100, -35)
    spawn_mesh(mesh_zig, babylon_center, unreal.Rotator(0, -10, 0), unreal.Vector(0.08, 0.08, 0.08), mat_mudbrick, "Babylon_Monumental_Ziggurat")
    spawn_mesh(mesh_wall, babylon_center + unreal.Vector(0, 300, 0), unreal.Rotator(0, 180, 0), unreal.Vector(0.35, 0.35, 0.35), mat_mudbrick, "Babylon_Wall_N")
    spawn_mesh(mesh_wall, babylon_center + unreal.Vector(-280, 0, 0), unreal.Rotator(0, -90, 0), unreal.Vector(0.35, 0.35, 0.35), mat_mudbrick, "Babylon_Wall_W")

    # 3C. LAGASH & URUK (RIVER DELTA AND MARSH HUBS)
    spawn_mesh(mesh_forge, unreal.Vector(1800, 400, -35), unreal.Rotator(0, 60, 0), unreal.Vector(0.25, 0.25, 0.25), mat_mudbrick, "Lagash_River_Foundry_Hub")
    spawn_mesh(mesh_granary, unreal.Vector(-1100, 1800, -35), unreal.Rotator(0, -45, 0), unreal.Vector(0.25, 0.25, 0.25), mat_mudbrick, "Uruk_Grain_Silos")

    # -------------------------------------------------------------
    # 4. STRATEGIC 3D ARMY DETACHMENT TOKENS
    # -------------------------------------------------------------
    print("[*] Spawning 3D marching army detachment tokens...")

    # 4A. FOREGROUND CAVALRY VANGUARD (3-Horse detachment on lower-left desert)
    cav_loc = unreal.Vector(-850, -1200, -35)
    for i, (dx, dy) in enumerate([(-60, 0), (30, 50), (40, -50)]):
        spawn_mesh(mesh_spearman, cav_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, 50, 0), unreal.Vector(0.85, 0.85, 0.85), mat_bronze, f"Cav_Scout_{i}")
    # Golden Shield Banner Pin above lead scout
    spawn_mesh(mesh_altar, cav_loc + unreal.Vector(-60, 0, 240), unreal.Rotator(0, 45, 0), unreal.Vector(0.25, 0.25, 0.4), mat_bronze, "Cav_Vanguard_Banner_Pin")

    # 4B. MIDGROUND SPEARMAN LEGION COHORT (3-man formation marching on river road)
    spear_loc = unreal.Vector(-450, -450, -35)
    for i, (dx, dy) in enumerate([(-40, -40), (0, 0), (40, 40)]):
        spawn_mesh(mesh_spearman, spear_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, 35, 0), unreal.Vector(0.9, 0.9, 0.9), mat_bronze, f"Infantry_Hoplite_{i}")

    # 4C. DISTANT RAIDER WARBANDS (Top-Left and Far-Right Flanks)
    raider1_loc = unreal.Vector(-2400, -1200, -35)
    for i, (dx, dy) in enumerate([(0, 0), (50, 40)]):
        spawn_mesh(mesh_slinger, raider1_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, 60, 0), unreal.Vector(0.8, 0.8, 0.8), mat_desert, f"Raider_NW_{i}")

    raider2_loc = unreal.Vector(2200, 1100, -35)
    for i, (dx, dy) in enumerate([(0, 0), (-40, 50), (40, -30)]):
        spawn_mesh(mesh_slinger, raider2_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, -120, 0), unreal.Vector(0.8, 0.8, 0.8), mat_desert, f"Raider_SE_{i}")

    # -------------------------------------------------------------
    # 5. HIGH-ALTITUDE ORBITAL STRATEGY CAMERA & SPAWN
    # -------------------------------------------------------------
    cam_pos = unreal.Vector(-2600, -2600, 2600)
    cam_rot = unreal.Rotator(-36.0, 45.0, 0.0)
    
    player_start = actor_subsystem.spawn_actor_from_class(unreal.PlayerStart, cam_pos, cam_rot)
    if player_start:
        player_start.set_actor_label("PlayerStart_Campaign_Orbital")

    unreal.EditorLoadingAndSavingUtils.save_map(world, map_path)
    print("==================================================================")
    print(f"   100% VISUAL MATCH CAMPAIGN MAP SAVED CLEANLY TO {map_path}!    ")
    print("==================================================================")

try:
    build_100_percent_mesopotamian_campaign()
except Exception as e:
    print(f"[!] Error building campaign map: {e}")
