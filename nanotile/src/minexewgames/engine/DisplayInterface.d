module minexewgames.engine.DisplayInterface;

import minexewgames.framework.types;

interface DisplayInterface {
    void createWindow();
    void flip();
    ivec2 getViewportSize();
}
