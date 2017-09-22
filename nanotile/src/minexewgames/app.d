
module minexewgames.app;

import minexewgames.di;
import minexewgames.di.Proxy;
import minexewgames.engine;
import minexewgames.engineimpl.EngineImpl;

import minexewgames.n3d2.Renderer;

import minexewgames.ntile.MainMenu;

import std.conv;
import std.stdio;
import std.stream;

import minexewgames.cfx2.node;

class Game {
    @Autowired DisplayInterface di;

    @Autowired Proxy!Scene scene;
    @Autowired MainLoop mainLoop;

    @Autowired Renderer r;

    void run() {
        di.createWindow();
        
        r.startup();

        scene.instance = diGet!MainMenu;
        mainLoop.run();
    }
}

void startup() {
    //try {
        // Inject Scene as a proxy so that we can swap it at runtime
        diProvidedBy!(Scene, Proxy!Scene);

        Engine engine = diGet!Engine;
        engine.startup();

        (diGet!Game).run();
    /*}
    catch (Exception e) {
        std.stdio.writeln(e.msg);
    }*/
}

void shutdown() {
    try {
        Engine engine = diGet!Engine;
        engine.shutdown();
    }
    catch (Exception e) {
        std.stdio.writeln(e.msg);
    }
}

void dumpNode(Node node) {
    writef("<%s=%s", node.name, node.text);
    foreach (attrib; node.attributes) {
        writef(" %s=%s", attrib.name, attrib.value);
    }
    writeln(">");
    foreach (child ; node.children)
        dumpNode(child);
        writefln("</%s>", node.name);
}

void main(string[] args) {	
    startup();
    shutdown();
}
