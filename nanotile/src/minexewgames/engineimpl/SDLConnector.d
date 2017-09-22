module minexewgames.engineimpl.SDLConnector;

public import derelict.opengl3.gl3;
public import derelict.sdl2.image;
public import derelict.sdl2.sdl;

import minexewgames.di;

class SDLConnector {
    @Initializer
    void init() {
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        DerelictGL3.load();

        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_NOPARACHUTE);
    }
    
    void glContextCreated() {
        DerelictGL3.reload();
    }
}
