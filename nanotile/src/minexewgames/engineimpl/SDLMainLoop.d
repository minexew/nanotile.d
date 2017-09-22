module minexewgames.engineimpl.SDLMainLoop;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.engineimpl.SDLConnector;

class SDLMainLoop : MainLoop {
    override void run() {
        for (stopped = false; !stopped; ) {
            frame();
            SDL_Delay(16);
        }
    }

    override void stop() {
        stopped = true;
    }

    // FIXME: Where does this method belong?
    void frame() {
        scene.onFrame();
        scene.onDraw();

        di.flip();  // belongs here? rly?
    }

    bool stopped;

    @Autowired DisplayInterface di;
    @Autowired Logger logger;
    @Autowired Scene scene;
}
