unit Utilities;

interface

uses crt;

procedure RootineLogo(X, Y: LongInt);
procedure displayClockNumber(number: LongInt);
function isValidUsername(username: String): Boolean;
function isValidName(fullname: String): Boolean;

implementation
const 
    ALLOWED_USERNAME_CHARS = ['a'..'z', 'A'..'Z', '0'..'9'];
    ALLOWED_FULLNAME_CHARS = ['a'..'z', 'A'..'Z', ' ', '-', ''''];
    BORDER_WIDTH = 120;
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
    if (Length(username) < 1) or (Length(username) > 20) then
    begin
        isValidUsername := False;
        Exit;
    end;

    for i := 1 to Length(username) do
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
    for i := 1 to Length(fullname) do
    begin
        if not (fullname[i] in ALLOWED_FULLNAME_CHARS) then
        begin
            isValidName := False;
            Exit;
        end;
    end;
    isValidName := True;
end;

end.
