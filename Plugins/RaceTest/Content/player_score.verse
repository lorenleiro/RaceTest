using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }   
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }

# A Verse-authored creative device that can be placed in a level
player_score := class(creative_device):
    @editable
    var PlayerScore : int = 0
    @editable
    HudMessage : hud_message_device = hud_message_device{}
    PlayerMessage<localizes>(ScoreDisplay:int) : message = "Player speed: {ScoreDisplay}"
    @editable
    GoldGranter : item_granter_device = item_granter_device{}

    OnBegin<override>()<suspends> : void =
        spawn {InitializeCheckpoints()}
        SubscribeTargetDummyEvent()
        

    InitializeCheckpoints()<suspends> : void =
        TaggedActors := GetCreativeObjectsWithTag(checkpoint_win{})
        for(TaggedActor : TaggedActors, WinCheckpoint := race_checkpoint_device[TaggedActor]):
            WinCheckpoint.CheckpointCompletedEvent.Subscribe(OnPlayerTouch)

    OnPlayerTouch(Player : agent) : void =
        set PlayerScore = PlayerScore + 1
        
        HudMessage.SetDisplayTime(0.5)
        HudMessage.SetText(PlayerMessage(PlayerScore))
        HudMessage.Show(Player)

                    

    UpdateScore() : void =
        set PlayerScore = PlayerScore + 1
        HudMessage.SetDisplayTime(0.5)
        HudMessage.SetText(PlayerMessage(PlayerScore))
        HudMessage.Show()
        PlayerMessage(PlayerScore)

        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (Player : player = AllPlayers[0]):
         if (FortniteCharacter : fort_character = Player.GetFortCharacter[]):
            if(Agent := FortniteCharacter.GetAgent[]):
                GoldGranter.GrantItem(Agent)

    SubscribeTargetDummyEvent() : void =
        TaggedActors := GetCreativeObjectsWithTag(dummy_target{})
        for(TaggedActor : TaggedActors, Dummy := shooting_range_target_device[TaggedActor]):
            Dummy.HitEvent.Subscribe(UpdateScore)
