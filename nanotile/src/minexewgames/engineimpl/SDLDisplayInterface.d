module minexewgames.engineimpl.SDLDisplayInterface;

import minexewgames.di;
import minexewgames.engine;
import minexewgames.engineimpl;
import minexewgames.framework.types;

import minexewgames.engineimpl.SDLConnector;

import std.conv;
import std.stdio;

class SDLDisplayInterface : DisplayInterface {
    enum configNode = "Display";

    @Config {
        ivec2 resolution;
    }

    @Autowired SDLConnector sdl;

    SDL_Window* window;

    override void createWindow() {
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
        SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);
        
        window = SDL_CreateWindow("Minexew Games Engine",
                SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                resolution.x, resolution.y,
                SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
        assert(window != null);
        
        SDL_GLContext glcontext = SDL_GL_CreateContext(window);
        assert(glcontext != null);
        
        sdl.glContextCreated();
    }

    override void flip() {
        SDL_GL_SwapWindow(window);
    }
    
    override ivec2 getViewportSize() {
        return resolution;
    }
}
