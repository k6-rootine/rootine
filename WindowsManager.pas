{
Cette unité fixe la taille de la fenêtre du terminal Windows au démarrage du programme, empêche l'utilisateur de la redimensionner et empêche le défilement (scroll) dans le terminal.
Elle ne dépend d'aucune autre unité du programme et ne fonctionne que sous Windows (sous un autre système, elle ne fait rien).
}
unit WindowsManager;

interface

{
    @abstract(Fixe la taille de la fenêtre du terminal)
    La taille du tampon est égale à la taille de la fenêtre : il n'y a rien au-delà de l'écran visible, donc le défilement est impossible.
    Le redimensionnement et l'agrandissement de la fenêtre sont bloqués, et la sélection à la souris est désactivée (elle mettrait le programme en pause).
    Pour qu'écrire dans la dernière case du cadre ne fasse pas défiler l'écran, la taille donnée doit être un peu plus grande que celle du cadre.
    À appeler une seule fois, au début du programme et avant tout affichage.
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

    { Réduit d'abord la fenêtre au minimum : Windows interdit une fenêtre plus grande que le tampon. }
    windowRect.Left := 0;
    windowRect.Top := 0;
    windowRect.Right := 0;
    windowRect.Bottom := 0;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { Fixe la taille du tampon, puis celle de la fenêtre (coordonnées inclusives, d'où le -1). }
    bufferSize.X := width;
    bufferSize.Y := height;
    SetConsoleScreenBufferSize(hOut, bufferSize);

    windowRect.Right := width - 1;
    windowRect.Bottom := height - 1;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { Retire la possibilité de redimensionner et d'agrandir : le style de la fenêtre, puis le menu système. }
    hWnd := GetConsoleWindow();
    windowStyle := GetWindowLong(hWnd, GWL_STYLE);
    SetWindowLong(hWnd, GWL_STYLE, windowStyle and not WS_SIZEBOX and not WS_MAXIMIZEBOX);
    SetWindowPos(hWnd, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    RemoveMenu(GetSystemMenu(hWnd, False), SC_SIZE, MF_BYCOMMAND);
    RemoveMenu(GetSystemMenu(hWnd, False), SC_MAXIMIZE, MF_BYCOMMAND);

    { Désactive la sélection à la souris : un clic dans le terminal mettrait le programme en pause. }
    GetConsoleMode(hIn, inputMode);
    SetConsoleMode(hIn, (inputMode and not ENABLE_QUICK_EDIT_MODE) or ENABLE_EXTENDED_FLAGS);

    { crt garde sa propre idée de la taille de l'écran, décidée avant cet appel : on la met à jour avec la vraie taille. }
    Window(1, 1, width, height);
    clrscr;
end;

{$ELSE}

procedure lockConsoleWindow(width, height: LongInt);
begin
    { rien à faire : seul Windows est géré }
end;

{$ENDIF}

end.
