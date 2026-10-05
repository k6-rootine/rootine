{ Gere les sauvegardes avec des fichiers types : un record par fichier.
  Les dossiers data sont relatifs au dossier depuis lequel le programme est lance. }
unit FileManager;

{$mode objfpc}

interface

uses UserData, TreeData, SysUtils;

const
    MAX_SPECIES = 100;
    DOSSIER_USR = 'data/users/';
    DOSSIER_TREE = 'data/trees/';

type
    { Les cases inutilisees de la liste contiennent ''. }
    TStringArray = array[1..MAX_SPECIES] of string;

{ Verifie si le fichier username.dat existe. }
function userExists(username: string): Boolean;

{ Enregistre user dans username.dat et remplace l'ancienne sauvegarde.
  Le pseudo doit etre un nom de fichier valide, sans chemin. }
procedure saveUser(user: TUser);

{ Lit un TUser depuis username.dat.
  Retourne un utilisateur vide si le fichier manque. }
function loadUser(username: string): TUser;

{ Verifie si le fichier speciesName.dat existe. }
function treeExists(speciesName: string): Boolean;

{ Lit un TTree depuis speciesName.dat.
  Retourne un arbre vide si le fichier manque. }
function loadTree(speciesName: string): TTree;

{ Liste les noms des fichiers .dat du dossier des arbres, sans l'extension.
  Ignore les dossiers et garde au maximum MAX_SPECIES noms.
  L'ordre des noms depend du dossier. }
function getAvailableSpecies(): TStringArray;

{ Compte les especes presentes dans la liste, au maximum MAX_SPECIES. }
function getNbAvailableSpecies(): Word;

implementation

function userExists(username: string): Boolean;
begin
    userExists := FileExists(DOSSIER_USR + username + '.dat');
end;

procedure saveUser(user: TUser);
var
    f: file of TUser;
begin
    if user.username = '' then
        raise EInOutError.Create('Le pseudo ne peut pas etre vide.');
    if not ForceDirectories(DOSSIER_USR) then
        raise EInOutError.Create('Impossible de creer le dossier des utilisateurs.');

    Assign(f, DOSSIER_USR + user.username + '.dat');
    Rewrite(f);
    try
        { Write enregistre tout le record en une seule operation. }
        Write(f, user);
    finally
        { Le fichier est ferme meme si une erreur survient. }
        Close(f);
    end;
end;

function loadUser(username: string): TUser;
var
    f: file of TUser;
    user: TUser;
begin
    user := initialiseUser();
    if userExists(username) then
    begin
        Assign(f, DOSSIER_USR + username + '.dat');
        Reset(f);
        try
            { FileSize compte les records, pas les octets. }
            if FileSize(f) <> 1 then
                raise EInOutError.Create('Le fichier doit contenir un utilisateur.');
            Read(f, user);
        finally
            Close(f);
        end;
    end;
    loadUser := user;
end;

function treeExists(speciesName: string): Boolean;
begin
    treeExists := FileExists(DOSSIER_TREE + speciesName + '.dat');
end;

function loadTree(speciesName: string): TTree;
var
    f: file of TTree;
    tree: TTree;
begin
    tree := initialiseTree();
    if treeExists(speciesName) then
    begin
        Assign(f, DOSSIER_TREE + speciesName + '.dat');
        Reset(f);
        try
            if FileSize(f) <> 1 then
                raise EInOutError.Create('Le fichier doit contenir un arbre.');
            { Read charge aussi les tableaux de phases du record. }
            Read(f, tree);
        finally
            Close(f);
        end;
    end;
    loadTree := tree;
end;

function getAvailableSpecies(): TStringArray;
var
    tab: TStringArray;
    search: TSearchRec;
    i, count: LongInt;
begin
    for i := 1 to MAX_SPECIES do
        tab[i] := '';
    count := 0;

    { FindFirst renvoie 0 lorsqu'un premier fichier est trouve. }
    if FindFirst(DOSSIER_TREE + '*.dat', faAnyFile, search) = 0 then
    begin
        try
            repeat
                if (search.Attr and faDirectory) = 0 then
                begin
                    count := count + 1;
                    tab[count] := ChangeFileExt(search.Name, '');
                end;
            until (count = MAX_SPECIES) or (FindNext(search) <> 0);
        finally
            FindClose(search);
        end;
    end;
    getAvailableSpecies := tab;
end;

function getNbAvailableSpecies(): Word;
var
    tab: TStringArray;
    i: LongInt;
    count: Word;
begin
    { Reutilise la liste pour compter exactement les memes fichiers. }
    tab := getAvailableSpecies();
    count := 0;
    for i := 1 to MAX_SPECIES do
        if tab[i] <> '' then
            count := count + 1;
    getNbAvailableSpecies := count;
end;

end.
