import unreal

def initialize_chronicles_of_dominion():
    print("==================================================================")
    print("   CHRONICLES OF DOMINION: LOADING FLAWLESS CAMPAIGN MAP SCENE   ")
    print("==================================================================")
    
    try:
        import EnsureFlawlessExposureAndTerrain
        EnsureFlawlessExposureAndTerrain.setup_flawless_campaign_scene()
    except Exception as e:
        print(f"[!] Campaign map builder note: {e}")

initialize_chronicles_of_dominion()
