unit FileManager;




interface

uses UserData, TreeData, Sysutils;

const
    MAX_SPECIES = 100;
    DOSSIER_USR = 'data/users/';
    DOSSIER_TREE = 'data/trees/';

type 
    TStringArray = Array[1..MAX_SPECIES] of string;


function userExists(username: string): Boolean;
procedure saveUser(user: TUser);
function loadUser(username: string): TUser;
function treeExists(speciesName: string): Boolean;
function loadTree(speciesName: string): TTree;
function getAvailableSpecies(): TStringArray;
function getNbAvailableSpecies(): Word;

implementation

function userExists(username: string): Boolean;
begin
    userExists := FileExists(DOSSIER_USR + username + '.txt');
end;

procedure saveUser(user: TUser);
var 
    f: TextFile;
begin
    AssignFile(f, DOSSIER_USR + user.username + '.txt');
    Rewrite(f);
    WriteLn(f, user.firstName);
    WriteLn(f, user.lastName);
    WriteLn(f, user.username);
    WriteLn(f, user.description);
    WriteLn(f, user.joinDate.day, ' ', user.joinDate.month, ' ', user.joinDate.year);
    WriteLn(f, user.nbSessionsDone, ' ', user.nbCyclesDone, ' ', user.totalFocusTime);
    WriteLn(f, user.forest.nbSpecies);

    for var i := 1 to user.forest.nbSpecies do
    begin
        WriteLn(f, user.forest.speciesName[i]);
        WriteLn(f, user.forest.nbTreesGrown[i]);
    end;

    CloseFile(f);

end;

function loadUser(username: string): TUser;
begin
    var 
    f: TextFile;
    user: TUser;
begin
    AssignFile(f, DOSSIER_USR + username + '.txt');
    Reset(f);
    ReadLn(f, user.firstName);
    ReadLn(f, user.lastName);
    ReadLn(f, user.username);
    ReadLn(f, user.description);
    ReadLn(f, user.joinDate.day, ' ', user.joinDate.month, ' ', user.joinDate.year);
    ReadLn(f, user.nbSessionsDone, ' ', user.nbCyclesDone, ' ', user.totalFocusTime);
    ReadLn(f, user.forest.nbSpecies);

    for var i := 1 to user.forest.nbSpecies do
    begin
        ReadLn(f, user.forest.speciesName[i]);
        ReadLn(f, user.forest.nbTreesGrown[i]);
    end;

    CloseFile(f);
    loadUser := user;
end;

function treeExists(speciesName: string): Boolean;
begin
  treeExists := FileExists(DOSSIER_TREE + speciesName + '.txt');
end;

function loadTree(speciesName: string): TTree;
begin
  // Implementation for loading tree data
end;

function getAvailableSpecies(): TStringArray;
begin
  // Implementation for getting available species
end;    

function getNbAvailableSpecies(): Word;
begin
  // Implementation for getting number of available species
end;    


end.
