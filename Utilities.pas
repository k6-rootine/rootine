unit Utilities;

interface

uses crt, SysUtils;

procedure RootineLogo(X, Y: LongInt);
procedure displayClockNumber(number: LongInt);
function isValidUsername(username: String): Boolean;
function isValidName(fullname: String): Boolean;
function computeGrowthPhase(nbPhases, elapsed, duration: LongInt): LongInt;
procedure writeWrapped(text: String; width: LongInt);
function waitKeyUntil(deadline: Int64; countdownRow: LongInt; var key: Char): Boolean;
function readIntegerUntil(prompt: String; minValue, maxValue: LongInt; deadline: Int64; countdownRow: LongInt; var timedOut: Boolean): LongInt;
function readInteger(prompt: String; minValue, maxValue: LongInt): LongInt;

const
    KEY_SPECIAL = #0; { first code of an extended key (arrows, F1...), followed by a second code }
    KEY_BACKSPACE = #8;
    KEY_ENTER = #13;

implementation
const 
    ALLOWED_USERNAME_CHARS = ['a'..'z', '0'..'9'];
    ALLOWED_FULLNAME_CHARS = ['a'..'z', 'A'..'Z', ' ', '-', ''''];
    BORDER_WIDTH = 121;
    BORDER_HEIGHT = 35;
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

procedure RootineLogo(X, Y: LongInt);
begin 
    {restrict the logo to a specific area of the console}
    Window(X, Y, X + 100, Y + 10);
    writeln('########                         ##     ##');
    writeln('##     ##                        ##     ##');
    writeln('##     ##                        ##');
    writeln('##     ##   ######    ######   ######   ##  ## #####   ######');
    writeln('########   ##    ##  ##    ##    ##     ##  ###    ## ##    ##');
    writeln('##   ##    ##    ##  ##    ##    ##     ##  ##     ## ########');
    writeln('##    ##   ##    ##  ##    ##    ##     ##  ##     ## ##');
    writeln('##     ##  ##    ##  ##    ##    ##  ## ##  ##     ## ##     ##');
    writeln('##      ##  ######    ######      ####  ##  ##     ##  ######');

    {reset the window to the full console size}
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);
end;

procedure displayClockNumber(number: LongInt);
var 
    i: LongInt;
begin 
    {0..9 numbers, -1 the colon}

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
begin 
    if nbPhases <= 0 then
        computeGrowthPhase := 0
    else if (duration <= 0) or (elapsed >= duration) then
        computeGrowthPhase := nbPhases
    else if elapsed <= 0 then
        computeGrowthPhase := 1
    else
        computeGrowthPhase := 1 + (elapsed * nbPhases) div duration;
end;

function secondsLeft(deadline: Int64): LongInt;
var
    remaining: Int64;
begin
    remaining := deadline - Int64(GetTickCount64);
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

{ waits for a key. Without deadline (0) it is a plain readkey. With a deadline it keeps the countdown up to date and returns False if the deadline is reached before a key is pressed }
function waitKeyUntil(deadline: Int64; countdownRow: LongInt; var key: Char): Boolean;
var
    lastShown: LongInt;
begin
    waitKeyUntil := True;

    if deadline = 0 then
        key := readkey
    else
    begin
        lastShown := secondsLeft(deadline);
        renderBreakCountdown(deadline, countdownRow);

        while (not keypressed) and (Int64(GetTickCount64) < deadline) do
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
                readkey {special keys send a second code that must be skipped}
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
        GoToXY(1, row);
        clreol;
        write(prompt);

        if deadline = 0 then
        begin
            readln(input);
            isEntered := True;
        end
        else
        begin
            input := '';
            key := ' ';
            repeat
                isEntered := waitKeyUntil(deadline, countdownRow, key);
                if isEntered then
                begin
                    if (key = KEY_BACKSPACE) and (length(input) > 0) then
                    begin
                        delete(input, length(input), 1);
                        write(KEY_BACKSPACE, ' ', KEY_BACKSPACE);
                    end
                    else if (key >= ' ') and (length(input) < 10) then
                    begin
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
            {a word longer than a whole line is cut}
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

            {lines stay one character shorter than the window so that a full line does not wrap by itself}
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
