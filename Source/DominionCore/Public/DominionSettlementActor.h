#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "DominionSettlementActor.generated.h"

class UStaticMeshComponent;
class UTextRenderComponent;

UENUM(BlueprintType)
enum class EDominionSettlementTier : uint8
{
    Village UMETA(DisplayName = "Village / Hamlets"),
    Town UMETA(DisplayName = "Walled Town"),
    Citadel UMETA(DisplayName = "Provincial Citadel"),
    ImperialCapital UMETA(DisplayName = "Imperial Metropolis")
};

UCLASS()
class DOMINIONCORE_API ADominionSettlementActor : public AActor
{
    GENERATED_BODY()

public:
    ADominionSettlementActor();

    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<UStaticMeshComponent> CitadelMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    FString SettlementName = TEXT("Citadel of Ur-Kish");

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    int32 TeamID = 0; // 0 = Player, 1 = Nomadic Raiders, 2 = Elamite Coalition

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    EDominionSettlementTier Tier = EDominionSettlementTier::Citadel;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    int32 Population = 139000;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    int32 GarrisonStrength = 1200;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    float RealmStability = 0.85f; // 0.0 to 1.0

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    float GrainProductionRate = 45.0f; // per minute

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    float BronzeProductionRate = 12.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Settlement")
    bool bIsSelected = false;
};
