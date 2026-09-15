import unreal

def initialize_chronicles_of_dominion():
    print("==================================================================")
    print("   CHRONICLES OF DOMINION: ASSEMBLING 100% VISUAL CAMPAIGN MAP   ")
    print("==================================================================")
    
    try:
        import AssembleFullMesopotamianCampaign
        AssembleFullMesopotamianCampaign.build_100_percent_mesopotamian_campaign()
    except Exception as e:
        print(f"[!] Campaign map builder note: {e}")

initialize_chronicles_of_dominion()
