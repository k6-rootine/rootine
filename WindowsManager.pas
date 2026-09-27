{ Fixe la taille de la fenêtre du terminal au démarrage du programme, empêche l'utilisateur de la redimensionner, et empêche le défilement (scroll) dans le terminal.  }
unit WindowsManager;

interface

{$IFDEF WINDOWS}
uses
    Windows, crt;
{$ENDIF}

{$IFDEF UNIX}

{$ENDIF}

{ @abstract(Fixe la taille de la fenêtre du terminal, bloque le
  redimensionnement, et empêche le défilement.)

  À appeler une seule fois, au début du programme.

  @param(width La largeur de la fenêtre, en nombre de colonnes.)
  @param(height La hauteur de la fenêtre, en nombre de lignes.) 
}
procedure lockConsoleWindow(width, height: LongInt);


implementation

{$IFDEF WINDOWS}

procedure lockConsoleWindow(width, height: LongInt);
var
    hOut: THandle;
    hWnd: LongWord;
    hSysMenu: HMENU;
    windowRect: TSmallRect;
    bufferSize: TCoord;
    windowStyle: LongInt;
    consoleMode: LongWord;
const
    ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
begin
    hOut := GetStdHandle(STD_OUTPUT_HANDLE);

    GetConsoleMode(hOut, consoleMode);
    SetConsoleMode(hOut, consoleMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING);

    { Réduit d'abord la fenêtre au minimum : Windows interdit une fenêtre plus grande que le tampon. }
    windowRect.Left := 0;
    windowRect.Top := 0;
    windowRect.Right := 0;
    windowRect.Bottom := 0;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { Fixe la taille du tampon. Elle est égale à la taille de la fenêtre : 
    il n'y a donc rien au-delà de l'écran visible, et le  défilement (scroll) devient impossible. }
    bufferSize.X := width;
    bufferSize.Y := height;
    SetConsoleScreenBufferSize(hOut, bufferSize);

    { Fixe la taille de la fenêtre (coordonnées inclusives, d'où le -1). }
    windowRect.Left := 0;
    windowRect.Top := 0;
    windowRect.Right := width - 1;
    windowRect.Bottom := height - 1;
    SetConsoleWindowInfo(hOut, True, windowRect);

    { Retire la possibilité de redimensionner : d'abord le style de la fenêtre, puis le menu système. }
    hWnd := GetConsoleWindow();

    windowStyle := GetWindowLong(hWnd, GWL_STYLE);
    windowStyle := windowStyle and not WS_SIZEBOX and not WS_MAXIMIZEBOX;
    SetWindowLong(hWnd, GWL_STYLE, windowStyle);

    { Force le redessin du cadre pour appliquer le nouveau style. }
    SetWindowPos(hWnd, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);

    hSysMenu := GetSystemMenu(hWnd, False);
    RemoveMenu(hSysMenu, SC_SIZE, MF_BYCOMMAND);
    RemoveMenu(hSysMenu, SC_MAXIMIZE, MF_BYCOMMAND);

    { crt garde sa propre idée de la taille de l'écran, décidée avant
      cet appel. On la met à jour avec la vraie taille, sinon crt
      continue de faire défiler le texte à l'ancienne taille. }
    Window(1, 1, width, height);
    ClrScr;
end;

{$ENDIF}

{$IFDEF UNIX}
procedure lockConsoleWindow(width, height: LongInt); 
begin 
    { nothing }
end;
{$ENDIF}

end.