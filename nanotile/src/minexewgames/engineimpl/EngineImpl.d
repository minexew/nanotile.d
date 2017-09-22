
module minexewgames.engineimpl.EngineImpl;

import minexewgames.di;
import minexewgames.engine;
import minexewgames.engineimpl;
import minexewgames.engineimpl.SDLall;

class EngineImpl : Engine {
    @Autowired Logger logger;
    @Autowired MainLoop mainLoop;

    this() {
        diProvidedBy!(ConfigurationManager, ConfigurationManagerImpl);
        diProvidedBy!(Logger, LoggerImpl);
        diProvidedBy!(ResourceManager, ResourceManagerImpl);
        diProvidedBy!(System, SystemImpl);
        
        // SDL
        diProvidedBy!(DisplayInterface, SDLDisplayInterface);
        diProvidedBy!(InputInterface, SDLInputInterface);
        diProvidedBy!(MainLoop, SDLMainLoop);
    }

    override void startup() {
        logger.log(LogLevel.always, "Engine", "Minexew Games Engine TRUNK");
        logger.log(LogLevel.always, "Engine", "Copyright (c) 2014 Minexew Games");
    }

    override void shutdown() {
        logger.log(LogLevel.always, "Engine", "Engine shut down.");
    }
}

static this() {
    diProvidedBy!(Engine, EngineImpl);
}
