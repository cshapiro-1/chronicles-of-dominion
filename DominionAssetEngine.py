import unreal

def run_dominion_asset_engine():
    print("==================================================")
    print("   DOMINION ASSET ENGINE (DAE) - IN-HOUSE GENERATOR")
    print("==================================================")
    
    package_dir = "/Game/DominionAssets/Citadel"
    editor_asset_lib = unreal.EditorAssetLibrary
    if not editor_asset_lib.does_directory_exist(package_dir):
        editor_asset_lib.make_directory(package_dir)

    mudbrick_mat = editor_asset_lib.load_asset("/Game/Materials/MI_Mesopotamian_Mudbrick")

    prim_opts = unreal.GeometryScriptPrimitiveOptions()
    calc_normals = unreal.GeometryScriptCalculateNormalsOptions()
    tangent_opts = unreal.GeometryScriptTangentsOptions()
    empty_sel = unreal.GeometryScriptMeshSelection()
    create_opts = unreal.GeometryScriptCreateNewStaticMeshAssetOptions()
    create_opts.enable_nanite = True

    created_meshes = {}

    def build_and_save_asset(dyn_mesh, asset_name):
        unreal.GeometryScript_UVs.set_mesh_u_vs_from_box_projection(dyn_mesh, 0, unreal.Transform(), empty_sel)
        unreal.GeometryScript_Normals.recompute_normals(dyn_mesh, calc_normals)
        unreal.GeometryScript_Normals.compute_tangents(dyn_mesh, tangent_opts)

        asset_path = f"{package_dir}/{asset_name}"
        unreal.GeometryScript_NewAssetUtils.create_new_static_mesh_asset_from_mesh(
            dyn_mesh,
            asset_path,
            create_opts
        )
        sm = editor_asset_lib.load_asset(asset_path)
        if sm:
            if mudbrick_mat:
                sm.set_material(0, mudbrick_mat)
            col_opts = unreal.GeometryScriptCollisionFromMeshOptions()
            unreal.GeometryScript_Collision.set_static_mesh_collision_from_mesh(dyn_mesh, sm, col_opts)
            unreal.EditorLoadingAndSavingUtils.save_packages([sm.get_package()], True)
            print(f"  [+] Generated & Registered Nanite Asset: {asset_name}")
            created_meshes[asset_name] = sm
        else:
            print(f"  [-] Failed to load {asset_path}")
        return sm

    # 1. Rampart Wall Segment (Battered Wall + 2 Pilaster Buttresses + 4 Crenellations)
    mesh_wall = unreal.DynamicMesh()
    t = unreal.Transform()
    t.translation = unreal.Vector(0, 0, 150)
    unreal.GeometryScript_Primitives.append_box(mesh_wall, prim_opts, t, dimension_x=400.0, dimension_y=120.0, dimension_z=300.0, steps_x=4, steps_y=4, steps_z=4)
    for bx in [-120.0, 120.0]:
        tb = unreal.Transform()
        tb.translation = unreal.Vector(bx, -75, 140)
        unreal.GeometryScript_Primitives.append_box(mesh_wall, prim_opts, tb, dimension_x=60.0, dimension_y=50.0, dimension_z=280.0)
    for cx in [-150.0, -50.0, 50.0, 150.0]:
        tc = unreal.Transform()
        tc.translation = unreal.Vector(cx, -30, 330)
        unreal.GeometryScript_Primitives.append_box(mesh_wall, prim_opts, tc, dimension_x=60.0, dimension_y=60.0, dimension_z=60.0)
    build_and_save_asset(mesh_wall, "SM_DAE_Rampart_Wall")

    # 2. Corner Bastion Tower (Flared Base + Machicolations Cornice + Parapets)
    mesh_tower = unreal.DynamicMesh()
    t_base = unreal.Transform()
    t_base.translation = unreal.Vector(0, 0, 50)
    unreal.GeometryScript_Primitives.append_box(mesh_tower, prim_opts, t_base, dimension_x=320.0, dimension_y=320.0, dimension_z=100.0)
    t_shaft = unreal.Transform()
    t_shaft.translation = unreal.Vector(0, 0, 250)
    unreal.GeometryScript_Primitives.append_box(mesh_tower, prim_opts, t_shaft, dimension_x=260.0, dimension_y=260.0, dimension_z=300.0)
    t_cornice = unreal.Transform()
    t_cornice.translation = unreal.Vector(0, 0, 420)
    unreal.GeometryScript_Primitives.append_box(mesh_tower, prim_opts, t_cornice, dimension_x=290.0, dimension_y=290.0, dimension_z=40.0)
    for px in [-120.0, 0.0, 120.0]:
        for py in [-120.0, 120.0]:
            tcp = unreal.Transform()
            tcp.translation = unreal.Vector(px, py, 460)
            unreal.GeometryScript_Primitives.append_box(mesh_tower, prim_opts, tcp, dimension_x=45.0, dimension_y=45.0, dimension_z=50.0)
    for py in [-60.0, 60.0]:
        for px in [-120.0, 120.0]:
            tcp = unreal.Transform()
            tcp.translation = unreal.Vector(px, py, 460)
            unreal.GeometryScript_Primitives.append_box(mesh_tower, prim_opts, tcp, dimension_x=45.0, dimension_y=45.0, dimension_z=50.0)
    build_and_save_asset(mesh_tower, "SM_DAE_Corner_Bastion")

    # 3. Imperial Gatehouse (Twin Bastions + Keystone Portal Header)
    mesh_gate = unreal.DynamicMesh()
    t_gl = unreal.Transform()
    t_gl.translation = unreal.Vector(-220, 0, 250)
    unreal.GeometryScript_Primitives.append_box(mesh_gate, prim_opts, t_gl, dimension_x=200.0, dimension_y=240.0, dimension_z=500.0)
    t_gr = unreal.Transform()
    t_gr.translation = unreal.Vector(220, 0, 250)
    unreal.GeometryScript_Primitives.append_box(mesh_gate, prim_opts, t_gr, dimension_x=200.0, dimension_y=240.0, dimension_z=500.0)
    t_arch = unreal.Transform()
    t_arch.translation = unreal.Vector(0, 0, 420)
    unreal.GeometryScript_Primitives.append_box(mesh_gate, prim_opts, t_arch, dimension_x=260.0, dimension_y=220.0, dimension_z=160.0)
    t_key = unreal.Transform()
    t_key.translation = unreal.Vector(0, -115, 430)
    unreal.GeometryScript_Primitives.append_box(mesh_gate, prim_opts, t_key, dimension_x=80.0, dimension_y=20.0, dimension_z=100.0)
    build_and_save_asset(mesh_gate, "SM_DAE_Imperial_Gatehouse")

    # 4. Processional Pillar (Stepped Plinth + 16-faceted Column + Flared Capital)
    mesh_pillar = unreal.DynamicMesh()
    t_pb1 = unreal.Transform()
    t_pb1.translation = unreal.Vector(0, 0, 20)
    unreal.GeometryScript_Primitives.append_box(mesh_pillar, prim_opts, t_pb1, dimension_x=120.0, dimension_y=120.0, dimension_z=40.0)
    t_pb2 = unreal.Transform()
    t_pb2.translation = unreal.Vector(0, 0, 50)
    unreal.GeometryScript_Primitives.append_box(mesh_pillar, prim_opts, t_pb2, dimension_x=100.0, dimension_y=100.0, dimension_z=20.0)
    t_cyl = unreal.Transform()
    t_cyl.translation = unreal.Vector(0, 0, 60)
    unreal.GeometryScript_Primitives.append_cylinder(mesh_pillar, prim_opts, t_cyl, radius=40.0, height=400.0, radial_steps=16)
    t_cap1 = unreal.Transform()
    t_cap1.translation = unreal.Vector(0, 0, 460)
    unreal.GeometryScript_Primitives.append_cylinder(mesh_pillar, prim_opts, t_cap1, radius=55.0, height=20.0, radial_steps=16)
    t_cap2 = unreal.Transform()
    t_cap2.translation = unreal.Vector(0, 0, 490)
    unreal.GeometryScript_Primitives.append_box(mesh_pillar, prim_opts, t_cap2, dimension_x=130.0, dimension_y=130.0, dimension_z=30.0)
    build_and_save_asset(mesh_pillar, "SM_DAE_Processional_Pillar")

    # 5. Monumental Ziggurat Citadel (3 Tiered Terraces + Axial Grand Stairs + Summit Cella)
    mesh_zig = unreal.DynamicMesh()
    t_z1 = unreal.Transform()
    t_z1.translation = unreal.Vector(0, 0, 300)
    unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_z1, dimension_x=5000.0, dimension_y=3800.0, dimension_z=600.0)
    for step_y in range(-1500, 1600, 600):
        t_zb = unreal.Transform()
        t_zb.translation = unreal.Vector(2550, step_y, 300)
        unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_zb, dimension_x=120.0, dimension_y=300.0, dimension_z=580.0)
        t_zb.translation = unreal.Vector(-2550, step_y, 300)
        unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_zb, dimension_x=120.0, dimension_y=300.0, dimension_z=580.0)
    t_z2 = unreal.Transform()
    t_z2.translation = unreal.Vector(0, 100, 850)
    unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_z2, dimension_x=3600.0, dimension_y=2600.0, dimension_z=500.0)
    t_z3 = unreal.Transform()
    t_z3.translation = unreal.Vector(0, 200, 1300)
    unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_z3, dimension_x=2400.0, dimension_y=1600.0, dimension_z=400.0)
    t_cella = unreal.Transform()
    t_cella.translation = unreal.Vector(0, 250, 1725)
    unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_cella, dimension_x=1400.0, dimension_y=1000.0, dimension_z=450.0)
    t_cdoor = unreal.Transform()
    t_cdoor.translation = unreal.Vector(0, -260, 1650)
    unreal.GeometryScript_Primitives.append_box(mesh_zig, prim_opts, t_cdoor, dimension_x=300.0, dimension_y=50.0, dimension_z=300.0)
    # Axial Grand Stairs
    t_st1 = unreal.Transform()
    t_st1.translation = unreal.Vector(0, -2400, 0)
    unreal.GeometryScript_Primitives.append_linear_stairs(mesh_zig, prim_opts, t_st1, step_width=500.0, step_height=30.0, step_depth=50.0, num_steps=20)
    t_st2 = unreal.Transform()
    t_st2.translation = unreal.Vector(0, -1400, 600)
    unreal.GeometryScript_Primitives.append_linear_stairs(mesh_zig, prim_opts, t_st2, step_width=400.0, step_height=30.0, step_depth=50.0, num_steps=17)
    t_st3 = unreal.Transform()
    t_st3.translation = unreal.Vector(0, -600, 1100)
    unreal.GeometryScript_Primitives.append_linear_stairs(mesh_zig, prim_opts, t_st3, step_width=300.0, step_height=30.0, step_depth=50.0, num_steps=13)
    build_and_save_asset(mesh_zig, "SM_DAE_Monumental_Ziggurat")

    # 6. Granary Vault (Raised Foundation + 4 Silo Towers with Conical Caps)
    mesh_granary = unreal.DynamicMesh()
    t_gf = unreal.Transform()
    t_gf.translation = unreal.Vector(0, 0, 25)
    unreal.GeometryScript_Primitives.append_box(mesh_granary, prim_opts, t_gf, dimension_x=1200.0, dimension_y=800.0, dimension_z=50.0)
    for sx in [-350.0, 350.0]:
        for sy in [-200.0, 200.0]:
            t_silo = unreal.Transform()
            t_silo.translation = unreal.Vector(sx, sy, 50)
            unreal.GeometryScript_Primitives.append_cylinder(mesh_granary, prim_opts, t_silo, radius=160.0, height=300.0, radial_steps=16)
            t_dome = unreal.Transform()
            t_dome.translation = unreal.Vector(sx, sy, 350)
            unreal.GeometryScript_Primitives.append_cone(mesh_granary, prim_opts, t_dome, base_radius=170.0, top_radius=0.0, height=120.0, radial_steps=16)
    build_and_save_asset(mesh_granary, "SM_DAE_Granary_Vault")

    # 7. War Forge & Barracks (Compound + 2 Smelting Flues + Portico)
    mesh_forge = unreal.DynamicMesh()
    t_ff = unreal.Transform()
    t_ff.translation = unreal.Vector(0, 0, 150)
    unreal.GeometryScript_Primitives.append_box(mesh_forge, prim_opts, t_ff, dimension_x=1400.0, dimension_y=900.0, dimension_z=300.0)
    for kx in [-400.0, 400.0]:
        t_kiln = unreal.Transform()
        t_kiln.translation = unreal.Vector(kx, 0, 300)
        unreal.GeometryScript_Primitives.append_cylinder(mesh_forge, prim_opts, t_kiln, radius=80.0, height=200.0, radial_steps=12)
    for cx in [-500.0, -250.0, 0.0, 250.0, 500.0]:
        t_col = unreal.Transform()
        t_col.translation = unreal.Vector(cx, -480, 0)
        unreal.GeometryScript_Primitives.append_cylinder(mesh_forge, prim_opts, t_col, radius=25.0, height=300.0, radial_steps=12)
    t_roof = unreal.Transform()
    t_roof.translation = unreal.Vector(0, -480, 315)
    unreal.GeometryScript_Primitives.append_box(mesh_forge, prim_opts, t_roof, dimension_x=1200.0, dimension_y=120.0, dimension_z=30.0)
    build_and_save_asset(mesh_forge, "SM_DAE_WarForge_Barracks")

    # 8. Courtyard Altar (Tiered Podium + 4 Horned Finials)
    mesh_altar = unreal.DynamicMesh()
    t_a1 = unreal.Transform()
    t_a1.translation = unreal.Vector(0, 0, 30)
    unreal.GeometryScript_Primitives.append_box(mesh_altar, prim_opts, t_a1, dimension_x=300.0, dimension_y=300.0, dimension_z=60.0)
    t_a2 = unreal.Transform()
    t_a2.translation = unreal.Vector(0, 0, 90)
    unreal.GeometryScript_Primitives.append_box(mesh_altar, prim_opts, t_a2, dimension_x=220.0, dimension_y=220.0, dimension_z=60.0)
    t_a3 = unreal.Transform()
    t_a3.translation = unreal.Vector(0, 0, 140)
    unreal.GeometryScript_Primitives.append_box(mesh_altar, prim_opts, t_a3, dimension_x=160.0, dimension_y=160.0, dimension_z=40.0)
    for hx in [-70.0, 70.0]:
        for hy in [-70.0, 70.0]:
            t_horn = unreal.Transform()
            t_horn.translation = unreal.Vector(hx, hy, 175)
            unreal.GeometryScript_Primitives.append_box(mesh_altar, prim_opts, t_horn, dimension_x=20.0, dimension_y=20.0, dimension_z=30.0)
    build_and_save_asset(mesh_altar, "SM_DAE_Courtyard_Altar")

    # -------------------------------------------------------------
    # LEVEL ASSEMBLY: Rebuild Lvl_TopDown with In-House Nanite Assets
    # -------------------------------------------------------------
    print("=== ASSEMBLING LEVEL WITH DOMINION ASSET ENGINE SUITE ===")
    world = unreal.EditorLoadingAndSavingUtils.load_map("/Game/TopDown/Lvl_TopDown")
    actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    all_actors = actor_subsystem.get_all_level_actors()

    retain_classes = ["DirectionalLight", "SkyLight", "SkyAtmosphere", "ExponentialHeightFog", "PostProcessVolume", "PlayerStart", "WorldDataLayers"]
    for a in all_actors:
        cname = a.get_class().get_name()
        if cname not in retain_classes:
            actor_subsystem.destroy_actor(a)

    def spawn_static_actor(mesh, loc, rot=unreal.Rotator(0, 0, 0), scale=unreal.Vector(1, 1, 1), label="Citadel_Actor"):
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

    # 1. Colossal Monumental Ziggurat Citadel (North)
    spawn_static_actor(created_meshes["SM_DAE_Monumental_Ziggurat"], unreal.Vector(0, 1600, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1, 1, 1), "Monumental_Ziggurat_Citadel")

    # 2. Outer Perimeter Curtain Walls (East, West, North, South)
    # East Wall
    for i in range(-5, 6):
        spawn_static_actor(created_meshes["SM_DAE_Rampart_Wall"], unreal.Vector(2500, i * 390, 0), unreal.Rotator(0, 90, 0), unreal.Vector(1, 1, 1), f"Wall_East_{i}")
    # West Wall
    for i in range(-5, 6):
        spawn_static_actor(created_meshes["SM_DAE_Rampart_Wall"], unreal.Vector(-2500, i * 390, 0), unreal.Rotator(0, -90, 0), unreal.Vector(1, 1, 1), f"Wall_West_{i}")
    # North Wall
    for i in range(-5, 6):
        spawn_static_actor(created_meshes["SM_DAE_Rampart_Wall"], unreal.Vector(i * 390, 2400, 0), unreal.Rotator(0, 180, 0), unreal.Vector(1, 1, 1), f"Wall_North_{i}")
    # South Wall (flanking gatehouse)
    for i in [-5, -4, -3, -2, 2, 3, 4, 5]:
        spawn_static_actor(created_meshes["SM_DAE_Rampart_Wall"], unreal.Vector(i * 390, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1, 1, 1), f"Wall_South_{i}")

    # 3. Imperial Gatehouse (South Entrance)
    spawn_static_actor(created_meshes["SM_DAE_Imperial_Gatehouse"], unreal.Vector(0, -2400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.4, 1.4, 1.4), "Imperial_Gatehouse_Portal")

    # 4. Corner Bastion Towers (4 Corners)
    spawn_static_actor(created_meshes["SM_DAE_Corner_Bastion"], unreal.Vector(2500, 2400, 0), unreal.Rotator(0, 45, 0), unreal.Vector(1.4, 1.4, 1.4), "Bastion_Corner_NE")
    spawn_static_actor(created_meshes["SM_DAE_Corner_Bastion"], unreal.Vector(-2500, 2400, 0), unreal.Rotator(0, -45, 0), unreal.Vector(1.4, 1.4, 1.4), "Bastion_Corner_NW")
    spawn_static_actor(created_meshes["SM_DAE_Corner_Bastion"], unreal.Vector(2500, -2400, 0), unreal.Rotator(0, 135, 0), unreal.Vector(1.4, 1.4, 1.4), "Bastion_Corner_SE")
    spawn_static_actor(created_meshes["SM_DAE_Corner_Bastion"], unreal.Vector(-2500, -2400, 0), unreal.Rotator(0, -135, 0), unreal.Vector(1.4, 1.4, 1.4), "Bastion_Corner_SW")

    # 5. Processional Colonnade Avenue of the God-Kings
    for y_idx, y_pos in enumerate(range(-1900, 200, 320)):
        spawn_static_actor(created_meshes["SM_DAE_Processional_Pillar"], unreal.Vector(-400, y_pos, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), f"Pillar_L_{y_idx}")
        spawn_static_actor(created_meshes["SM_DAE_Processional_Pillar"], unreal.Vector(400, y_pos, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1.2, 1.2, 1.2), f"Pillar_R_{y_idx}")

    # 6. East Wing: War Forge Armory & Foundry
    spawn_static_actor(created_meshes["SM_DAE_WarForge_Barracks"], unreal.Vector(1400, -400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1, 1, 1), "WarForge_Armory")

    # 7. West Wing: Granary Silo Vaults
    spawn_static_actor(created_meshes["SM_DAE_Granary_Vault"], unreal.Vector(-1400, -400, 0), unreal.Rotator(0, 0, 0), unreal.Vector(1, 1, 1), "Granary_Vault_Silos")

    # 8. Courtyard Altars
    spawn_static_actor(created_meshes["SM_DAE_Courtyard_Altar"], unreal.Vector(-800, -1400, 0), unreal.Rotator(0, 45, 0), unreal.Vector(1.5, 1.5, 1.5), "Altar_Courtyard_West")
    spawn_static_actor(created_meshes["SM_DAE_Courtyard_Altar"], unreal.Vector(800, -1400, 0), unreal.Rotator(0, -45, 0), unreal.Vector(1.5, 1.5, 1.5), "Altar_Courtyard_East")

    unreal.EditorLoadingAndSavingUtils.save_map(world, "/Game/TopDown/Lvl_TopDown")
    print("==================================================")
    print("   DAE ASSETS & CITADEL LEVEL ASSEMBLED SUCCESSFULLY")
    print("==================================================")

run_dominion_asset_engine()
