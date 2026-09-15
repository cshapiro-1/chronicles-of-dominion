#include "DominionArmyTokenActor.h"
#include "Components/StaticMeshComponent.h"
#include "UObject/ConstructorHelpers.h"

ADominionArmyTokenActor::ADominionArmyTokenActor()
{
    PrimaryActorTick.bCanEverTick = true;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    SetRootComponent(SceneRoot);

    TokenMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("TokenMesh"));
    TokenMesh->SetupAttachment(SceneRoot);
    TokenMesh->SetCollisionProfileName(TEXT("BlockAll"));

    static ConstructorHelpers::FObjectFinder<UStaticMesh> MeshFinder(TEXT("/Game/Characters/Mannequins/Meshes/SM_Sumerian_Spearman"));
    if (!MeshFinder.Succeeded())
    {
        static ConstructorHelpers::FObjectFinder<UStaticMesh> FallbackFinder(TEXT("/Game/DominionAssets/Citadel/SM_DAE_Courtyard_Altar"));
        if (FallbackFinder.Succeeded())
        {
            TokenMesh->SetStaticMesh(FallbackFinder.Object);
        }
    }
    else
    {
        TokenMesh->SetStaticMesh(MeshFinder.Object);
    }
    TokenMesh->SetRelativeScale3D(FVector(1.2f, 1.2f, 1.2f));
}

void ADominionArmyTokenActor::BeginPlay()
{
    Super::BeginPlay();
    TargetLocation = GetActorLocation();
}

void ADominionArmyTokenActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (bIsMoving)
    {
        FVector CurrentLoc = GetActorLocation();
        FVector Dir = (TargetLocation - CurrentLoc);
        float Dist = Dir.Size2D();

        if (Dist < 20.0f)
        {
            SetActorLocation(FVector(TargetLocation.X, TargetLocation.Y, CurrentLoc.Z));
            bIsMoving = false;
        }
        else
        {
            Dir.Z = 0.0f;
            Dir.Normalize();
            FVector NewLoc = CurrentLoc + Dir * MoveSpeed * DeltaTime;
            SetActorLocation(NewLoc);

            FRotator TargetRot = Dir.Rotation();
            SetActorRotation(FMath::RInterpTo(GetActorRotation(), TargetRot, DeltaTime, 5.0f));
        }
    }
}

void ADominionArmyTokenActor::MoveToLocation(const FVector& Destination)
{
    TargetLocation = Destination;
    bIsMoving = true;
}
