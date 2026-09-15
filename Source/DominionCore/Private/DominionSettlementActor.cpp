#include "DominionSettlementActor.h"
#include "Components/StaticMeshComponent.h"
#include "UObject/ConstructorHelpers.h"

ADominionSettlementActor::ADominionSettlementActor()
{
    PrimaryActorTick.bCanEverTick = false;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    SetRootComponent(SceneRoot);

    CitadelMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("CitadelMesh"));
    CitadelMesh->SetupAttachment(SceneRoot);
    CitadelMesh->SetCollisionProfileName(TEXT("BlockAll"));
    CitadelMesh->SetMobility(EComponentMobility::Static);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> MeshFinder(TEXT("/Game/DominionAssets/Citadel/SM_DAE_Monumental_Ziggurat"));
    if (MeshFinder.Succeeded())
    {
        CitadelMesh->SetStaticMesh(MeshFinder.Object);
        CitadelMesh->SetRelativeScale3D(FVector(0.08f, 0.08f, 0.08f)); // Miniature strategic token scale
    }
}

void ADominionSettlementActor::BeginPlay()
{
    Super::BeginPlay();
}
