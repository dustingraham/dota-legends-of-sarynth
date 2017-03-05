// Even if the code is not re-executed, if a javascript file with a Game.AddCommand
// is recompiled mid-game, the command completely breaks.

// They even need their own independent XML file. As just throwing it in as an
// include in the custom_ui_manifest.xml file will cause it to break.

// Hence, their relegation to isolation here.

function WrapFunction(name) {
    return function() {
        Game[name]();
    };
}

Game.AddCommand("+CustomGameInventory", WrapFunction("CustomOnPressedInventory"), "", 0);
Game.AddCommand("-CustomGameInventory", WrapFunction("CustomOnReleasedInventory"), "", 0);
