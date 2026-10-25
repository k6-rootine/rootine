unit Utilities;

interface

uses crt;

procedure RootineLogo(X, Y: LongInt);
procedure ClockNumber(number: LongInt);
function isValidUsername(username: String): Boolean;
function isValidFullname(fullname: String): Boolean;

implementation
const 
    ALLOWED_USERNAME_CHARS = ['a'..'z', 'A'..'Z', '0'..'9'];
    ALLOWED_FULLNAME_CHARS = ['a'..'z', 'A'..'Z', ' '];
    BORDER_WIDTH = 120;
    BORDER_HEIGHT = 35;

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

procedure ClockNumber(number: LongInt);
begin 

end;

function isValidUsername(username: String): Boolean;
var 
    i: LongInt;
begin 
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

function isValidFullname(fullname: String): Boolean;
var 
    i: LongInt;
begin 
    for i := 1 to Length(fullname) do
    begin
        if not (fullname[i] in ALLOWED_FULLNAME_CHARS) then
        begin
            isValidFullname := False;
            Exit;
        end;
    end;
    isValidFullname := True;
end;

end.
