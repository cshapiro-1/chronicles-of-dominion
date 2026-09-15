import unreal

def initialize_chronicles_of_dominion():
    print("==================================================================")
    print("   CHRONICLES OF DOMINION: INITIALIZING CAMPAIGN & TACTICAL MAPS  ")
    print("==================================================================")
    
    # 1. Build Grand Strategy Campaign Map
    try:
        import BuildMesopotamianCampaignMap
        BuildMesopotamianCampaignMap.build_campaign_map()
    except Exception as e:
        print(f"[!] Campaign map builder note: {e}")

    # 2. Build Tactical RTS Battlefield
    try:
        import BuildMasterpieceCitadel
        BuildMasterpieceCitadel.build_masterpiece_citadel()
    except Exception as e:
        print(f"[!] Tactical citadel builder note: {e}")

initialize_chronicles_of_dominion()
