:: Exécution Visionneur
if "%1"=="-v" (
    start /B "" java -cp visionneur_1_2\visionneur-1.2.jar;visionneur_1_2\ivy-java-1.2.18.jar fr.irit.diamant.ivy.viewer.Visionneur
) else if "%1"=="--visionneur" (
    start /B "" java -cp visionneur_1_2\visionneur-1.2.jar;visionneur_1_2\ivy-java-1.2.18.jar fr.irit.diamant.ivy.viewer.Visionneur
)

:: Exécution SRA5
cd "SRA5"
start /B "" "sra5.exe"

:: Exécution OneDollarIvy
cd "..\OneDollarIvy\windows-amd64"
start /B "" "OneDollarIvy.exe"

:: Exécution Palette
cd "..\..\Palette\windows-amd64"
start /B "" "Palette.exe"