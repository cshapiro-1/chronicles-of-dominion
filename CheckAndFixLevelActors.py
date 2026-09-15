import unreal

def check_and_fix_level():
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    editor_asset_lib = unreal.EditorAssetLibrary

    world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/TopDown/Lvl_TopDown")
    if not world:
        unreal.log_error("Could not load /Game/TopDown/Lvl_TopDown")
        return

    actors = actor_subsystem.get_all_level_actors()
    unreal.log(f"==================================================")
    unreal.log(f"   CHECKING LEVEL: {len(actors)} ACTORS FOUND    ")
    unreal.log(f"==================================================")

    for a in actors:
        cname = a.get_class().get_name()
        label = a.get_actor_label()
        loc = a.get_actor_location()
        unreal.log(f"ACTOR: [{cname}] {label} @ ({loc.x:.1f}, {loc.y:.1f}, {loc.z:.1f})")

        if isinstance(a, unreal.StaticMeshActor):
            smc = a.static_mesh_component
            sm = smc.static_mesh
            sm_name = sm.get_name() if sm else "NONE"
            mat_num = smc.get_num_materials()
            mats = [smc.get_material(i).get_name() if smc.get_material(i) else "NONE" for i in range(mat_num)]
            unreal.log(f"   -> Mesh: {sm_name} | Materials: {mats}")

check_and_fix_level()
