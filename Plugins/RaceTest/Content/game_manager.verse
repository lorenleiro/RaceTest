using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }   
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}

dummy_target := class(tag){}
checkpoint_win := class(tag){}

# A Verse-authored creative device that can be placed in a level
game_manager := class(creative_device):

    @editable
    FreetimeTime : float = 10.0
    @editable
    ClickTime : float = 15.0
    @editable
    RaceCountdownTime : float = 3.0
    @editable 
    RaceTime :float = 30.0
    @editable
    HudMessage : hud_message_device = hud_message_device{}
    @editable
    RaceManager : race_manager_device = race_manager_device{}
    @editable
    RaceStartTimer : timer_device = timer_device{}

    @editable
    RaceDoorBarrierBlock : barrier_device = barrier_device{}
    @editable
    Teleporter : teleporter_device = teleporter_device{}

    PlayerMessage<localizes>(MessageDisplay:string) : message = "{MessageDisplay}"
    var MaybeUIPlayer : [player]?text_block = map{}
    IDLEText<localizes> : message = "Free time"
    ClickText<localizes> : message = "Click time"
    CountdownText<localizes> : message = "Countdown"
    RaceText<localizes> : message = "Race"

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{GameLoop()}

    GameLoop()<suspends> : void =
        spawn{FreetimeState()}
        Sleep(FreetimeTime)
        spawn{ClickState()}
        Sleep(ClickTime)
        spawn{CountdownState()}

    FreetimeState()<suspends> : void =
        Print("Free time state")
        RaceDoorBarrierBlock.Enable()
        SetGameTimer(FreetimeTime)
        UpdatePlayersUI(IDLEText)
        ToggleAllDummys(false)
        HudMessage.SetDisplayTime(FreetimeTime)
        HudMessage.SetText(PlayerMessage("Free time!"))
        HudMessage.Show()

    ClickState()<suspends> : void =
        Print("Click time state")
        SetGameTimer(ClickTime)
        UpdatePlayersUI(ClickText)
        ToggleAllDummys(true)
        HudMessage.SetDisplayTime(ClickTime)
        HudMessage.SetText(PlayerMessage("Click to gain speed"))
        HudMessage.Show()
    
    CountdownState()<suspends> : void =
        Print("Countdown time state")
        UpdatePlayersUI(CountdownText)
        ToggleAllDummys(false)
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (Player : player = AllPlayers[0]):
         if (FortniteCharacter : fort_character = Player.GetFortCharacter[]):
            if(Agent : agent = FortniteCharacter.GetAgent[]):
                SetGameTimer(RaceCountdownTime)
                Sleep(RaceCountdownTime)
                spawn{StartRace()}

    StartRace()<suspends> : void =
        Print("Race starts")
        RaceDoorBarrierBlock.Disable()
        SetGameTimer(RaceTime)
        UpdatePlayersUI(RaceText)
        RaceManager.Begin();
        Sleep(RaceTime)
        Print("Race ends")
        RaceManager.End()
        TeleportPlayersBack()
        spawn{GameLoop()}

    ToggleAllDummys(Toggle : logic)<suspends> : void =
        TaggedActors := GetCreativeObjectsWithTag(dummy_target{})
        for(TaggedActor : TaggedActors, Dummy := shooting_range_target_device[TaggedActor]):
            if(Toggle?):
                Dummy.Enable()
            else:
                Dummy.Disable()

    SetGameTimer(Time : float) : void =
        RaceStartTimer.SetMaxDuration(Time)
        RaceStartTimer.Reset()
        RaceStartTimer.Start()

    UpdateUI(Agent :agent, UIText : message) : void =
        if(InPlayer := player[Agent], PlayerUI := GetPlayerUI[InPlayer]):
            if(MyUI := MaybeUIPlayer[InPlayer]?): # Check first if a UI already exist and remove it
                PlayerUI.RemoveWidget(MyUI)
                if(set MaybeUIPlayer[InPlayer] = false){}

            # Create the new UI text
            NewUI : text_block = text_block{DefaultText := UIText}
            PlayerUI.AddWidget(NewUI)
            if (set MaybeUIPlayer[InPlayer] = option{NewUI}) {}

    UpdatePlayersUI(UIText : message) : void =
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (Player : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = Player.GetFortCharacter[]):
                if(PlayerAgent := FortniteCharacter.GetAgent[]):
                    UpdateUI(PlayerAgent, UIText)

    CreateMyUI(UIText : message) : canvas =
        MyCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := button_loud{DefaultText := UIText}
                
        return MyCanvas

    TeleportPlayersBack() : void =
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (Player : player = AllPlayers[0]):
         if (FortniteCharacter : fort_character = Player.GetFortCharacter[]):
            if(Agent : agent = FortniteCharacter.GetAgent[]):
                Teleporter.Teleport(Agent)