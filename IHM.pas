{
Cette unité gère toute l'interface avec l'utilisateur : l'affichage des écrans dans le terminal et la lecture au clavier. @br
Les procédures sont regroupées par préfixe : @br
    + display : dessine un écran complet puis (généralement) attend la réponse de l'utilisateur @br
    + render : redessine uniquement une zone de l'écran de session, sans attendre @br
    + poll : lit le clavier sans attendre @br
Tous les écrans sont dessinés dans une fenêtre du terminal de 121 x 35, entourée d'un cadre. Le texte est blanc par défaut. @br
}
unit IHM;

interface
uses 
    UserData, TreeData, CycleData, FileManager, crt, SysUtils, Utilities;

type
    { Le choix de l'utilisateur dans le menu de démarrage. }
    TStartChoice = (
        { Importer un profil existant. }
        IMPORT, 
        { Créer un nouveau profil. }
        REGISTER, 
        { Quitter le programme. }
        QUIT_START, 
        { Aucun choix. }
        NONE_START);

    { Le choix de l'utilisateur dans le menu principal. }    
    TMainMenuChoice = (
        { Voir le profil et les statistiques. }
        VIEW_PROFILE, 
        { Voir la forêt. }
        VIEW_FOREST, 
        { Se déconnecter et revenir au menu de démarrage. }
        LOGOUT, 
        { Démarrer une session de travail. }
        START, 
        { Quitter le programme. }
        QUIT_MAINMENU, 
        { Aucun choix. }
        NONE_MAINMENU);

    { Le choix de l'utilisateur après avoir sélectionné une espèce d'arbre }    
    TTreeChoice = (
        { Utiliser cet arbre. }
        CONFIRM_TREE, 
        { Voir un aperçu de l'arbre entièrement poussé. }
        PREVIEW_TREE, 
        { Revenir à la liste des espèces ou revenir à l'écran de session quand le temps de la pause est écoulé. }
        CANCEL_TREE, 
        { Aucun choix. }
        NONE_TREECHOICE);

    { Une action de l'utilisateur sur l'écran de session }
    TSessionAction = (
        { Mettre en pause ou reprendre le minuteur. }
        TOGGLE_PAUSE, 
        { Quitter la session. }
        QUIT_SESSION, 
        { Changer d'arbre (uniquement pendant une pause). }
        CHANGE_TREE, 
        { Passer à la session suivante (uniquement pendant une pause). }
        SKIP_PHASE, 
        { Aucune action. }
        NONE_SESSIONACTION);

    { La réponse de l'utilisateur à la confirmation pour quitter la session. }    
    TQuitAnswer = (
        { Quitter. L'arbre en cours meurt. }
        QUIT_YES, 
        { Continuer la session. }
        QUIT_NO, 
        { Pas encore de réponse. }
        QUIT_PENDING);

{ 
    @abstract(Affiche le menu de démarrage)
    @param choice Le choix de l'utilisateur
}
procedure displayStartMenu(var choice: TStartChoice);

{
    @abstract(Affiche le menu principal)
    @param choice Le choix de l'utilisateur
    @param user L'utilisateur connecté
}
procedure displayMainMenu(var choice: TMainMenuChoice; user: TUser);

{
    @abstract(Demande le nom d'utilisateur pour importer le profil)
    Le nom saisi est converti automatiquement en minuscules. 
    Si l'utilisateur n'existe pas, un message d'erreur s'affiche et le nom est redemandé, 
        jusqu'à ce qu'il existe ou qu'une entrée vide soit validée.
    @param username Le nom d'utilisateur d'un compte existant, ou une chaîne vide si l'utilisateur a annulé
}
procedure displayLogin(var username: String);

{
    @abstract(Demande les informations d'un nouveau compte)
    Il y a des conditions imposées sur les informations. 
    Si l'utilisateur ne les suit pas, des messages d'erreurs s'affichent et l'information est redemandée, jusqu'à ce que les entrées soient validées.
    Le nom d'utilisateur est converti automatiquement en minuscules. 
    @param firstname Le prénom saisi, peut être vide
    @param username Le nom d'utilisateur saisi. Si vide, l'inscription est annulée
    @param description La description saisie, peut être vide
}
procedure displayRegister(var firstname, username, description: String);

{
    @abstract(Affiche le profil et les statistiques de l'utilisateur)
    @param user L'utilisateur dont on affiche le profil
}
procedure displayProfile(user: TUser);

{
    @abstract(Affiche la forêt de l'utilisateur)
    @param forst La forêt de l'utilisateur
    @param idx Le numéro de l'espèce choisie dans la forêt
}
procedure displayForestOverview(forest: TForest; var idx: LongInt);

{
    @abstract(Affiche un arbre entièrement poussé avec son nom et sa description)
    @param tree L'arbre à afficher
    @param deadline La fin de la pause, en ms, ou 0 s'il n'y a pas de limite de temps
    @param timedOut Vrai si l'attente s'est arrêtée parce que le temps est écoulé. Faux si une touche a été pressée.
}
procedure displayTreeFull(tree: TTree; deadline: Int64; var timedOut: Boolean);

{
    @abstract(Affiche le choix du mode de cycle)
    @param mode Le mode choisi, ou NONE_MODE si l'utilisateur revient en arrière
}
procedure displayCycleModeMenu(var mode: TMode);


{
    @abstract(Demande les paramètres d'un cycle personnalisé puis les fait confirmer)
    @param focusDuration La durée d'une session de concentration, en minutes
    @param shortBreakDuration La durée d'une pause courte, en minutes
    @param longBreakDuration La durée d'une pause longue, en minutes
    @param nbSessionsBeforeLongBreak Le nombre de sessions de concentration avant une pause longue
    @param confirmed Vrai si l'utilisateur a confirmé. Faux s'il a annulé et les valeurs renvoyées ne doivent alors pas être utilisées
}
procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);

{
    @abstract(Affiche les paramètres du mode Pomodoro et demande de les confirmer)
    @param focusDuration La durée d'une session de concentration, en minutes
    @param shortBreakDuration La durée d'une pause courte, en minutes
    @param longBreakDuration La durée d'une pause longue, en minutes
    @param nbSessionsBeforeLongBreak Le nombre de sessions de concentration avant une pause longue
    @param confirmed Vrai si l'utilisateur a confirmé. Faux s'il a annulé
}
procedure displayPomodoroConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);

{
    @abstract(Affiche la liste des espèces disponibles et demande laquelle faire pousser)
    @param species La liste des noms d'espèces disponibles
    @param choice Le numéro de l'espèce choisie dans la liste, ou 0 si l'utilisateur revient en arrière ou si le temps est écoulé
    @param deadline La fin de la pause, en ms, ou 0 s'il n'y a pas de limite de temps
    @param timedOut Vrai si la saisie s'est arrêtée parce que le temps est écoulé.
}
procedure displayTreeList(species: TStringArray; var choice: LongInt; deadline: Int64; var timedOut: Boolean);

{
    @abstract(Affiche le choix à faire après avoir sélectionné une espèce)
    @param speciesName Le nom de l'espèce choisie, affiché dans le titre
    @param action Le choix de l'utilisateur
    @param deadline La fin de la pause, en ms, ou 0 s'il n'y a pas de limite de temps
    @param timedOut Vrai si le temps est écoulé avant qu'une touche valide soit pressée
}
procedure displayTreeChoice(speciesName: String; var action: TTreeChoice; deadline: Int64; var timedOut: Boolean);

{
    @abstract(Dessine l'arbre dans sa zone dédiée)
    L'arbre est dessiné caractère par caractère, chacun avec sa couleur. La couleur par défaut est rétablie ensuite.
    @param tree L'arbre à dessiner
    @param treePhase Le numéro de la phase de croissance à dessiner
}
procedure renderTreeArea(tree: TTree; treePhase: LongInt);

{
    @abstract(Dessine l'horloge dans sa zone dédiée)
    Le temps est affiché en grands chiffres sous la forme mm:ss. Seule la zone de l'horloge est modifiée.
    @param time Le temps à afficher, en secondes
}
procedure renderClockArea(time: LongInt);

{
    @abstract(Dessine la liste des touches disponibles dans sa zone dédiée)
    @param sessionPhase La phase de la session en cours
}
procedure renderInstructionsArea(sessionPhase: TPhaseSession);

{
    @abstract(Lit une action de l'utilisateur sur l'écran de session, sans attendre)
    @param sessionPhase La phase de la session en cours
    @param action L'action demandée
}
procedure pollSessionInput(sessionPhase: TPhaseSession; var action: TSessionAction);

{
    @abstract(Affiche le résumé à la fin d'un cycle et attend une touche)
    @param cycle Le cycle qui vient de se terminer
}
procedure displayCycleEnd(cycle: TCycle);

{
    @abstract(Affiche la confirmation pour quitter la session pendant une session de concentration)
}
procedure displayQuitConfirmation();

{
    @abstract(Lit la réponse à la confirmation pour quitter la session, sans attendre)
    @param answer La réponse
}
procedure pollQuitConfirmation(var answer: TQuitAnswer);

{
    @abstract(Dessine le cadre autour de tour l'écran)
}
procedure renderOuterBorder();

{
    @abstract(Dessine les lignes de séparation de l'écran des session)
}
procedure renderInnerBorder();

{
    @abstract(Prépare un nouvel écran : éfface tout, puis dessine le logo, le cadre, et un titre)
    @param heading Le titre à afficher
}
procedure renderScreenHeader(heading: String);

{
    @abstract(Prépare le terminal au démarrage du programme)
}
procedure initialiseScreen();

{
    @abstract(Affiche les informations de la session dans sa zone dédiée)
    @param phase La phase de la session en cours
    @param session Le numéro de la session de concentration en cours
    @param speciesName Le nom de l'espèce de l'arbre
    @param isPaused Vrai si le minuteur est en pause. Faux sinon
}
procedure renderStatsArea(phase: TPhaseSession; session: LongInt; speciesName: String; isPaused: Boolean);



const
    BORDER_CHAR = '*'; { Caractère avec lequel le cadre est tracé }
    BORDER_WIDTH = 121; { Nombre de colonnes de l'écran, cadre compris }
    BORDER_HEIGHT = 35; { Nombre de lignes de l'écran, cadre compris }
    BORDER_TREE_VERTICAL = 80; { Colonne de la ligne qui sépare l'arbre (à gauche) du panneau à droite }
    BORDER_CLOCK_HORIZONTAL = 13; { Ligne qui sépare l'horloge des informations de la session }
    BORDER_STATS_HORIZONTAL = 20; { Ligne qui sépare les informations de la session des instructions }
    LOGO_X = 30; { Colonne du coin supérieur gauche du logo }
    LOGO_Y = 5; { Ligne du coin supérieur gauche du logo }
    HEADING_ROW = 16; { Ligne du titre centré, sous le logo }
    CONTENT_ROW = 18; { Première ligne du contenu d'un écran, sous le titre }
    MENU_X = 40; { Colonne de gauche des menus et des choix }
    LIST_X = 30; { Colonne de gauche des listes, de la connexion et du profil }
    FORM_X = 15; { Colonne de gauche du formulaire d'inscription }
    DEFAULT_COLOR = crt.White; { Couleur défaut du programme }

implementation

const
    RESET_MARGIN = 5; { Window() resetting margin }

procedure enterArea(x1, y1, x2, y2: LongInt);
begin
    { restricts the output to a rectangular area of the console (corners/borders are included) }
    Window(x1, y1, x2, y2);
    GoToXY(1, 1);
end;

procedure leaveArea();
begin
    { resets the output to the whole console }
    Window(1, 1, BORDER_WIDTH + RESET_MARGIN, BORDER_HEIGHT + RESET_MARGIN);
end;

function phaseLabel(phase: TPhaseSession): String;
begin
    { returns the French label of a session phase }
    if phase = FOCUS then
        phaseLabel := 'Concentration'
    else if phase = SHORT_BREAK then
        phaseLabel := 'Pause courte'
    else if phase = LONG_BREAK then
        phaseLabel := 'Pause longue'
    else
        phaseLabel := '';
end;

procedure renderOuterBorder();
var 
    width, height : LongInt;
begin 
    GoToXY(1, 1);
    for height := 1 to BORDER_HEIGHT do
    begin
        if (height = 1) or (height = BORDER_HEIGHT) then
        begin 
            for width := 1 to BORDER_WIDTH do
                write(BORDER_CHAR);
        end
        else 
        begin 
            GoToXY(1, height);
            write(BORDER_CHAR);
            GoToXY(BORDER_WIDTH, height);
            write(BORDER_CHAR);

            if (height = BORDER_HEIGHT - 1) then
                writeln;
        end;
    end;
end;

procedure renderVerticalSeparator();
var
    vertical : LongInt;
begin
    { draws the vertical line between the tree (left) and the right-hand panel }
    for vertical := 2 to BORDER_HEIGHT - 1 do
    begin
        GoToXY(BORDER_TREE_VERTICAL, vertical);
        write(BORDER_CHAR);
    end;
end;

procedure renderHorizontalSeparator(y: LongInt);
var
    horizontal : LongInt;
begin
    { draws a horizontal line across the right-hand panel at the specified y-coordinate }
    for horizontal := BORDER_TREE_VERTICAL + 1 to BORDER_WIDTH - 1 do
    begin
        GoToXY(horizontal, y);
        write(BORDER_CHAR);
    end;
end;

procedure renderInnerBorder();
begin
    { display the separation line between the tree and the clock/stats/instructions areas }
    renderVerticalSeparator();
    { display the separation line between the clock and the stats areas }
    renderHorizontalSeparator(BORDER_CLOCK_HORIZONTAL);
    { display the separation line between the stats and instructions areas }
    renderHorizontalSeparator(BORDER_STATS_HORIZONTAL);
end;

procedure renderScreenHeader(heading: String);
begin
    clrscr;
    RootineLogo(LOGO_X, LOGO_Y);
    renderOuterBorder();
    GoToXY((BORDER_WIDTH - length(heading)) div 2, HEADING_ROW);
    write(heading);
end;

procedure initialiseScreen();
begin
    TextColor(DEFAULT_COLOR);
    clrscr;
end;

procedure displayStartMenu(var choice: TStartChoice);
var 
    key: Char;
begin 
    { menu }
    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);

    writeln('Bienvenue ! Veuillez choisir une option :');
    writeln;
    writeln('[1]   Importer un compte existant');
    writeln;
    writeln('[2]   Creer un nouveau compte');
    writeln;
    writeln('[0]   Quitter');

    leaveArea();

    { user's input }
    choice := NONE_START;
    repeat
        key := readkey;

        if (key = '1') then
            choice := IMPORT
        else if (key = '2') then
            choice := REGISTER
        else if (key = '0') then
            choice := QUIT_START;
    until choice in [IMPORT, REGISTER, QUIT_START];
end;

procedure displayMainMenu(var choice: TMainMenuChoice; user: TUser);
var 
    welcomeMessage: String;
    key: Char;
begin 
    { center the welcome message horizontally }
    if getName(user) = '' then
        welcomeMessage := 'Salut, ' + getUsername(user) + ' ! Pret a commencer une session de travail ?'
    else
        welcomeMessage := 'Salut, ' + getName(user) + ' ! Pret a commencer une session de travail ?';
    GoToXY((BORDER_WIDTH - length(welcomeMessage)) div 2, HEADING_ROW);
    writeln(welcomeMessage);
    writeln;

    { menu }
    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);

    writeln('Veuillez choisir une option :');
    writeln;
    writeln('[1]   Demarrer une session de travail');
    writeln;
    writeln('[2]   Voir mon profil');
    writeln;
    writeln('[3]   Voir ma foret');
    writeln;
    writeln('[4]   Se deconnecter');
    writeln;
    writeln('[0]   Quitter');

    leaveArea();

    { user's input }
    choice := NONE_MAINMENU;
    repeat
        key := readkey;

        if (key = '1') then
            choice := START
        else if (key = '2') then
            choice := VIEW_PROFILE
        else if (key = '3') then
            choice := VIEW_FOREST
        else if (key = '4') then
            choice := LOGOUT
        else if (key = '0') then
            choice := QUIT_MAINMENU;
    until choice in [VIEW_PROFILE, VIEW_FOREST, LOGOUT, START, QUIT_MAINMENU];
end;

procedure displayLogin(var username: String);
begin 
    enterArea(LIST_X, CONTENT_ROW, LIST_X + 50, BORDER_HEIGHT - 2);

    { enter username. if doesn't exist, ask again. }
    repeat
        GoToXY(1, 1);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        username := lowercase(username);

        if not userExists(username) and (username <> '') then
        begin
            GoToXY(1, 2);
            clreol;
            writeln('Utilisateur inexistant. Veuillez reessayer.');
        end;
    until userExists(username) or (username = '');

    leaveArea();
end;

procedure displayRegister(var firstname, username, description: String);
begin 
    { initialise variables }
    firstname := '';
    username := '';
    description := '';

    enterArea(FORM_X, CONTENT_ROW, FORM_X + 90, BORDER_HEIGHT - 2);

    { display instructions }
    writeln('Attention ! ');
    writeln('- Les espaces et les caracteres speciaux ne sont pas autorises dans le nom d''utilisateur.');
    writeln('- Le nom d''utilisateur doit etre unique et entre 1 et 30 caracteres.');
    writeln('- Les caracteres speciaux, sauf le tiret et l''apostrophe, ne sont pas autorises dans le prenom.');

    { enter username. if already exists or invalid, ask again. an empty username cancels. }
    repeat
        GoToXY(1, 7);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        username := lowercase(username);

        { remove the previous error message, then display the new one if needed }
        GoToXY(1, 8);
        clreol;
        if (username <> '') and userExists(username) then
            writeln('Nom d''utilisateur deja existant. Veuillez reessayer.')
        else if (username <> '') and not isValidUsername(username) then
            writeln('Nom d''utilisateur invalide. Veuillez reessayer.');
    until (username = '') or ((not userExists(username)) and isValidUsername(username));

    { firstname and desc are only asked if the registration was not cancelled }
    if username <> '' then
    begin
        { enter first name, if invalid, ask again }
        repeat
            GoToXY(1, 9);
            clreol;
            write('Veuillez entrer votre prenom : ');
            readln(firstname);

            { remove the previous error message, then display the new one if needed }
            GoToXY(1, 10);
            clreol;
            if not isValidName(firstname) then
                writeln('Prenom invalide. Veuillez reessayer.');
        until isValidName(firstname);

        GoToXY(1, 11);
        clreol;
        write('Veuillez entrer une description de votre profil : ');
        readln(description);
    end;

    leaveArea();
end;

procedure displayProfile(user: TUser);
var
    i, totalTrees: LongInt;
    joinDate: TDate;
    forest: TForest;
begin
    { variables }
    joinDate := getJoinDate(user);
    forest := getForest(user);

    { calculate the total number of trees grown }
    totalTrees := 0;
    for i := 1 to getNbSpecies(forest) do
        totalTrees := totalTrees + getNbTreesGrown(forest, i);

    enterArea(LIST_X, CONTENT_ROW, LIST_X + 60, BORDER_HEIGHT - 2);

    { display all information }
    writeln('Nom d''utilisateur : ', getUsername(user));
    writeln('Prenom : ', getName(user));
    writeln('Date de creation du compte : ', format('%.2d/%.2d/%4d', [getDay(joinDate), getMonth(joinDate), getYear(joinDate)]));
    writeWrapped('Description : ' + getUserDescription(user), 61);
    writeln('Nombre de cycles completes : ', getNbCyclesDone(user));
    writeln('Nombre de sessions completees : ', getNbSessionsDone(user));
    writeln('Temps total de concentration : ', format('%.2d:%.2d:%.2d', [getTotalFocusTime(user) div 3600, getTotalFocusTime(user) div 60 mod 60, getTotalFocusTime(user) mod 60]));
    writeln('Nombre d''especes differentes ayant pousse : ', getNbSpecies(forest));
    writeln('Nombre total d''arbres ayant pousse : ', totalTrees);
    writeln;
    writeln('Appuyez sur une touche pour revenir...');

    leaveArea();
end; 

procedure displayForestOverview(forest: TForest; var idx: LongInt);
const
    ROWS_PER_COLUMN = 7; { divides the list into multiple columns }
    COLUMN_WIDTH = 30;
var
    i, nbSpecies: LongInt;
    heading: String;
begin
    { get information about nbspecies }
    nbSpecies := getNbSpecies(forest);

    if nbSpecies = 0 then
        heading := 'Votre foret est vide pour le moment.'
    else
        heading := 'Votre foret : choisissez une espece a afficher :';

    renderScreenHeader(heading);

    if nbSpecies = 0 then
    begin
        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

        writeln('Terminez une session de concentration pour faire pousser votre premier arbre.');
        writeln;
        write('Appuyez sur une touche pour revenir...');

        leaveArea();
        readkey;
        idx := 0;
    end
    else
    begin
        { species are listed in columns of ROWS_PER_COLUMN entries, with their tree count }
        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

        for i := 1 to nbSpecies do
        begin
            GoToXY(1 + ((i - 1) div ROWS_PER_COLUMN) * COLUMN_WIDTH, 1 + ((i - 1) mod ROWS_PER_COLUMN)); { formula to calculate position to print items in this layout }
            write('[', i, ']   ', getForestSpeciesName(forest, i), ' (x', getNbTreesGrown(forest, i), ')');
        end;
        GoToXY(1, ROWS_PER_COLUMN + 2);
        write('[0]   Retour');
        GoToXY(1, ROWS_PER_COLUMN + 4);
        idx := readInteger('Votre choix : ', 0, nbSpecies);

        leaveArea();
    end;
end;

procedure displayTreeFull(tree: TTree; deadline: Int64; var timedOut: Boolean);
var
    key: Char;
begin
    { render borders }
    clrscr;
    renderOuterBorder();
    renderVerticalSeparator();

    { render the tree in final phase }
    renderTreeArea(tree, getNbPhases(tree));

    enterArea(BORDER_TREE_VERTICAL + 3, 3, BORDER_WIDTH - 4, BORDER_HEIGHT - 1);

    { info in the right }
    writeln(uppercase(getSpeciesName(tree)));
    writeln('Apercu de l''etat final');
    writeln;
    writeWrapped(getTreeDescription(tree), BORDER_WIDTH - 4 - (BORDER_TREE_VERTICAL + 3) + 1);
    writeln;
    writeln;
    writeln('Appuyez sur une touche pour revenir');
    timedOut := not waitKeyUntil(deadline, BORDER_HEIGHT - 6, key);

    leaveArea();
end;

procedure displayCycleModeMenu(var mode: TMode);
var
    key: Char;
    isReturn: Boolean;
    heading: String;
begin
    { initialise variables }
    isReturn := False;
    mode := NONE_MODE;
    heading := 'Veuillez choisir un mode de cycle :';

    renderScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);

    writeln('[1]   Mode Pomodoro');
    writeln;
    writeln('[2]   Mode Personnalise');
    writeln;
    writeln('[0]   Retour');

    leaveArea();

    repeat
        key := readkey;

        if (key = '1') then
            mode := POMODORO
        else if (key = '2') then
            mode := CUSTOM
        else if (key = '0') then
            isReturn := True;
    until (mode in [POMODORO, CUSTOM]) or isReturn;
end;

procedure printConfiguration(focus, shortBreak, longBreak, nbSessions: LongInt);
begin
    writeln('Duree de concentration : ', focus, ' minutes');
    writeln;
    writeln('Duree de pause courte : ', shortBreak, ' minutes');
    writeln;
    writeln('Duree de pause longue : ', longBreak, ' minutes');
    writeln;
    writeln('Sessions avant une pause longue : ', nbSessions);
end;

procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);
const
    MAX_MINUTES = 90;
    MAX_NB_SESSIONS = 99;
var
    key: Char;
    heading: String;
begin
    repeat
        { form: one field every two rows, the row below each field is used by readInteger for its error message }
        heading := 'Mode personnalise : entrez vos parametres';
        renderScreenHeader(heading);

        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

        GoToXY(1, 1);
        focusDuration := readInteger('Duree de concentration (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 3);
        shortBreakDuration := readInteger('Duree de pause courte (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 5);
        longBreakDuration := readInteger('Duree de pause longue (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 7);
        nbSessionsBeforeLongBreak := readInteger('Sessions avant une pause longue (1-' + inttostr(MAX_NB_SESSIONS) + ') : ', 1, MAX_NB_SESSIONS);

        leaveArea();

        { summary and choice }
        heading := 'Votre configuration :';
        renderScreenHeader(heading);

        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

        printConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
        writeln;
        writeln('[1]   Confirmer et demarrer');
        writeln;
        writeln('[2]   Modifier les parametres');
        writeln;
        writeln('[0]   Annuler');

        leaveArea();

        repeat
            key := readkey;
        until (key = '1') or (key = '2') or (key = '0');
    until key <> '2';

    confirmed := (key = '1');
end;

procedure displayPomodoroConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);
var
    key: Char;
    heading: String;
begin
    heading := 'Mode Pomodoro';
    renderScreenHeader(heading);

    enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

    printConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
    writeln;
    writeln('[1]   Confirmer et demarrer');
    writeln;
    writeln('[0]   Annuler');

    leaveArea();

    repeat
        key := readkey;
    until (key = '1') or (key = '0');

    confirmed := (key = '1');
end;

procedure displayTreeList(species: TStringArray; var choice: LongInt; deadline: Int64; var timedOut: Boolean);
const
    ROWS_PER_COLUMN = 7;
    COLUMN_WIDTH = 30;
var
    i, nbSpecies: LongInt;
    heading: String;
begin
    nbSpecies := getNbAvailableSpecies(species);
    heading := 'Selectionnez un arbre a faire pousser :';

    renderScreenHeader(heading);

    enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);

    for i := 0 to nbSpecies - 1 do
    begin
        GoToXY(1 + (i div ROWS_PER_COLUMN) * COLUMN_WIDTH, 1 + (i mod ROWS_PER_COLUMN));
        if (i < 9) then
            write('[', i + 1, ']   ', species[i])
        else
            write('[', i + 1, ']  ', species[i]);
    end;
    GoToXY(1, ROWS_PER_COLUMN + 2);
    write('[0]   Retour');
    GoToXY(1, ROWS_PER_COLUMN + 4);
    choice := readIntegerUntil('Votre choix : ', 0, nbSpecies, deadline, ROWS_PER_COLUMN + 7, timedOut);
    if timedOut then
        choice := 0;

    leaveArea();
end;

procedure displayTreeChoice(speciesName: String; var action: TTreeChoice; deadline: Int64; var timedOut: Boolean);
var
    key: Char;
    heading: String;
begin
    { initialise variables }
    heading := 'Vous avez choisi : ' + speciesName;
    action := NONE_TREECHOICE;
    timedOut := False;

    renderScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);

    writeln('[1]   Confirmer ce choix');
    writeln;
    writeln('[2]   Voir un apercu de l''arbre');
    writeln;
    writeln('[0]   Retour / Choisir un autre arbre');

    repeat
        if waitKeyUntil(deadline, 14, key) then
        begin
            if (key = '1') then
                action := CONFIRM_TREE
            else if (key = '2') then
                action := PREVIEW_TREE
            else if (key = '0') then
                action := CANCEL_TREE;
        end
        else
        begin
            timedOut := True;
            action := CANCEL_TREE;
        end;
    until action <> NONE_TREECHOICE;

    leaveArea();
end;

procedure renderTreeArea(tree: TTree; treePhase: LongInt);
var 
    vertical, horizontal: LongInt;
    phase: TPhase;
begin 
    phase := getPhase(tree, treePhase);

    for vertical := 2 to MAX_VERTICAL - 1 do
    begin
        for horizontal := 2 to MAX_HORIZONTAL - 1 do
        begin
            GoToXY(horizontal, vertical);
            TextColor(Byte(TColor(getColor(phase, horizontal, vertical))));
            write(getElement(phase, horizontal, vertical));
        end;
        writeln;
    end;

    TextColor(DEFAULT_COLOR);
    GoToXY(1, 1);
end;

procedure renderDigit(offsetX, digit: LongInt);
begin
    { draws one clock symbol (digit 0..9, or -1 for the colon) at a horizontal offset inside the clock area }
    enterArea(BORDER_TREE_VERTICAL + offsetX, 4, BORDER_WIDTH - 1, BORDER_CLOCK_HORIZONTAL);
    displayClockNumber(digit);
    leaveArea();
end;

procedure renderClockArea(time: LongInt);
var
    m1, m2, s1, s2: LongInt;
begin
    { calculate each component of the clock }
    m1 := (time div 60) div 10;
    m2 := (time div 60) mod 10;
    s1 := (time - (time div 60) * 60) div 10;
    s2 := (time - (time div 60) * 60) mod 10;

    renderDigit(4, m1);
    renderDigit(12, m2);
    renderDigit(19, -1); { colon }
    renderDigit(24, s1);
    renderDigit(32, s2);
end;

procedure renderInstructionsArea(sessionPhase: TPhaseSession);
begin 
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_STATS_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_HEIGHT - 1);
    clrscr;

    if sessionPhase = FOCUS then
    begin 
        writeln('[1] Pause/Resume');
        writeln;
        writeln('[0] Quitter la session');
    end
    else
    begin 
        writeln('[1] Pause/Resume');
        writeln;
        writeln('[2] Passer a la prochaine session');
        writeln;
        writeln('[3] Changer d''arbre');
        writeln;
        writeln('[0] Quitter la session');
    end;

    leaveArea();
end;

procedure renderStatsArea(phase: TPhaseSession; session: LongInt; speciesName: String; isPaused: Boolean);
begin
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_CLOCK_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_STATS_HORIZONTAL - 1);
    clrscr;

    writeln('Phase : ', phaseLabel(phase));
    writeln('Session : ', session);
    writeln('Arbre : ', speciesName);

    { write, not writeln: a newline on the last row would scroll the area }
    if isPaused then
        write('Etat : En pause')
    else
        write('Etat : En cours');

    leaveArea();
end;

procedure pollSessionInput(sessionPhase: TPhaseSession; var action: TSessionAction);
var
    key: Char;
begin
    action := NONE_SESSIONACTION;

    if keypressed then
    begin
        key := readkey;

        if key = KEY_SPECIAL then
            readkey { special keys send a second code that must be skipped }
        else if key = '1' then
            action := TOGGLE_PAUSE
        else if key = '0' then
            action := QUIT_SESSION
        else if (sessionPhase <> FOCUS) and (key = '2') then
            action := SKIP_PHASE
        else if (sessionPhase <> FOCUS) and (key = '3') then
            action := CHANGE_TREE;
    end;
end;

procedure displayCycleEnd(cycle: TCycle);
var
    heading, modeName: String;
    nbSessionsDone: LongInt;
begin
    { a cycle can only succeed from a break (the current session is complete) 
    and only be abandoned during a focus phase (the current session is unfinished) }

    if getState(cycle) = FINISHED then
    begin
        heading := 'Cycle termine, bravo !';
        nbSessionsDone := getCurrentSession(cycle);
    end
    else
    begin
        heading := 'Cycle abandonne : l''arbre en cours n''a pas survecu.';
        nbSessionsDone := getCurrentSession(cycle) - 1;
    end;

    if getMode(cycle) = POMODORO then
        modeName := 'Pomodoro'
    else
        modeName := 'Personnalise';

    renderScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);

    writeln('Mode : ', modeName);
    writeln;
    writeln('Sessions de concentration terminees : ', nbSessionsDone);
    writeln;
    write('Appuyez sur une touche pour continuer...');

    leaveArea();
    readkey;
end;

procedure displayQuitConfirmation();
begin
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_STATS_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_HEIGHT - 1);
    clrscr;

    writeln('Quitter la session ?');
    writeln;
    writeln('L''arbre en cours va mourir.');
    writeln;
    writeln('[1] Oui, quitter');
    writeln;
    writeln('[2] Non, continuer');

    leaveArea();
end;

procedure pollQuitConfirmation(var answer: TQuitAnswer);
var
    key: Char;
begin
    { reads the answer to the quit confirmation without waiting: QUIT_PENDING if no valid key was pressed }
    answer := QUIT_PENDING;

    if keypressed then
    begin
        key := readkey;

        if key = KEY_SPECIAL then
            readkey { special keys send a second code that must be skipped }
        else if key = '1' then
            answer := QUIT_YES
        else if key = '2' then
            answer := QUIT_NO;
    end;
end;

end.

