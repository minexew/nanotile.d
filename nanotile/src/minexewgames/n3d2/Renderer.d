module minexewgames.n3d2.Renderer;

public import minexewgames.framework.types;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.VertexArray;

import std.conv;

enum AttrLoc {
    position = 0,
    normal = 1,
    color = 2,
    uv = 3,
}

align(16)
struct Vertex1 {
    @Location(AttrLoc.position)
    vec3 pos;

    @Location(AttrLoc.color) @Normalized
    byte4 rgba;

    @Location(AttrLoc.uv)
    vec2 uv;
}

static assert(Vertex1.sizeof == 32);

class Renderer {
    VertexArray immedVertexArray;
    RenderingContext immedContext;
    @Autocreated Camera immedCam;
    
    @Autowired DisplayInterface di;
    @Autowired Logger logger;
    
    ResourceManager resMgr;
    
    ShaderProgram bound;
    ShaderProgram basic;

    GLuint activeTexture;

    void startup() {
        initOpenGL();
        
        auto view = di.getViewportSize();
        glViewport(0, 0, view.x, view.y);
        check();
        
        logger.log(LogLevel.info, "Renderer", "OpenGL Version: " ~ to!string(glGetString(GL_VERSION))
            ~ "; " ~ to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
        logger.log(LogLevel.info, "Renderer", "OpenGL: " ~ to!string(glGetString(GL_RENDERER))
            ~ " [" ~ to!string(glGetString(GL_VENDOR)) ~ "]");
        
        immedVertexArray = diNew!VertexArray();
        immedVertexArray.initVertexType!Vertex1();
        // FIXME: use own ResMgr
        basic = createResourceFromRecipe!ShaderProgram(null, "path=n3d2/shaders/basic");
        
        //immedCam.setOrthoScreenSpace(-1.0f, 1.0f);
        immedContext = diNew!RenderingContext(basic);
    }
    
    void initOpenGL() {
    	immutable auto c = RGB.darkGrey;
    	glClearColor(c.r / 255.0f, c.g / 255.0f, c.b / 255.0f, 0.0f);
    	
    	glEnable(GL_BLEND);
    	diGet!RenderingState.setVariable(RenderingStateVariable.blendMode, BlendMode.alpha);
    }
    
    Vertex1* vertices(uint count) {
        return immedVertexArray.allocLive!Vertex1(count);
    }
    
    void useProgram(ShaderProgram prog) {
        glUseProgram(prog.program);
        bound = prog;
    }
    
    void check(string file = __FILE__, size_t line = __LINE__) {
        auto err = glGetError();
        
        if (err != GL_NO_ERROR)
            throw new Exception(to!string(err), file, line);
    }
    
    void clear() {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    void flush() {
        if (immedVertexArray.empty())
            return;
        
        immedContext.setup(immedCam);
        
        immedVertexArray.install();
        immedVertexArray.draw(PrimitiveMode.triangles);
        check();
        
        immedContext.teardown();
        
        immedVertexArray.clear();
    }
    
    GLuint getActiveTexture() {
        return activeTexture;
    }
    
    Camera getImmedCamera() {
        return immedCam;
    }
    
    RenderingContext getImmedContext() {
        return immedContext;
    }
    
    void setActiveTexture(int unit, GLuint tex) {
        assert(unit <= 0);
        
        if (activeTexture != tex) {
            glBindTexture(GL_TEXTURE_2D, tex);
            activeTexture = tex;
        }
    }
}
