unit Utilities;

interface

uses crt;

procedure RootineLogo(X, Y: LongInt);
procedure ClockNumber(number: LongInt);

implementation
procedure RootineLogo(X, Y: LongInt);
begin 
    GoToXY(X, Y);
    write('########                         ##     ##');
    GoToXY(X, Y + 1);
    write('##     ##                        ##     ##');
    GoToXY(X, Y + 2);
    write('##     ##                        ##');
    GoToXY(X, Y + 3);
    write('##     ##   ######    ######   ######   ##  ## #####   ######');
    GoToXY(X, Y + 4);
    write('########   ##    ##  ##    ##    ##     ##  ###    ## ##    ##');
    GoToXY(X, Y + 5);
    write('##   ##    ##    ##  ##    ##    ##     ##  ##     ## ########');
    GoToXY(X, Y + 6);
    write('##    ##   ##    ##  ##    ##    ##     ##  ##     ## ##');
    GoToXY(X, Y + 7);
    write('##     ##  ##    ##  ##    ##    ##  ## ##  ##     ## ##     ##');
    GoToXY(X, Y + 8);
    write('##      ##  ######    ######      ####  ##  ##     ##  ######');
end;

procedure ClockNumber(number: LongInt);
begin 

end;

end.
