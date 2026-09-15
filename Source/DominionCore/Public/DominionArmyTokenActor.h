#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "DominionArmyTokenActor.generated.h"

class UStaticMeshComponent;

UCLASS()
class DOMINIONCORE_API ADominionArmyTokenActor : public AActor
{
    GENERATED_BODY()

public:
    ADominionArmyTokenActor();

    virtual void BeginPlay() override;
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
    TObjectPtr<UStaticMeshComponent> TokenMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    FString ArmyName = TEXT("I. Imperial Vanguard Cohort");

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    int32 TeamID = 0; // 0 = Player, 1 = Nomadic Raiders, 2 = Elamites

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    int32 SoldierCount = 350;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    float Morale = 95.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    float MoveSpeed = 300.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    FVector TargetLocation = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    bool bIsMoving = false;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Army")
    bool bIsSelected = false;

    UFUNCTION(BlueprintCallable, Category = "Dominion|Army")
    void MoveToLocation(const FVector& Destination);
};
