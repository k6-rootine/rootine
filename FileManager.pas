{ Gere les sauvegardes avec des fichiers types : un record par fichier.
  Les dossiers data sont relatifs au dossier depuis lequel le programme est lance. }
unit FileManager;

interface

uses UserData, TreeData, SysUtils;

const
    MAX_SPECIES = 100;
    PATH_DATA = 'data/';
    PATH_USER = 'data/users/';
    PATH_TREE = 'data/trees/';
    FILE_EXT = '.dat';

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
function getNbAvailableSpecies(): LongInt;

implementation

function userExists(username: string): Boolean;
begin
    userExists := FileExists(PATH_USER + username + FILE_EXT);
end;

procedure saveUser(user: TUser);
var
    f: File of TUser;
begin
    assign(f, PATH_USER + getUsername(user) + FILE_EXT);
    rewrite(f);
    write(f, user);
    close(f);
end;

function loadUser(username: String): TUser;
var
    f: File of TUser;
    user: TUser;
begin
    assign(f, PATH_USER + username + FILE_EXT);
    reset(f);
    read(f, user);
    close(f);
    loadUser := user;
end;

function treeExists(speciesName: string): Boolean;
begin
    treeExists := FileExists(PATH_TREE + speciesName + '.dat');
end;

function loadTree(speciesName: string): TTree;
var
    f: File of TTree;
    tree: TTree;
begin
    assign(f, PATH_TREE + speciesName + FILE_EXT);
    reset(f);
    read(f, tree);
    close(f);
    loadTree := tree;
end;

function getAvailableSpecies(): TStringArray;
var
    f: File of TStringArray;
    tab: TStringArray;
begin
    assign(f, PATH_TREE + 'species' + FILE_EXT);
    reset(f);
    read(f, tab);
    close(f);
    getAvailableSpecies := tab;
end;

function getNbAvailableSpecies(): LongInt;
begin
    { I leave this function blank to verify what I wanted to do here after. No need to touch. }
    getNbAvailableSpecies := 0;
end;

end.
