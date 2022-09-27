#pragma semicolon 1

public Plugin myinfo = 
{
	name = "MOTD Profile",
	author = "enderG aka Young <",
	version = "1.0.0"
};

public void OnPluginStart()
{
    RegConsoleCmd("profile", Command_Profile, "Opens the player selection menu");
    RegConsoleCmd("myprofile", Command_MyProfile, "Opens the caller profile");

    LoadTranslations("motdprofile.phrases");
}

public Action Command_Profile(int iClient, int iArgs) 
{
    char 
        sName[MAX_NAME_LENGTH],
        sId[8];

    SetGlobalTransTarget(iClient);

    Menu hMenu = new Menu(Handler_hMenu, MenuAction_End|MenuAction_Select);
    hMenu.SetTitle("%t:\n ", "menu_select_a_player");

    for (int i = 1; i <= MaxClients; i++)
	{
        if(IsClientInGame(i) && !IsFakeClient(i) && GetClientName(i, sName, sizeof sName))
        {
            IntToString(i, sId, sizeof sId);
            hMenu.AddItem(sId, sName);
        }
    }

    hMenu.Display(iClient, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public Action Command_MyProfile(int iClient, int iArgs) 
{
    QueryClientConVar(iClient, "cl_disablehtmlmotd", OpenProfile, iClient);

    return Plugin_Handled;
}

public int Handler_hMenu(Menu hMenu, MenuAction action, int iClient, int iItem)
{
    switch(action)
    {
        case MenuAction_End:
        {
            delete hMenu;
        }
        case MenuAction_Select:
        {
            char sId[8];
            hMenu.GetItem(iItem, sId, sizeof sId);
            QueryClientConVar(iClient, "cl_disablehtmlmotd", OpenProfile, StringToInt(sId));
        }
    }
}

public void OpenProfile(QueryCookie cookie, int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any iTarget)
{
    if(StringToInt(cvarValue))
    {
        PrintToChat(iClient, "%T", "motd_error", iClient);
        return;
    }

    if(!IsClientInGame(iTarget))
    {
        PrintToChat(iClient, "%T", "player_left", iClient);
        return;
    }

    char sBuff[64];
    GetClientAuthId(iTarget, AuthId_SteamID64, sBuff, sizeof sBuff);
    Format(sBuff, sizeof sBuff, "http://steamcommunity.com/profiles/%s", sBuff);
    ShowMOTDPanel(iClient, sBuff, sBuff, MOTDPANEL_TYPE_URL);
}