#include <sourcemod>

#pragma newdecls required

Handle g_PlayersTimers[MAXPLAYERS+1];
ConVar g_cvProtectTime;

public Plugin myinfo = {
    name        = "BuyZone Protect",
    author      = "Ramón Berrutti",
    description = "Protect some seconds players inside the buyzone",
    version     = "1.0",
    url         = "https://ramonberrutti.com"
}

public void OnPluginStart() {

    g_cvProtectTime = CreateConVar("buyzone_protect_time", "10.0", "Sets whether my plugin is enabled");

    HookEvent("enter_buyzone", OnEvent_EnterBuyzone, EventHookMode_Post);
    HookEvent("exit_buyzone", OnEvent_ExitBuyzone, EventHookMode_Post);
}

public void OnClientDisconnect(int client)
{
	if( g_PlayersTimers[client] != null )
	{
		KillTimer(g_PlayersTimers[client]);
		g_PlayersTimers[client] = null;
	}
}

public Action OnEvent_EnterBuyzone(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId( event.GetInt("userid") );
    
    if( client > 0 && g_PlayersTimers[client] == null ) {
        g_PlayersTimers[client] = CreateTimer(g_cvProtectTime.FloatValue, OnTimerTrigger, client );
        SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
        PrintToChat(client, "[\x02BuyZone - Protect\x01] You have entered \x02BuyZone\01, you are \x02protected\x01 from any damage!");
    }
}

public Action OnEvent_ExitBuyzone(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId( event.GetInt("userid") );

    if( client > 0 && g_PlayersTimers[client] != null ) {
        KillTimer(g_PlayersTimers[client]);
        g_PlayersTimers[client] = null;
        PrintToChat(client, "[\x02BuyZone - Protect\x01] You are \x04unprotected\x01 from any damage!");
        SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
    }
}

public Action OnTimerTrigger(Handle timer, int client) {
    g_PlayersTimers[client] = null;
    PrintToChat(client, "[\x02BuyZone - Protect\x01] You are \x04unprotected\x01 from any damage!");
    SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}