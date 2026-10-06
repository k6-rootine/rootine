{ 
Cette unité gère la lecture et l'écriture des fichiers de sauvegarde des utilisateurs et des arbres.
}
unit FileManager;

interface

uses UserData, TreeData, SysUtils;

const
    MAX_SPECIES = 100; //< Nombre maximum théorique d'espèces d'arbres.
    PATH_DATA = 'data/'; //< Chemin vers le dossier contenant les données.
    PATH_USER = 'data/users/'; //< Chemin vers le dossier contenant les fichiers de sauvegarde des utilisateurs.
    PATH_TREE = 'data/trees/'; //< Chemin vers le dossier contenant les fichiers de sauvegarde des arbres.
    FILE_EXT = '.dat'; //< Extension des fichiers de sauvegarde.

type
{ Tableau contenant les noms des espèces d'arbres disponibles, au maximum @code(MAX_SPECIES). }
    TStringArray = array[1..MAX_SPECIES] of string;


{   
    @abstract(Vérifie si un utilisateur existe)
    Elle cherche un fichier nommé @code(username.dat) dans le dossier @code(PATH_USER).
    @param(username Le nom d'utilisateur à vérifier.)
    @returns(Un booléen indiquant si l'utilisateur existe.)
}

function userExists(username: string): Boolean;

{   
    @abstract(Enregistre un utilisateur dans un fichier.
    Créé/actualise @code(username.dat) et remplace l'ancienne sauvegarde. Le pseudo doit être un nom de fichier valide, sans chemin.)
}
procedure saveUser(user: TUser);

{   
    @abstract(Charge un utilisateur depuis son fichier
    Le pseudo doit être un nom de fichier valide, sans chemin. Retourne un @code(TUser) vide si l'utilisateur n'existe pas.
    @param(username Le nom d'utilisateur à charger.)
    @returns(Un @code(TUser) actualisé.)
}
function loadUser(username: string): TUser;


{   
    @abstract(Vérifie si une espèce d'arbre existe)
    Elle cherche un fichier nommé @code(speciesName.dat) dans le dossier @code(PATH_TREE).
    @param(speciesName Le nom de l'espèce à vérifier.)
    @returns(Un booléen indiquant si l'espèce existe.)
}
function treeExists(speciesName: string): Boolean;

{   
    @abstract(Charge une espèce d'arbre depuis son fichier
    Le nom de l'espèce doit être un nom de fichier valide, sans chemin. Retourne un @code(TTree) vide si l'espèce n'existe pas.
    @param(speciesName Le nom de l'espèce à charger.)
    @returns(Un @code(TTree) actualisé.)
}

function loadTree(speciesName: string): TTree;

{ 
    @abstract(Récupère la liste des espèces d'arbres disponibles)
    Lis le fichier @code(species.dat) contenant la liste des espèces d'arbres disponibles et retourne un tableau de type @code(TStringArray). 
    @returns(Un @code(TStringArray) contenant les noms des espèces d'arbres disponibles, au maximum @code(MAX_SPECIES).)
}
function getAvailableSpecies(): TStringArray;

{ 

    @abstract(Compte les espèces présentes dans la liste)
    Compte les espèces presentes dans la liste, au maximum @code(MAX_SPECIES).    
    @returns(Un entier représentant le nombre d'espèces présentes dans la liste.)

}
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
