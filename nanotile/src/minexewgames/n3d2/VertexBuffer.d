module minexewgames.n3d2.VertexBuffer;

import minexewgames.di;
import minexewgames.engine;
import minexewgames.framework.types;

import minexewgames.n3d2.annotations;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.Renderer;

import std.traits;
import std.stdio;

class VertexBufferConfig {
    // TODO: Make a variable
    size_t maxVertexBufferSize;
}

class VertexBufferBindingManager(GLenum type) {
    VertexBuffer bound;
    void* mapping = null;
    
    void bind(VertexBuffer vb) {
        if (bound is vb)
            return;
        
        makeSureNotMapped();
            
        bound = vb;
        glBindBuffer(type, vb.vbo);
    }
    
    void* map(VertexBuffer vb, GLenum mode) {
        if (bound !is vb)
            bind(vb);
        
        if (mapping == null)
            mapping = glMapBuffer(type, mode);
        
        return mapping;
    }
    
    void makeSureNotMapped() {
        if (mapping != null) {
            glUnmapBuffer(type);
            mapping = null;
        }
    }
}

class VertexBuffer {
    @Autowired Renderer r;
    @Autowired VertexBufferConfig config;
    @Autowired VertexBufferBindingManager!GL_ARRAY_BUFFER mgr;

    GLuint vbo = 0;
    
    size_t vertexSize;
    size_t used = 0, capacity = 0;
    
    GLenum type = GL_ARRAY_BUFFER;
    
    @Initializer
    void init(size_t vertexSize) {
        this.vertexSize = vertexSize;
        
        glGenBuffers(1, &vbo);
        r.check();
    }
    
    void bind() {
        mgr.bind(this);
    }
    
    bool empty() const {
        return used == 0;
    }
    
    void clear() {
        used = 0;
    }
    
    ubyte* allocOffline(size_t count) {
        mgr.bind(this);
        r.check();
        
        if (used + count > capacity) {
            // FIXME: will trash data
            
            capacity = alignBulkSize!4096(used + count);
            glBufferData(type, capacity * vertexSize, null, GL_STATIC_DRAW);
            
            //writefln("Ive alloced %u x %u = %u", capacity, vertexSize, capacity * vertexSize);
            r.check();
        }
        
        ubyte* vertices = cast(ubyte*) mgr.map(this, GL_WRITE_ONLY);
        assert(vertices != null);
            
        //writefln("I'll give you %u x %u = %u", capacity, vertexSize, capacity * vertexSize);
   
        r.check();
        
        auto ptr = vertices + used * vertexSize;
        used += count;
        return ptr;
    }
    
    ubyte* allocLive(size_t count) {
        mgr.bind(this);
        r.check();
        
        if (used + count > capacity) {
            r.flush();

            if (capacity * 2 * vertexSize <= config.maxVertexBufferSize) {
                capacity = (capacity == 0) ? 64 : capacity * 2;
                assert(capacity >= used + count);
                
                mgr.makeSureNotMapped();
                glBufferData(type, capacity * vertexSize, null, GL_STREAM_DRAW);
            }
            
            //writefln("Ive alloced %u x %u = %u", capacity, vertexSize, capacity * vertexSize);
            r.check();
        }
        
        ubyte* vertices = cast(ubyte*) mgr.map(this, GL_WRITE_ONLY);
        assert(vertices != null);
            
        //writefln("I'll give you %u x %u = %u", capacity, vertexSize, capacity * vertexSize);
        
        r.check();
        
        auto ptr = vertices + used * vertexSize;
        used += count;
        return ptr;
    }
    
    void beforeDraw() {
        mgr.makeSureNotMapped();
    }
}
