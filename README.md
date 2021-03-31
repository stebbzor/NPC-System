# NPC System

This is a very simple NPC system created for developers to use in whatever case they need it. It's still a WIP and I've really just put about 2 hours into this but the plan is to eventually have a UI system that people can utilize and probably need to add exports so that you can add NPC's through other resources.

But usage as of right now is as simple as making a new file in the **npcs/** folder and follow the _example.lua_ file.

I've always wanted to make resources to release publically and this'll be a step towards that. This resource shouldn't effect your FPS at all and uses "RegisterKeyMapping" and Raycasting to handle interactions. This was all created in FxDK.

```lua
local exampleNPC = {}
-- Name of the NPC
exampleNPC.name = "Mrs. Someone"
-- Description of the NPC
exampleNPC.desc = "I'm so descriptive"
-- Definitive location (Make sure you get the height right)
exampleNPC.location = vector3(1602.390, 6623.020, 14.835)
-- Heading of the NPC (Where it's facing)
exampleNPC.heading = 90
-- If set to true then it'll play a "Hello" from the NPC when you interact with it
exampleNPC.greetingSound = true
-- Model used for the NPC (https://docs.fivem.net/docs/game-references/ped-models/)
exampleNPC.model = "a_f_m_fatwhite_01"
-- Default animation the NPC is in. (List of animations: https://www.pastebin.com/6mrYTdQv)
exampleNPC.anim = "WORLD_HUMAN_GUARD_PATROL"

-- This function is called when the NPC is loaded and initialized.
exampleNPC.init = function(pEntity)

end

-- This function is called when the +st_npcInteraction bind is called when facing the NPC within 5 units. (Default Button is: E)
-- pEntity is the entity itself
-- pName is the name you set above
-- pDesc is the description you set above.
exampleNPC.onUse = function(pEntity, pName, pDesc)
    TriggerEvent('chat:addMessage', {
        color = {255, 50, 50},
        multiline = true,
        args = {pName, "Stop touching me.."}
    })

    -- Here you can do some interesting triggers.
end

NPCS:Register(exampleNPC)
```
