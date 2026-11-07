{
Cette unité stocke et manipule les informations de l'utilisateur telles que la date d'inscription, l'identité et les statistiques, ainsi que la forêt d'arbres cultivés grâce aux sessions terminées.
}
unit UserData;

interface
    uses SysUtils;

    { Nombre maximum d'espèces d'arbres différentes qu'une forêt peut contenir. }
    const MAX_SPECIES = 100;

   { Une date calendaire (jour/mois/année).
    Utilisée pour la date d'inscription de l'utilisateur. }      
    type TDate = Record
        day, month, year : LongInt;
    end;
    
    { La forêt de l'utilisateur : pour chaque espèce d'arbre, le nombre d'arbres cultivés et son nom.
    nbTreesGrown[i] et speciesName[i] décrivent la même espèce.
    Seuls les indices 1..nbSpecies sont significatifs, le reste vaut '' et 0. }
    type TForest = Record
            speciesName : Array[1..MAX_SPECIES] of string;
            nbTreesGrown : Array[1..MAX_SPECIES] of LongInt;
            nbSpecies : LongInt;
        end;
    
   {le profil de l'utilisateur avec sa forêt et ses statistiques}
    type TUser = Record
        name, username, description : string;
        joinDate : TDate;
        nbSessionsDone, nbCyclesDone, totalFocusTime : LongInt;
        forest : TForest;
        end;


    {--- DATE ---}

    { Construit une date à partir de ses trois parties.
    @returns le TDate correspondant. }
    function initialiseDate(day, month, year: LongInt): TDate;
    
    { @returns Le jour du mois de la date. }
    function getDay(date: TDate): LongInt;

    { @returns Le mois de la date. }
    function getMonth(date: TDate): LongInt;

    { @returns L'année de la date. }
    function getYear(date: TDate): LongInt;


    {----FORÊT---}

    { Crée une forêt vide : aucune espèce, tous les noms '' et tous les compteurs à 0.
        @returns Une nouvelle forêt vide. }
    function initialiseForest(): TForest;

    { Donne le nombre d'arbres cultivés pour une espèce.
        @param forest  La forêt à lire.
        @param n       Position de l'espèce (1..nbSpecies).
        @returns Le nombre d'arbres de l'espèce n, ou 0 si n est hors limites.}
    function getNbTreesGrown(forest: TForest; n: LongInt): LongInt;

    { @returns Le nombre d'espèces différentes dans la forêt. }
    function getNbSpecies(forest: TForest): LongInt;
    
    {  Recherche une espèce par son nom (sensible à la casse, correspondance exacte).
        @param forest  La forêt dans laquelle chercher.
        @param tree    Nom de l'espèce recherchée.
        @returns La position (1..nbSpecies) de l'espèce, ou 0 si elle n'est pas dans la forêt. }
    function findSpecies(forest: TForest; tree: string): LongInt;

    { Donne le nom de l'espèce à une position donnée.
        @param forest  La forêt à lire.
        @param n       Position de l'espèce (1..nbSpecies).
        @returns Le nom de l'espèce, ou une espace simple ' ' si n est hors limites. }
    function getForestSpeciesName(forest: TForest; n: LongInt): string;

    {--UTILISATEUR--}

    { Crée un nouvel utilisateur vierge.
        Le nom, le nom d'utilisateur et la description sont vides, tous les compteurs valent 0,
        la forêt est vide, et joinDate est fixée à la date système du jour.
        @returns Un nouvel utilisateur. }
    function initialiseUser(): TUser;

    { @returns Le nom affiché de l'utilisateur. }
    function getName(user: TUser): string;

    { Définit le nom affiché de l'utilisateur.
        @param user  L'utilisateur à modifier.
        @param name  Le nouveau nom. }
    procedure setName(var user: TUser; name: string);

    { Définit le nom d'utilisateur. Aucune vérification d'unicité ni de format n'est faite ici.
        @param user      L'utilisateur à modifier.
        @param username  Le nouveau nom d'utilisateur. }
    procedure setUsername(var user: TUser; username: string);

    { @returns Le nom d'utilisateur (identifiant de connexion) de l'utilisateur. }
    function getUsername(user: TUser): string;

    { Définit la description.
        @param user         L'utilisateur à modifier.
        @param description  La nouvelle description. }
    procedure setUserDescription(var user: TUser; description: string);

    { @returns La description (biographie) de l'utilisateur. }
    function getUserDescription(user: TUser): string;

    { Définit le nombre de sessions terminées.
        @param user  L'utilisateur à modifier.
        @param nb    Le nouveau total (devrait être >= 0, non vérifié). }
    procedure setNbSessionsDone(var user: TUser; nb: LongInt);

    { @returns Le nombre total de sessions de concentration terminées par l'utilisateur. }
    function getNbSessionsDone(user: TUser): LongInt;

    { Définit le nombre de cycles terminés.
        @param user  L'utilisateur à modifier.
        @param nb    Le nouveau total (devrait être >= 0, non vérifié). }
    procedure setNbCyclesDone(var user: TUser; nb: LongInt);

    { @returns Le nombre total de cycles terminés par l'utilisateur. }
    function getNbCyclesDone(user: TUser): LongInt;

    { Définit le temps de concentration total.
        @param user  L'utilisateur à modifier.
        @param nb    Le nouveau total, dans la même unité que les durées des cycles (devrait être >= 0, non vérifié). }
    procedure setTotalFocusTime(var user: TUser; nb: LongInt);

    { @returns Le temps de concentration total, dans l'unité utilisée pour les durées des cycles. }
    function getTotalFocusTime(user: TUser): LongInt;

    { @returns Une copie de la forêt de l'utilisateur. Modifier la copie ne change pas l'utilisateur ; utiliser addTree pour cultiver des arbres. }
    function getForest(user: TUser): TForest;

    { @returns La date de création du compte.}
    function getJoinDate(user: TUser): TDate;

    {Ajoute un arbre cultivé de l'espèce donnée à la forêt de l'utilisateur.
        Si l'espèce est nouvelle, elle est d'abord ajoutée à la fin de la liste.
        Si l'espèce est nouvelle et que la forêt contient déjà MAX_SPECIES espèces, il ne se passe rien.
        @param user  L'utilisateur à modifier.
        @param tree  Nom de l'espèce (sensible à la casse). }
    procedure addTree(var user: TUser; tree: string);

implementation

    {--DATE--}

    function initialiseDate(day, month, year: LongInt): TDate;
    var 
        date: TDate;
    begin
        date.day := day;
        date.month := month;
        date.year := year;

        initialiseDate := date;
    end;
 
    function getDay(date: TDate): LongInt;
    begin
        getDay := date.day;
    end;
 
    function getMonth(date: TDate): LongInt;
    begin
        getMonth := date.month;
    end;
 
    function getYear(date: TDate): LongInt;
    begin
        getYear := date.year;
    end;


    {--FORÊT-- }

    function initialiseForest(): TForest;
    var
        forest : TForest;
        i : LongInt;
    begin
        forest.nbSpecies := 0;
        for i := 1 to MAX_SPECIES do
        begin
            forest.speciesName[i] := '';
            forest.nbTreesGrown[i] := 0;
        end;
        initialiseForest:= forest;
    end;

    function getNbTreesGrown(forest: TForest; n: LongInt): LongInt;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getNbTreesGrown := forest.nbTreesGrown[n]
        else
            getNbTreesGrown := 0;
    end;

    function getNbSpecies(forest: TForest): LongInt;
    begin
        getNbSpecies := forest.nbSpecies;
    end;

     {on parcourt de i = 1 à nbSpecies pour voir si l'arbre existe. S'il est trouvé, on renvoie sa position. S'il n'existe pas, on renvoie 0}
    function findSpecies(forest: TForest; tree: string): LongInt;
    var 
        i : LongInt;
        found : Boolean;
    begin
        i := 1;
        found := False;
        while (i <= forest.nbSpecies) and (not found) do
        begin
            if forest.speciesName[i] = tree then
                found := True
            else 
                i := i + 1;
        end;

        if found then
            findSpecies := i 
        else
            findSpecies := 0;
    end;
    
    function getForestSpeciesName(forest: TForest; n: LongInt): string;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getForestSpeciesName := forest.speciesName[n]
        else
            getForestSpeciesName := ' ';
    end;

    {--UTILISATEUR--}

    function initialiseUser(): TUser;
    var
        user : TUser;
        dd, mm, yy : Word;
    begin
        DecodeDate(date, yy, mm, dd);

        user.name := '';
        user.username := '';
        user.description := '';
        user.joinDate := initialiseDate(dd, mm, yy);
        user.nbSessionsDone := 0;
        user.nbCyclesDone := 0;
        user.totalFocusTime := 0;
        user.forest := initialiseForest();
        
        initialiseUser := user;
    end;

    function getName(user: TUser): string;
    begin
        getName := user.name;
    end;
 
    procedure setName(var user: TUser; name: string);
    begin
        user.name := name;
    end;
 
    function getUsername(user: TUser): string;
    begin
        getUsername := user.username;
    end;
 
    procedure setUsername(var user: TUser; username: string);
    begin
        user.username := username;
    end;
 
    function getUserDescription(user: TUser): string;
    begin
        getUserDescription := user.description;
    end;
 
    procedure setUserDescription(var user: TUser; description: string);
    begin
        user.description := description;
    end;
 
    function getNbSessionsDone(user: TUser): LongInt;
    begin
        getNbSessionsDone := user.nbSessionsDone;
    end;
 
    procedure setNbSessionsDone(var user: TUser; nb: LongInt);
    begin
        user.nbSessionsDone := nb;
    end;
 
    function getNbCyclesDone(user: TUser): LongInt;
    begin
        getNbCyclesDone := user.nbCyclesDone;
    end;
 
    procedure setNbCyclesDone(var user: TUser; nb: LongInt);
    begin
        user.nbCyclesDone := nb;
    end;
 
    function getTotalFocusTime(user: TUser): LongInt;
    begin
        getTotalFocusTime := user.totalFocusTime;
    end;
 
    procedure setTotalFocusTime(var user: TUser; nb: LongInt);
    begin
        user.totalFocusTime := nb;
    end;
 
    function getJoinDate(user: TUser): TDate;
    begin
        getJoinDate := user.joinDate;
    end;
 
    function getForest(user: TUser): TForest;
    begin
        getForest := user.forest;
    end;
 
    procedure addTree(var user: TUser; tree: string);
    var
        n : LongInt;
    begin
        n := findSpecies(user.forest, tree);
 
        {si c'est une nouvelle espèce, elle est créée à la fin de la liste (on vérifie qu'il reste de la place)}
        if n = 0 then
        begin
            if user.forest.nbSpecies < MAX_SPECIES then
            begin
                user.forest.nbSpecies := user.forest.nbSpecies + 1;
                n := user.forest.nbSpecies;
                user.forest.speciesName[n] := tree;
                user.forest.nbTreesGrown[n] := 0;
            end;
        end;
 
        
        if (n <> 0) then
            user.forest.nbTreesGrown[n] := user.forest.nbTreesGrown[n] + 1;
    end;
    
end.