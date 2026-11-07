{ 
Cette unité gère la lecture et l'écriture des fichiers de sauvegarde des utilisateurs et des arbres.
}
unit FileManager;

interface

uses UserData, TreeData, SysUtils;

const
    PATH_DATA = 'data/'; //< Chemin vers le dossier contenant les données.
    PATH_USER = 'data/users/'; //< Chemin vers le dossier contenant les fichiers de sauvegarde des utilisateurs.
    PATH_TREE = 'data/trees/'; //< Chemin vers le dossier contenant les fichiers de sauvegarde des arbres.
    FILE_EXT_USER = '.user'; //< Extension des fichiers de sauvegarde des utilisateurs.
    FILE_EXT_TREE = '.dat'; //< Extension des fichiers de sauvegarde des arbres.
    
{   
    @abstract(Vérifie si un utilisateur existe)
    Elle cherche un fichier nommé @code(username.user) dans le dossier @code(PATH_USER).
    @param(username Le nom d'utilisateur à vérifier.)
    @returns(Un booléen indiquant si l'utilisateur existe.)
}
function userExists(username: string): Boolean;

{   
    @abstract(Enregistre un utilisateur dans un fichier.
    Créé/actualise @code(username.user) et remplace l'ancienne sauvegarde. Le pseudo doit être un nom de fichier valide, sans chemin.)
}
procedure saveUser(user: TUser);

{   
    @abstract(Charge un utilisateur depuis son fichier)
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
    @abstract(Charge une espèce d'arbre depuis son fichier)
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
    @returns(Un entier représentant le nombre d'espèces présentes dans la liste.)

}
function getNbAvailableSpecies(availableSpecies: TStringArray): LongInt;

implementation

function userExists(username: string): Boolean;
begin
    userExists := FileExists(PATH_USER + username + FILE_EXT_USER);
end;

procedure saveUser(user: TUser);
var
    f: File of TUser;
begin
    assign(f, PATH_USER + getUsername(user) + FILE_EXT_USER);
    rewrite(f);
    write(f, user);
    close(f);
end;

function loadUser(username: String): TUser;
var
    f: File of TUser;
    user: TUser;
begin
    user := initialiseUser();

    if userExists(username) then
    begin
        assign(f, PATH_USER + username + FILE_EXT_USER);
        reset(f);
        read(f, user);
        close(f);
    end;
    
    loadUser := user;
end;

function treeExists(speciesName: string): Boolean;
begin
    treeExists := FileExists(PATH_TREE + speciesName + FILE_EXT_TREE);
end;

function loadTree(speciesName: string): TTree;
var
    f: File of TTree;
    tree: TTree;
begin

    if treeExists(speciesName) then
    begin
        assign(f, PATH_TREE + speciesName + FILE_EXT_TREE);
        reset(f);
        read(f, tree);
        close(f);
    end
    else
    begin
        tree := initialiseTree();
    end;
    loadTree := tree;
end;

function getAvailableSpecies(): TStringArray;
var
    f: Text;
    line: String;
    tab: TStringArray;
begin
    assign(f, PATH_DATA + 'species.txt');
    reset(f);
    setlength(tab, 0);
    while not eof(f) do
    begin
        readln(f, line);
        setlength(tab, length(tab) + 1);
        tab[length(tab) - 1] := line;
    end;
    close(f);
    getAvailableSpecies := tab;
end;

function getNbAvailableSpecies(availableSpecies: TStringArray): LongInt;
begin
    getNbAvailableSpecies := length(availableSpecies);
end;

end.
