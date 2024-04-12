# <p align="center"> YimActions </p>
<p align="center"> Play GTA V Animations &amp; Scenarios Using YimMenu </p>

![Screenshot 2024-02-08 040632](https://github.com/xesdoog/YimActions/assets/66764345/9bdde22d-0efa-4d6c-8385-6c0be1d79a99)

![YimActions-modified](https://github.com/YimMenu-Lua/YimActions/assets/66764345/d6628ede-4a83-4f0e-a901-3ae648794f58)

![YimActions(4)](https://github.com/xesdoog/YimActions/assets/66764345/e26f12c0-d1de-41ea-a2c1-df23c79deb8b)

> [!NOTE]
> From now on, this will be the main script. It contains both [SAMURAI's Scenarios](https://github.com/YimMenu-Lua/SAMURAI-Scenarios) and [SAMURAI's Animations](https://github.com/YimMenu-Lua/SAMURAI-Animations) so the standalone scripts will not be updated any further. All new updates will be in this repo.

## Setup:

1. Go to the [Releases](https://github.com/xesdoog/YimActions/releases) tab and download the latest version of YimActions.
2. Unzip the archive and place both **YimActions.lua** and **animdata.lua** in YimMenu's scripts folder which is located at:
######
    %AppData%\YimMenu\scripts

## Usage:

- **Animations:**

  - Playing animations using the script UI:
    1. Open **YimActions** and select the ![image](https://github.com/xesdoog/YimActions/assets/66764345/b976c1f7-0fd2-4fac-ae66-1a978dcf9874) tab at the top.
    2. Select an animation from the list then press **Play**.
    3. Once you're done, you can either pres **Stop** to stop the animation and delete any spawned props and/or particle effects, or you can simply press **[G]** on keyboard / **[DPAD Left]** on controller to do the same thing without opening the menu. If you want to drop the props instead of deleting them, you can open the UI and press **Remove Attachments**. This button also helps if a prop gets stuck and fails to be removed.
    4. **Optional:** If you want to change the animation behavior, enable **Edit Flags** before playing the animation and set your desired settings.

  - Playing animations using hotkeys:
    1. Open **YimActions** and select the ![image](https://github.com/xesdoog/YimActions/assets/66764345/02e85706-2e79-4e84-aa42-38a5d0da22ed) tab at the top.

    2. Check the ![image](https://github.com/xesdoog/YimActions/assets/66764345/802ca62f-184c-45d6-af53-35694c7f59f5) option.
    3. You can now close the UI and navigate through the list of animations by pressing ![icons8-page-down-button-16](https://github.com/xesdoog/YimActions/assets/66764345/bf56e0a5-72bd-4f26-9e9d-728897792002) **[PAGE DOWN]** and ![icons8-page-up-button-32](https://github.com/xesdoog/YimActions/assets/66764345/a9108737-d1bd-4db5-aae5-fe0702af05e1) **[PAGE UP]** and play the selected animation by pressing **[DEL]** on keyboard or ✖️ on controller. This option will save for the next script load but using these hotkeys will require you to initiate YimActions once by simply opening the script UI and closing it.

   - Playing animations on NPCs:
     1. Open **YimActions** and select the ![image](https://github.com/xesdoog/YimActions/assets/66764345/b976c1f7-0fd2-4fac-ae66-1a978dcf9874) tab at the top.
     2. Select an NPC from the dropdown list at the bottom then press spawn. This NPC will now follow you everywhere and will wait for you outside if you go into an interior.
     3. Select an animation from the list and pres **Play On NPC** at the bottom. You can play the same animation on yourself or select a different one.
        > *NOTE: This is still a work in progress so expect to encounter a few bugs.*
     4. You can play every animation on an NPC that's sitting inside your car by adjusting the animation flags if needed. Example: if an animation plays on the full body like dancing anims for example, enable **Edit Flags** and select *Loop* and *Upper Body* so the NPC can still play it while sitting in your vehicle.

- **Scenarios:**
  - You can only play scenarios using the UI:
    1. Open **YimActions** and select the ![image](https://github.com/xesdoog/YimActions/assets/66764345/e61e675b-b41e-406b-9e0f-846290d374fa) tab at the top.
    2. Select a scenario from the list then press **Play**.
    3. Once you're done, you can either press **Stop** to stop the scenario or simply press **[G]** on keyboard / **[DPAD Left]** on controller to do the same thing without opening the menu.
       > *NOTE: You cannot control scenario props. Scenarios are different from animations.*

## Known Issues:

- Some particle effects are not visible to other players. I will probably fix them later but I'm quickly losing passion.
- If you are not host of the session, you will occasionally lose control over some spawned NPCs if you spawn more than one or two. Those NPCs will not follow you anymore and you can no longer delete them using the script.

## Credits:

- [ShinyWasabi](https://github.com/ShinyWasabi) 
   - Taught me how to write a proper [search function](https://www.unknowncheats.me/forum/3979688-post5.html) that disables game input while typing. Thank you! ❤️

- [Lonelybud](https://github.com/lonelybud) 
   - Taught me how not to crash the game everytime I pressed a button 😭 I had no idea what the [fiber pool](https://github.com/YimMenu-Lua/SAMURAI-Scenarios/issues/1) was...

- [Deadlineem](https://github.com/deadlineem)
   - Gave useful feedback on scenarios and also was there whenever I asked for insight in UC forum.

- [Harmless](https://github.com/Harmless05) 
   - Wrote a very neat config system for [Harmless's Scripts](https://github.com/YimMenu-Lua/Harmless-Scripts). So neat in fact that I stole it! 😸
