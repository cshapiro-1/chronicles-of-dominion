import unreal

def build_campaign_map():
    print("==================================================================")
    print("   BUILDING GRAND STRATEGY CAMPAIGN MAP (Lvl_CampaignMap)        ")
    print("==================================================================")
    
    editor_asset_lib = unreal.EditorAssetLibrary
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    
    # Ensure directory exists
    if not editor_asset_lib.does_directory_exist("/Game/Maps"):
        editor_asset_lib.make_directory("/Game/Maps")

    # Create / Load Map
    world = unreal.EditorLoadingAndSavingUtils.new_map_from_template("/Game/Maps/Lvl_CampaignMap", False)
    if not world:
        world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/Maps/Lvl_CampaignMap")

    # Clean existing actors
    all_actors = actor_subsystem.get_all_level_actors()
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in ["WorldDataLayers"]:
            actor_subsystem.destroy_actor(a)

    # Load Key Materials
    mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Alluvial_Terrain")
    if not mat_terrain:
        mat_terrain = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")
    mat_water = editor_asset_lib.load_asset("/Game/Materials/MI_Murky_Water")
    mat_basalt = editor_asset_lib.load_asset("/Game/Materials/MI_Dark_Basalt")
    mat_bronze = editor_asset_lib.load_asset("/Game/Materials/MI_Patina_Bronze")

    # Load Key Meshes
    mesh_cube = editor_asset_lib.load_asset("/Game/LevelPrototyping/Meshes/SM_Cube")
    mesh_zig = editor_asset_lib.load_asset("/Game/DominionAssets/Citadel/SM_DAE_Monumental_Ziggurat")
    mesh_spearman = editor_asset_lib.load_asset("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Spearman")

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
    # 1. PHYSICAL ATMOSPHERIC SUN & ENVIRONMENT
    # -------------------------------------------------------------
    sun_rot = unreal.Rotator(-45.0, 40.0, 0.0)
    sun_actor = actor_subsystem.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0, 0, 5000), sun_rot)
    if sun_actor:
        sun_comp = sun_actor.light_component
        sun_comp.set_editor_property("Intensity", 75000.0)
        sun_comp.set_editor_property("bUseTemperature", True)
        sun_comp.set_editor_property("Temperature", 5500.0)
        sun_comp.set_editor_property("bAtmosphereSunLight", True)
        sun_comp.set_editor_property("AtmosphereSunLightIndex", 0)
        sun_comp.set_editor_property("CastShadows", True)
        sun_actor.set_actor_label("Campaign_Sun_DirectionalLight")

    # Sky Atmosphere
    sky_atmo = actor_subsystem.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    if sky_atmo:
        sky_atmo.set_actor_label("SkyAtmosphere")

    # Sky Light
    sky_light = actor_subsystem.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0, 0, 2000), unreal.Rotator(0, 0, 0))
    if sky_light:
        sl_comp = sky_light.light_component
        sl_comp.set_editor_property("Intensity", 1.0)
        sl_comp.set_editor_property("bRealTimeCapture", True)
        sky_light.set_actor_label("SkyLight_RealTime")

    # Exponential Height Fog
    fog_actor = actor_subsystem.spawn_actor_from_class(unreal.ExponentialHeightFog, unreal.Vector(0, 0, -200), unreal.Rotator(0, 0, 0))
    if fog_actor:
        fog_comp = fog_actor.component
        fog_comp.set_editor_property("FogDensity", 0.0015)
        fog_comp.set_editor_property("FogInscatteringColor", unreal.LinearColor(0.85, 0.75, 0.6, 1.0))
        fog_actor.set_actor_label("Campaign_Desert_Fog")

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
    # 2. CONTINUOUS ALLUVIAL CAMPAIGN TERRAIN (300m x 300m Basin)
    # -------------------------------------------------------------
    spawn_mesh(mesh_cube, unreal.Vector(0, 0, -100), unreal.Rotator(0, 0, 0), unreal.Vector(300, 300, 2), mat_terrain, "Terrain_FertileCrescent_Basin")

    # River Courses (Euphrates & Tigris water channels)
    # Euphrates River Channel
    spawn_mesh(mesh_cube, unreal.Vector(-1200, 0, 5), unreal.Rotator(0, 25, 0), unreal.Vector(8, 220, 0.2), mat_water, "River_Euphrates_Mesh")
    # Tigris River Channel
    spawn_mesh(mesh_cube, unreal.Vector(1400, 200, 5), unreal.Rotator(0, 20, 0), unreal.Vector(8, 220, 0.2), mat_water, "River_Tigris_Mesh")

    # -------------------------------------------------------------
    # 3. PROVINCIAL SETTLEMENT NODES
    # -------------------------------------------------------------
    settlement_class = unreal.load_class(None, "/Script/DominionCore.DominionSettlementActor")
    if settlement_class:
        # Settlement 1: Citadel of Ur-Kish (Capital)
        s1 = actor_subsystem.spawn_actor_from_class(settlement_class, unreal.Vector(0, -600, 20), unreal.Rotator(0, 0, 0))
        if s1:
            s1.set_editor_property("SettlementName", "Citadel of Ur-Kish")
            s1.set_editor_property("TeamID", 0)
            s1.set_editor_property("Population", 139000)
            s1.set_editor_property("GarrisonStrength", 1200)
            s1.set_actor_label("Settlement_UrKish")

        # Settlement 2: Lagash (Southern River Hub)
        s2 = actor_subsystem.spawn_actor_from_class(settlement_class, unreal.Vector(1800, -1400, 20), unreal.Rotator(0, 30, 0))
        if s2:
            s2.set_editor_property("SettlementName", "Lagash")
            s2.set_editor_property("TeamID", 0)
            s2.set_editor_property("Population", 84000)
            s2.set_editor_property("GarrisonStrength", 800)
            s2.set_actor_label("Settlement_Lagash")

        # Settlement 3: Uruk (Western Silt Port)
        s3 = actor_subsystem.spawn_actor_from_class(settlement_class, unreal.Vector(-2000, 800, 20), unreal.Rotator(0, -20, 0))
        if s3:
            s3.set_editor_property("SettlementName", "Uruk")
            s3.set_editor_property("TeamID", 1)
            s3.set_editor_property("Population", 95000)
            s3.set_editor_property("GarrisonStrength", 950)
            s3.set_actor_label("Settlement_Uruk")

        # Settlement 4: Babylon (Northern Metropolis)
        s4 = actor_subsystem.spawn_actor_from_class(settlement_class, unreal.Vector(800, 2200, 20), unreal.Rotator(0, 0, 0))
        if s4:
            s4.set_editor_property("SettlementName", "Babylon")
            s4.set_editor_property("TeamID", 2)
            s4.set_editor_property("Population", 210000)
            s4.set_editor_property("GarrisonStrength", 2500)
            s4.set_actor_label("Settlement_Babylon")

    # -------------------------------------------------------------
    # 4. MARCHING ARMY TOKENS
    # -------------------------------------------------------------
    army_class = unreal.load_class(None, "/Script/DominionCore.DominionArmyTokenActor")
    if army_class:
        # Player Vanguard Army
        a1 = actor_subsystem.spawn_actor_from_class(army_class, unreal.Vector(-300, -1100, 30), unreal.Rotator(0, 45, 0))
        if a1:
            a1.set_editor_property("ArmyName", "I. Imperial Vanguard Cohort")
            a1.set_editor_property("TeamID", 0)
            a1.set_editor_property("SoldierCount", 350)
            a1.set_actor_label("Army_Imperial_Vanguard")

        # Raider Warband Token
        a2 = actor_subsystem.spawn_actor_from_class(army_class, unreal.Vector(-1400, 1600, 30), unreal.Rotator(0, -135, 0))
        if a2:
            a2.set_editor_property("ArmyName", "Nomadic Raider Warband")
            a2.set_editor_property("TeamID", 1)
            a2.set_editor_property("SoldierCount", 200)
            a2.set_actor_label("Army_Nomadic_Raiders")

    # -------------------------------------------------------------
    # 5. STRATEGIC CAMPAIGN CAMERA / PLAYER START
    # -------------------------------------------------------------
    player_start = actor_subsystem.spawn_actor_from_class(unreal.PlayerStart, unreal.Vector(0, -2200, 1200), unreal.Rotator(-40, 90, 0))
    if player_start:
        player_start.set_actor_label("PlayerStart_Campaign")

    unreal.EditorLoadingAndSavingUtils.save_map(world, "/Game/Maps/Lvl_CampaignMap")
    print("==================================================================")
    print("   Lvl_CampaignMap ASSEMBLED AND SAVED CLEANLY!                   ")
    print("==================================================================")

try:
    build_campaign_map()
except Exception as e:
    print(f"[!] Error building campaign map: {e}")
