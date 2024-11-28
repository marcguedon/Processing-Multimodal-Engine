@REM Exécution Visionneur
@REM start /B "" java -cp visionneur_1_2\visionneur-1.2.jar;visionneur_1_2\ivy-java-1.2.18.jar fr.irit.diamant.ivy.viewer.Visionneur

@REM Exécution SRA5
cd "sra5"
start /B "" "sra5.exe"

@REM Exécution OneDollarIvy
cd "..\OneDollarIvy"
start /B "" "OneDollarIvy.exe"

@REM Exécution Palette
cd "..\Palette"
start /B "" "Palette.exe"