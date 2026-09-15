import unreal

def setup_flawless_campaign_scene():
    editor_asset_lib = unreal.EditorAssetLibrary
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)

    map_path = "/Game/TopDown/Lvl_TopDown"
    world = unreal.EditorLoadingAndSavingUtils.load_map(map_path)
    if not world:
        unreal.log_error(f"Cannot load {map_path}")
        return

    # Clear all actors
    all_actors = actor_subsystem.get_all_level_actors()
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in ["WorldDataLayers"]:
            actor_subsystem.destroy_actor(a)

    # 1. Post Process Volume with UNRESTRICTED Auto-Exposure Range (Cannot Ever Go Black)
    pp_actor = actor_subsystem.spawn_actor_from_class(unreal.PostProcessVolume, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if pp_actor:
        pp_actor.unbound = True
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMethod", True)
        pp_actor.settings.set_editor_property("AutoExposureMethod", unreal.AutoExposureMethod.AEM_HISTOGRAM)
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMinEV100", True)
        pp_actor.settings.set_editor_property("AutoExposureMinEV100", -10.0) # Down to pitch dark
        pp_actor.settings.set_editor_property("bOverride_AutoExposureMaxEV100", True)
        pp_actor.settings.set_editor_property("AutoExposureMaxEV100", 20.0)  # Up to blazing sun
        pp_actor.settings.set_editor_property("bOverride_AutoExposureBias", True)
        pp_actor.settings.set_editor_property("AutoExposureBias", 1.0)
        pp_actor.set_actor_label("PostProcessVolume_Flawless")

    # 2. Powerful Directional Sun Light
    sun_actor = actor_subsystem.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0, 0, 5000), unreal.Rotator(-40.0, 45.0, 0.0))
    if sun_actor:
        sc = sun_actor.light_component
        sc.set_editor_property("Intensity", 100000.0) # 100K Lux Physical Sun
        sc.set_editor_property("bUseTemperature", True)
        sc.set_editor_property("Temperature", 5500.0)
        sc.set_editor_property("bAtmosphereSunLight", True)
        sc.set_editor_property("AtmosphereSunLightIndex", 0)
        sc.set_editor_property("CastShadows", True)
        sc.set_editor_property("bAffectsWorld", True)
        sun_actor.set_actor_label("Sun_DirectionalLight")

    # 3. Sky Atmosphere & Sky Light
    sky_atmo = actor_subsystem.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if sky_atmo:
        sky_atmo.set_actor_label("SkyAtmosphere")

    sky_light = actor_subsystem.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0, 0, 2000), unreal.Rotator(0, 0, 0))
    if sky_light:
        sl = sky_light.light_component
        sl.set_editor_property("Intensity", 5.0)
        sl.set_editor_property("bRealTimeCapture", True)
        sl.set_editor_property("bAffectsWorld", True)
        sky_light.set_actor_label("SkyLight_RealTime")

    # 4. Exponential Height Fog
    fog_actor = actor_subsystem.spawn_actor_from_class(unreal.ExponentialHeightFog, unreal.Vector(0, 0, -200), unreal.Rotator(0, 0, 0))
    if fog_actor:
        fc = fog_actor.component
        fc.set_editor_property("FogDensity", 0.001)
        fc.set_editor_property("FogInscatteringColor", unreal.LinearColor(0.85, 0.75, 0.60, 1.0))
        fog_actor.set_actor_label("Atmospheric_Desert_Fog")

    # Load Assets
    mesh_cube = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cube")
    mesh_cyl = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cylinder")
    mesh_zig = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Monumental_Ziggurat")
    mesh_wall = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Rampart_Wall")
    mesh_gate = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Imperial_Gatehouse")
    mesh_bastion = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Corner_Bastion")
    mesh_spearman = editor_asset_lib.load_asset("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Spearman")
    mesh_slinger = editor_asset_lib.load_asset("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Slinger")
    mesh_granary = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Granary_Vault")
    mesh_altar = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Courtyard_Altar")

    mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Alluvial_Terrain")
    if not mat_terrain:
        mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_mudbrick = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_water = editor_asset_lib.load_asset("/Game/Materials/MI_Murky_Water")
    mat_bronze = editor_asset_lib.load_asset("/Game/Materials/MI_Patina_Bronze")

    def spawn(mesh, loc, rot=unreal.Rotator(0,0,0), scale=unreal.Vector(1,1,1), mat=None, label="Actor"):
        if not mesh: return None
        act = actor_subsystem.spawn_actor_from_class(unreal.StaticMeshActor, loc, rot)
        if act:
            smc = act.static_mesh_component
            smc.set_static_mesh(mesh)
            smc.set_world_scale3d(scale)
            smc.set_mobility(unreal.ComponentMobility.STATIC)
            smc.set_collision_profile_name("BlockAll")
            if mat: smc.set_material(0, mat)
            act.set_actor_label(label)
        return act

    # 5. Massive Terrain Tableland (Centered at 0,0,0 - 1000m x 1000m continuous plane)
    spawn(mesh_cube, unreal.Vector(0, 0, -50), unreal.Rotator(0, 0, 0), unreal.Vector(600, 600, 1), mat_terrain, "Terrain_Global_Alluvial_Plane")

    # Fertile Corridor
    spawn(mesh_cube, unreal.Vector(600, 400, -45), unreal.Rotator(0, -25, 0), unreal.Vector(150, 400, 1.1), mat_mudbrick, "Terrain_Fertile_River_Corridor")

    # Winding Euphrates River
    spawn(mesh_cube, unreal.Vector(-2400, -2200, -40), unreal.Rotator(0, 35, 0), unreal.Vector(25, 300, 0.4), mat_water, "River_Euphrates_North")
    spawn(mesh_cube, unreal.Vector(-500, -500, -40), unreal.Rotator(0, 50, 0), unreal.Vector(28, 350, 0.4), mat_water, "River_Euphrates_Center")
    spawn(mesh_cube, unreal.Vector(1600, 1200, -40), unreal.Rotator(0, 32, 0), unreal.Vector(32, 350, 0.4), mat_water, "River_Euphrates_South")

    # Oxbow Lakes
    spawn(mesh_cyl, unreal.Vector(-400, -950, -38), unreal.Rotator(0, 0, 0), unreal.Vector(18, 38, 0.4), mat_water, "Oxbow_Lake_West")
    spawn(mesh_cyl, unreal.Vector(800, 300, -38), unreal.Rotator(0, 20, 0), unreal.Vector(22, 45, 0.4), mat_water, "Wetlands_Lake_East")

    # 6. Citadel of Ur-Kish (Center-Right at 800, -200)
    cc = unreal.Vector(800, -200, -35)
    spawn(mesh_zig, cc, unreal.Rotator(0, 15, 0), unreal.Vector(0.08, 0.08, 0.08), mat_mudbrick, "UrKish_Ziggurat")
    spawn(mesh_wall, cc + unreal.Vector(300, 0, 0), unreal.Rotator(0, 90, 0), unreal.Vector(0.4, 0.4, 0.4), mat_mudbrick, "UrKish_Wall_E")
    spawn(mesh_wall, cc + unreal.Vector(-300, 0, 0), unreal.Rotator(0, -90, 0), unreal.Vector(0.4, 0.4, 0.4), mat_mudbrick, "UrKish_Wall_W")
    spawn(mesh_wall, cc + unreal.Vector(0, 280, 0), unreal.Rotator(0, 180, 0), unreal.Vector(0.4, 0.4, 0.4), mat_mudbrick, "UrKish_Wall_N")
    spawn(mesh_gate, cc + unreal.Vector(0, -280, 0), unreal.Rotator(0, 0, 0), unreal.Vector(0.45, 0.45, 0.45), mat_mudbrick, "UrKish_Gate")

    # Outlying Dwellings
    for ox, oy in [(-180, -420), (180, -450), (-350, -250), (400, 180), (220, 380)]:
        spawn(mesh_granary, cc + unreal.Vector(ox, oy, 0), unreal.Rotator(0, (ox+oy)%90, 0), unreal.Vector(0.2, 0.2, 0.2), mat_mudbrick, f"UrKish_Dwelling_{ox}")

    # Floating Heraldic Shield Pin
    spawn(mesh_altar, cc + unreal.Vector(0, 0, 380), unreal.Rotator(0, 45, 0), unreal.Vector(0.5, 0.5, 0.8), mat_bronze, "UrKish_Heraldic_Shield_Pin")

    # Southern Border Fort
    spawn(mesh_bastion, unreal.Vector(1300, -1100, -35), unreal.Rotator(0, 25, 0), unreal.Vector(0.5, 0.5, 0.5), mat_mudbrick, "Southern_Watchpost_Fort")

    # Babylon Metropolis (Up-River)
    bc = unreal.Vector(-300, 1400, -35)
    spawn(mesh_zig, bc, unreal.Rotator(0, -10, 0), unreal.Vector(0.1, 0.1, 0.1), mat_mudbrick, "Babylon_Ziggurat")
    spawn(mesh_wall, bc + unreal.Vector(0, 350, 0), unreal.Rotator(0, 180, 0), unreal.Vector(0.45, 0.45, 0.45), mat_mudbrick, "Babylon_Wall")

    # 7. Army Tokens
    # Cavalry Vanguard (Foreground Left)
    cav_loc = unreal.Vector(-950, -1350, -35)
    for i, (dx, dy) in enumerate([(-70, 0), (35, 60), (45, -60)]):
        spawn(mesh_spearman, cav_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, 50, 0), unreal.Vector(1.1, 1.1, 1.1), mat_bronze, f"Cav_Scout_{i}")
    spawn(mesh_altar, cav_loc + unreal.Vector(-70, 0, 280), unreal.Rotator(0, 45, 0), unreal.Vector(0.3, 0.3, 0.5), mat_bronze, "Cav_Banner_Pin")

    # Spearman Legion Cohort (Midground River Crossing)
    spear_loc = unreal.Vector(-500, -500, -35)
    for i, (dx, dy) in enumerate([(-50, -50), (0, 0), (50, 50)]):
        spawn(mesh_spearman, spear_loc + unreal.Vector(dx, dy, 0), unreal.Rotator(0, 35, 0), unreal.Vector(1.2, 1.2, 1.2), mat_bronze, f"Hoplite_{i}")

    # Raider Warbands (Distant Hills)
    raider1_loc = unreal.Vector(-2800, -1400, -35)
    for i in range(3):
        spawn(mesh_slinger, raider1_loc + unreal.Vector(i*60, i*40, 0), unreal.Rotator(0, 60, 0), unreal.Vector(1.0, 1.0, 1.0), mat_terrain, f"Raider_NW_{i}")

    raider2_loc = unreal.Vector(2600, 1300, -35)
    for i in range(3):
        spawn(mesh_slinger, raider2_loc + unreal.Vector(i*60, -i*40, 0), unreal.Rotator(0, -120, 0), unreal.Vector(1.0, 1.0, 1.0), mat_terrain, f"Raider_SE_{i}")

    # 8. PlayerStart / Camera Positioning
    player_start = actor_subsystem.spawn_actor_from_class(unreal.PlayerStart, unreal.Vector(-2600, -2600, 2400), unreal.Rotator(-36.0, 45.0, 0.0))
    if player_start:
        player_start.set_actor_label("PlayerStart_Campaign_Orbital")

    unreal.EditorLoadingAndSavingUtils.save_map(world, map_path)
    unreal.log("==================================================")
    unreal.log("   FLAWLESS CAMPAIGN SCENE SAVED TO Lvl_TopDown!  ")
    unreal.log("==================================================")

setup_flawless_campaign_scene()
