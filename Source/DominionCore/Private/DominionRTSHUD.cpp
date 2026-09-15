#include "DominionRTSHUD.h"
#include "DominionGameModeBase.h"
#include "DominionRTSPlayerController.h"
#include "DominionRTSPawn.h"
#include "DominionUnitActor.h"
#include "DominionBuildingActor.h"
#include "DominionSettlementActor.h"
#include "DominionArmyTokenActor.h"
#include "DominionTutorialSubsystem.h"
#include "DominionSupplyLineSubsystem.h"
#include "DominionFormationSystem.h"
#include "DominionDemographicsSubsystem.h"
#include "DominionPoliticalEstatesSystem.h"
#include "Engine/Canvas.h"
#include "Engine/Font.h"
#include "Kismet/GameplayStatics.h"

ADominionRTSHUD::ADominionRTSHUD()
{
}

void ADominionRTSHUD::PostInitializeComponents()
{
	Super::PostInitializeComponents();
}

void ADominionRTSHUD::DrawHUD()
{
	Super::DrawHUD();

	if (!Canvas) return;

	const float ScreenW = Canvas->SizeX;
	const float ScreenH = Canvas->SizeY;
	const float DPIScale = FMath::Clamp(ScreenH / 1080.0f, 0.75f, 2.5f);

	UFont* DefaultFont = GEngine->GetSmallFont();
	UFont* MediumFont = GEngine->GetMediumFont() ? GEngine->GetMediumFont() : DefaultFont;
	UFont* LargeFont = GEngine->GetLargeFont() ? GEngine->GetLargeFont() : MediumFont;

	// High-contrast, drop-shadowed crisp text helper
	auto DrawParchmentText = [this, DPIScale](UFont* Font, const FString& Text, float X, float Y, float Scale, const FLinearColor& TextColor)
	{
		if (!Font) Font = GEngine->GetMediumFont() ? GEngine->GetMediumFont() : GEngine->GetSmallFont();
		float FinalScale = Scale * DPIScale;
		
		// Drop shadow
		Canvas->DrawColor = FColor(0, 0, 0, 255);
		Canvas->DrawText(Font, Text, X + (1.5f * DPIScale), Y + (1.5f * DPIScale), FinalScale, FinalScale, FFontRenderInfo());
		// Main text
		Canvas->DrawColor = TextColor.ToFColor(true);
		Canvas->DrawText(Font, Text, X, Y, FinalScale, FinalScale, FFontRenderInfo());
	};

	// Ornate beveled tablet helper
	auto DrawBeveledTablet = [this, DPIScale](const FVector2D& Pos, const FVector2D& Size, const FLinearColor& BGColor, const FLinearColor& GoldColor)
	{
		// Main dark background fill
		FCanvasTileItem BG(Pos, Size, BGColor);
		BG.BlendMode = SE_BLEND_Translucent;
		Canvas->DrawItem(BG);

		// Outer gold frame
		FCanvasBoxItem OuterBox(Pos, Size);
		OuterBox.SetColor(GoldColor);
		OuterBox.LineThickness = 2.0f * DPIScale;
		Canvas->DrawItem(OuterBox);

		// Inner recessed bevel line
		if (Size.X > 10.0f * DPIScale && Size.Y > 10.0f * DPIScale)
		{
			FCanvasBoxItem InnerBox(Pos + FVector2D(3.0f * DPIScale, 3.0f * DPIScale), Size - FVector2D(6.0f * DPIScale, 6.0f * DPIScale));
			InnerBox.SetColor(GoldColor * 0.45f);
			InnerBox.LineThickness = 1.0f * DPIScale;
			Canvas->DrawItem(InnerBox);
		}
	};

	// Draw filled circle helper
	auto DrawFilledCircle = [this](const FVector2D& Center, float Radius, const FLinearColor& Color, int32 Segments = 48)
	{
		for (float r = 1.0f; r <= Radius; r += 2.5f)
		{
			float Step = 2.0f * PI / (float)Segments;
			for (int32 i = 0; i < Segments; ++i)
			{
				float A1 = (float)i * Step;
				float A2 = (float)(i + 1) * Step;
				FVector2D P1 = Center + FVector2D(FMath::Cos(A1) * r, FMath::Sin(A1) * r);
				FVector2D P2 = Center + FVector2D(FMath::Cos(A2) * r, FMath::Sin(A2) * r);
				Canvas->K2_DrawLine(P1, P2, 3.0f, Color);
			}
		}
	};

	// Draw circle ring outline helper
	auto DrawCircleRing = [this](const FVector2D& Center, float Radius, float Thickness, const FLinearColor& Color, int32 Segments = 64)
	{
		float Step = 2.0f * PI / (float)Segments;
		for (int32 i = 0; i < Segments; ++i)
		{
			float A1 = (float)i * Step;
			float A2 = (float)(i + 1) * Step;
			FVector2D P1 = Center + FVector2D(FMath::Cos(A1) * Radius, FMath::Sin(A1) * Radius);
			FVector2D P2 = Center + FVector2D(FMath::Cos(A2) * Radius, FMath::Sin(A2) * Radius);
			Canvas->K2_DrawLine(P1, P2, Thickness, Color);
		}
	};

	// Palette definitions (Masterwork Hewn Basalt, Burnished Bronze & Aged Parchment)
	const FLinearColor ColorBasaltBG = FLinearColor(0.045f, 0.04f, 0.035f, 0.95f);
	const FLinearColor ColorBurnishedGold = FLinearColor(0.88f, 0.72f, 0.30f, 1.0f);
	const FLinearColor ColorBronzeTrim = FLinearColor(0.72f, 0.52f, 0.28f, 1.0f);
	const FLinearColor ColorParchment = FLinearColor(0.96f, 0.92f, 0.82f, 1.0f);
	const FLinearColor ColorMutedGold = FLinearColor(1.0f, 0.84f, 0.40f, 1.0f);
	const FLinearColor ColorVerdigris = FLinearColor(0.18f, 0.42f, 0.38f, 1.0f);
	const FLinearColor ColorParchmentBG = FLinearColor(0.82f, 0.74f, 0.58f, 0.96f);

	ADominionGameModeBase* GM = Cast<ADominionGameModeBase>(UGameplayStatics::GetGameMode(GetWorld()));
	ADominionRTSPlayerController* PC = Cast<ADominionRTSPlayerController>(GetOwningPlayerController());
	UDominionDemographicsSubsystem* Demo = GetWorld() ? GetWorld()->GetSubsystem<UDominionDemographicsSubsystem>() : nullptr;
	UDominionPoliticalEstatesSystem* Estates = GetWorld() ? GetWorld()->GetSubsystem<UDominionPoliticalEstatesSystem>() : nullptr;

	// =========================================================================
	// 1. TOP MACRO RESOURCE & ESTATE BAROMETER STRIP (AST-08 BENCHMARK)
	// =========================================================================
	const float TopY = 8.0f * DPIScale;
	const float TopH = 50.0f * DPIScale;

	// Top Master Ribbon Frame
	DrawBeveledTablet(FVector2D(0, 0), FVector2D(ScreenW, TopH + (12.0f * DPIScale)), FLinearColor(0.03f, 0.025f, 0.02f, 0.92f), ColorBronzeTrim * 0.7f);

	// --- 1A. LEFT: 6-RESOURCE LEDGER (Grain, Timber, Stone, Bronze, Gold, Pop) ---
	struct FMacroResource
	{
		const TCHAR* Icon;
		int32 Amount;
		int32 Rate;
	};

	int32 GrainVal = GM ? FMath::RoundToInt(GM->Grain) : 1420;
	int32 BronzeVal = GM ? FMath::RoundToInt(GM->Bronze) : 650;
	int32 ClayVal = GM ? FMath::RoundToInt(GM->Clay) : 1200;

	const FMacroResource Resources[6] = {
		{ TEXT("GRN"), GrainVal, 45 },
		{ TEXT("TMB"), 850, 18 },
		{ TEXT("STN"), ClayVal, 25 },
		{ TEXT("BRZ"), BronzeVal, 12 },
		{ TEXT("GLD"), 5200, 80 },
		{ TEXT("POP"), 6500, 100 }
	};

	const float ResStartX = 18.0f * DPIScale;
	const float ResWidth = 380.0f * DPIScale;
	const float ResSpacing = ResWidth / 6.0f;

	for (int32 i = 0; i < 6; ++i)
	{
		float ItemX = ResStartX + i * ResSpacing;
		// Resource Tag
		DrawParchmentText(DefaultFont, Resources[i].Icon, ItemX, TopY + (4.0f * DPIScale), 0.85f, ColorBurnishedGold);
		// Resource Amount
		DrawParchmentText(MediumFont, FString::Printf(TEXT("%d"), Resources[i].Amount), ItemX + (22.0f * DPIScale), TopY + (2.0f * DPIScale), 0.95f, ColorParchment);
		// Rate / Turn
		FString RateStr = (i == 5) ? TEXT("100%") : FString::Printf(TEXT("(+%d/m)"), Resources[i].Rate);
		DrawParchmentText(DefaultFont, RateStr, ItemX + (4.0f * DPIScale), TopY + (20.0f * DPIScale), 0.75f, ColorBurnishedGold * 0.85f);
	}

	// --- 1B. CENTER: 3 ESTATE BAROMETER RADIAL DIALS (Altar, Throne, Masses) ---
	const float DialRadius = 30.0f * DPIScale;
	const float CenterX = ScreenW * 0.5f;

	struct FEstateDial
	{
		const TCHAR* Name;
		const TCHAR* Subtitle;
		float Value; // 0.0 to 1.0
		FLinearColor AccentColor;
	};

	float AltarVal = Estates ? (Estates->GetPriesthoodLoyalty() / 100.0f) : 0.65f;
	float ThroneVal = Estates ? (Estates->GetNobilityLoyalty() / 100.0f) : 0.60f;
	float MassesVal = Estates ? (Estates->GetMassesLoyalty() / 100.0f) : 0.58f;

	const FEstateDial EstateDials[3] = {
		{ TEXT("Altar"), TEXT("Church"), AltarVal, FLinearColor(0.85f, 0.70f, 0.25f) },
		{ TEXT("Throne"), TEXT("Nobles"), ThroneVal, FLinearColor(0.75f, 0.45f, 0.20f) },
		{ TEXT("Masses"), TEXT("Serfs"), MassesVal, FLinearColor(0.35f, 0.75f, 0.45f) }
	};

	const float DialOffsets[3] = { -85.0f * DPIScale, 0.0f, 85.0f * DPIScale };
	for (int32 d = 0; d < 3; ++d)
	{
		FVector2D DialCenter(CenterX + DialOffsets[d], TopY + DialRadius + (2.0f * DPIScale));

		// Dial Parchment Disc
		DrawFilledCircle(DialCenter, DialRadius, FLinearColor(0.86f, 0.80f, 0.68f, 0.98f), 32);
		DrawCircleRing(DialCenter, DialRadius, 2.0f * DPIScale, ColorBronzeTrim, 32);
		DrawCircleRing(DialCenter, DialRadius - (3.0f * DPIScale), 1.0f * DPIScale, ColorBronzeTrim * 0.5f, 32);

		// Radial Gauge Ticks
		for (int32 deg = -120; deg <= 120; deg += 30)
		{
			float Rad = FMath::DegreesToRadians((float)deg - 90.0f);
			FVector2D T1 = DialCenter + FVector2D(FMath::Cos(Rad) * (DialRadius - (7.0f * DPIScale)), FMath::Sin(Rad) * (DialRadius - (7.0f * DPIScale)));
			FVector2D T2 = DialCenter + FVector2D(FMath::Cos(Rad) * (DialRadius - (3.0f * DPIScale)), FMath::Sin(Rad) * (DialRadius - (3.0f * DPIScale)));
			Canvas->K2_DrawLine(T1, T2, 1.2f * DPIScale, ColorBronzeTrim * 0.7f);
		}

		// Needle Pointer
		float AngleDeg = FMath::Lerp(-120.0f, 120.0f, EstateDials[d].Value) - 90.0f;
		float NeedleRad = FMath::DegreesToRadians(AngleDeg);
		FVector2D NeedleTip = DialCenter + FVector2D(FMath::Cos(NeedleRad) * (DialRadius - (5.0f * DPIScale)), FMath::Sin(NeedleRad) * (DialRadius - (5.0f * DPIScale)));
		Canvas->K2_DrawLine(DialCenter, NeedleTip, 2.0f * DPIScale, FLinearColor(0.12f, 0.10f, 0.08f));
		DrawFilledCircle(DialCenter, 3.5f * DPIScale, ColorBronzeTrim, 16);

		// Value Text & Subtitle below Dial
		FString DialValStr = FString::Printf(TEXT("%.0f%%"), EstateDials[d].Value * 100.0f);
		DrawParchmentText(DefaultFont, DialValStr, DialCenter.X - (10.0f * DPIScale), DialCenter.Y + (12.0f * DPIScale), 0.75f, FLinearColor(0.15f, 0.12f, 0.08f));

		// Label Banner Below Dial
		const float PlaqueW = 60.0f * DPIScale;
		const float PlaqueH = 32.0f * DPIScale;
		FVector2D PlaquePos(DialCenter.X - PlaqueW * 0.5f, DialCenter.Y + DialRadius + (4.0f * DPIScale));
		DrawBeveledTablet(PlaquePos, FVector2D(PlaqueW, PlaqueH), ColorBasaltBG, ColorBronzeTrim * 0.8f);

		DrawParchmentText(MediumFont, EstateDials[d].Name, PlaquePos.X + (12.0f * DPIScale), PlaquePos.Y + (3.0f * DPIScale), 0.85f, ColorBurnishedGold);
		DrawParchmentText(DefaultFont, EstateDials[d].Subtitle, PlaquePos.X + (14.0f * DPIScale), PlaquePos.Y + (17.0f * DPIScale), 0.75f, ColorParchment * 0.8f);
	}

	// --- 1C. RIGHT: EPOCH TITLE & SPEED BUTTONS ---
	const float EpochX = ScreenW - (260.0f * DPIScale);
	DrawParchmentText(LargeFont, TEXT("BRONZE AGE"), EpochX, TopY + (8.0f * DPIScale), 1.25f, ColorBurnishedGold);

	bool bPaused = PC ? PC->IsTacticalPaused() : false;
	FLinearColor PauseColor = bPaused ? FLinearColor(1.0f, 0.35f, 0.25f) : ColorParchment;
	DrawParchmentText(DefaultFont, TEXT("[||]"), EpochX + (120.0f * DPIScale), TopY + (12.0f * DPIScale), 0.85f, PauseColor);
	DrawParchmentText(DefaultFont, TEXT("[>] 1X"), EpochX + (146.0f * DPIScale), TopY + (12.0f * DPIScale), 0.85f, !bPaused ? ColorMutedGold : ColorParchment * 0.6f);
	DrawParchmentText(DefaultFont, TEXT("[L] LEDGER"), EpochX + (192.0f * DPIScale), TopY + (12.0f * DPIScale), 0.85f, bShowProductionLedger ? ColorMutedGold : ColorParchment);

	// =========================================================================
	// 2. BOTTOM-LEFT: PROVINCIAL SETTLEMENT CARD (CITADEL OF UR-KISH)
	// =========================================================================
	const float ProvW = 340.0f * DPIScale;
	const float ProvH = 130.0f * DPIScale;
	const float ProvX = 24.0f * DPIScale;
	const float ProvY = ScreenH - ProvH - (24.0f * DPIScale);

	DrawBeveledTablet(FVector2D(ProvX, ProvY), FVector2D(ProvW, ProvH), ColorBasaltBG, ColorBronzeTrim);

	// Dynastic Heraldic Crest Box
	const float CrestSize = 88.0f * DPIScale;
	const float CrestX = ProvX + (14.0f * DPIScale);
	const float CrestY = ProvY + (14.0f * DPIScale);
	DrawBeveledTablet(FVector2D(CrestX, CrestY), FVector2D(CrestSize, CrestSize), FLinearColor(0.08f, 0.04f, 0.04f, 0.98f), ColorBurnishedGold);

	// Draw Imperial Eagle Crest Relief (Geometric double-headed eagle)
	FVector2D CCenter(CrestX + CrestSize * 0.5f, CrestY + CrestSize * 0.5f);
	Canvas->K2_DrawLine(CCenter + FVector2D(0, -25.0f * DPIScale), CCenter + FVector2D(-20.0f * DPIScale, -10.0f * DPIScale), 2.0f * DPIScale, ColorBurnishedGold);
	Canvas->K2_DrawLine(CCenter + FVector2D(0, -25.0f * DPIScale), CCenter + FVector2D(20.0f * DPIScale, -10.0f * DPIScale), 2.0f * DPIScale, ColorBurnishedGold);
	Canvas->K2_DrawLine(CCenter + FVector2D(-20.0f * DPIScale, -10.0f * DPIScale), CCenter + FVector2D(-30.0f * DPIScale, 15.0f * DPIScale), 2.5f * DPIScale, ColorBurnishedGold);
	Canvas->K2_DrawLine(CCenter + FVector2D(20.0f * DPIScale, -10.0f * DPIScale), CCenter + FVector2D(30.0f * DPIScale, 15.0f * DPIScale), 2.5f * DPIScale, ColorBurnishedGold);
	Canvas->K2_DrawLine(CCenter + FVector2D(-30.0f * DPIScale, 15.0f * DPIScale), CCenter + FVector2D(0, 30.0f * DPIScale), 2.0f * DPIScale, ColorBurnishedGold);
	Canvas->K2_DrawLine(CCenter + FVector2D(30.0f * DPIScale, 15.0f * DPIScale), CCenter + FVector2D(0, 30.0f * DPIScale), 2.0f * DPIScale, ColorBurnishedGold);
	DrawFilledCircle(CCenter, 6.0f * DPIScale, ColorBurnishedGold, 12);

	// Province Details
	const float DetailX = CrestX + CrestSize + (18.0f * DPIScale);
	DrawParchmentText(LargeFont, TEXT("CITADEL OF UR-KISH"), DetailX, ProvY + (12.0f * DPIScale), 1.05f, ColorParchment);
	DrawParchmentText(DefaultFont, TEXT("(unselected)"), DetailX, ProvY + (32.0f * DPIScale), 0.85f, ColorBurnishedGold * 0.7f);

	DrawParchmentText(DefaultFont, TEXT("PROVINCE POPULATION"), DetailX, ProvY + (52.0f * DPIScale), 0.80f, ColorBurnishedGold);
	DrawParchmentText(MediumFont, TEXT("👥 139k   🛡️ 1200"), DetailX, ProvY + (68.0f * DPIScale), 0.95f, ColorParchment);

	// Realm Stability Pips
	DrawParchmentText(DefaultFont, TEXT("REALM STABILITY"), DetailX, ProvY + (90.0f * DPIScale), 0.80f, ColorBurnishedGold);
	for (int32 p = 0; p < 4; ++p)
	{
		FVector2D PipPos(DetailX + (100.0f * DPIScale) + p * (16.0f * DPIScale), ProvY + (96.0f * DPIScale));
		FLinearColor PipColor = (p < 3) ? FLinearColor(0.25f, 0.85f, 0.40f) : FLinearColor(0.85f, 0.35f, 0.20f);
		DrawFilledCircle(PipPos, 4.5f * DPIScale, PipColor, 12);
	}

	// =========================================================================
	// 3. BOTTOM-CENTER: ENGRAVED ACTION RIBBON (5 CATEGORY COMMAND TABS)
	// =========================================================================
	const float BtnW = 54.0f * DPIScale;
	const float BtnH = 48.0f * DPIScale;
	const float RibbonW = (BtnW * 5.0f) + (40.0f * DPIScale);
	const float RibbonX = (ScreenW - RibbonW) * 0.5f;
	const float RibbonY = ScreenH - BtnH - (24.0f * DPIScale);

	const TCHAR* ActionIcons[5] = { TEXT("🪖"), TEXT("🚩"), TEXT("👑"), TEXT("⚔️"), TEXT("📜") };
	const TCHAR* ActionKeys[5] = { TEXT("[1]"), TEXT("[2]"), TEXT("[3]"), TEXT("[4]"), TEXT("[5]") };

	for (int32 b = 0; b < 5; ++b)
	{
		FVector2D BtnPos(RibbonX + b * (BtnW + (8.0f * DPIScale)), RibbonY);
		DrawBeveledTablet(BtnPos, FVector2D(BtnW, BtnH), ColorBasaltBG, ColorBronzeTrim);

		DrawParchmentText(LargeFont, ActionIcons[b], BtnPos.X + (12.0f * DPIScale), BtnPos.Y + (6.0f * DPIScale), 1.0f, ColorBurnishedGold);
		DrawParchmentText(DefaultFont, ActionKeys[b], BtnPos.X + (14.0f * DPIScale), BtnPos.Y + (30.0f * DPIScale), 0.70f, ColorParchment * 0.75f);
	}

	// =========================================================================
	// 4. BOTTOM-RIGHT: PARCHMENT CARTOGRAPHIC REGIONAL MINIMAP (AST-08)
	// =========================================================================
	const float MapW = 320.0f * DPIScale;
	const float MapH = 220.0f * DPIScale;
	const float MapX = ScreenW - MapW - (24.0f * DPIScale);
	const float MapY = ScreenH - MapH - (24.0f * DPIScale);

	// Wooden & Bronze Framed Tablet
	DrawBeveledTablet(FVector2D(MapX, MapY), FVector2D(MapW, MapH), ColorParchmentBG, ColorBronzeTrim);

	// Cartographic River Splines (Tigris & Euphrates in brown ink)
	const FLinearColor ColorInkRiver = FLinearColor(0.25f, 0.42f, 0.48f, 0.95f);
	const FLinearColor ColorInkMountains = FLinearColor(0.42f, 0.35f, 0.28f, 0.85f);

	// Euphrates River Course
	Canvas->K2_DrawLine(FVector2D(MapX + (40.0f * DPIScale), MapY + (20.0f * DPIScale)), FVector2D(MapX + (110.0f * DPIScale), MapY + (70.0f * DPIScale)), 2.5f * DPIScale, ColorInkRiver);
	Canvas->K2_DrawLine(FVector2D(MapX + (110.0f * DPIScale), MapY + (70.0f * DPIScale)), FVector2D(MapX + (160.0f * DPIScale), MapY + (130.0f * DPIScale)), 2.5f * DPIScale, ColorInkRiver);
	Canvas->K2_DrawLine(FVector2D(MapX + (160.0f * DPIScale), MapY + (130.0f * DPIScale)), FVector2D(MapX + (240.0f * DPIScale), MapY + (190.0f * DPIScale)), 3.0f * DPIScale, ColorInkRiver);

	// Tigris River Course
	Canvas->K2_DrawLine(FVector2D(MapX + (90.0f * DPIScale), MapY + (15.0f * DPIScale)), FVector2D(MapX + (170.0f * DPIScale), MapY + (60.0f * DPIScale)), 2.5f * DPIScale, ColorInkRiver);
	Canvas->K2_DrawLine(FVector2D(MapX + (170.0f * DPIScale), MapY + (60.0f * DPIScale)), FVector2D(MapX + (220.0f * DPIScale), MapY + (120.0f * DPIScale)), 2.5f * DPIScale, ColorInkRiver);
	Canvas->K2_DrawLine(FVector2D(MapX + (220.0f * DPIScale), MapY + (120.0f * DPIScale)), FVector2D(MapX + (250.0f * DPIScale), MapY + (185.0f * DPIScale)), 2.8f * DPIScale, ColorInkRiver);

	// Mountain Hatching Ridges
	for (int32 m = 0; m < 6; ++m)
	{
		FVector2D MtPos(MapX + (180.0f * DPIScale) + m * (18.0f * DPIScale), MapY + (30.0f * DPIScale) + m * (14.0f * DPIScale));
		Canvas->K2_DrawLine(MtPos, MtPos + FVector2D(6.0f * DPIScale, -10.0f * DPIScale), 1.5f * DPIScale, ColorInkMountains);
		Canvas->K2_DrawLine(MtPos + FVector2D(6.0f * DPIScale, -10.0f * DPIScale), MtPos + FVector2D(12.0f * DPIScale, 0.0f), 1.5f * DPIScale, ColorInkMountains);
	}

	// Settlement Node Pins
	struct FMapPin { const TCHAR* Name; float X; float Y; FLinearColor FactionColor; };
	const FMapPin Pins[4] = {
		{ TEXT("Ur-Kish"), 140.0f, 100.0f, FLinearColor(0.85f, 0.25f, 0.25f) },
		{ TEXT("Lagash"), 190.0f, 145.0f, FLinearColor(0.25f, 0.55f, 0.95f) },
		{ TEXT("Uruk"), 120.0f, 65.0f, FLinearColor(0.85f, 0.70f, 0.25f) },
		{ TEXT("Babylon"), 240.0f, 120.0f, FLinearColor(0.65f, 0.35f, 0.85f) }
	};

	for (int32 p = 0; p < 4; ++p)
	{
		FVector2D PinPos(MapX + Pins[p].X * DPIScale, MapY + Pins[p].Y * DPIScale);
		DrawFilledCircle(PinPos, 4.0f * DPIScale, Pins[p].FactionColor, 12);
		DrawCircleRing(PinPos, 5.5f * DPIScale, 1.2f * DPIScale, FLinearColor(0.12f, 0.10f, 0.08f), 12);
		DrawParchmentText(DefaultFont, Pins[p].Name, PinPos.X - (16.0f * DPIScale), PinPos.Y + (6.0f * DPIScale), 0.70f, FLinearColor(0.15f, 0.12f, 0.08f));
	}
}

void ADominionRTSHUD::SetCommandGridActions(const TArray<FDominionCommandAction>& Actions)
{
	CurrentActions = Actions;
}

bool ADominionRTSHUD::ExecuteHotkeyAction(const FString& Hotkey)
{
	return false;
}

bool ADominionRTSHUD::HandleClick(float MouseX, float MouseY)
{
	return false;
}

void ADominionRTSHUD::DrawSelectionMarquee()
{
}

void ADominionRTSHUD::DrawMinimapOverlay()
{
}
