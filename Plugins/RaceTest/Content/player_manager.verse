using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }   
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }

# A Verse-authored creative device that can be placed in a level
player_manager := class(creative_device):

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{FindPlayers()}

    FindPlayers()<suspends> : void =
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        for(FortniteCharacter : AllPlayers):
            PlayerScore : player_score = player_score{}