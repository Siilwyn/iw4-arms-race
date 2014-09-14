// Arms Race by Siilwyn
// Thanks to the community at http://itsmods.com/

// https://github.com/Siilwyn/iw4-arms-race/
// Version 0.0

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallBacks();
    maps\mp\gametypes\_globallogic::SetupCallBacks();

    registerTimeLimitDvar(level.gameType, 10, 0, 1440);
    registerScoreLimitDvar(level.gameType, 500, 0, 5000);
    registerRoundLimitDvar(level.gameType, 1, 0, 10);
    registerWinLimitDvar(level.gameType, 1, 0, 10);
    registerRoundSwitchDvar(level.gameType, 3, 0, 30);
    registerNumLivesDvar(level.gameType, 0, 0, 10);
    registerHalfTimeDvar(level.gameType, 0, 0, 1);

    level.teamBased = true;
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
    level.onPlayerKilled = ::onPlayerKilled;

    game["dialog"]["gametype"] = "tm_death";

    if(getDvarInt("g_hardcore"))
        game["dialog"]["gametype"] = "hc_tm_death";
    else if(getDvarInt("camera_thirdPerson"))
        game["dialog"]["gametype"] = "thirdp_tm_death";

    game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
}

onStartGameType()
{
    setClientNameMode("auto_change");

    if(!isdefined(game["switchedsides"]))
        game["switchedsides"] = false;

    if(game["switchedsides"])
    {
        oldAttackers = game["attackers"];
        oldDefenders = game["defenders"];
        game["attackers"] = oldDefenders;
        game["defenders"] = oldAttackers;
    }

    setObjectiveText("allies", "Eliminate the enemy.");
    setObjectiveText("axis", "Eliminate the enemy.");
    setObjectiveScoreText("allies", "Kill enemies to advance your weapon rank. First to get a kill with the last weapon wins.");
    setObjectiveScoreText("axis", "Kill enemies to advance your weapon rank. First to get a kill with the last weapon wins.");
    setObjectiveHintText("allies", "Master your arsenal.");
    setObjectiveHintText("axis", "Master your arsenal.");

    setDvarIfUninitialized("scr_ar_vampirism", 0);

    level.vampirism = getDvarInt("scr_ar_vampirism");

    setDvar("ui_gametype", "Arms Race");
    setDvar("didyouknow", "Arms Race modification made by Siilwyn. ^0(0.0)");

    setDvar("scr_war_timelimit", 15);
    setDvar("scr_war_scorelimit", 26);

    level.highestWeaponIndex = [];
    level.highestWeaponIndex["allies"] = 0;
    level.highestWeaponIndex["axis"] = 0;

    level.spawnMins = (0, 0, 0);
    level.spawnMaxs = (0, 0, 0);
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_allies_start");
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_axis_start");
    maps\mp\gametypes\_spawnlogic::addSpawnPoints("allies", "mp_tdm_spawn");
    maps\mp\gametypes\_spawnlogic::addSpawnPoints("axis", "mp_tdm_spawn");
    level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins, level.spawnMaxs);
    setMapCenter(level.mapCenter);

    allowed[0] = "war";
    allowed[1] = "airdrop_pallet";
    maps\mp\gametypes\_gameobjects::main(allowed);

    level thread onPlayerConnect();
    setSpecialLoadouts();
}

onPlayerConnect()
{
    while(!level.gameEnded)
    {
        level waittill("connected", player);

        player.firstSpawn = true;
        player.weaponIndex = 0;

        player setClientDvar("cg_scoreboardPingGraph", 0);
        player setClientDvar("cg_scoreboardPingText", 1);
        player setClientDvar("cg_fovScale", 1.125);

        player notifyOnPlayerCommand("use_description", "+actionslot 1");

        player thread toggleDescription();
    }
}

setSpecialLoadouts()
{
    level.weapons = [];
    level.weapons[0] = "mp5k";
    level.weapons[1] = "uzi";
    level.weapons[2] = "kriss";
    level.weapons[3] = "m79";
    level.weapons[4] = "ump45";
    level.weapons[5] = "p90";
    level.weapons[6] = "spas12";
    level.weapons[7] = "striker";
    level.weapons[8] = "m1014";
    level.weapons[9] = "model1887";
    level.weapons[10] = "scar";
    level.weapons[11] = "famas";
    level.weapons[12] = "ak47";
    level.weapons[13] = "m4";
    level.weapons[14] = "fal";
    level.weapons[15] = "aug";
    level.weapons[16] = "cheytac";
    level.weapons[17] = "m240";
    level.weapons[18] = "mg4";
    level.weapons[19] = "glock";
    level.weapons[20] = "coltanaconda";
    level.weapons[21] = "tmp";
    level.weapons[22] = "usp";
    level.weapons[23] = "deserteagle";
    level.weapons[24] = "pp2000";
    level.weapons[25] = "beretta";
    level.weapons[26] = "throwingknife";
}

toggleDescription()
{
    self endon("disconnect");

    self.descriptionElem = createDescription();
    self.inMenu = false;

    while(!level.gameEnded)
    {
        self waittill("use_description");

        if(!self.inMenu)
        {
            self.inMenu = true;

            self setClientDvar("ui_drawcrosshair", 0);

            self.descriptionElem fadeOverTime(1);
            self.descriptionElem.alpha = 0.75;
            self.descriptionElem.title fadeOverTime(1);
            self.descriptionElem.title.alpha = 1;
            self.descriptionElem.titleSub fadeOverTime(1);
            self.descriptionElem.titleSub.alpha = 1;
            self.descriptionElem.content fadeOverTime(1);
            self.descriptionElem.content.alpha = 1;
            self.descriptionElem.content2 fadeOverTime(1);
            self.descriptionElem.content2.alpha = 1;
        }
        else if(self.inMenu)
        {
            self.inMenu = false;

            self setClientDvar("ui_drawcrosshair", 1);
            self setWaterSheeting(1, 2);

            self.descriptionElem fadeOverTime(0.8);
            self.descriptionElem.alpha = 0;
            self.descriptionElem.title fadeOverTime(0.8);
            self.descriptionElem.title.alpha = 0;
            self.descriptionElem.titleSub fadeOverTime(0.8);
            self.descriptionElem.titleSub.alpha = 0;
            self.descriptionElem.content fadeOverTime(0.8);
            self.descriptionElem.content.alpha = 0;
            self.descriptionElem.content2 fadeOverTime(0.8);
            self.descriptionElem.content2.alpha = 0;
        }
    }
}

createDescription()
{
    containerElem = newClientHudElem(self);
    containerElem.elemType = "bar";
    containerElem.width = 300;
    containerElem.height = 300;
    containerElem.color = (0, 0, 0);
    containerElem.alpha = 0;
    containerElem.children = [];
    containerElem setParent(level.uiParent);
    containerElem setShader("black", 1000, 1000);
    containerElem setPoint("CENTER", "CENTER", 0, 0);

    containerElem.title = createFontString("bigfixed", 0.8);
    containerElem.title.point = "TOPLEFT";
    containerElem.title.xOffset = 10;
    containerElem.title.yOffset = 7;
    containerElem.title.alpha = 0;
    containerElem.title setParent(containerElem);
    containerElem.title setText("Arms Race ^80.0");

    containerElem.titleSub = createFontString("default", 0.8);
    containerElem.titleSub.point = "TOPLEFT";
    containerElem.titleSub.xOffset = 11;
    containerElem.titleSub.yOffset = 25;
    containerElem.titleSub.alpha = 0;
    containerElem.titleSub setParent(containerElem);
    containerElem.titleSub setText("By Siilwyn.");

    containerElem.content = createFontString("default", 1.0);
    containerElem.content.point = "TOPLEFT";
    containerElem.content.xOffset = 11;
    containerElem.content.yOffset = 45;
    containerElem.content.alpha = 0;
    containerElem.content setParent(containerElem);
    containerElem.content setText("Arms race is a gun-progression mode featuring instant respawning and a ton of close-quarter combat.\nPlayers gain new weapons immediately after registering a kill as they work their way through each weapon in the game.");

    containerElem.content2 = createFontString("default", 1.0);
    containerElem.content2.point = "TOPLEFT";
    containerElem.content2.xOffset = 11;
    containerElem.content2.yOffset = 80;
    containerElem.content2.alpha = 0;
    containerElem.content2 setParent(containerElem);
    containerElem.content2 setText("Get a kill with the final weapon and win the match.");

    return containerElem;
}

getSpawnPoint()
{
    if(self.firstSpawn)
    {
        self.firstSpawn = false;
        self closeMenus();
        self.pers["class"] = "gamemode";
        self.pers["lastClass"] = "";
        self.class = self.pers["class"];
        self.lastClass = self.pers["lastClass"];
        self thread maps\mp\gametypes\_playerlogic::spawnClient();
    }

    spawnTeam = self.pers["team"];
    if(game["switchedsides"])
        spawnTeam = getOtherTeam(spawnTeam);

    if(level.inGracePeriod)
    {
        spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_tdm_spawn_" + spawnTeam + "_start");
        spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnPoints);
    }
    else
    {
        spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints(spawnTeam);
        spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnPoints);
    }

    return spawnPoint;
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId)
{
    if(isPlayer(attacker) && attacker != self && sMeansOfDeath != "MOD_MELEE")
    {
        attacker.weaponIndex++;
        attacker thread giveOneWeapon(level.weapons[attacker.weaponIndex]);

        if(attacker.weaponIndex > 26)
        {
            attacker.finalKill = true;
            maps\mp\gametypes\_gamelogic::endGame(attacker.team, "Mastered the arsenal");
        }
    }
    else if(self.weaponIndex > 0)
    {
        self.weaponIndex--;
    }

    updateTeamscores();
}

giveOneWeapon(weapon)
{
    self takeAllWeapons();
    weaponMp = weapon + "_mp";
    self giveWeapon(weaponMp, 0, false);
    wait (0.10);
    self switchToWeapon(weaponMp, 0, false);
}

updateTeamscores()
{
    foreach(player in level.players)
    {
        if(player.weaponIndex > level.highestWeaponIndex[player.team])
            level.highestWeaponIndex[player.team] = player.weaponIndex;
    }

    game["teamScores"]["allies"] = level.highestWeaponIndex["allies"];
    setTeamScore("allies", level.highestWeaponIndex["allies"]);
    game["teamScores"]["axis"] = level.highestWeaponIndex["axis"];
    setTeamScore("axis", level.highestWeaponIndex["axis"]);
}
