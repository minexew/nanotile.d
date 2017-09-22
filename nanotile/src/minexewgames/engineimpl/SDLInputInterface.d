module minexewgames.engineimpl.SDLInputInterface;

import minexewgames.engine;

import minexewgames.engineimpl.SDLConnector;

import std.c.stdlib;

class SDLInputInterface : InputInterface {
    override bool getVkeyEventPrelim(VkeyState_t* ev_out) {
        SDL_Event ev;

        while (SDL_PollEvent(&ev)) {
            switch (ev.type) {
                case SDL_QUIT:
                    ev_out.vkey.type = VKEY_SPECIAL;
                    ev_out.vkey.key = SPECIAL_CLOSE_WINDOW;
                    return true;

                default:
                    {}
            }
        }

        return false;
    }
}
