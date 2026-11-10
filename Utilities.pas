{
    Cette unité regroupe les procédures et fonctions utilitaires du programme.
}
unit Utilities;

interface

uses crt, SysUtils;

{
    @abstract(Dessine le logo Rootine)
    @param X La colonne du coin supérieur gauche du logo
    @param Y La ligne du coin supérieur gauche du logo
}
procedure RootineLogo(X, Y: LongInt);

{
    @abstract(Écrit un symbole de l'horloge en grand)
    @param number Le chiffre à écrire, de 0 à 9, ou -1 pour les deux points
}
procedure displayClockNumber(number: LongInt);

{
    @abstract(Vérifie qu'un nom d'utilisateur est valide)
    @param username Le nom d'utilisateur à vérifier
    @returns(Vrai si le nom d'utilisateur est valide)
}
function isValidUsername(username: String): Boolean;

{
    @abstract(Vérifie qu'un prénom est valide)
    @param fullname le prénom à vérifier
    @returns(Vrai si le prénom est valide)
}
function isValidName(fullname: String): Boolean;

{
    @abstract(Calcule la phase de croissance d'un arbre selon te temps écoulé)
    Les phases 1 à nbPhases - 1 se succèdent à intervalles réguliers (croissance linéaire) pendant la session, sauf pendant ses 5 dernières secondes. La dernière phase (nbPhases) n'est affichée que pendant ces 5 dernières secondes, jusqu'à la fin de la session.
    @param nbPhases Le nombre de phases de l'arbre
    @param elapsed Le temps écoulé de la session, en secondes
    @param duration La durée totale de la session, en secondes
    @returns(Le numéro de la phase à afficher, de 1 à nbPhases, ou 0 si nbPhases n'est pas strictement positif)
}
function computeGrowthPhase(nbPhases, elapsed, duration: LongInt): LongInt;

{
    @abstract(Écrit un texte sur plusieurs lignes sans couper les mots)
    @param text Le texte à écrire
    @param width La largeur de la zone d'écriture, en nombre de colonnes
}
procedure writeWrapped(text: String; width: LongInt);

{
    @abstract(Attend une touche, avec une limite de temps éventuelle)
    @param deadline La fin de l'attente, en millisecondes, ou 0 s'il n'y a pas de limite de temps
    @param countdownRow La ligne de la fenêtre courante où le temps restant est affiché
    @param key La touche pressée
    @returns(Vrai si une touche a été pressée. Faux si le temps est écoulé)
}
function waitKeyUntil(deadline: Int64; countdownRow: LongInt; var key: Char): Boolean;

{
    @abstract(Lit un nombre entier compris dans un intervalle, avec une limite de temps éventuelle)
    @param prompt Le message affiché devant la saisie
    @param minValue La plus petite valeur acceptée
    @param maxValue La plus grande valeur acceptée
    @param deadline La fin de la saisie, en millisecondes, ou 0 s'il n'y a pas de limite de temps
    @param countdownRow La ligne de la fenêtre courante où le temps restant est affiché
    @param timedOut Vrai si la saise s'est arrêtée parce que le temps est écoulé
    @returns(Le nombre saisi. Si le temps est écoule, la valeur renvoyée n'est pas significative)
}
function readIntegerUntil(prompt: String; minValue, maxValue: LongInt; deadline: Int64; countdownRow: LongInt; var timedOut: Boolean): LongInt;

{
    @abstract(Lit un nombre entier compris dans un intervalle, sans limite de temps)
    @param prompt Le message affiché devant la saisie
    @param minValue La plus petite valeur acceptée
    @param maxValue La plus grande valeur acceptée
    @returns(Le nombre saisi)
}
function readInteger(prompt: String; minValue, maxValue: LongInt): LongInt;

{
    @abstract(Restreint l'affichage à une zone rectangulaire du cadre)
    Les coordonnées sont celles du cadre : (1, 1) est son coin supérieur gauche. Les coins donnés font partie de la zone. Le curseur est placé en haut à gauche de la zone.
    Chaque appel doit être suivi d'un appel à leaveArea quand on a fini d'écrire dans la zone.
    @param x1 La colonne du coin supérieur gauche de la zone
    @param y1 La ligne du coin supérieur gauche de la zone
    @param x2 La colonne du coin inférieur droit de la zone
    @param y2 La ligne du coin inférieur droit de la zone
}
procedure enterArea(x1, y1, x2, y2: LongInt);

{
    @abstract(Remet l'affichage sur tout le cadre)
    Annule enterArea : les coordonnées sont de nouveau celles du cadre entier.
}
procedure leaveArea();

{
    @abstract(Donne l'instant actuel en millisecondes)
    Le nombre est celui de GetTickCount64. Il ne sert qu'à mesurer des durées en faisant la différence de deux appels.
    @returns(Le nombre de millisecondes écoulées depuis le démarrage de Windows)
}
function currentTick(): Int64;

{
    @abstract(Calcule l'instant d'une échéance située dans un certain nombre de secondes)
    @param seconds Le nombre de secondes avant l'échéance
    @returns(L'instant de l'échéance, en millisecondes)
}
function deadlineIn(seconds: LongInt): Int64;

const
    KEY_SPECIAL = #0; //> Premier code d'une touche spéciale (flèches, F1...), suivi d'un second code 
    KEY_BACKSPACE = #8; //> Touche Retour arrière 
    KEY_ENTER = #13; //> Touche Entrée 
    BORDER_WIDTH = 121; //> Nombre de colonnes de l'écran, cadre compris 
    BORDER_HEIGHT = 35; //> Nombre de lignes de l'écran, cadre compris 
    SCREEN_MARGIN_X = 4; //> Distance, en colonnes, entre les bords gauche et droit du terminal verrouillé et le cadre
    SCREEN_MARGIN_Y = 2; //> Distance, en lignes, entre les bords haut et bas du terminal verrouillé et le cadre

implementation
const 
    ALLOWED_USERNAME_CHARS = ['a'..'z', '0'..'9'];
    ALLOWED_FULLNAME_CHARS = ['a'..'z', 'A'..'Z', ' ', '-', ''''];
    NUMBERS : Array[0..9, 1..7] of String = (
        ('######', '##  ##', '##  ##', '##  ##', '##  ##', '##  ##', '######'),   { 0 }
        ('####  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '######'),   { 1 }
        ('######', '    ##', '    ##', '######', '##    ', '##    ', '######'),   { 2 }
        ('######', '    ##', '    ##', '######', '    ##', '    ##', '######'),   { 3 }
        ('##  ##', '##  ##', '##  ##', '######', '    ##', '    ##', '    ##'),   { 4 }
        ('######', '##    ', '##    ', '######', '    ##', '    ##', '######'),   { 5 }
        ('######', '##    ', '##    ', '######', '##  ##', '##  ##', '######'),   { 6 }
        ('######', '    ##', '    ##', '    ##', '    ##', '    ##', '    ##'),   { 7 }
        ('######', '##  ##', '##  ##', '######', '##  ##', '##  ##', '######'),   { 8 }
        ('######', '##  ##', '##  ##', '######', '    ##', '    ##', '######')    { 9 }
    );
    COLON : Array[1..7] of String = ('    ', '    ', ' ## ', '    ', ' ## ', '    ', '    ');

procedure enterArea(x1, y1, x2, y2: LongInt);
begin
    { restricts the output to a rectangular area of the frame (corners/borders are included) }
    Window(x1 + SCREEN_MARGIN_X, y1 + SCREEN_MARGIN_Y, x2 + SCREEN_MARGIN_X, y2 + SCREEN_MARGIN_Y);
    GoToXY(1, 1);
end;

procedure leaveArea();
begin
    { resets the output to the whole frame }
    Window(SCREEN_MARGIN_X + 1, SCREEN_MARGIN_Y + 1, BORDER_WIDTH + SCREEN_MARGIN_X + 1, BORDER_HEIGHT + SCREEN_MARGIN_Y + 1);
end;

function currentTick(): Int64;
begin
    currentTick := Int64(GetTickCount64);
end;

procedure RootineLogo(X, Y: LongInt);
begin 
    enterArea(X, Y, BORDER_WIDTH - 1, Y + 10);

    writeln('########                         ##     ##');
    writeln('##     ##                        ##     ##');
    writeln('##     ##                        ##');
    writeln('##     ##   ######    ######   ######   ##  ## #####   ######');
    writeln('########   ##    ##  ##    ##    ##     ##  ###    ## ##    ##');
    writeln('##   ##    ##    ##  ##    ##    ##     ##  ##     ## ########');
    writeln('##    ##   ##    ##  ##    ##    ##     ##  ##     ## ##');
    writeln('##     ##  ##    ##  ##    ##    ##  ## ##  ##     ## ##     ##');
    writeln('##      ##  ######    ######      ####  ##  ##     ##  ######');

    leaveArea();
end;

procedure displayClockNumber(number: LongInt);
var 
    i: LongInt;
begin 
    { 0..9 numbers, -1 the colon }

    if (number >= 0) and (number <= 9) then 
        for i := 1 to 7 do 
            writeln(NUMBERS[number][i])
    else if (number = -1) then 
        for i := 1 to 7 do 
            writeln(COLON[i]);
end;

function isValidUsername(username: String): Boolean;
var 
    i: LongInt;
begin 
    if (length(username) < 1) or (length(username) > 30) then
    begin
        isValidUsername := False;
        Exit;
    end;

    for i := 1 to length(username) do
    begin
        if not (username[i] in ALLOWED_USERNAME_CHARS) then
        begin
            isValidUsername := False;
            Exit;
        end;
    end;
    isValidUsername := True;
end;

function isValidName(fullname: String): Boolean;
var 
    i: LongInt;
begin
    for i := 1 to length(fullname) do
    begin
        if not (fullname[i] in ALLOWED_FULLNAME_CHARS) then
        begin
            isValidName := False;
            Exit;
        end;
    end;
    isValidName := True;
end;

function computeGrowthPhase(nbPhases, elapsed, duration: LongInt): LongInt;
const 
    LAST_PHASE_SECONDS = 5;
begin 
    if nbPhases <= 0 then
        computeGrowthPhase := 0
    else if (nbPhases = 1) or (duration <= 0) or (elapsed >= duration) then
        computeGrowthPhase := nbPhases
    else if elapsed <= 0 then
        computeGrowthPhase := 1
    else if duration - elapsed <= LAST_PHASE_SECONDS then
        { the last phase is only shown during the last seconds of the session }
        computeGrowthPhase := nbPhases
    else
        { the phases 1 to nbPhases - 1 grow linearly during the time before the last seconds }
        computeGrowthPhase := 1 + (elapsed * (nbPhases - 1)) div (duration - LAST_PHASE_SECONDS);
end;

function deadlineIn(seconds: LongInt): Int64;
begin
    deadlineIn := currentTick() + Int64(seconds) * 1000;
end;

function secondsLeft(deadline: Int64): LongInt;
var
    remaining: Int64;
begin
    { returns the time remaining by calculating the difference between two ticks, then convert to seconds }
    remaining := deadline - currentTick();

    if remaining <= 0 then
        secondsLeft := 0
    else
        secondsLeft := LongInt((remaining + 999) div 1000);
end;

procedure renderBreakCountdown(deadline: Int64; row: LongInt);
var
    x, y, seconds: LongInt;
begin
    seconds := secondsLeft(deadline);
    x := WhereX;
    y := WhereY;
    GoToXY(1, row);
    clreol;
    write('Temps restant de la pause : ', format('%.2d:%.2d', [seconds div 60, seconds mod 60]));
    GoToXY(x, y);
end;

function waitKeyUntil(deadline: Int64; countdownRow: LongInt; var key: Char): Boolean;
var
    lastShown: LongInt;
begin
    waitKeyUntil := True;

    if deadline = 0 then
        { no time constraint, just read }
        key := readkey
    else
    begin
        lastShown := secondsLeft(deadline); { time currently displayed in countdown }
        renderBreakCountdown(deadline, countdownRow);

        while (not keypressed) and (currentTick() < deadline) do
        begin
            if secondsLeft(deadline) <> lastShown then
            begin
                lastShown := secondsLeft(deadline);
                renderBreakCountdown(deadline, countdownRow);
            end;
            delay(20);
        end;

        if keypressed then
        begin
            key := readkey;
            if key = KEY_SPECIAL then
                readkey; { special keys send a second code that must be skipped }
        end
        else
            waitKeyUntil := False;
    end;
end;

function readIntegerUntil(prompt: String; minValue, maxValue: LongInt; deadline: Int64; countdownRow: LongInt; var timedOut: Boolean): LongInt;
var
    input: String;
    value, code, row: LongInt;
    isValid, isEntered: Boolean;
    key: Char;
begin
    timedOut := False;
    value := minValue;
    row := WhereY;
    repeat
        { write the prompt at a specific coord }
        GoToXY(1, row);
        clreol;
        write(prompt);

        if deadline = 0 then
        begin
            { no time constraint. readln normally }
            readln(input);
            isEntered := True;
        end
        else
        begin
            input := '';
            key := ' ';
            repeat
                { verify if the user presses a key }
                isEntered := waitKeyUntil(deadline, countdownRow, key);
                if isEntered then
                begin
                    if (key = KEY_BACKSPACE) and (length(input) > 0) then
                    begin
                        { backspace -> delete the previous character }
                        delete(input, length(input), 1);
                        write(KEY_BACKSPACE, ' ', KEY_BACKSPACE);
                    end
                    else if (key in ['0'..'9']) and (length(input) < 10) then { length input < 10 since LongInt max 10 digits }
                    begin
                        { prints out the corresponding number }
                        input := input + key;
                        write(key);
                    end;
                end;
            until (not isEntered) or (key = KEY_ENTER);
        end;

        if not isEntered then
        begin
            timedOut := True;
            isValid := True;
        end
        else
        begin
            val(input, value, code);
            isValid := (code = 0) and (value >= minValue) and (value <= maxValue);

            GoToXY(1, row + 1);
            clreol;
            if not isValid then
                write('Valeur invalide : entrez un entier entre ', minValue, ' et ', maxValue, '.');
        end;
    until isValid;
    readIntegerUntil := value;
end;

function readInteger(prompt: String; minValue, maxValue: LongInt): LongInt;
var
    timedOut: Boolean;
begin
    readInteger := readIntegerUntil(prompt, minValue, maxValue, 0, 1, timedOut);
end;

procedure writeWrapped(text: String; width: LongInt);
var
    w: String;
    lineLength, spacePos: LongInt;
begin
    lineLength := 0;
    text := text + ' ';

    while length(text) > 0 do
    begin
        spacePos := pos(' ', text);
        w := copy(text, 1, spacePos - 1);
        delete(text, 1, spacePos);

        if w <> '' then
        begin
            { a word longer than a whole line is cut }
            while length(w) >= width do
            begin
                if lineLength > 0 then
                begin
                    writeln;
                    lineLength := 0;
                end;
                writeln(copy(w, 1, width - 1));
                delete(w, 1, width - 1);
            end;

            { lines stay one character shorter than the window so that a full line does not wrap by itself }
            if (lineLength > 0) and (lineLength + 1 + length(w) > width - 1) then
            begin
                writeln;
                lineLength := 0;
            end;

            if lineLength > 0 then
            begin
                write(' ');
                lineLength := lineLength + 1;
            end;
            write(w);
            lineLength := lineLength + length(w);
        end;
    end;
    writeln;
end;

end.
