module minexewgames.n3d2.RenderingContext;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.VertexArray;

import std.stdio;
import std.string;

// lol GL
void uniformSetter(T, int size)(ShaderUniformLocation loc) if (is(T == float) && size == 1) {
    glUniform1fv(loc.loc, 1, cast(T*) loc.value);
}

private class ShaderUniformLocation {
    RenderingContext ctx;
    GLint loc;
    
    void* value;
    bool knownDirty;
    
    void function(ShaderUniformLocation loc) doSetUniform;
    
    this(RenderingContext ctx) {
        this.ctx = ctx;
        knownDirty = false;
    }
    
    void set(void* value) {
        this.value = value;
        ctx.setUniform(this);
    }
}

struct ShaderVariable(T) {
    ShaderUniformLocation loc;
    T value;
    
    void bind(RenderingContext ctx, string varName) {
        loc = new ShaderUniformLocation(ctx);
        
        loc.doSetUniform = &uniformSetter!(ElementType!T, numElements!T);
        ctx.bind(loc, varName);
    }
    
    void opAssign(T value) {
        if (loc is null)
            return;
            
        this.value = value;
        loc.set(&this.value);
    }
}

// Need to override this if you want to supply own uniforms to shader
class RenderingContext {
    @Autowired Renderer r;
    bool isHot;
    
    ShaderProgram prog;

    GLint u_ModelViewProjectionMatrix;
    GLint u_Texture2D;
    
    Texture texture2D;
    
    ShaderUniformLocation[] setUniforms;
    
    @Initializer
    void init(ShaderProgram prog) {
        this.prog = prog;
        
        u_ModelViewProjectionMatrix = glGetUniformLocation(prog.program, "u_ModelViewProjectionMatrix");
        
        u_Texture2D = glGetUniformLocation(prog.program, "u_Texture2D");
    }
    
    bool bind(ShaderUniformLocation loc, string name) {
        loc.loc = glGetUniformLocation(prog.program, toStringz(name));
        
        return loc.loc >= 0;
    }
    
    Texture getTexture2D() {
        return this.texture2D;
    }
    
    void setTexture2D(Texture texture2D) {
        this.texture2D = texture2D;
        
        if (isHot)
            texture2D.bind();
    }
    
    void setUniform(ShaderUniformLocation loc) {
        if (isHot)
            loc.doSetUniform(loc);
        else if (!loc.knownDirty) {
            setUniforms ~= loc;
            loc.knownDirty = true;
        }
    }
    
    void setup(Camera cam) {
        r.useProgram(prog);

        if (u_ModelViewProjectionMatrix >= 0) {
            // TODO: do this lazily
            mat4 mvp;
            cam.setUpMatrices(mvp);
            glUniformMatrix4fv(u_ModelViewProjectionMatrix, 1, GL_FALSE, &mvp.arrayof[0]);
        }

        if (u_Texture2D >= 0) {
            glUniform1i(u_Texture2D, 0);
        }

        if (texture2D !is null)
            texture2D.bind();

        foreach (loc; setUniforms) {
            loc.doSetUniform(loc);
            loc.knownDirty = false;
        }
        
        setUniforms = [];       // FIXME: alloc alloc alloc

        isHot = true;
    }
    
    void teardown() {
        isHot = false;
    }
}