module minexewgames.engine.InputInterface;

import std.stdint;

enum// VkeyType_t
{
    VKEY_NONE,          // null input
    VKEY_ANALOG,        // joystick/gamepad analog
    VKEY_JOYBTN,        // joystick/gamepad buttons, triggers
    VKEY_KEY,           // keyboard
    VKEY_MOUSEBTN,      // mouse button
    VKEY_SPECIAL        // special vkeys (see below)
};

// int16_t Vkey_t::key for VKEY_SPECIAL
enum
{
    SPECIAL_CLOSE_WINDOW
};

// Vkey_t: 8 bytes
struct Vkey_t
{
    int16_t type,       // one of VkeyType_t
            device,     // device index (unique among same VkeyType_t) or -1 if any/unspecified/not applicable
            key,        // key index, button index, analog axis (unique among one device)
            subkey;     // sub-key index (actual meaning varies)
};

// VkeyState_t: 16 bytes
struct VkeyState_t
{
    Vkey_t  vkey;
    int     flags,      // VKEY_VALUE_CHANGED is only applicable to VKEY_ANALOG
            value;      // currently only applicable to VKEY_ANALOG
                        // always 0..32767, subkey determines actual direction (+1/-1)
};

interface InputInterface {
    bool getVkeyEventPrelim(VkeyState_t* ev_out);
}
