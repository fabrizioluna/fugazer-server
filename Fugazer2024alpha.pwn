/*

Fugazer Alpha
- Programador: axrr
- Mapper: Cuban_0222/BAD_BOY
- Fecha de creación: 17 de Mayo del 2017

*/

#include <a_samp>
#include <a_mysql>
#include <progress2>
#include <sscanf2>
#include <YSI\y_commands>
#include <YSI\y_ini>
#include <dini>
#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <streamer>
#include <OnPlayerPause>

#pragma tabsize 0

// SERVER CONFIGURATION
#define MAXPLAYERS 		50
#define MAX_CLANES 		50
#define MAX_STRING 		128
#define MAX_WAR_ZONES 	20

#define SERVER_FULL_NAME 	"Fugazer Freeroam Español Latino"
#define SERVER_FULL_LANG 	"Español"
#define SERVER_FULL_GAMEMODE "Fugazer 0.1alpha"

#define MySQL_SERVER 		"localhost"
#define MySQL_USER 			"root"
#define MySQL_DATABASE 		"fugazer_freeroam_database"
#define MySQL_PASSWORD 		""

#define function%0(%1) \
	forward%0(%1); public%0(%1) // Evita escribir public y forward para una función.

// MASCARAS DE BITS(BITMASKS)
#define ispLogged			0b00000000000000000000000000000001 
#define ispRegisted			0b00000000000000000000000000000010
#define ispAdmin			0b00000000000000000000000000000100
#define ispInClan			0b00000000000000000000000000001000 
#define ispClanLeader		0b00000000000000000000000000010000 
#define ispClanSubLeader	0b00000000000000000000000000100000 
#define ispClanRecluter		0b00000000000000000000000001000000 
#define ispJail				0b00000000000000000000000010000000 
#define ispDeathMatch		0b00000000000000000000000100000000

// COLORES GLOBALES
#define MARILLO 			0xFAFA44FF
#define Morado2 			0x9473FFFF
#define Celeste 			0x00FFFFFF
#define VerdeClaro 			0x00FF00FF
#define Blanco 				0xFFFFFFAA
#define Wadmin 				0x00FF4FFF
#define Rojo 				0xFF0000FF
#define Negro 				0x000000FE
#define Verde 				0x00E200FF
#define Azul 				0x0017FFFF
#define Caca 				0x9EFF00FF
#define Rosa 				0xFF00FFFF
#define CoVip 				0x00FFB3FF
#define Gris 				0x00000080
#define Morado 				0x9D1DFFFF
#define Azul2 				0x005FFFFF
#define Gris3 				0x919AB9FF
#define Caca3 				0xFF0000AA
#define Gris4 				0xC0C0C0AA
#define Ama23 				0xFFC100FF
#define VerdexD 			0x77FF30FF
#define VERDE 				0x95FF00FF
#define AzulClaro10 		0x00A8FFFF
#define Naranja    			0xFF8040FF
#define Amarillo    		0xFFFF00AA
#define Avisoo 				0xFFFFB1FF

// CARACTERES ESPECIALES PARA GAMEPLAYERTEXT O TEXTDRAWS
#define SPECIAL_KEY_INT "¯" //Este signo es de ¿
#define SPECIAL_KEY_EXC "^" //Este signo es de !
#define SPECIAL_KEY_Ñ "®"
#define SPECIAL_KEY_A "˜"
#define SPECIAL_KEY_E "ž"
#define SPECIAL_KEY_I "¢"
#define SPECIAL_KEY_O "¦"
#define SPECIAL_KEY_U "ª"

// REGISTER AND LOG IN
#define IDENTIFICATION_SIGN_UP 	1
#define IDENTIFICATION_SIGN_IN 	2

// CLANES
#define CLAN_CREATION_NAME 						3
#define CLAN_CREATION_TAG 						4
#define	CLAN_CREATION_INVITE 					5
#define CLAN_ADMINISTRATION_LEADER 				6
#define CLAN_ADMINISTRATION_RECLUTER 			7
#define CLAN_ADMINISTRATION_CHANGE_TEAMKILL		8
#define CLAN_ADMINISTRATION_CHANGE_SKIN			9
#define CLAN_ADMINISTRATION_CHANGE_COLOR		10
#define CLAN_ADMINISTRATION_CHANGE_RANKS		11
#define CLAN_ADMINISTRATION_CHANGE_KICK			12
#define CLAN_ADMINISTRATION_RANKS_R1			13
#define CLAN_ADMINISTRATION_RANKS_R2			14
#define CLAN_ADMINISTRATION_KICK_USER1			15
#define CLAN_ADMINISTRATION_KICK_USER2			16

#define CLAN_CC_LIST1							17
#define CLAN_CC_LIST2							18
#define CLAN_CC_LIST3							19
#define CLAN_CC_LIST4							20
#define CLAN_CC_LIST5							21
#define CLAN_CC_LIST6							22
#define CLAN_CC_LIST7							23
#define CLAN_CC_LIST8							24
#define CLAN_CC_LIST9							25
#define CLAN_CC_LIST10							26
#define CLAN_CC_LIST11							27
#define CLAN_CC_LIST12							28

// VARIABLES GLOBALES
new bitMask[MAXPLAYERS];
new MySQL_CONNECTION;

new Text:Fugazer_Layout[7];

// LUEGO REVISAMOS SI PODEMOS MEJORAR LOS TIMERS
new Timer[MAXPLAYERS][30];

new myString[MAX_STRING];

enum playerInfo {
	NAME[32],
	IP[16],
	ADMIN,
	PASSWORD,
	KILLS,
	DEATHS,
	SCORE,
	MONEY,
	SKIN,
	LAST_CONNECTION,
	IS_INCLAN
};
new playerProps[MAXPLAYERS][playerInfo];

// ADMIN VARS
enum commandsAdmin {
	COUNTDOWN_LOGIN,
	KICK_TIME
}
new adminProps[MAXPLAYERS][commandsAdmin];
new PlayerText:SignIn_TextDraw_CountDown[MAXPLAYERS];
new startCountDownAdminAccount[MAXPLAYERS];


// CLANES VARS
enum clanInfo {
	FULL_NAME[64],
	TAG[32],
	CLAN_ID_NEXT,
	CLAN_ID_PRIMARY,
	CLAN_RANK,
	CLAN_SKIN,
	CLAN_COLOR,
	CLAN_GANGZONECOLOR,
	CLAN_ANTITEAMKILL
};
new clanProps[MAXPLAYERS][clanInfo];

//new JugadorRegistrado[MAXPLAYERS];
new wrongPasswordLimit[MAXPLAYERS];

// CLAN WARS VARS
enum clanWarVars {
	WAR_ZONE_NAME[32],
	Float:WAR_ZONE_X1,
	Float:WAR_ZONE_Y1,
	Float:WAR_ZONE_X2,
	Float:WAR_ZONE_Y2,
	WAR_ZONE_COLOR,
	WAR_ZONE_TIME_CONQUER,
	WAR_ZONE_TIME_BAR,
	WAR_ZONE_TIME_ATTACK,
	WAR_ZONE_CLAN_ID_FLAG,
	WAR_ZONE_MAX_INT_PLAYERS,
	WAR_ZONE_GANGZONE_CREATE,
	WAR_ZONE_AREAS,
	WAR_ZONE_CLAN_MONEY,
    WAR_ZONE_USER_MONEY,
    WAR_ZONE_USER_SCORE,
	WAR_ZONE_CURRENT_USERS_AREA[MAX_CLANES],
	WAR_ZONE_CURRENT_ZONE_USER,
	Bar:WAR_ZONE_BAR_TIME,
	Text:WAR_ZONE_TEXDRAW_AREA_NAME
};

new warProps[MAX_WAR_ZONES][clanWarVars];
new WARZONE_ATTACK_CLAN_NAME[MAX_WAR_ZONES][32];
new WARZONE_ATTACK_CLAN_ID[MAX_WAR_ZONES];			
new WARZONE_ATTACK_CLAN_GANGZONE[MAX_WAR_ZONES]; 

new bool:areaIsAttack[MAX_WAR_ZONES] = false;
new areaIsAttackBy[MAX_WAR_ZONES];
new Text:WAR_ZONE_TEXDRAW_AREA_TEXT;
new PlayerText:WAR_ZONE_TEXDRAW_CURRENT_TIME[MAXPLAYERS];

// Progress bar - attacking zone
//new Bar:warZoneProgressBar[MAX_WAR_ZONES];
new updateRemaningTimeGangZone[MAX_WAR_ZONES];

// ARRAYS
new clanRanksText[][] =
{
    "Miembro", "Veterano", "Teniente", "SubLíder", "Líder"
};

new const LIST_MONTHS[][] = {
	"Enero", 
	"Febrero", 
	"Marzo", 
	"Abril", 
	"Mayo", 
	"Junio", 
	"Julio", 
	"Agosto", 
	"Septiembre", 
	"Octubre",
	"Noviembre", 
	"Diciembre"
};

new Float:Spawns[][16] =
{
    {1913.959228, -1358.506347, 13.605768, 137.347366},
	{-2030.434448, 156.722152, 33.938232, 271.768585},
	{948.934448, 2108.401855, 19.693887, 1.153009},
	{1343.281372, 2597.719482, 10.820312, 176.869491},
	{2087.555664, 2186.733642, 10.820312, 186.225326},
	{2012.302124, 1515.481079, 10.820312, 275.150177},
	{2446.410888, 1287.487670, 10.820312, 177.099151},
	{-1951.136352, 688.013977, 46.562500, 0.000000},
	{-2757.511962, 395.519836, 4.335937, 272.752502},
	{-2021.890991, -43.710788, 35.352428, 182.908599},
	{-1423.436279, -169.720870, 14.148437, 317.494415},
	{1307.457641, 1252.407714, 10.820312, 353.964294},
	{146.200149, -1951.344604, 3.773437, 0.857749},
	{1496.652465, -1659.034545, 14.046875, 1.087505},
	{2010.505371, -2339.766845, 13.546875, 100.746742},
	{952.796752, -923.542297, 43.953048, 180.479705}
};

new getRandomColor[78] =
{
	0x02BEFFFF, 0xFF5BFFFF, 0xFF00FFFF, 0xFF5106FF, 0x01FF06FF, 0x0141FFFF, 0x00D9FFFF, 0xFFFF00FF,
	0x64C800FF, 0x820039FF, 0xD500B5FF, 0xD50068FF, 0x620068FF, 0x62FA68FF, 0x00FF60FF, 0x00FFCBFF,
	0xFF0000FF, 0x720000FF, 0x9D9B9AFF, 0x9D3F9AFF, 0xD13F9AFF, 0xD13F4EFF, 0x44008AFF, 0x8800FEFF,
	0xAD00FEFF, 0x6B99FEFF, 0x6BDCFEFF, 0x6BDCB1FF, 0x0FDCB1FF, 0x0F77B1FF, 0x0F772EFF, 0xC41F2EFF,
	0xE0F32EFF,0x18F71FFF,0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,
	0x3C1C0DFF,
	0x12D6D4FF,0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,
	0x2FD9DEFF,0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,
	0x3214AAFF,0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,
	0xDCDE3DFF,0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,
	0xEEDC2DFF,
};

main()
{
	print("SERVER ON");

}


public OnGameModeInit()
{
	SetGameModeText(""SERVER_FULL_GAMEMODE"");
	SendRconCommand("hostname "SERVER_FULL_NAME"");
	SendRconCommand("language "SERVER_FULL_LANG"");
 	
 	// MYSQL DATABASE CONNECTION
    print("[MySQL-INFO]: Iniciando conexión a la base de datos...");
	MySQL_CONNECTION = mysql_connect(MySQL_SERVER, MySQL_USER, MySQL_DATABASE, MySQL_PASSWORD);
	if(mysql_log() == 1)
	{
		print("[MySQL-INFO]: Conexión establecida con éxito:");
		printf("[MySQL-INFO]: (Servidor: '%s', Usuario: '%s', Clave: '%s', Base de Datos: '%s')", MySQL_SERVER, MySQL_USER, MySQL_PASSWORD, MySQL_DATABASE);
	}
	else
	{
	    print("[MySQL-INFO]: Error: Se produjó un error al intentar conectar con la base de datos.");
		mysql_close(); 
		SendRconCommand("exit");
	}

	// TextDraws Server
	createTextDraws();

	// CLAN WAR _System Initializing
	mysql_tquery(MySQL_CONNECTION, "SELECT * FROM clan_territories_zones", "clanWarLoadAllZones", "");

	UsePlayerPedAnims();
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

function clanWarLoadAllZones()
{
	/*  Crea todas las zonas conquistables o gangzones desde la database
	    @file[]:            File to return the line from.
	    @line:              Line number to return.
	*/
	for(new i = 0; i<cache_get_row_count(MySQL_CONNECTION); i++)
	{
	    cache_get_row(i, 1, warProps[i][WAR_ZONE_NAME], MySQL_CONNECTION, 26);
    	warProps[i][WAR_ZONE_X1] = 					cache_get_row_float(i, 5, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_Y1] = 					cache_get_row_float(i, 6, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_X2] = 					cache_get_row_float(i, 7, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_Y2] = 					cache_get_row_float(i, 8, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_COLOR] = 				cache_get_row_int(i, 4, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_TIME_CONQUER] = 		cache_get_row_int(i, 13, MySQL_CONNECTION);
		warProps[i][WAR_ZONE_TIME_BAR] = 			cache_get_row_int(i, 13, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_CLAN_ID_FLAG] = 		cache_get_row_int(i, 12, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_MAX_INT_PLAYERS] = 	cache_get_row_int(i, 3, MySQL_CONNECTION);
    	// Rewards clan:
    	warProps[i][WAR_ZONE_CLAN_MONEY] =			cache_get_row_int(i, 11, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_USER_MONEY] =			cache_get_row_int(i, 10, MySQL_CONNECTION);
    	warProps[i][WAR_ZONE_USER_SCORE] =			cache_get_row_int(i, 9, MySQL_CONNECTION);

    	// Limpiamos todas las zonas
    	GangZoneHideForAll(warProps[i][WAR_ZONE_GANGZONE_CREATE]);

    	warProps[i][WAR_ZONE_GANGZONE_CREATE] = 	GangZoneCreate(
    		warProps[i][WAR_ZONE_X1], 
    		warProps[i][WAR_ZONE_Y1],
    		warProps[i][WAR_ZONE_X2], 
    		warProps[i][WAR_ZONE_Y2]
    	);

    	// Creamos las gangzones
        GangZoneShowForAll(warProps[i][WAR_ZONE_GANGZONE_CREATE], warProps[i][WAR_ZONE_COLOR]);

        // Creamos todas las áreas para conquistar
    	warProps[i][WAR_ZONE_AREAS] = CreateDynamicRectangle(warProps[i][WAR_ZONE_X1], 
    		warProps[i][WAR_ZONE_Y1],
    		warProps[i][WAR_ZONE_X2], 
    		warProps[i][WAR_ZONE_Y2], 
    		-1, 
    		-1, 
    		-1
    	);

    	warProps[i][WAR_ZONE_BAR_TIME] = CreateProgressBar(431.00, 431.00, 76.50, 6.19, -16719401, warProps[i][WAR_ZONE_TIME_BAR]);

	    warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME] = TextDrawCreate(514.000000, 426.000000, warProps[i][WAR_ZONE_NAME]);
		TextDrawBackgroundColor(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 255);
		TextDrawFont(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 3);
		TextDrawLetterSize(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 0.300000, 1.399999);
		TextDrawColor(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 1493106943);
		TextDrawSetOutline(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 1);
		TextDrawSetProportional(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 1);
		TextDrawSetSelectable(warProps[i][WAR_ZONE_TEXDRAW_AREA_NAME], 0);

	    WAR_ZONE_TEXDRAW_AREA_TEXT = TextDrawCreate(470.000000, 330.000000, "Conquistando...");
	    TextDrawBackgroundColor(WAR_ZONE_TEXDRAW_AREA_TEXT, 255);
	    TextDrawFont(WAR_ZONE_TEXDRAW_AREA_TEXT, 2);
	    TextDrawLetterSize(WAR_ZONE_TEXDRAW_AREA_TEXT, 0.310000, 1.200000);
	    TextDrawColor(WAR_ZONE_TEXDRAW_AREA_TEXT, -2621185);
	    TextDrawSetOutline(WAR_ZONE_TEXDRAW_AREA_TEXT, 1);
	    TextDrawSetProportional(WAR_ZONE_TEXDRAW_AREA_TEXT, 1);
	    TextDrawSetSelectable(WAR_ZONE_TEXDRAW_AREA_TEXT, 0);

    	// Imprimimos todas las zonas encontradas en la base de datos
    	printf("ClanWar - Zonas Encontradas: %d. %s", i, warProps[i][WAR_ZONE_NAME]);
    }
    return 1;
}

function showAllGangzonesServer(playerid)
{
	/*  Activa todas las gangzones al conectarse el jugador
	    @playerid:          Recibe el identificador del jugador.
	    notes:              La zona '0' debemos activarla manualmente(bugueada por alguna razon) :(
	*/
	for(new i = 0; i<MAX_WAR_ZONES; i++)
	{
		GangZoneShowForPlayer(playerid, warProps[i][WAR_ZONE_GANGZONE_CREATE], warProps[i][WAR_ZONE_COLOR]);
	}
	
	GangZoneShowForPlayer(playerid, warProps[0][WAR_ZONE_GANGZONE_CREATE], warProps[0][WAR_ZONE_COLOR]);
    return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    // Encontrar el área
    new thisArea = -1;
	for(new a = 0; a < MAX_WAR_ZONES; a++)
	{
		if(areaid == warProps[a][WAR_ZONE_AREAS])
		{
			thisArea = a;
			break;
		}
		else 
		{
			thisArea = -1;
		} 
	}

	// Si no hay concidencias... finalizamos el proceso.
	if(thisArea == -1) return 1;

    new
        stringZone[128],
        query[256],
        Cache: result,
        clanZoneName[32]
    ;

    mysql_format(MySQL_CONNECTION, query, sizeof(query), 
        "SELECT name_clan_owner FROM clan_territories_zones WHERE id_zone = '%d'", thisArea);
    result = mysql_query(MySQL_CONNECTION, query);

    if (cache_num_rows() > 0) 
    {
        cache_get_field_content(0, "name_clan_owner", clanZoneName, sizeof(clanZoneName));
    }
    else
    {
        format(stringZone, sizeof(stringZone), "*** Está zona no ha sido reclamada por nadie!");
    }
    cache_delete(result);

    format(stringZone, sizeof(stringZone), "*** Esta zona está conquistada por el clan %s!", clanZoneName);
    SendClientMessage(playerid, Naranja, stringZone);

    if(bitMask[playerid] & ispInClan)
    {
    	//if((areaIsAttack[thisArea]) & (areaIsAttackBy[thisArea] == clanProps[playerid][CLAN_ID_PRIMARY]))
    	//{
    		//warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]++;
        	//warProps[playerid][WAR_ZONE_CURRENT_ZONE_USER] = thisArea;
    	//}
        // Verificar si el clan del jugador es diferente al de la zona
        if ((clanProps[playerid][CLAN_ID_PRIMARY] != warProps[thisArea][WAR_ZONE_CLAN_ID_FLAG]) && !(areaIsAttack[thisArea]))
        {

        	// Aumentamos el contador cuando un jugador del mismo
        	// clan ingresa a la zona para poder conquistarla
        	warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]++;
        	warProps[playerid][WAR_ZONE_CURRENT_ZONE_USER] = thisArea;

            // Verificar si el máximo de jugadores en la zona se alcanzó
            // Y nos aseguramos si la zona esta bajo ataque

            // Si funciona asi, recordemos resetear la variable para ese id de clan.
            if((warProps[thisArea][WAR_ZONE_MAX_INT_PLAYERS] <= warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]) 
            	&& !(areaIsAttack[thisArea]))
            {
            	new stringmsg[128];
            	// Flash zone attacking
                GangZoneFlashForAll(warProps[thisArea][WAR_ZONE_GANGZONE_CREATE], clanProps[playerid][CLAN_GANGZONECOLOR]);

				format(stringmsg, sizeof(stringmsg), "{00FFE2}*** ClanWar: %s está atacando %s!", clanProps[playerid][FULL_NAME], warProps[thisArea][WAR_ZONE_NAME]);
				SendClientMessageToAll(-1, stringmsg);

				areaIsAttack[thisArea] = true;
				areaIsAttackBy[thisArea] = clanProps[playerid][CLAN_ID_PRIMARY];
				warProps[thisArea][WAR_ZONE_TIME_ATTACK] = 0;

				strmid(WARZONE_ATTACK_CLAN_NAME[thisArea], clanProps[playerid][FULL_NAME], 0, strlen(clanProps[playerid][FULL_NAME]), 64);
				WARZONE_ATTACK_CLAN_ID[thisArea] = 			clanProps[playerid][CLAN_ID_PRIMARY];
				WARZONE_ATTACK_CLAN_GANGZONE[thisArea] = 	clanProps[playerid][CLAN_GANGZONECOLOR];

    			SetProgressBarMaxValue(warProps[thisArea][WAR_ZONE_BAR_TIME], warProps[thisArea][WAR_ZONE_TIME_BAR]);
				updateRemaningTimeGangZone[thisArea] = SetTimerEx("updateGangZoneAttack", 1000, true, "d", thisArea);
				
            }
            else 
            {
    			new stringzona[76];
				format(stringzona, sizeof(stringzona), "~n~~n~~n~~n~~n~~n~~r~~h~~h~"SPECIAL_KEY_EXC"%d/%d jugadores~n~~r~~h~~h~para conquistar!", \
					warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]], 
					warProps[thisArea][WAR_ZONE_MAX_INT_PLAYERS]
				);
				foreach(new i: Player)
				{
					if(IsPlayerConnected(i))
					{
			    		if((clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY]) & (warProps[i][WAR_ZONE_CURRENT_ZONE_USER] == thisArea))
			    		{
							GameTextForPlayer(i, stringzona, 5000, 5);
						}
					}
				}
            }
        }
        else
        {
        	if((areaIsAttack[thisArea]) && (areaIsAttackBy[thisArea] == clanProps[playerid][CLAN_ID_PRIMARY]))
        	{
        		warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]++;
				warProps[playerid][WAR_ZONE_CURRENT_ZONE_USER] = thisArea;
    			GameTextForPlayer(playerid, "~r~~h~~h~"SPECIAL_KEY_EXC"Tu clan est"SPECIAL_KEY_A"~n~~r~~h~~h~asediando esta zona!", 5000, 3);
    			return 1;
        	}
        }
    }

    return 1;
}


function updateGangZoneAttack(const areaid)
{
	/*  Funcion que actualiza el tiempo de conquista de cada zona.
	    @areaid:          	Recibe el identificador de la zona de conquista de OnPlayerEnterDynamicArea.
	*/
	warProps[areaid][WAR_ZONE_TIME_ATTACK]++;

	new stringProgress[64];
	new progress = getProgressPercentage(warProps[areaid][WAR_ZONE_TIME_ATTACK], warProps[areaid][WAR_ZONE_TIME_CONQUER]);
    
    SetProgressBarValue(warProps[areaid][WAR_ZONE_BAR_TIME], warProps[areaid][WAR_ZONE_TIME_ATTACK]);

    format(stringProgress, sizeof(stringProgress), "progreso: %d%%", progress);
	foreach(new i : Player)
	{
		if((bitMask[i] & ispInClan) && (warProps[i][WAR_ZONE_CURRENT_ZONE_USER] == areaid) 
			&& (areaIsAttack[areaid]) && areaIsAttackBy[areaid] == clanProps[i][CLAN_ID_PRIMARY])
		{
			UpdateProgressBar(warProps[areaid][WAR_ZONE_BAR_TIME], i);
			TextDrawShowForPlayer(i, warProps[areaid][WAR_ZONE_TEXDRAW_AREA_NAME]);
			TextDrawShowForPlayer(i, WAR_ZONE_TEXDRAW_AREA_TEXT);
			PlayerTextDrawSetString(i, WAR_ZONE_TEXDRAW_CURRENT_TIME[i], stringProgress);
			PlayerTextDrawShow(i, WAR_ZONE_TEXDRAW_CURRENT_TIME[i]);
		}
	}

	if(warProps[areaid][WAR_ZONE_TIME_ATTACK] > warProps[areaid][WAR_ZONE_TIME_CONQUER])
	{
		// Matamos el timer de actualización
		KillTimer(updateRemaningTimeGangZone[areaid]);

		new Query[170], stringmsg2[150], successString[129];

		GangZoneShowForAll(warProps[areaid][WAR_ZONE_GANGZONE_CREATE], WARZONE_ATTACK_CLAN_GANGZONE[areaid]);

		mysql_format(MySQL_CONNECTION, Query, sizeof(Query), 
			"UPDATE clan_territories_zones SET name_clan_owner='%s', current_gangzone_color = %d, current_clan_owner_id = %d WHERE id_zone = %d", \ 
			WARZONE_ATTACK_CLAN_NAME[areaid], 
			WARZONE_ATTACK_CLAN_GANGZONE[areaid], 
			WARZONE_ATTACK_CLAN_ID[areaid], 
			areaid
		);
		mysql_query(MySQL_CONNECTION, Query, false);
		
		// TODO: Ok, aqui lo hariamos por temporadas = mes.
		// ALTER TABLE Clanes ADD COLUMN clan_conquest_jun2024 INT DEFAULT 0;
		// Creariamos otra tabla donde tenga(conquistas del mes, kills del mes, muertes del mes, carreras del mes, derbys o etc.)
		// Guardariamos solo 3 meses de actividad de clan
		// Podriamos tener un comando para ver los mejores clanes en cada area.
		// tengo duda si agregar dinero para clan en cada conquista, no lo agregare pero antes si exista jejeje

		//Esto de momento estará en pendiente.
		//mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "UPDATE Clanes SET ConquistasActual = ConquistasActual + 1, ConquistasClanTotal = ConquistasClanTotal + 1 WHERE IDClan = %d", WARZONE_ATTACK_CLAN_ID[areaid]);
		//mysql_query(MySQL_CONNECTION, Query, false);
		format(stringmsg2, sizeof(stringmsg2), "*** ClanWar: El clan %s conquistó %s!", WARZONE_ATTACK_CLAN_NAME[areaid], warProps[areaid][WAR_ZONE_NAME]);
		SendClientMessageToAll(Naranja, stringmsg2);

		format(successString, sizeof(successString), "{FFDE00}* ClanWar: Han conquistado %s para su clan! Reciben: $%d, exp+%d.", \
			warProps[areaid][WAR_ZONE_NAME], warProps[areaid][WAR_ZONE_USER_MONEY], warProps[areaid][WAR_ZONE_USER_SCORE]);
		
		foreach(new i : Player)
		{
			if((bitMask[i] & ispInClan) && (warProps[i][WAR_ZONE_CURRENT_ZONE_USER] == areaid) && (areaIsAttack[areaid]))
			{
				resetVarsTerritoryTakenUser(i, areaid, true);
				GameTextForPlayer(i, "~g~~h~~h~Zona conquistada!", 3000, 3);
				SendClientMessage(i, -1, successString);
				sendClanRewards(i, warProps[areaid][WAR_ZONE_USER_MONEY], warProps[areaid][WAR_ZONE_USER_SCORE]);
			}
		}
		// Reset all vars territory global
		resetVarsTerritoryTaken(areaid, WARZONE_ATTACK_CLAN_ID[areaid], true, true);
	}
	else
	{

	}
	return 1;
}

stock sendClanRewards(playerid, const money, const score)
{
	/*  Envia las recompensas por conquistar una zona a cada jugador.
	    @playerid:          Recibe el identificador del jugador.
	    @money:          	Recibe la cantidad de dinero a dar.
	    @score:          	Recibe la cantidad de score a dar.
	*/
	playerProps[playerid][SCORE] += score;
	playerProps[playerid][MONEY] += money;

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, playerProps[playerid][MONEY]);
	SetPlayerScore(playerid, GetPlayerScore(playerid)+playerProps[playerid][SCORE]);
}

stock resetVarsTerritoryTakenUser(playerid, const areaid, const bool:resetUserInZone)
{
	HideProgressBarForPlayer(playerid, warProps[areaid][WAR_ZONE_BAR_TIME]);
	TextDrawHideForPlayer(playerid, warProps[areaid][WAR_ZONE_TEXDRAW_AREA_NAME]);
	TextDrawHideForPlayer(playerid, WAR_ZONE_TEXDRAW_AREA_TEXT);
	PlayerTextDrawSetString(playerid, WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], "_");
	PlayerTextDrawHide(playerid, WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid]);
	if(resetUserInZone) warProps[playerid][WAR_ZONE_CURRENT_ZONE_USER] = -1;
}

stock resetVarsTerritoryTaken(const areaid, const clanid, const bool:resetUsersInZone, const bool:changeClanTerritory)
{
	areaIsAttack[areaid] = 											false;
	areaIsAttackBy[areaid] = 										-1;
	warProps[areaid][WAR_ZONE_TIME_ATTACK] = 						0;
	if(resetUsersInZone) warProps[areaid][WAR_ZONE_CURRENT_USERS_AREA][clanid] = 		-1;
	WARZONE_ATTACK_CLAN_NAME[areaid] =								"\0"; 
	WARZONE_ATTACK_CLAN_GANGZONE[areaid] =							-1;
	WARZONE_ATTACK_CLAN_ID[areaid] =								-1;
	warProps[areaid][WAR_ZONE_TIME_ATTACK] =						0;
	if(changeClanTerritory) warProps[areaid][WAR_ZONE_CLAN_ID_FLAG] =						clanid;
}


stock getProgressPercentage(currentTime, totalTime)
{
    if (totalTime == 0) return 0;
    new percentage = (currentTime * 100) / totalTime;
    if (percentage > 100) percentage = 100;
    return percentage;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	new thisArea = -1;
	for(new a = 0; a < MAX_WAR_ZONES; a++)
	{
		if(areaid == warProps[a][WAR_ZONE_AREAS])
		{
			thisArea = a;
			break;
		}
		else 
		{
			thisArea = -1;
		} 
	}

	// Si no hay concidencias... finalizamos el proceso.
	if(thisArea == -1) return 1;
	if(!(bitMask[playerid] & ispInClan)) return 1;

	// Conditions
	new _zoneUnderAttack = (areaIsAttack[thisArea]) && (areaIsAttackBy[thisArea] == clanProps[playerid][CLAN_ID_PRIMARY]);
	new _usersInArea = (warProps[thisArea][WAR_ZONE_MAX_INT_PLAYERS] >= warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]);

	// Restamos el jugador que salió
	warProps[thisArea][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]]--;
	warProps[playerid][WAR_ZONE_CURRENT_ZONE_USER] = -1;
	resetVarsTerritoryTakenUser(playerid, thisArea, false);

	if(_zoneUnderAttack)
	{
		if(_usersInArea)
		{
			new cancelString[128];
			format(cancelString, sizeof(cancelString), "{FFFF00}* ClanWar: La conquista por %s se canceló por falta de miembros.", warProps[thisArea][WAR_ZONE_NAME]);
			foreach(new i : Player)
			{
				if((bitMask[i] & ispInClan) && (warProps[i][WAR_ZONE_CURRENT_ZONE_USER] == thisArea) && (areaIsAttack[thisArea]))
				{
					GameTextForPlayer(i, "~r~~h~~h~conquista cancelada!", 3000, 0);
					SendClientMessage(i, -1, cancelString);
					resetVarsTerritoryTakenUser(i, thisArea, false);
				}
			}
			KillTimer(updateRemaningTimeGangZone[thisArea]);
			resetVarsTerritoryTakenUser(playerid, thisArea, true);
			resetVarsTerritoryTaken(thisArea, clanProps[playerid][CLAN_ID_PRIMARY], false, false);
			GangZoneShowForAll(warProps[thisArea][WAR_ZONE_GANGZONE_CREATE], warProps[thisArea][WAR_ZONE_COLOR]);
		}
	}
	
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPosEx(playerid, 491.004791, -14.016995, 1000.687805, 89.746116, 17, 0);
    SetPlayerCameraPos(playerid, 485.36, -13.84, 1002.12);
	SetPlayerCameraLookAt(playerid, 490.36, -13.90, 1000.69);
 	SetPlayerWeather(playerid, 9);
    SetPlayerTime(playerid, 22, 0);
	SetPlayerInterior(playerid, 17);
	return 1;
}

public OnPlayerConnect(playerid)
{
	new rand = random(sizeof(getRandomColor));
	SetPlayerColor(playerid, getRandomColor[rand]);
	SetTimerXP(playerid, 1, "RevisarPlayer", 2200);

	// Inicializamos todas las gangzones al jugador
	showAllGangzonesServer(playerid);

	SignIn_TextDraw_CountDown[playerid] = CreatePlayerTextDraw(playerid,282.000000, 259.000000, "Inicia Sesion:~n~ 1 segundos");
	PlayerTextDrawBackgroundColor(playerid,SignIn_TextDraw_CountDown[playerid], 255);
	PlayerTextDrawFont(playerid,SignIn_TextDraw_CountDown[playerid], 3);
	PlayerTextDrawLetterSize(playerid,SignIn_TextDraw_CountDown[playerid], 0.340000, 1.799999);
	PlayerTextDrawColor(playerid,SignIn_TextDraw_CountDown[playerid], -1);
	PlayerTextDrawSetOutline(playerid,SignIn_TextDraw_CountDown[playerid], 1);
	PlayerTextDrawSetProportional(playerid,SignIn_TextDraw_CountDown[playerid], 1);
	PlayerTextDrawSetSelectable(playerid,SignIn_TextDraw_CountDown[playerid], 0);

	WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid] = CreatePlayerTextDraw(playerid,361.000000, 427.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 255);
	PlayerTextDrawFont(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 3);
	PlayerTextDrawLetterSize(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 0.240000, 1.399999);
	PlayerTextDrawColor(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], -2621441);
	PlayerTextDrawSetOutline(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 1);
	PlayerTextDrawSetProportional(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 1);
	PlayerTextDrawSetSelectable(playerid,WAR_ZONE_TEXDRAW_CURRENT_TIME[playerid], 0);

	TextDrawShowForPlayer(playerid, Fugazer_Layout[0]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[1]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[2]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[3]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[4]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[5]);
	TextDrawShowForPlayer(playerid, Fugazer_Layout[6]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// TODO: Manejar más organizadamente esta parte
	// De momento solo reseteamos las variables
	hardResetVars(playerid);
	return 1;
}

stock hardResetVars(const playerid)
{
	// PLAYER GLOBAL VARS
	playerProps[playerid][NAME] = '\0';
	playerProps[playerid][IP] = '\0';
	playerProps[playerid][PASSWORD] = '\0';
	playerProps[playerid][ADMIN] = 0;
	playerProps[playerid][KILLS] = 0;
	playerProps[playerid][DEATHS] = 0;
	playerProps[playerid][MONEY] = 0;
	playerProps[playerid][SCORE] = 0;
	playerProps[playerid][SKIN] = 0;
	playerProps[playerid][LAST_CONNECTION] = 0;
	playerProps[playerid][IS_INCLAN] = 0;

	// CLAN PLAYER VARS
	clanProps[playerid][FULL_NAME] = '\0';
	clanProps[playerid][TAG] = '\0';
	clanProps[playerid][CLAN_ID_NEXT] = 0;
	clanProps[playerid][CLAN_ID_PRIMARY] = 0;
	clanProps[playerid][CLAN_RANK] = 0;
	clanProps[playerid][CLAN_SKIN] = 0;
	clanProps[playerid][CLAN_COLOR] = 0;
	clanProps[playerid][CLAN_GANGZONECOLOR] = 0;
	clanProps[playerid][CLAN_ANTITEAMKILL] = 0;

	DeletePVar(playerid, "CLAN_ID_INVITATION");
	DeletePVar(playerid, "USER_ID_INVITATION");

	// BITS PLAYER
	bitMask[playerid] = 0;
	bitMask[playerid] &= ~ispRegisted;
	bitMask[playerid] &= ~ispLogged;
	bitMask[playerid] &= ~ispInClan;
    bitMask[playerid] &= ~ispClanLeader;
    bitMask[playerid] &= ~ispClanSubLeader;
    bitMask[playerid] &= ~ispClanRecluter;
    //bitMask[playerid] &= ~ispClanLeader; 

}

public OnPlayerSpawn(playerid)
{
	SpawnsRand(playerid);
	return 1;
}

SpawnsRand(playerid)
{
    new rand = random(sizeof(Spawns));
    SetPlayerPosEx(playerid, Spawns[rand][0], Spawns[rand][1], Spawns[rand][2], Spawns[rand][3], 0, 0);
    return 1;
}

stock SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Float:A, interiorid, worldid)
{
    SetPlayerPos(playerid, X, Y, Z);
    SetPlayerFacingAngle(playerid, A);
    SetPlayerInterior(playerid, interiorid);
    SetPlayerVirtualWorld(playerid, worldid);
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp(cmdtext, "/ccontraseña", true) == 0 || strcmp(cmdtext, "/mp", true) == 0 || strcmp(cmdtext, "/pm", true) == 0 ||
	strcmp(cmdtext, "/asay", true) == 0
	|| strcmp(cmdtext, "/expulsar", true) == 0 || strcmp(cmdtext, "/ban", true) == 0 || strcmp(cmdtext, "/lsay", true) == 0
	|| strcmp(cmdtext, "/nsay", true) == 0 || strcmp(cmdtext, "/login", true) == 0 || strcmp(cmdtext, "/c", true) == 0)
    {

	}
	else
	{
		static stringj[128];
		format(stringj,sizeof(stringj),"* AdminInfo CMD: %s(%d) %s", GET_PLAYER_NAME(playerid), playerid, cmdtext);
		sendAdminInfoMessage(stringj);
	}
	return 1;
}

YCMD:commandtest1(playerid, params[], help)
{
	if (!sscanf(params, "ddd", params[0], params[1], params[2]))
	{
		if(params[1] == 1)
		{
			return warProps[params[2]][WAR_ZONE_CURRENT_USERS_AREA][params[0]]++;
		}
		warProps[params[2]][WAR_ZONE_CURRENT_USERS_AREA][params[0]]--;
	}
	else SendClientMessage(playerid, -1, " usa: /commandtest1 <id clan> <1. sumar o 0. restar> <area id>");	
	return 1;
}

YCMD:cmdtest2(playerid, params[], help)
{
	if (!sscanf(params, "d", params[0]))
	{
		new small_string[128];
		format(small_string, sizeof(small_string), "* Los valores: %d/%d area attack: %d, area attack by clan id: %d", \
			warProps[params[0]][WAR_ZONE_MAX_INT_PLAYERS], 
			warProps[params[0]][WAR_ZONE_CURRENT_USERS_AREA][clanProps[playerid][CLAN_ID_PRIMARY]],
			areaIsAttack[params[0]],
			areaIsAttackBy[params[0]]
		);
		SendClientMessage(playerid, -1, small_string);
	}
	return 1;
}

YCMD:cmdtest3(playerid, params[], help)
{
	new small_string[100];
	format(small_string, sizeof(small_string), "* %s es la fecha actual", getCurrentDate(playerid));
	SendClientMessage(playerid, Blanco, small_string);
	return 1;
}

YCMD:cmdtest4(playerid, params[], help)
{
	if (!sscanf(params, "d", params[0]))
	{
		GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~r~~h~~h~"SPECIAL_KEY_EXC"2/5 jugadores~n~~r~~h~~h~para conquistar!", 5000, params[0]);
	}
}

YCMD:fecha(playerid, params[], help)
{
	new small_string[500];
	format(small_string, sizeof(small_string), 
		"{FF5BD3}'%s' {FFFFFF}es una cuenta registrada, por favor\n{FF5BD3}* Ingresa tu contraseña para iniciar sesión\n", GET_PLAYER_NAME(playerid));
	ShowPlayerDialog(playerid, 17289, DIALOG_STYLE_INPUT, "{FFFFFF}Inicio de sesión:", small_string,"Aceptar","Kick");
	return 1;
}

YCMD:register(playerid, params[], help)
{
	//if(ComandosBloqueados[playerid] == true) return SendClientMessage(playerid, -1, "{FFFF00}* No hagas flood de comandos, es sancionado."), DesbloquearComandosP(playerid);
	if (bitMask[playerid] & ispRegisted) 
		return SendClientMessage(playerid, -1, "*** No puedes registrar está cuenta porque ya se encuentra en la base de datos.");
	ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_UP, DIALOG_STYLE_INPUT, "{FFFFFF}Registro:", 
		"{FFFFFF}Para continuar con el registro de tu cuenta, por favor\n{FF5BD3}* Ingresa una contraseña en el recuadro de abajo -\n{FF5BD3}Entre 6 y 25 caracteres de longitud:",
		"Aceptar","Kick");
	return 1;
}

YCMD:lpm(playerid, params[], help){ playerProps[playerid][MONEY] = 1600000; playerProps[playerid][SCORE] = 1500; return 1; }

stock isBlockCommands(playerid)
{
	if(bitMask[playerid] & ispJail)
	{
	 	SendClientMessage(playerid, Naranja, "Un administrador te ha encarcelado. Espera a que te quiten la sanción.");
	  	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~r~~h~~h~primero usa /salir", 4000, 5);
   		return 1;
   	}
	if(bitMask[playerid] & ispDeathMatch)
	{
		SendClientMessage(playerid, Naranja, "Antes de usar comandos debes de salir de la zona con: /salir.");
		GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~r~~h~~h~primero usa /salir", 4000, 5);
		return 1;
	}
	return 1;
}

//COMANDOS DE CLANES
YCMD:clan(playerid, params[], help)
{
	if(!isBlockCommands(playerid))
		return 1;
	//CREAR
	if(strcmp(params,"crear",true) == 0)
	{
        if(bitMask[playerid] & ispInClan) return SendClientMessage(playerid, -1, "{C00000}* No puedes crear un clan nuevo si eres parte de uno. Usa: /clan salir, para salir de tu clan.");
       	if(playerProps[playerid][MONEY] >= 1000000)
       	{
			if(playerProps[playerid][SCORE] >= 250)
			{
	        	ShowPlayerDialog(playerid, CLAN_CREATION_NAME, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "\
	                		{FFFFFF}Por favor ingresa el nombre del clan a crear\n{FFBEFF}Recuerda que el nombre solo puede contener {FFFFFF}7-22{FFBEFF} de caracteres:", "Aceptar", "Cancelar");
				//ShowPlayerDialog(playerid, CLAN_CREATION_NAME, DIALOG_STYLE_INPUT, "{FFFFFF}Crear Clan:", "{FFFFFF}Ingresa el {01A2FF}NOMBRE{FFFFFF} del clan a crear.\nRecuerda, el nombre solo puede contener de {01A2FF}7-22{FFFFFF} de longitud:\nUna vez des Aceptar el clan estará creado.", "Aceptar", "Cancelar");
			}
			else SendClientMessage(playerid, -1, "{C00000}* No dispones de la cantidad de score necesaria para crear un clan.");
  		}
  		else SendClientMessage(playerid, -1, "{C00000}* No dispones de la cantidad de dinero necesaria para crear un clan.");
 	}
 	//ADMINISRTRAR
	else if(strcmp(params,"administrar",true) == 0)
	{
 		if(!(bitMask[playerid] & ispInClan)) 
			return SendClientMessage(playerid, -1, "{C00000}*** No formas parte de un clan para ejecutar esta acción.");
	    if(bitMask[playerid] & ispClanLeader || ispClanSubLeader)
		{
			return ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_LEADER, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:", \
				"AntiTeamKill(Matarse entre si)\nCambiar Skin\nColor del Clan\nModificar Rangos\nExpulsar Miembros\nAdministrar Fondos\nClan Estadisticas\nNotificaciones\nClan Base\n","Seleccionar","Cancelar");
		}
		/*if(bitMask[playerid] & ispClanRecluter)
		{
			return ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_RECLUTER, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:", \
				"AntiTeamKill(Matarse entre si)\nCambiar Skin\nColor del Clan\nModificar Rangos\nExpulsar Miembros\nAdministrar Fondos\nClan Estadisticas\nNotificaciones\nClan Base\n","Seleccionar","Cancelar");
		}*/
		else SendClientMessage(playerid, -1, "{FF1800}*** Éste comando es solo para Líderes del clan.");
	}
	//INVITAR
	else if(strcmp(params,"invitar",true) == 0)
	{
		if(!(bitMask[playerid] & ispInClan)) 
			return SendClientMessage(playerid, -1, "{C00000}*** No formas parte de un clan para ejecutar esta acción.");
		if(!(bitMask[playerid] & ispClanLeader || ispClanSubLeader || ispClanRecluter)) 
			return SendClientMessage(playerid, -1, "{C00000}*** No tienes suficiente nivel para usar este comando.");
		ShowPlayerDialog(playerid, CLAN_CREATION_INVITE, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "\
	                		{FFFFFF}Por favor ingresa el id del jugador -\n{FFBEFF}Al que deseas invitar a tu clan:", "Aceptar", "Cancelar");
	}
	//SALIR
	else if(strcmp(params,"salir",true) == 0)
	{
	 	if(bitMask[playerid] & ispInClan)
		{	
			new Query[85], Cache:result;
			mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT * FROM clans_members WHERE name_member = '%e'", GET_PLAYER_NAME(playerid));
			result = mysql_query(MySQL_CONNECTION, Query);
			if(cache_get_row_count(MySQL_CONNECTION) > 0)
			{
				cache_delete(result);
				if(!(bitMask[playerid] & ispClanLeader))
				{
					mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "DELETE FROM clans_members WHERE name_member = '%s'", GET_PLAYER_NAME(playerid));
					mysql_query(MySQL_CONNECTION, Query, false);

					clanProps[playerid][FULL_NAME] = '\0';
					clanProps[playerid][TAG] = '\0';
					clanProps[playerid][CLAN_ID_NEXT] = 0;
					clanProps[playerid][CLAN_ID_PRIMARY] = 0;
					clanProps[playerid][CLAN_RANK] = 0;
					clanProps[playerid][CLAN_SKIN] = 0;
					clanProps[playerid][CLAN_COLOR] = 0;
					clanProps[playerid][CLAN_GANGZONECOLOR] = 0;
					clanProps[playerid][CLAN_ANTITEAMKILL] = 0;

					// BITS PLAYER
					bitMask[playerid] &= ~ispInClan;
				    bitMask[playerid] &= ~ispClanLeader;
				    bitMask[playerid] &= ~ispClanSubLeader;
				    bitMask[playerid] &= ~ispClanRecluter;
				    cache_delete(result);
				    format(Query, sizeof(Query), "{00FFE2}* <%s> Clan: %s salió del clan voluntariamente!", clanProps[playerid][TAG], GET_PLAYER_NAME(playerid));
				    sendClanMessage(playerid, Query);
				}
				// TODO: Si el jugador es el lider del clan enviar un dialog para cambiar de nuevo lider.
			}
			else 
			{
				SendClientMessage(playerid, -1, "{C00000}*** No formas parte de ningún clan.");
			}
	    }
		else SendClientMessage(playerid, -1, "{C00000}*** No formas parte de un clan para ejecutar esta acción.");
	}
	//RECHAZAR
	else if(strcmp(params,"rechazar",true) == 0)
	{
	    static stringc[128];
	    if(GetPVarInt(playerid, "CLAN_ID_INVITATION") < 1)
		{
			return SendClientMessage(playerid, -1, "{FFDE00}*** No has recibido ninguna invitación de clan.");
		}
		SendClientMessage(playerid, -1, "{FFDE00}*** Has rechazado la invitación a unirte al clan.");
		format(stringc, sizeof(stringc), "{FFFF00}* %s rechazó la invitación de union a tu clan.", GET_PLAYER_NAME(playerid));
		SendClientMessage(GetPVarInt(playerid, "USER_ID_INVITATION"), -1, stringc);
		DeletePVar(playerid, "CLAN_ID_INVITATION");
		DeletePVar(playerid, "USER_ID_INVITATION");
		return 1;
	}
	//ACEPTAR
	else if(strcmp(params,"aceptar",true) == 0)
	{
	    if(!(bitMask[playerid] & ispInClan))
	    {
			if(GetPVarInt(playerid, "CLAN_ID_INVITATION") < 1)
				return SendClientMessage(playerid, -1, "{FFDE00}*** No has recibido ninguna invitación para unirte.");

			new Cache:result, Query[250], getClanMembersCount, getClanMaxMembers;

			mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT * FROM clans_members WHERE id_clan = %d", GetPVarInt(playerid, "CLAN_ID_INVITATION"));
			result = mysql_query(MySQL_CONNECTION, Query);
			getClanMembersCount = 			cache_get_row_count(MySQL_CONNECTION);
			cache_delete(result, MySQL_CONNECTION);

			result = mysql_query(MySQL_CONNECTION, "SELECT max_clan_members FROM serverconfig");
			getClanMaxMembers = 			cache_get_row_int(0, 0, MySQL_CONNECTION);
			cache_delete(result, MySQL_CONNECTION);

			// Comprueba que el clan no este lleno
			if(getClanMaxMembers >= getClanMembersCount)
			{
				// Creamos al usuario en la tabla.
				mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "INSERT INTO clans_members(clans_members, id_clan, rank_member) VALUES('%s', %d, %d);",\
					GET_PLAYER_NAME(playerid), GetPVarInt(playerid, "CLAN_ID_INVITATION"), 1);
				mysql_query(MySQL_CONNECTION, Query, false);

				// CLEAN PVARS
				DeletePVar(playerid, "CLAN_ID_INVITATION");
				DeletePVar(playerid, "USER_ID_INVITATION");

				// Obtiene toda la data del clan si todo esta OK.
				getUserData(playerid, false);
			}
			else 
			{
				DeletePVar(playerid, "CLAN_ID_INVITATION");
				DeletePVar(playerid, "USER_ID_INVITATION");
				return SendClientMessage(playerid, -1, "{FFDE00}*** Este clan está actualmente lleno.");
			}
		}
		else SendClientMessage(playerid, -1, "{C00000}*** Ya posees un clan, no puedes aceptar unirte a otro.");
	}
	else{
		SendClientMessage(playerid, -1, "Usa: /clan [crear, salir, administrar, invitar].");
	}
	return 1;
}

YCMD:c(playerid, params[], help)
{
	new text[128];
 	if((bitMask[playerid] & ispInClan) && (bitMask[playerid] && ispRegisted) && ( bitMask[playerid] & ispLogged))
  	{
  		if (!sscanf(params, "s[70]", params[0]))
  		{
   			format(text, sizeof text, "* <%s>[%s]%s(%d): %s", \
   				clanProps[playerid][TAG], clanRanksText[clanProps[playerid][CLAN_RANK]-1], GET_PLAYER_NAME(playerid), playerid, params[0]);
     		foreach(new i : Player)
     		{
       			if(IsPlayerConnected(i))
         		{
          			if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY]) SendClientMessage(i, clanProps[playerid][CLAN_COLOR], text);
            	}
        	}
        }
        else SendClientMessage(playerid, -1, "Usa: /c [texto].");
    }
    else SendClientMessage(playerid, -1, "No formas parte de un clan para utilizar este comando.");
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

stock bool:checkLength(min_range, max_range, text[]){
	// Retorna TRUE o FALSE si la cadena de texto
	// se encuentra en el rango especificado
    return (strlen(text) < min_range || strlen(text) > max_range);
}

stock sendMessage(playerid, msg[]){
	SendClientMessage(playerid, Blanco, msg);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
    {
        case IDENTIFICATION_SIGN_UP:
        {
            static bool:PASSWORD_VERIFY[MAXPLAYERS], PASSWORD_MATCH[MAXPLAYERS][20];
            if(!response) return SendClientMessage(playerid, -1, "{C70000}Has escogido no registrarte en nuestro servidor."), Kick(playerid);
            else
            {
                if(checkLength(5, 20, inputtext)) return PASSWORD_VERIFY[playerid] = false, 
                	ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_UP, DIALOG_STYLE_PASSWORD,"{FFFFFF}Error:", "{FFFFFF}La contraseña que colocaste no posee los parametros permitidos.\nPor favor escribe una nueva contraseña:", "Registrar", "");
                if(!PASSWORD_VERIFY[playerid])
                {
                    strmid(PASSWORD_MATCH[playerid], inputtext, 0, strlen(inputtext), 20);
                    ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_UP, DIALOG_STYLE_PASSWORD,"{FFFFFF}Verficación", "{FFFFFF}Verificación de la contraseña\nIngresa de nuevo la contraseña para validar:", "Aceptar", "");
                    bitMask[playerid] |= ispRegisted;
                    PASSWORD_VERIFY[playerid] = true;
                    return 1;
                }
                if(PASSWORD_VERIFY[playerid])
                {
					if(!strcmp(inputtext, PASSWORD_MATCH[playerid], true))
					{
						PASSWORD_VERIFY[playerid] = false;
						registerUser(playerid, inputtext);
					}
	                else return PASSWORD_VERIFY[playerid] = false, 
	                	ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_UP, DIALOG_STYLE_PASSWORD,"{FFFFFF}Error", "{FFFFFF}La primera contraseña no coicide con la segunda.\n{FFFFFF}Escriba una nueva contraseña para registrarse:", "Registrar", "");
	            }
            }
        }
        case IDENTIFICATION_SIGN_IN:
        {
            if(!response) return SendClientMessage(playerid, -1, "{C70000}Has escogido no logearte en nuestro servidor."), Kick(playerid);
            else
            {
                if(checkLength(5, 20, inputtext)) return ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_IN, DIALOG_STYLE_INPUT,"{FFFFFF}Error:","{FFFFFF}La contraseña que colocaste no posee los parametros permitidos.\n{FFFFFF}Vuelva a intentar iniciar sesión:\n","Aceptar","Salir");
                if(!strcmp(inputtext, playerProps[playerid][PASSWORD], true))
                {
					new getCurrentIP[16], query[25];
					GetPlayerIp(playerid, getCurrentIP, sizeof(getCurrentIP));
					format(query, sizeof(query), "UPDATE `players` SET `ip`='%s' WHERE username='%s'", getCurrentIP, GET_PLAYER_NAME(playerid));
   					mysql_function_query(MySQL_CONNECTION, query, true, "OnQueryFinish", "ii", 2, playerid);
   					KillTimer(startCountDownAdminAccount[playerid]);
			        PlayerTextDrawHide(playerid, SignIn_TextDraw_CountDown[playerid]);
			        PlayerTextDrawDestroy(playerid, SignIn_TextDraw_CountDown[playerid]);
			        adminProps[playerid][COUNTDOWN_LOGIN] = 0;
			        getUserData(playerid, true);
				}
                else
				{
                    wrongPasswordCount(playerid);
                    wrongPasswordLimit[playerid] += 1;
					ShowPlayerDialog(playerid, IDENTIFICATION_SIGN_IN, DIALOG_STYLE_PASSWORD,"{FFFFFF}Error", "{FFFFFF}Has colocado una contraseña incorrecta.\nIngresa de nuevo tu contraseña:", "Aceptar", "");
            	}
            }
        }
    }
    // CLAN SYSTEM
    switch(dialogid)
    {
        case CLAN_CREATION_NAME:
        {
            if(!response) return SendClientMessage(playerid, -1, "Se canceló la operación.");
            {
            	new query[250];
                if(checkLength(7, 22, inputtext)) 
                	return ShowPlayerDialog(playerid, CLAN_CREATION_NAME, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "\
                		{FFFFFF}Por favor ingresa el nombre del clan a crear\n{FFBEFF}Recuerda que el nombre solo puede contener {FFFFFF}7-22{FFFFFF} de longitud:\
                		\n{FF0001}El nombre de tu clan es muy largo o muy corto, escribe otro:", "Aceptar", "Cancelar");
               	
                mysql_format(MySQL_CONNECTION, query, sizeof(query), "SELECT* FROM clanes_groups WHERE clan_name = '%e'", inputtext);
				new Cache:result = mysql_query(MySQL_CONNECTION, query);
				if(cache_get_row_count(MySQL_CONNECTION) == 0) // COMPRUEBA QUE EL NOMBRE DEL CLAN NO EXISTA
				{
					new stringjj2[1800];
				    strmid(clanProps[playerid][FULL_NAME], inputtext, 0, 32, 32);
	               	format(stringjj2, sizeof (stringjj2), "{FFFFFF}Felicidades, has creado el clan: {01A2FF}%s{FFFFFF}.\
	               		\nAhora, por favor escribe el TAG de tu clan. Sólo podrá ser de {01A2FF}1-4{FFFFFF} de longitud:", clanProps[playerid][FULL_NAME]);
	               	ShowPlayerDialog(playerid, CLAN_CREATION_TAG, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", stringjj2, "Aceptar", "");
	               	cache_delete(result, MySQL_CONNECTION);
				}
				else 
				{
					cache_delete(result, MySQL_CONNECTION);
					sendMessage(playerid, "* Lo sentimos pero el nombre del clan ya se encuentra en uso.");
				}
            }
        }
        case CLAN_CREATION_TAG:
        {
            if(!response) return ShowPlayerDialog(playerid, CLAN_CREATION_TAG, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "{FFFFFF}No puedes cancelar la creación de tu clan. Escribe el TAG para seguir:", "Aceptar", "");
            {
                new tmp[20], idx, Query[300], Cache:result, currentDate[3], clan_string[100];

                tmp = strtok(inputtext, idx);
                if(checkLength(2, 5, inputtext)) 
                	return ShowPlayerDialog(playerid, CLAN_CREATION_TAG, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "{FFFFFF}El TAG de tu clan es muy largo, \
                		por favor introduce otra:", "Aceptar", "");

                if(strfind(tmp, "[", true) != -1 || strfind(tmp, "]", true) != -1)
                	return ShowPlayerDialog(playerid, CLAN_CREATION_TAG, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", "{FFFFFF}El tag de tu clan no puede llevar corchetes. \
                		\nEscribe por ejemplo: FZR", "Aceptar", "");
				mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT* FROM clanes_groups WHERE clan_tag = '%s'", inputtext);
				result = mysql_query(MySQL_CONNECTION, Query);
				if(cache_get_row_count(MySQL_CONNECTION) == 0)
				{
    				mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT current_groups_total FROM clans_groups_max WHERE id_groups_max = '%d'", 1);
					result = mysql_query(MySQL_CONNECTION, Query);
					clanProps[playerid][CLAN_ID_NEXT] = cache_get_field_content_int(0, "current_groups_total", MySQL_CONNECTION);
					clanProps[playerid][CLAN_ID_NEXT] += 1;
					cache_delete(result, MySQL_CONNECTION);
					mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "UPDATE `clans_groups_max` SET `current_groups_total` = '%d' WHERE `id_groups_max` = %d", clanProps[playerid][CLAN_ID_NEXT], 1);
					mysql_query(MySQL_CONNECTION, Query, false);
					cache_delete(result, MySQL_CONNECTION);

					getdate(
						currentDate[0], 
						currentDate[1], 
						currentDate[2]
					);
					mysql_format(MySQL_CONNECTION, Query, sizeof(Query), 
						"INSERT INTO clanes_groups(clan_name, clan_tag, founder_name, id_clan, creation_day, creation_month, creation_year) \
						VALUES('%e', '%s', '%s', %d, %d, %d, %d);", 
						clanProps[playerid][FULL_NAME], inputtext, GET_PLAYER_NAME(playerid), clanProps[playerid][CLAN_ID_NEXT], 
						currentDate[2], currentDate[1], currentDate[0]);

					result = mysql_query(MySQL_CONNECTION, Query);
					cache_delete(result, MySQL_CONNECTION);

					mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT id_clan FROM clanes_groups WHERE clan_name = '%s'", clanProps[playerid][FULL_NAME]);
					result = mysql_query(MySQL_CONNECTION, Query);
    				clanProps[playerid][CLAN_ID_PRIMARY] = cache_get_field_content_int(0, "IDClan", MySQL_CONNECTION);
    				cache_delete(result, MySQL_CONNECTION);

    				clanProps[playerid][CLAN_RANK] = 5;
    				bitMask[playerid] |= ispInClan;
    				bitMask[playerid] |= ispClanLeader;
					
					mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "INSERT INTO clans_members(name_member, id_clan, rank_member) VALUES('%s', %d, %d);",\
					GET_PLAYER_NAME(playerid), clanProps[playerid][CLAN_ID_PRIMARY], clanProps[playerid][CLAN_RANK]);
					mysql_query(MySQL_CONNECTION, Query, false);

					// TODO: Hacer que aquí compruebe si el jugador ya tiene clan
					//	Si ya tiene entonces que el rango más alto pase al jugador
					// que tenga el segundo rango más alto, por ejemplo sublider
					// Trabajar esto cuando los rangos de clanes ya sirvan.
					// NOTA: Quizá sea mejor trabajarlo en (/clan salir o /clan expulsar).

					/*mysql_format(MySQL_CONNECTION, query, sizeof(query), "SELECT* FROM Clanes WHERE NombreClan = '%e'", inputtext);
					new Cache:result = mysql_query(MySQL_CONNECTION, query);
					if(cache_get_row_count(MySQL_CONNECTION) == 0) // COMPRUEBA QUE EL NOMBRE DEL CLAN NO EXISTA
					{
						new stringjj2[1800];
					    strmid(clanProps[playerid][FULL_NAME], inputtext, 0, 32, 32);
		               	format(stringjj2, sizeof (stringjj2), "{FFFFFF}Felicidades, has creado el clan: {01A2FF}%s{FFFFFF}.\
		               		\nAhora, por favor escribe el TAG de tu clan. Sólo podrá ser de {01A2FF}1-4{FFFFFF} de longitud:", clanProps[playerid][FULL_NAME]);
		               	ShowPlayerDialog(playerid, CLAN_CREATION_TAG, DIALOG_STYLE_INPUT, "{E9E200}Sistema de Clanes:", stringjj2, "Aceptar", "");
		               	cache_delete(result, MySQL_CONNECTION);
					}
					else 
					{
						cache_delete(result, MySQL_CONNECTION);
						sendMessage(playerid, "* Lo sentimos pero el nombre del clan ya se encuentra esta en uso.");
					}*/
					///

					strmid(clanProps[playerid][TAG], inputtext, 0, strlen(inputtext), 64);
                	SetPlayerColor(playerid, 0);

                	ResetPlayerMoney(playerid);
		    		playerProps[playerid][MONEY] -= 1000000;
					GivePlayerMoney(playerid, playerProps[playerid][MONEY]);
					playerProps[playerid][SCORE] -= 250;

					format(clan_string, sizeof(clan_string), "{00FF00}*** Enhorabuena has creado el clan '%s' correctamente.", clanProps[playerid][FULL_NAME]);
					SendClientMessage(playerid, -1, clan_string);
					SendClientMessage(playerid, -1, "   Eres el Líder de tu clan, escribe: /clan para ver las preferencias.");
				}
				else
    			{
					cache_delete(result, MySQL_CONNECTION);
					SendClientMessage(playerid, -1, "{FFE900}*** Lo sentimos pero ya existe un clan con ese tag.");
				}
   			}
  		}

    }
    if(dialogid == CLAN_CREATION_INVITE)
	{
		if(!response) return SendClientMessage(playerid, -1, "Se canceló la operación.");
		new playerInvite;
		if(sscanf(inputtext, "u", playerInvite)) 	return SendClientMessage(playerid, Rojo, "*** Este jugador no se encuentra conectado.");
	    if(!IsPlayerConnected(playerInvite)) 		return SendClientMessage(playerid, Rojo, "*** Este jugador no se encuentra conectado.");
		if(playerInvite == playerid) 				return SendClientMessage(playerid, Rojo, "*** No puedes enviarte invitación a ti mismo!");
		if(bitMask[playerInvite] & ispInClan)		return SendClientMessage(playerid, Rojo, "*** El jugador ya se encuentra en un clan.");

		static Query[250], temp[52];
		mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT clan_name FROM clanes_groups WHERE id_clan = %d", clanProps[playerid][CLAN_ID_PRIMARY]);
		new Cache:result = mysql_query(MySQL_CONNECTION, Query);

		cache_get_field_content(0, "clan_name", temp, MySQL_CONNECTION, sizeof(temp));

		if(cache_get_row_count(MySQL_CONNECTION) == 0)
		{
			cache_delete(result, MySQL_CONNECTION);
			return SendClientMessage(playerid, Rojo, "*** Ocurrió un error, intentalo más tarde o comunicate con un admin."); 
		}
		cache_delete(result, MySQL_CONNECTION);

		format(Query, sizeof(Query), "{FFBEFF}*** Clan: {FFFFFF}%s(id:%d){FFBEFF} te ha invitado al clan {FFFFFF}'%s'{FFBEFF}. Escribe: /clan aceptar o rechazar.", GET_PLAYER_NAME(playerid), playerid, temp);
		SendClientMessage(playerInvite, -1, Query);
		format(Query, sizeof(Query), "{FFBEFF}*** Has enviado una invitación de clan a {FFFFFF}%s(id:%d){FFBEFF}.", GET_PLAYER_NAME(playerInvite), playerInvite);
		SendClientMessage(playerid, -1, Query);
		SetPVarInt(playerInvite, "CLAN_ID_INVITATION", clanProps[playerid][CLAN_ID_PRIMARY]);
		SetPVarInt(playerInvite, "USER_ID_INVITATION", playerid);
	}
	// CLAN ADMINISTRAR
	if(dialogid == CLAN_ADMINISTRATION_LEADER)
   	{
  	 	if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
   		switch(listitem)
   		{
			case 0:
			{
    			ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_CHANGE_TEAMKILL, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:","Activar\nDesactivar\n","Seleccionar","Cancelar");
        	}
			case 1:
			{
				ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_CHANGE_SKIN, DIALOG_STYLE_INPUT, "{FFFFFF}Configuración de tu Clan:","Ingresa el ID del skin:\n","Aceptar","Cancelar");
			}
			case 2:
			{
				ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_CHANGE_COLOR, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:", "{FF0000}Colores Rojos\n{FF7400}Colores Naranjas\n{712B00}Colores Marrones\n{FFE900}Colores Amarillos\n{02E900}Colores Verdes\n{02E9F0}Colores Azules Claros\n{0052FF}Azules Oscuros\n{B900FF}Colores Violetas\n{FF4CF0}Colores Rosas\n{6C6C8B}Colores Grises\n{3C3F44}Color Negro\n{FFFFFF}Color Blanco\n", "Aceptar", "Cancelar");
    		}
    		case 3..4:
			{
				new Query[2700], rango;
				mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT* FROM clans_members WHERE id_clan = %d ORDER BY rank_member DESC", clanProps[playerid][CLAN_ID_PRIMARY]);
				new Cache:result = mysql_query(MySQL_CONNECTION, Query);
				if(cache_get_row_count(MySQL_CONNECTION) <= 1)
				{
					cache_delete(result, MySQL_CONNECTION);
					return SendClientMessage(playerid, -1, "{FFFF00}*** Error: no se puede mostrar porque no hay más miembros en tu clan.");
				}
				new PName[32];
				Query = "";
				for(new i = 1; i<cache_get_row_count(MySQL_CONNECTION)-1; i++)
				{
					cache_get_field_content(i, "name_member", PName, MySQL_CONNECTION, sizeof(PName));
					rango = cache_get_field_content_int(i, "rank_member", MySQL_CONNECTION);
					format(Query, sizeof(Query), "%s{FFFFFF}%s: %s\n", Query, clanRanksText[rango-1], PName);
				}
				cache_get_field_content(cache_get_row_count(MySQL_CONNECTION)-1, "name_member", PName, MySQL_CONNECTION, sizeof(PName));
				rango = cache_get_field_content_int(cache_get_row_count(MySQL_CONNECTION)-1, "rank_member", MySQL_CONNECTION);
				format(Query, sizeof(Query), "%s{FFFFFF}%s: {FFFFFF}%s", Query, clanRanksText[rango-1], PName);

				// Si en la lista seleccíonó en 'Modificar miembros' entonces -
				// Enviará esta lista, si no... será la de expulsar jugadores.
				if(listitem == 3)
				{
					SetPVarInt(playerid, "FilasClan", cache_get_row_count(MySQL_CONNECTION));
					cache_delete(result, MySQL_CONNECTION);
					return ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_RANKS_R1, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:", Query, "Seleccionar", "Cancelar");
				}
				ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_KICK_USER1, DIALOG_STYLE_LIST, "{FFFFFF}Configuración de tu Clan:", Query, "Expulsar", "Cancelar");
				SetPVarInt(playerid, "FilasClan", cache_get_row_count(MySQL_CONNECTION));
				cache_delete(result, MySQL_CONNECTION);
			}
    	}
	}
	// ANTITEAMKILL CLAN
	if(dialogid == CLAN_ADMINISTRATION_CHANGE_TEAMKILL)
   	{
   		static stringc[128], query[128];
   		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
   		switch(listitem)
   		{
			case 0:
			{
				format(stringc, sizeof(stringc), "{00FFFF}* <%s> %s habilitó el AntiTeamKill y ahora no se podrán hacer daño entre clan.", \
					clanProps[playerid][TAG], GET_PLAYER_NAME(playerid));
    			foreach(new i : Player)
				{
       				if(IsPlayerConnected(i))
         			{
          				if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
            			{
             				SendClientMessage(i, -1, stringc);
             				SetPlayerTeam(i, clanProps[i][CLAN_ANTITEAMKILL]);
							clanProps[i][CLAN_ANTITEAMKILL] = 1;
							sendNotificactionSound(i);
                		}
            		}
        		}
        		mysql_format(MySQL_CONNECTION, query, sizeof(query), "UPDATE clanes_groups SET enable_antiteamkill = '%d' WHERE id_clan ='%d'", \
        			clanProps[playerid][CLAN_ANTITEAMKILL], clanProps[playerid][CLAN_ID_PRIMARY]);
				mysql_query(MySQL_CONNECTION, query, false);
        	}
			case 1:
			{
				format(stringc, sizeof(stringc), "{00FFFF}* <%s> %s deshabilitó el AntiTeamKill y ahora podrán hacerse daño entre clan.", \
					clanProps[playerid][TAG], GET_PLAYER_NAME(playerid));
    			foreach(new i : Player)
				{
       				if(IsPlayerConnected(i))
         			{
          				if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
            			{
             				SendClientMessage(i, -1, stringc);
             				SetPlayerTeam(i, 0);
							clanProps[i][CLAN_ANTITEAMKILL] = 0;
							sendNotificactionSound(i);
                		}
            		}
        		}
        		mysql_format(MySQL_CONNECTION, query, sizeof(query), "UPDATE clanes_groups SET enable_antiteamkill = '%d' WHERE id_clan ='%d'", \
        			clanProps[playerid][CLAN_ANTITEAMKILL], clanProps[playerid][CLAN_ID_PRIMARY]);
				mysql_query(MySQL_CONNECTION, query, false);
			}
    	}
  	}
	// CHANGE SKIN CLAN
	if(dialogid == CLAN_ADMINISTRATION_CHANGE_SKIN)
   	{
   		static stringc[128], query[128];
   		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
   		{
			format(stringc, sizeof(stringc), "{00FFFF}* <%s> %s ha cambiado el skin del clan '%d'.", clanProps[playerid][TAG], GET_PLAYER_NAME(playerid), strval(inputtext));
    		foreach(new i : Player)
			{
       			if(IsPlayerConnected(i))
         		{
          			if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
            		{
             			SendClientMessage(i, -1, stringc);
                		clanProps[i][CLAN_SKIN] = strval(inputtext);
                		SetPlayerSkin(i, clanProps[i][CLAN_SKIN]);
                		sendNotificactionSound(i);
                	}
            	}
        	}
        	mysql_format(MySQL_CONNECTION, query, sizeof(query), "UPDATE clanes_groups SET clan_skin = '%d' WHERE id_clan ='%d'", strval(inputtext), clanProps[playerid][CLAN_ID_PRIMARY]);
			mysql_query(MySQL_CONNECTION, query, false);
    	}
  	}
	// CHANGE RANK USER
	if(dialogid == CLAN_ADMINISTRATION_RANKS_R1)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		new Query[800];
		mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT * FROM clans_members WHERE id_clan = %d ORDER BY rank_member DESC", clanProps[playerid][CLAN_ID_PRIMARY]);
		new Cache:result = mysql_query(MySQL_CONNECTION, Query);
		if(cache_get_row_count(MySQL_CONNECTION) != GetPVarInt(playerid, "FilasClan") || clanProps[playerid][CLAN_RANK] != 5)
		{
			SendClientMessage(playerid, -1, "{FFFF00}*** Ocurrio un error en la operación.");
			cache_delete(result, MySQL_CONNECTION);
			return 1;
		}
		new pName[32];
		cache_get_row(listitem+1, 1, pName, MySQL_CONNECTION, sizeof(pName));
		cache_delete(result, MySQL_CONNECTION);
		SetPVarString(playerid, "Modificar_A", pName);
		DeletePVar(playerid, "FilasClan");
		Query[0] = '\0';
		for(new i=0; i<4; i++)
			format(Query, sizeof(Query), "%s{FFFFFF}%s\n", Query, clanRanksText[i]);
		ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_RANKS_R2, DIALOG_STYLE_LIST, "{FFFFFF}Rangos Disponibles:", Query, "Seleccionar", "Cancelar");
	}
	if(dialogid == CLAN_ADMINISTRATION_RANKS_R2)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		new Query[130], name[128], Cache:result;
  		GetPVarString(playerid, "Modificar_A", name, sizeof(name));
  		cache_delete(result, MySQL_CONNECTION);
		mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "UPDATE clans_members SET rank_member = %d WHERE name_member = '%s'", listitem+1, name);
		result=mysql_query(MySQL_CONNECTION, Query);
		if(cache_affected_rows(MySQL_CONNECTION) == 0)
		{
			cache_delete(result, MySQL_CONNECTION);
			SendClientMessage(playerid, -1, "{FFFF00}*** Ocurrio un error en la operación.");
			return 1;
		}
		cache_delete(result, MySQL_CONNECTION);
		foreach(new i : Player)
		{
		    if(strIgual(name, GET_PLAYER_NAME(i)))
			clanProps[i][CLAN_RANK] = listitem+1;
		}
		format(name, sizeof(name), "{00FF00}* <%s> %s cambió el rango de %s a '%s'.", clanProps[playerid][FULL_NAME], GET_PLAYER_NAME(playerid), name, clanRanksText[listitem]);
		foreach(new i : Player)
		{
			if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
			SendClientMessage(i, -1, name);
		}
	}
	// KICK CLAN USER
	if(dialogid == CLAN_ADMINISTRATION_KICK_USER1)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		new Query[128];
		mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "SELECT * FROM clans_members WHERE id_clan = %d ORDER BY rank_member DESC", clanProps[playerid][CLAN_ID_PRIMARY]);
		new Cache:result = mysql_query(MySQL_CONNECTION, Query);
		if(cache_get_row_count(MySQL_CONNECTION) != GetPVarInt(playerid, "FilasClan") || clanProps[playerid][CLAN_RANK] != 5)
		{
			SendClientMessage(playerid, -1, "{FFFF00}*** Ocurrio un error en la operación.");
			cache_delete(result, MySQL_CONNECTION);
			return 1;
		}
		new pName[32];
		cache_get_row(listitem+1, 1, pName, MySQL_CONNECTION, sizeof(pName));
		cache_delete(result, MySQL_CONNECTION);
		SetPVarString(playerid, "Modificar_A", pName);
		DeletePVar(playerid, "FilasClan");
			format(Query, sizeof(Query), "{FFFFFF}¿Seguro/a de que quieres expulsar a '%s'?\n{FFFFFF}       Pulsa 'Acepto' para finalizar.", pName);
		ShowPlayerDialog(playerid, CLAN_ADMINISTRATION_KICK_USER2, DIALOG_STYLE_MSGBOX, "{FFFFFF}Expulsión del Clan:", Query, "Acepto", "Cancelar");
	}
	if(dialogid == CLAN_ADMINISTRATION_KICK_USER2)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(response)
		{
			case 1:
			{
				new Query[85], pname[32];
				GetPVarString(playerid, "Modificar_A", pname, sizeof(pname));

				// TODO: Estar seguro de que en la tabla de players no tengamos 'EnClan'
				// Si es así, entonces setearla en 0.
				mysql_format(MySQL_CONNECTION, Query, sizeof(Query), "DELETE FROM clans_members WHERE name_member = '%s'", pname);
				new Cache:result = mysql_query(MySQL_CONNECTION, Query);
				if(cache_affected_rows(MySQL_CONNECTION) == 0)
				{
					cache_delete(result, MySQL_CONNECTION);
					return SendClientMessage(playerid, -1, "{FFFF00}*** Hubo un error al expulsar al jugador, no existe en el clan.");
				}
				cache_delete(result, MySQL_CONNECTION);
				mysql_query(MySQL_CONNECTION, Query, false);
				foreach(new i : Player)
				{
					if(strIgual(pname, GET_PLAYER_NAME(i)))
					{
						SetPlayerTeam(i, 0);
						clanProps[i][FULL_NAME] = '\0';
						clanProps[i][TAG] = '\0';
						clanProps[i][CLAN_ID_NEXT] = 0;
						clanProps[i][CLAN_ID_PRIMARY] = 0;
						clanProps[i][CLAN_RANK] = 0;
						clanProps[i][CLAN_SKIN] = -1;
						clanProps[i][CLAN_COLOR] = 0;
						clanProps[i][CLAN_GANGZONECOLOR] = 0;
						clanProps[i][CLAN_ANTITEAMKILL] = 0;
						bitMask[i] &= ~ispInClan;
					    bitMask[i] &= ~ispClanLeader;
					    bitMask[i] &= ~ispClanSubLeader;
					    bitMask[i] &= ~ispClanRecluter;
						SendClientMessage(i, -1, "{00FFE2}*** Has sido expulsado de tu clan.");
					}
				}
				format(Query, sizeof(Query), "{00FFE2}* <%s> Clan: %s expulsó a %s del clan!", clanProps[playerid][FULL_NAME], GET_PLAYER_NAME(playerid), pname);
				foreach(new i : Player)
				{
					if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
					SendClientMessage(i, -1, Query);
				}
			}
		}
	}
		//MAINCOLORS
	if(dialogid == CLAN_ADMINISTRATION_CHANGE_COLOR)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ShowPlayerDialog(playerid, CLAN_CC_LIST1, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{FF7281}Rojo Opción 1\n{FF5D64}Rojo Opción 2\n{FF4558}Rojo Opción 3\n{FF3748}Rojo Opción 4\n{FF2632}Rojo Opción 5\n{FF0000}Rojo Opción 6\n{FF1921}Rojo Opción 7\n{FF0000}Rojo Opción 8\n{F50000}Rojo Opción 9\n{E80000}Rojo Opción 10\n{D30000}Rojo Opción 11\n{C00000}Rojo Opción 12\n{AF0000}Rojo Opción 13\n{A00000}Rojo Opción 14\n{930000}Rojo Opción 15\n{830000}Rojo Opción 16\n", "Aceptar", "Cancelar");}
			case 1: {ShowPlayerDialog(playerid, CLAN_CC_LIST2, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{FFA100}Naranja Opción 1\n{FF8300}Naranja Opción 2\n{FF7000}Naranja Opción 3\n{FF5B00}Naranja Opción 4\n{FF4800}Naranja Opción 5\n{FF3700}Naranja Opción 6\n", "Aceptar", "Cancelar");}
			case 2: {ShowPlayerDialog(playerid, CLAN_CC_LIST3, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{AFA17A}Café Opción 1\n{AF907A}Café Opción 2\n{AF827A}Café Opción 3\n{AF825D}Café Opción 4\n{AF6C5D}Café Opción 5\n{AF575D}Café Opción 6\n{88575D}Café Opción 7\n{D7AB95}Café Opción 8\n{A53200}Café Opción 9\n{A57C00}Café Opción 10\n{A53200}Café Opción 11\n", "Aceptar", "Cancelar");}
			case 3: {ShowPlayerDialog(playerid, CLAN_CC_LIST4, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{FFFFBC}Amarillo Opción 1\n{FFFF97}Amarillo Opción 2\n{FFFF6C}Amarillo Opción 3\n{FFFF56}Amarillo Opción 4\n{FFFF33}Amarillo Opción 5\n{FFFF16}Amarillo Opción 6\n{FFFF03}Amarillo Opción 7\n{FFE600}Amarillo Opción 8\n{EEE600}Amarillo Opción 9\n{EED000}Amarillo Opción 10\n{EEBA00}Amarillo Opción 11\n", "Aceptar", "Cancelar");}
			case 4: {ShowPlayerDialog(playerid, CLAN_CC_LIST5, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{BBFF00}Verde Opción 1\n{8FFF00}Verde Opción 2\n{5AFF00}Verde Opción 3\n{1BFF00}Verde Opción 4\n{00EF00}Verde Opción 5\n{00D500}Verde Opción 6\n{00A600}Verde Opción 7\n{009600}Verde Opción 8\n{007900}Verde Opción 9\n{00B549}Verde Opción 10\n{77BA50}Verde Opción 11\n{77FF50}Verde Opción 12\n{ABFF00}Verde Opción 13\n{00D4B3}Verde Opción 14\n", "Aceptar", "Cancelar");}
			case 5: {ShowPlayerDialog(playerid, CLAN_CC_LIST6, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{00FFD3}Celeste Opción 1\n{00FFE2}Celeste Opción 2\n{00FFF2}Celeste Opción 3\n{00EBFF}Celeste Opción 4\n{00BFFF}Celeste Opción 5\n{00A9FF}Celeste Opción 6\n{0093FF}Celeste Opción 7\n", "Aceptar", "Cancelar");}
			case 6: {ShowPlayerDialog(playerid, CLAN_CC_LIST7, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{0086FF}Azul Fuerte Opción 1\n{005FFF}Azul Fuerte Opción 2\n{0040FF}Azul Fuerte Opción 3\n{0017FF}Azul Fuerte Opción 4\n{0000CD}Azul Fuerte Opción 5\n", "Aceptar", "Cancelar");}
			case 7: {ShowPlayerDialog(playerid, CLAN_CC_LIST8, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{EB00FF}Violeta Opción 1\n{C400FF}Violeta Opción 2\n{9300FF}Violeta Opción 3\n{6A00FF}Violeta Opción 4\n{6A006F}Violeta Opción 5\n{CE83FF}Violeta Opción 6\n{9F73FF}Violeta Opción 7\n", "Aceptar", "Cancelar");}
			case 8: {ShowPlayerDialog(playerid, CLAN_CC_LIST9, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{FFD3FF}Rosa Opción 1\n{FFA4FF}Rosa Opción 2\n{FF6DFF}Rosa Opción 3\n{FF00FF}Rosa Opción 4\n{FF008F}Rosa Opción 5\n", "Aceptar", "Cancelar");}
			case 9: {ShowPlayerDialog(playerid, CLAN_CC_LIST10, DIALOG_STYLE_LIST, "{E9E200}Sistema de Clanes:", "{8178AE}Gris Opción 1\n{817896}Gris Opción 2\n{817872}Gris Opción 3\n{C4CDDC}Gris Opción 4\n", "Aceptar", "Cancelar");}
			case 10: {ClanColorChange(playerid, 0x46434EFF, 0x46434EAA);}
			case 11: {ClanColorChange(playerid, 0xEEF8F8FF, 0xEEF8F8AA);}
		}
	}
	//ROJOS
	if(dialogid == CLAN_CC_LIST1)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xFF7281FF, 0xFF7281AA);}
			case 1: {ClanColorChange(playerid, 0xFF5D64FF, 0xFF5D64AA);}
			case 2: {ClanColorChange(playerid, 0xFF4558FF, 0xFF4558AA);}
			case 3: {ClanColorChange(playerid, 0xFF3748FF, 0xFF3748AA);}
			case 4: {ClanColorChange(playerid, 0xFF2632FF, 0xFF2632AA);}
			case 5: {ClanColorChange(playerid, 0xFF0000FF, 0xFF0000AA);}
			case 6: {ClanColorChange(playerid, 0xFF1921FF, 0xFF1921AA);}
			case 7: {ClanColorChange(playerid, 0xFF0000FF, 0xFF0000AA);}
			case 8: {ClanColorChange(playerid, 0xF50000FF, 0xF50000AA);}
			case 9: {ClanColorChange(playerid, 0xE80000FF, 0xE80000AA);}
			case 10: {ClanColorChange(playerid, 0xD30000FF, 0xD30000AA);}
			case 11: {ClanColorChange(playerid, 0xC00000FF, 0xC00000AA);}
			case 12: {ClanColorChange(playerid, 0xAF0000FF, 0xAF0000AA);}
			case 13: {ClanColorChange(playerid, 0xA00000FF, 0xA00000AA);}
			case 14: {ClanColorChange(playerid, 0x930000FF, 0x930000AA);}
			case 15: {ClanColorChange(playerid, 0x830000FF, 0x830000AA);}
		}
	}
	//NARANJAS
	if(dialogid == CLAN_CC_LIST2)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xFFA100FF, 0xFFA100AA);}
			case 1: {ClanColorChange(playerid, 0xFF8300FF, 0xFF8300AA);}
			case 2: {ClanColorChange(playerid, 0xFF7000FF, 0xFF7000AA);}
			case 3: {ClanColorChange(playerid, 0xFF5B00FF, 0xFF5B00AA);}
			case 4: {ClanColorChange(playerid, 0xFF4800FF, 0xFF4800AA);}
			case 5: {ClanColorChange(playerid, 0xFF3700FF, 0xFF3700AA);}
		}
	}
	//CAFÉ
	if(dialogid == CLAN_CC_LIST3)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xAFA17AFF, 0xAFA17AAA);}
			case 1: {ClanColorChange(playerid, 0xAF907AFF, 0xAF907AAA);}
			case 2: {ClanColorChange(playerid, 0xAF827AFF, 0xAF827AAA);}
			case 3: {ClanColorChange(playerid, 0xAF825DFF, 0xAF825DAA);}
			case 4: {ClanColorChange(playerid, 0xAF6C5DFF, 0xAF6C5DAA);}
			case 5: {ClanColorChange(playerid, 0xAF575DFF, 0xAF575DAA);}
			case 6: {ClanColorChange(playerid, 0x88575DFF, 0x88575DAA);}
			case 7: {ClanColorChange(playerid, 0xD7AB95FF, 0xD7AB95AA);}
			case 8: {ClanColorChange(playerid, 0xA53200FF, 0xA53200AA);}
			case 9: {ClanColorChange(playerid, 0xA57C00FF, 0xA57C00AA);}
			case 10: {ClanColorChange(playerid, 0xA52E00FF, 0xA52E00AA);}
		}
	}
	//AMARILLO
	if(dialogid == CLAN_CC_LIST4)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xFFFFBCFF, 0xFFFFBCAA);}
			case 1: {ClanColorChange(playerid, 0xFFFF97FF, 0xFFFF97AA);}
			case 2: {ClanColorChange(playerid, 0xFFFF6CFF, 0xFFFF6CAA);}
			case 3: {ClanColorChange(playerid, 0xFFFF56FF, 0xFFFF56AA);}
			case 4: {ClanColorChange(playerid, 0xFFFF33FF, 0xFFFF33AA);}
			case 5: {ClanColorChange(playerid, 0xFFFF16FF, 0xFFFF16AA);}
			case 6: {ClanColorChange(playerid, 0xFFFF03FF, 0xFFFF03AA);}
			case 7: {ClanColorChange(playerid, 0xFFE600FF, 0xFFE600AA);}
			case 8: {ClanColorChange(playerid, 0xEEE600FF, 0xEEE600AA);}
			case 9: {ClanColorChange(playerid, 0xEED000FF, 0xEED000AA);}
			case 10: {ClanColorChange(playerid, 0xEEBA00FF, 0xEEBA00AA);}
		}
	}
	//VERDES
	if(dialogid == CLAN_CC_LIST5)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xBBFF00FF, 0xBBFF00AA);}
			case 1: {ClanColorChange(playerid, 0x8FFF00FF, 0x8FFF00AA);}
			case 2: {ClanColorChange(playerid, 0x5AFF00FF, 0x5AFF00AA);}
			case 3: {ClanColorChange(playerid, 0x5AFF00FF, 0x5AFF00AA);}
			case 4: {ClanColorChange(playerid, 0x1BFF00FF, 0x1BFF00AA);}
			case 5: {ClanColorChange(playerid, 0x00EF00FF, 0x00EF00AA);}
			case 6: {ClanColorChange(playerid, 0x00D500FF, 0x00D500AA);}
			case 7: {ClanColorChange(playerid, 0x00A600FF, 0x00A600AA);}
			case 8: {ClanColorChange(playerid, 0x009600FF, 0x009600AA);}
			case 9: {ClanColorChange(playerid, 0x007900FF, 0x007900AA);}
			case 10: {ClanColorChange(playerid, 0x00B549FF, 0x00B549AA);}
			case 11: {ClanColorChange(playerid, 0x77BA50FF, 0x77BA50AA);}
			case 12: {ClanColorChange(playerid, 0x77FF50FF, 0x77FF50AA);}
			case 13: {ClanColorChange(playerid, 0xABFF00FF, 0xABFF00AA);}
			case 14: {ClanColorChange(playerid, 0x00D4B3FF, 0x00D4B3AA);}
		}
	}
	//CELESTE
	if(dialogid == CLAN_CC_LIST6)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0x00FFD3FF, 0x00FFD3AA);}
			case 1: {ClanColorChange(playerid, 0x00FFE2FF, 0x00FFE2AA);}
			case 2: {ClanColorChange(playerid, 0x00FFF2FF, 0x00FFF2AA);}
			case 3: {ClanColorChange(playerid, 0x00EBFFFF, 0x00EBFFAA);}
			case 4: {ClanColorChange(playerid, 0x00BFFFFF, 0x00BFFFAA);}
			case 5: {ClanColorChange(playerid, 0x00A9FFFF, 0x00A9FFAA);}
			case 6: {ClanColorChange(playerid, 0x0093FFFF, 0x0093FFAA);}
		}
	}
	//AZUL FUERTE
	if(dialogid == CLAN_CC_LIST7)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0x0086FFFF, 0x0086FFAA);}
			case 1: {ClanColorChange(playerid, 0x005FFFFF, 0x005FFFAA);}
			case 2: {ClanColorChange(playerid, 0x0040FFFF, 0x0040FFAA);}
			case 3: {ClanColorChange(playerid, 0x0017FFFF, 0x0017FFAA);}
			case 4: {ClanColorChange(playerid, 0x0000CDFF, 0x0000CDAA);}
		}
	}
	//VIOLETA
	if(dialogid == CLAN_CC_LIST8)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xEB00FFFF, 0xEB00FFAA);}
			case 1: {ClanColorChange(playerid, 0xC400FFFF, 0xC400FFAA);}
			case 2: {ClanColorChange(playerid, 0x9300FFFF, 0x9300FFAA);}
			case 3: {ClanColorChange(playerid, 0x6A00FFFF, 0x6A00FFAA);}
			case 4: {ClanColorChange(playerid, 0x6A006FFF, 0x6A006FAA);}
			case 5: {ClanColorChange(playerid, 0xCE83FFFF, 0xCE83FFAA);}
			case 6: {ClanColorChange(playerid, 0x9F73FFFF, 0x9F73FFAA);}
		}
	}
	//ROSA
	if(dialogid == CLAN_CC_LIST9)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0xFFD3FFFF, 0xFFD3FFAA);}
			case 1: {ClanColorChange(playerid, 0xFFA4FFFF, 0xFFA4FFAA);}
			case 2: {ClanColorChange(playerid, 0xFF6DFFFF, 0xFF6DFFAA);}
			case 3: {ClanColorChange(playerid, 0xFF00FFFF, 0xFF00FFAA);}
			case 4: {ClanColorChange(playerid, 0xFF008FFF, 0xFF008FAA);}
		}
	}
	//GRIS
	if(dialogid == CLAN_CC_LIST10)
	{
		if(!response) return SendClientMessage(playerid, -1, "No has seleccionado ninguna opción.");
		switch(listitem)
		{
			case 0: {ClanColorChange(playerid, 0x8178AEFF, 0x8178AEAA);}
			case 1: {ClanColorChange(playerid, 0x817896FF, 0x817896AA);}
			case 2: {ClanColorChange(playerid, 0x817872FF, 0x817872AA);}
			case 3: {ClanColorChange(playerid, 0xC4CDDCFF, 0xC4CDDCAA);}
		}
	}
	return 1;
}

// ---------------
// REGISTER AND LOGIN SYSTEM
function wrongPasswordCount(playerid)
{
	if(wrongPasswordLimit[playerid] == 1) SendClientMessage(playerid, Rojo, "Has escrito una contraseña incorrecta, sólo tienes 3 intentos más o serás expulsado.");
	if(wrongPasswordLimit[playerid] == 2) SendClientMessage(playerid, Rojo, "Has escrito una contraseña incorrecta, sólo tienes 2 intentos más o serás expulsado.");
	if(wrongPasswordLimit[playerid] == 3) SendClientMessage(playerid, Rojo, "Has escrito una contraseña incorrecta, sólo tienes 1 intentos más o serás expulsado.");
	if(wrongPasswordLimit[playerid] == 4){
	    new stryng[120];
		wrongPasswordLimit[playerid] = 0;
		format(stryng, sizeof(stryng), "* %s ha sido kickeado por exceder intentos de inicio de sesión.", GET_PLAYER_NAME(playerid));
		SendClientMessageToAll(Rojo, stryng);
		GameTextForPlayer(playerid, "~n~~n~~r~~h~~h~Kickeado!", 2000000000000, 3);
		adminProps[playerid][KICK_TIME] = SetTimerEx("sendKickPlayer", 500, 1, "ii", playerid, playerid);
	}
	return 1;
}

stock getCurrentDate(playerid)
{
	// GET DATE - FORMAT DAY/MONTH/YEAR
    static currentDate[MAXPLAYERS][3];
    getdate(
    	currentDate[playerid][0], 
    	currentDate[playerid][1], 
    	currentDate[playerid][2]
    );

    static dateStr[32];
    format(dateStr, sizeof(dateStr), "%d/%s/%d", 
    	currentDate[playerid][2], 
    	LIST_MONTHS[currentDate[playerid][1]-1], 
    	currentDate[playerid][0]);
    return dateStr;
}

stock strIgual(const string[], const string2[])
{
	if(strlen(string) != strlen(string2))
	    return false;
	if(strlen(string) <= 1 || strlen(string2) <= 1)
	    return false;
	new i = 0;
	while (i < strlen(string))
	{
	    if(string[i] != string2[i])
	        return false;
		i++;
	}
	return true;
}

stock SetTimerXP(playerid, idtimer, string[], time)
{
	Timer[playerid][idtimer] = SetTimerEx(string, time, false, "d", playerid);
	return 1;
}

stock KillTimerEx(playerid, idtimer)
{
	KillTimer(Timer[playerid][idtimer]);
	return 1;
}

stock GET_PLAYER_NAME(playerid){
    new FULL_USERNAME[MAX_PLAYER_NAME];
    GetPlayerName(playerid, FULL_USERNAME, sizeof(FULL_USERNAME));
    return FULL_USERNAME;
}


function registerUser(playerid, password[])
{
	static getIP_USER[16], getDate_USER[MAX_PLAYERS][3];
    format(myString, sizeof(myString), "{00D200}Fecha de registro: '%s'.", getCurrentDate(playerid));
    SendClientMessage(playerid, -1, "{00D200}Felicidades te has registrado en nuestro servidor correctamente. A continuación tus datos:");
    SendClientMessage(playerid, -1, myString);
    SendClientMessage(playerid, -1, "{00D200}* No olvides usar: /comandos[1-4] o /ayuda para ver la lista completa de comandos disponibles!");

	new Query[256];
    GetPlayerIp(playerid, getIP_USER, sizeof(getIP_USER));
    getdate(getDate_USER[playerid][0], getDate_USER[playerid][1], getDate_USER[playerid][2]);
    format(Query, sizeof(Query), "INSERT INTO `players` (username, password, ip, register_day, register_month, register_year) VALUES ('%s', '%s', '%s', '%d', '%d', '%d')", 
    	GET_PLAYER_NAME(playerid), 
    	password, 
    	getIP_USER,
    	getDate_USER[playerid][2], 
		getDate_USER[playerid][1], 
		getDate_USER[playerid][0]
	);
    mysql_function_query(MySQL_CONNECTION, Query, true, "OnQueryFinish", "ii", 0, playerid);

    bitMask[playerid] |= ispRegisted;
    return 1;
}

function getUserData(playerid, const bool:isStartGame)
{
	new query[350], string_clan[128], Cache: result;

	// CHECK IF THE PLAYER HAS STARTED THE GAME OR JOINED A CLAN.
	if(isStartGame)
	{
		SetCameraBehindPlayer(playerid);
		bitMask[playerid] |= ispLogged;
		bitMask[playerid] |= ispRegisted;
		SpawnPlayer(playerid);
	}

	// Verificamos si el jugador forma parte de un clan.
	mysql_format(MySQL_CONNECTION, query, sizeof(query), "SELECT id_clan, rank_member FROM clans_members WHERE name_member = '%s'", GET_PLAYER_NAME(playerid));
	result = mysql_query(MySQL_CONNECTION, query);
	if(cache_get_row_count(MySQL_CONNECTION) != 0)
	{
		static getClanSkin, getClanColor, getClanAntiKillTeam, getClanColorGang, getClanName[32], getClanTag[5];

		clanProps[playerid][CLAN_ID_PRIMARY] = 			cache_get_row_int(0, 0, MySQL_CONNECTION);
		clanProps[playerid][CLAN_RANK] = 				cache_get_row_int(0, 1, MySQL_CONNECTION);
		cache_delete(result, MySQL_CONNECTION);

		mysql_format(MySQL_CONNECTION, query, sizeof(query), 
			"SELECT clan_color, clan_skin, enable_antiteamkill, clan_name, clan_gangzone_color, clan_tag FROM clanes_groups WHERE id_clan = %d", \
			clanProps[playerid][CLAN_ID_PRIMARY]);

		result = mysql_query(MySQL_CONNECTION, query);

		// USER CLAN DATA
		getClanColor = 									cache_get_row_int(0, 0, MySQL_CONNECTION);
		getClanSkin = 									cache_get_row_int(0, 1, MySQL_CONNECTION);
		getClanAntiKillTeam = 							cache_get_row_int(0, 2, MySQL_CONNECTION);
		getClanColorGang = 								cache_get_row_int(0, 4, MySQL_CONNECTION);

		cache_get_field_content(0, "clan_name", getClanName, MySQL_CONNECTION, sizeof(getClanName));
		strmid(clanProps[playerid][FULL_NAME], getClanName, 0, 23, 23);

		cache_get_field_content(0, "clan_tag", getClanTag, MySQL_CONNECTION, sizeof(getClanTag));
		strmid(clanProps[playerid][TAG], getClanTag, 0, 17, 17);

		if(getClanColor != -1)
		{
			clanProps[playerid][CLAN_COLOR] = getClanColor;
			SetPlayerColor(playerid, getClanColor);
		}
		if(getClanSkin != -1)
		{
			clanProps[playerid][CLAN_SKIN] = getClanSkin;
			SetPlayerSkin(playerid, getClanSkin);
		} 
		if(getClanAntiKillTeam > 1)
		{
			clanProps[playerid][CLAN_ANTITEAMKILL] = getClanAntiKillTeam;
			SetPlayerTeam(playerid, getClanAntiKillTeam);
		}
		clanProps[playerid][CLAN_GANGZONECOLOR] = getClanColorGang; 

		// SET CLAN RANKS
		bitMask[playerid] |= ispInClan;
		switch(clanProps[playerid][CLAN_RANK])
		{
			case 5: bitMask[playerid] |= ispClanLeader;
			case 4: bitMask[playerid] |= ispClanSubLeader;
			case 3: bitMask[playerid] |= ispClanRecluter;
		}

		if(isStartGame)
		{
			format(string_clan, sizeof(string_clan), "{59FF00}<%s> Clan: %s(%d) inició sesión como %s del clan.", \
				clanProps[playerid][TAG], GET_PLAYER_NAME(playerid), playerid, clanRanksText[clanProps[playerid][CLAN_RANK]-1]);
			sendClanMessage(clanProps[playerid][CLAN_ID_PRIMARY], string_clan);
		}
		else 
		{
			// Si el jugador se unió al clan envia este mensaje.
			format(string_clan, sizeof(string_clan), "{00FFE2}* %s(id:%d) se ha unido a %s!", GET_PLAYER_NAME(playerid), playerid, clanProps[playerid][FULL_NAME]);
			sendClanMessage(clanProps[playerid][CLAN_ID_PRIMARY], string_clan);
		}
		
	}
	else
	{
		//TODO: Revisar esto porque se envia aunque no haya un error.
		SendClientMessage(playerid, Rojo, "*** Ocurrió un error innesperado, contacta a un administrador. Código de error: 0x100000.");
		print("[SERVER-LOG] Ocurrió un problema al cargar la información, código de error: 0x100000");
	}
	return 1;
}

function RevisarPlayer(playerid)
{
	new Query[256];
    format(Query, sizeof(Query), "SELECT * FROM `players` WHERE username='%s'", GET_PLAYER_NAME(playerid));
    mysql_function_query(MySQL_CONNECTION, Query, true, "OnQueryFinish", "ii",2, playerid);
    KillTimerEx(playerid, 1);
    return 1;
}

forward OnQueryFinish(resultid, extraid, ConnectionHandle);
public OnQueryFinish(resultid, extraid, ConnectionHandle)
{
    new Rows, Field;
    if(resultid != 0)
    {
        cache_get_data(Rows, Field);
    }
    switch(resultid)
    {
    	case 1:
    	{
        	if(Rows == 1)
        	{
            	static content[20], string_IP[32];
            	cache_get_field_content(0,"ip", string_IP);					strmid(playerProps[extraid][IP], string_IP, 0, strlen(string_IP), 50);
            	cache_get_field_content(0, "kills", content); 				playerProps[extraid][KILLS] = strval(content);
            	cache_get_field_content(0, "deaths", content); 				playerProps[extraid][DEATHS] = strval(content);
            	cache_get_field_content(0, "score", content); 				playerProps[extraid][SCORE] = strval(content);
            	cache_get_field_content(0, "money", content); 				playerProps[extraid][MONEY] = strval(content);
            	cache_get_field_content(0, "skin", content); 				playerProps[extraid][SKIN] = strval(content) || -1;
            	cache_get_field_content(0, "clan", content); 				playerProps[extraid][IS_INCLAN] = strval(content);
            	cache_get_field_content(0, "admin", content); 				playerProps[extraid][ADMIN] = strval(content);
	        }
            else if(!Rows)
            {
               print("[MySQL-INFO] Ocurrió un error al recuperar la información de un usuario.");
            }
        }
        case 2:
        {
            if(Rows == 1)
            {
            	static currentIP[16], lastConnection[MAX_PLAYERS][3], tempQUERY[128], content[20], string_IP[32];
                // TODO: ------- ESTO ES PROVICIONAL, DESPUES HACEMOS UNOS CAMPOS QUE REGISTREN LA ULTIMA FECHA DE INGRESO AL SERVER, ESTE SOLO ES LA FECHA DE REGISTRO DE LA CUENTA.
                cache_get_field_content(0,"ip", string_IP);
            	strmid(playerProps[extraid][IP], string_IP, 0, strlen(string_IP), 50);
                cache_get_field_content(0, "register_day", content); 		lastConnection[extraid][0] = strval(content);
                cache_get_field_content(0, "register_month", content); 		lastConnection[extraid][1] = strval(content);
                cache_get_field_content(0, "register_year", content); 		lastConnection[extraid][2] = strval(content);
                cache_get_field_content(0, "admin", content); 				playerProps[extraid][ADMIN] = strval(content);
				GetPlayerIp(extraid, currentIP, sizeof(currentIP));
				if(playerProps[extraid][ADMIN] >= 1){
					static temp[50];
					cache_get_field_content(0,"password", temp);
            		strmid(playerProps[extraid][PASSWORD], temp, 0, strlen(temp), 50);
					bitMask[extraid] |= ispRegisted;
					bitMask[extraid] |= ispAdmin;
					adminProps[extraid][COUNTDOWN_LOGIN] = 60;
					startCountDownAdminAccount[extraid] = SetTimerEx("countDownAdminAccount", 1500, true, "i", extraid);
					format(temp, sizeof(temp), "{FF5BD3}'%s' {FFFFFF}es una cuenta registrada, por favor\n{FF5BD3}* Ingresa tu contraseña para iniciar sesión\n", GET_PLAYER_NAME(extraid));
					return ShowPlayerDialog(extraid, IDENTIFICATION_SIGN_IN, DIALOG_STYLE_INPUT, 
						"{FFFFFF}Iniciar sesión:", 
						temp,
						"Aceptar","Kick");
				}
				if(!strcmp(currentIP, playerProps[extraid][IP], true))
				{
		    		new stringTT[110];
					format(stringTT, sizeof(stringTT), "{00DEFF}* %s bienvenido de nuevo tu última conexión fue el %d/%s/%d.", GET_PLAYER_NAME(extraid), lastConnection[extraid][0], LIST_MONTHS[lastConnection[extraid][1]], lastConnection[extraid][2]);
					SendClientMessage(extraid, -1, stringTT);
					SendClientMessage(extraid, -1, "{00DEFF} Posees el autologin activado, fuiste automaticamente spawneado.");
					SendClientMessage(extraid, -1, "{FFFFFF} Recuerda que si no deseas tener activo el auto-login puedes escribir: /noautologin.");
					bitMask[extraid] |= ispRegisted;
					bitMask[extraid] |= ispLogged;
					format(tempQUERY, sizeof(tempQUERY), "SELECT * FROM `players` WHERE `username` = '%s'", GET_PLAYER_NAME(extraid));
                	mysql_function_query(MySQL_CONNECTION, tempQUERY, true, "OnQueryFinish", "ii", 1, extraid);
                	getUserData(extraid, true);
				}
				else
				{
					static temp[50];
					cache_get_field_content(0,"password", temp);
            		strmid(playerProps[extraid][PASSWORD], temp, 0, strlen(temp), 50);
					bitMask[extraid] |= ispRegisted;
					format(temp, sizeof(temp), "{FF5BD3}'%s' {FFFFFF}es una cuenta registrada, por favor\n{FF5BD3}* Ingresa tu contraseña para iniciar sesión\n", GET_PLAYER_NAME(extraid));
					ShowPlayerDialog(extraid, IDENTIFICATION_SIGN_IN, DIALOG_STYLE_INPUT, 
						"{FFFFFF}Iniciar sesión:", 
						temp,
						"Aceptar","Kick");
				}
			}
	        else if(!Rows)
	        {
				SendClientMessage(extraid, -1, "{00DEFF} Bienvenido a VirtualZone Freeroam/DM - Versión 1.0!");
	        	SendClientMessage(extraid, -1, "{00DEFF}* No estás registrado en nuestro servidor, escribe: /register para crear una cuenta nueva.");
				SendClientMessage(extraid, -1, "{00DEFF} Recuerda que si no te registras tu progreso(EXP, Dinero y más) no se guardarán.");
	    	}
		}
	}
    return 1;
}

function countDownAdminAccount(playerid)
{
	new stryng[120], getIP[16];
	if(adminProps[playerid][COUNTDOWN_LOGIN] >= 2)
	{
		adminProps[playerid][COUNTDOWN_LOGIN] -= 1;
	}
	else if(adminProps[playerid][COUNTDOWN_LOGIN] == 1)
	{
	    KillTimer(startCountDownAdminAccount[playerid]);
        PlayerTextDrawHide(playerid, SignIn_TextDraw_CountDown[playerid]);
        PlayerTextDrawDestroy(playerid, SignIn_TextDraw_CountDown[playerid]);
        GameTextForPlayer(playerid, "~n~~n~~r~~h~~h~Kickeado!", 2000000000000, 3);
        SendClientMessage(playerid, Rojo, "* Has superado el tiempo máximo de inicio de sesión.");
		GetPlayerIp(playerid, getIP, sizeof(getIP));
		format(stryng, sizeof(stryng), "* AdminInfo: %s fue kickeado por no iniciar sesión con cuenta admin. - [IP: %s].", GET_PLAYER_NAME(playerid), getIP);
		sendAdminInfoMessage(stryng);
		adminProps[playerid][KICK_TIME] = SetTimerEx("sendKickPlayer", 500, 1, "ii", playerid, playerid);
	}
	format(stryng, sizeof(stryng), "_~n~Inicia sesion:~n~ %d segundos", adminProps[playerid][COUNTDOWN_LOGIN]);
	PlayerTextDrawSetString(playerid, SignIn_TextDraw_CountDown[playerid], stryng);
	PlayerTextDrawShow(playerid, SignIn_TextDraw_CountDown[playerid]);
	return 1;
}

function sendKickPlayer(playerid, player)
{
	KillTimer(adminProps[playerid][KICK_TIME]);
	Kick(player);
	return 1;
}

stock ClanColorChange(playerid, ColorRGB, GangZoneColor)
{
    new query[100], Cache:result, stringc[128];
	mysql_format(MySQL_CONNECTION, query, sizeof(query), "SELECT id_clan, rank_member FROM clans_members WHERE name_member = '%s'", GET_PLAYER_NAME(playerid));
	result = mysql_query(MySQL_CONNECTION, query);
	if(cache_get_row_count(MySQL_CONNECTION) != 0)
	{
		cache_delete(result, MySQL_CONNECTION);
	    mysql_format(MySQL_CONNECTION, query, sizeof(query), "UPDATE clanes_groups SET clan_color = '%d', clan_gangzone_color = '%d' WHERE id_clan ='%d'", \
	    	ColorRGB, GangZoneColor, clanProps[playerid][CLAN_ID_PRIMARY]);
		mysql_query(MySQL_CONNECTION, query, false);
		format(stringc, sizeof(stringc), "* <%s> Clan: %s(id:%d) cambió el color del clan!", clanProps[playerid][FULL_NAME], GET_PLAYER_NAME(playerid), playerid);
 		foreach(new i : Player)
		{
  			if(IsPlayerConnected(i))
      		{
     			if(clanProps[i][CLAN_ID_PRIMARY] == clanProps[playerid][CLAN_ID_PRIMARY])
           		{
 					SendClientMessage(i, ColorRGB, stringc);
             		sendNotificactionSound(i);
             		SetPlayerColor(i, ColorRGB);
             		clanProps[i][CLAN_COLOR] = GetPlayerColor(i);
       			}
        	}
    	}
    }
	cache_delete(result, MySQL_CONNECTION);
	return 1;
}

stock sendAdminInfoMessage(const string[])
{
	foreach(new adminid: Player)
	{
		if (playerProps[adminid][ADMIN] >= 1 && bitMask[adminid] & ispAdmin)
		{
			SendClientMessage(adminid, Gris4, string);
		}
	}
	return 1;
}

stock sendClanMessage(const clanid, const string[])
{
	foreach(new i: Player)
	{
		if(IsPlayerConnected(i))
         {
			if (clanProps[i][CLAN_ID_PRIMARY] == clanid && bitMask[i] & ispInClan)
			{
				SendClientMessage(i, Gris4, string);
			}
		}
	}
}

stock sendNotificactionSound(playerid)
{
    PlayerPlaySound(playerid, 1139, 0.0, 0.0, 0.0);
}


public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	//if(Administrador[playerid] >= 1){
    SetPlayerPosExV(playerid, Float:fX, Float:fY, Float:fZ);
    //return 1;
    //}

//    if(Vip[playerid] >= 1){
  //  SetPlayerPosExV(playerid, Float:fX, Float:fY, Float:fZ);
    //return 1;
	//}
    return 1;
}

stock SetPlayerPosExV(playerid, Float:x,Float:y,Float:z)
{
	new cartype = GetPlayerVehicleID(playerid); new State = GetPlayerState(playerid); new Float:Angulo; Angulo = GetVehicleZAngle(cartype, Angulo);
	if(State!=PLAYER_STATE_DRIVER)
	{
		SetPlayerPos(playerid,x,y,z); SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
		SetVehicleZAngle(cartype, Angulo+1);
	}
	else if(IsPlayerInVehicle(playerid, cartype) == 1)
	{
		SetVehiclePos(cartype,x,y,z); SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
	 	SetVehicleZAngle(cartype, Angulo+1);
	 	LinkVehicleToInterior(cartype, GetPlayerInterior(playerid));
	    SetVehicleVirtualWorld(cartype, GetPlayerVirtualWorld(playerid));
	} else {
		SetPlayerPos(playerid,x,y,z); SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
	}
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

stock createTextDraws()
{
		Fugazer_Layout[0] = TextDrawCreate(-3.0, 429.0, "a");
    TextDrawBackgroundColor(Fugazer_Layout[0], 255);
    TextDrawFont(Fugazer_Layout[0], 1);
    TextDrawLetterSize(Fugazer_Layout[0], -0.389999, 0.999999);
    TextDrawColor(Fugazer_Layout[0], 4095);
    TextDrawSetOutline(Fugazer_Layout[0], 0);
    TextDrawSetProportional(Fugazer_Layout[0], 1);
    TextDrawSetShadow(Fugazer_Layout[0], 1);
    TextDrawUseBox(Fugazer_Layout[0], 1);
    TextDrawBoxColor(Fugazer_Layout[0], 5803);
    TextDrawTextSize(Fugazer_Layout[0], 660.0, 13.0);
    TextDrawSetSelectable(Fugazer_Layout[0], 0);

    Fugazer_Layout[1] = TextDrawCreate(-3.0, 441.0, "a");
    TextDrawBackgroundColor(Fugazer_Layout[1], 255);
    TextDrawFont(Fugazer_Layout[1], 1);
    TextDrawLetterSize(Fugazer_Layout[1], -0.389999, 0.999999);
    TextDrawColor(Fugazer_Layout[1], 4095);
    TextDrawSetOutline(Fugazer_Layout[1], 0);
    TextDrawSetProportional(Fugazer_Layout[1], 1);
    TextDrawSetShadow(Fugazer_Layout[1], 1);
    TextDrawUseBox(Fugazer_Layout[1], 1);
    TextDrawBoxColor(Fugazer_Layout[1], 8638);
    TextDrawTextSize(Fugazer_Layout[1], 660.0, 13.0);
    TextDrawSetSelectable(Fugazer_Layout[1], 0);

    Fugazer_Layout[2] = TextDrawCreate(287.0, 426.0, "fugazer");
    TextDrawBackgroundColor(Fugazer_Layout[2], -721366590);
    TextDrawFont(Fugazer_Layout[2], 3);
    TextDrawLetterSize(Fugazer_Layout[2], 0.519999, 1.899999);
    TextDrawColor(Fugazer_Layout[2], -16733953);
    TextDrawSetOutline(Fugazer_Layout[2], 0);
    TextDrawSetProportional(Fugazer_Layout[2], 1);
    TextDrawSetShadow(Fugazer_Layout[2], 2);
    TextDrawSetSelectable(Fugazer_Layout[2], 0);

    Fugazer_Layout[3] = TextDrawCreate(317.000000, 438.000000, "Freeroam");
	TextDrawBackgroundColor(Fugazer_Layout[3], 156106683);
	TextDrawFont(Fugazer_Layout[3], 3);
	TextDrawLetterSize(Fugazer_Layout[3], 0.240000, 1.099999);
	TextDrawColor(Fugazer_Layout[3], 160432127);
	TextDrawSetOutline(Fugazer_Layout[3], 0);
	TextDrawSetProportional(Fugazer_Layout[3], 1);
	TextDrawSetShadow(Fugazer_Layout[3], 2);
	TextDrawSetSelectable(Fugazer_Layout[3], 0);

    Fugazer_Layout[4] = TextDrawCreate(132.0, 438.0, "/comandos - /teles - /juegos - /derby");
    TextDrawBackgroundColor(Fugazer_Layout[4], 255);
    TextDrawFont(Fugazer_Layout[4], 2);
    TextDrawLetterSize(Fugazer_Layout[4], 0.18, 1.0);
    TextDrawColor(Fugazer_Layout[4], -1);
    TextDrawSetOutline(Fugazer_Layout[4], 0);
    TextDrawSetProportional(Fugazer_Layout[4], 1);
    TextDrawSetShadow(Fugazer_Layout[4], 0);
    TextDrawSetSelectable(Fugazer_Layout[4], 0);

    Fugazer_Layout[5] = TextDrawCreate(361.0, 439.0, "kills: 955 mil - deaths: 997 mil - ratio: 0.98");
    TextDrawBackgroundColor(Fugazer_Layout[5], 255);
    TextDrawFont(Fugazer_Layout[5], 3);
    TextDrawLetterSize(Fugazer_Layout[5], 0.2, 0.999999);
    TextDrawColor(Fugazer_Layout[5], -1);
    TextDrawSetOutline(Fugazer_Layout[5], 0);
    TextDrawSetProportional(Fugazer_Layout[5], 1);
    TextDrawSetShadow(Fugazer_Layout[5], 1);
    TextDrawSetSelectable(Fugazer_Layout[5], 0);

    Fugazer_Layout[6] = TextDrawCreate(282.0, 428.0, "Usa: /deathmatch para unirte al mapa The Ship TDM");
    TextDrawAlignment(Fugazer_Layout[6], 3);
    TextDrawBackgroundColor(Fugazer_Layout[6], 255);
    TextDrawFont(Fugazer_Layout[6], 2);
    TextDrawLetterSize(Fugazer_Layout[6], 0.18, 1.0);
    TextDrawColor(Fugazer_Layout[6], -1);
    TextDrawSetOutline(Fugazer_Layout[6], 0);
    TextDrawSetProportional(Fugazer_Layout[6], 1);
    TextDrawSetShadow(Fugazer_Layout[6], 0);
    TextDrawSetSelectable(Fugazer_Layout[6], 0);
}

strtok(const string[], &index)
{
   new length = strlen(string);
   while ((index < length) && (string[index] <= ' '))
   {
      index++;
   }
   new offset = index;
   new result[20];
   while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
   {
      result[index - offset] = string[index];
      index++;
   }
   result[index - offset] = EOS;
   return result;
}