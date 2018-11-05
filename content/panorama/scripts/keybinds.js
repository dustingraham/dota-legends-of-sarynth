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

function CCKBind(key, funcName) {
    Game.CreateCustomKeyBind(key, funcName);
    Game.AddCommand(funcName, WrapFunction(funcName), '', 0);
}

CCKBind('n', 'KeyInventoryToggle');
CCKBind('p', 'KeyFocusToggle');

//CCKBind('j', 'KeySomethingToggle');

// Game.CreateCustomKeyBind('n', 'KeyInventoryToggle');
// Game.AddCommand('KeyInventoryToggle', WrapFunction('KeyInventoryToggle'), '', 0);
//
// Game.CreateCustomKeyBind('j', 'KeyFocusToggle');
// Game.AddCommand('KeyFocusToggle', WrapFunction('KeyFocusToggle'), '', 0);

// Game.CreateCustomKeyBind("h", "+npress");
// Game.AddCommand( "+npress", function() {
//     $.Msg("n up");
//     $.Msg('alt: ', GameUI.IsAltDown());
// }, "", 0 );
// Game.AddCommand( "-npress", function() {
//     $.Msg("n down");
//     $.Msg('alt: ', GameUI.IsAltDown());
// }, "", 0 );

// Game.AddCommand("+CustomGameInventory", WrapFunction("CustomOnPressedInventory"), "", 0);
// Game.AddCommand("-CustomGameInventory", WrapFunction("CustomOnReleasedInventory"), "", 0);
