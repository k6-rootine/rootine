{
Cette unité fixe la taille de la fenêtre du terminal Windows au démarrage du programme, empêche l'utilisateur de la redimensionner et empêche le défilement (scroll) dans le terminal.
Sous Windows, elle fixe et verrouille la taille de la fenêtre. Sous Linux, elle demande seulement au terminal de se redimensionner.
}
unit WindowsManager;

interface

{
    @abstract(Fixe la taille de la fenêtre du terminal)
    @param width La largeur de la fenêtre, en nombre de colonnes
    @param height La hauteur de la fenêtre, en nombre de lignes
}
procedure lockConsoleWindow(width, height: LongInt);

implementation

{$IFDEF WINDOWS}

uses
    Windows, crt;

procedure lockConsoleWindow(width, height: LongInt);
var
    hOut, hIn: THandle;
    hWnd: LongWord;
    windowRect: TSmallRect;
    bufferSize: TCoord;
    windowStyle: LongInt;
    inputMode: LongWord;
begin
    hOut := GetStdHandle(STD_OUTPUT_HANDLE);
    hIn := GetStdHandle(STD_INPUT_HANDLE);

    { shrink the window to the minimum: Windows does not allow a window bigger than the buffer }
    windowRect.Left := 0;
    windowRect.Top := 0;
    windowRect.Right := 0;
    windowRect.Bottom := 0;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { set the size of the buffer }
    bufferSize.X := width;
    bufferSize.Y := height;
    SetConsoleScreenBufferSize(hOut, bufferSize);

    { then the size of the window (the coordinates are inclusive so -1) }
    windowRect.Right := width - 1;
    windowRect.Bottom := height - 1;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { remove the possibility to resize and maximise: first the style of the window, then the system menu }
    hWnd := GetConsoleWindow();
    windowStyle := GetWindowLong(hWnd, GWL_STYLE);
    SetWindowLong(hWnd, GWL_STYLE, windowStyle and not WS_SIZEBOX and not WS_MAXIMIZEBOX);
    SetWindowPos(hWnd, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    RemoveMenu(GetSystemMenu(hWnd, False), SC_SIZE, MF_BYCOMMAND);
    RemoveMenu(GetSystemMenu(hWnd, False), SC_MAXIMIZE, MF_BYCOMMAND);

    { disable the selection with the mouse }
    GetConsoleMode(hIn, inputMode);
    SetConsoleMode(hIn, (inputMode and not ENABLE_QUICK_EDIT_MODE) or ENABLE_EXTENDED_FLAGS);

    { set window size }
    Window(1, 1, width, height);
    clrscr;
end;

{$ELSE}

uses
    crt, SysUtils;

procedure lockConsoleWindow(width, height: LongInt);
begin
    { crt only reads the size of the terminal when the program starts. If it is too small, ask the terminal to resize itself, then start the program again so that crt reads the new size. The argument --resized prevents starting again more than once }
    if ((WindMaxX < width) or (WindMaxY < height)) and (ParamStr(1) <> '--resized') then
    begin
        { control sequence understood by most terminals: resize to height rows and width columns }
        write(#27, '[8;', height, ';', width, 't');
        { the terminal resizes asynchronously: wait a little before starting again }
        delay(300);
        Halt(ExecuteProcess(ParamStr(0), '--resized'));
    end;

    { set window size }
    Window(1, 1, width, height);
    clrscr;
end;

{$ENDIF}

end.
