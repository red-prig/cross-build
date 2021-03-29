    :: Batch file to build FPC from sources.
    :: %1 : action = clean (remove all compiled stuff) / make (compile)
    :: %2 : target = W32 / W64
    :: !!! don't forget to set YOUR path to current FPC !!!
     
    @ECHO OFF

    rem Set INST=%~dp0\build
    rem mkdir %INST%

    IF "%2"=="W32" (
            SET CurrFP=C:\lazarus\fpc\3.2.0\bin\x86_64-win64
    )
    IF "%2"=="W64" (
            SET CurrFP=C:\lazarus\fpc\3.2.0\bin\x86_64-win64
    )
    SET OldPath=%Path%
    SET Path=%CurrFP%;%OldPath%
    SET Opts=-gl -Scghi -O3 -CX -XX -WG -l -vewnhibq -dRELEASE

    IF "%1"=="clean" (
        make clean all %Opt% FPC=%CurrFP%\ppc386.exe
        GOTO Exit
    )
     
    :: "Target" stuff works only if this option is set
    SETLOCAL ENABLEDELAYEDEXPANSION
    IF "%1"=="make" (
        SET Opt=OPT="%Opts%"
        SET Target=
        IF "%2"=="W32" (
            SET Target=OS_TARGET=win32 CPU_TARGET=i386
        )
        IF "%2"=="W64" (
            SET Target=OS_TARGET=win64 CPU_TARGET=x86_64
        )
        :: ...
        IF "!Target!"=="" (
            ECHO Target is abscent or unknown... quitting
            GOTO Exit
        )
        ECHO Will compile for !Target!
        rem PAUSE
        rem SET /P ans=Compile the compiler? [y/n]
        rem IF "!ans!"=="y" (
            CD compiler
            make cycle !Target! %Opt%
            CD ..
        rem )
        rem SET /P ans=Compile other units? [y/n]
        rem IF "!ans!"=="y" (
            make singlezipinstall !Target! %Opt%
        rem )
        GOTO Exit
    )
     
    ECHO Unknown param
     
    SETLOCAL DISABLEDELAYEDEXPANSION
     
    :Exit
    SET Path=%OldPath%
     
    PAUSE
