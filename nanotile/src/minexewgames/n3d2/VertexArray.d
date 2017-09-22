module minexewgames.n3d2.VertexArray;

import minexewgames.di;
import minexewgames.framework.annotationUtil;

import minexewgames.n3d2.annotations;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.Renderer;
import minexewgames.n3d2.ShaderProgram;
import minexewgames.n3d2.VertexBuffer;

import std.stdio;
import std.traits;

enum PrimitiveMode {
    triangles
}

immutable GLenum[] primitiveModes = [
    GL_TRIANGLES
];

class VertexArray {
    @Autowired Renderer r;
    VertexBuffer vb;
    
    GLuint vao;
    
    ~this() {
        glDeleteVertexArrays(1, &vao);
    }

    void initVertexType(Vertex)()
    {
        vb = diNew!VertexBuffer(Vertex.sizeof);
        
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);
        r.check();

        vb.bind();

        foreach (fieldName; __traits(allMembers, Vertex)) {
            static if (typeof(__traits(getOverloads, Vertex, fieldName)).length == 0
                    && !HasAnnotation!(Vertex, fieldName, Ignored)) {
                alias Field = typeof(__traits(getMember, Vertex, fieldName));
    
                enum normalized = HasAnnotation!(Vertex, fieldName, Normalized);
                enum fieldOffset = __traits(getMember, Vertex.init, fieldName).offsetof;
    
                /*int i = glGetAttribLocation(prog.program, fieldName);

                if (i < 0)
                    continue;*/

                int i = GetAnnotationInstance!(Vertex, fieldName, Location).index;

                glVertexAttribPointer(i, cast(GLint) numElements!Field, TypeToGLEnum!(ElementType!Field),
                        normalized ? GL_TRUE : GL_FALSE, Vertex.sizeof, cast(void*) fieldOffset);
                glEnableVertexAttribArray(i);
                r.check();
                
                //writefln("%d:(%d/%d)\t%x %s[%d] (normalized=%s)", i, fieldOffset, Vertex.sizeof,
                //    TypeToGLEnum!(ElementType!Field),
                //    fieldName, cast(GLint) numElements!Field, normalized);
            }
        }
        
        glBindVertexArray(0);
    }
    
    Vertex* allocOffline(Vertex)(size_t count) {
        return cast(Vertex*) vb.allocOffline(count);
    }
    
    Vertex* allocLive(Vertex)(size_t count) {
        return cast(Vertex*) vb.allocLive(count);
    }

    void clear() {
        vb.clear();
    }
    
    bool empty() const {
        return vb.empty();
    }
    
    void install() {
        vb.beforeDraw();
        vb.bind();
        
        r.check();
    }
    
    void draw(PrimitiveMode primitiveMode) {
        r.check();
        
        glBindVertexArray(vao);
        glDrawArrays(primitiveModes[primitiveMode], 0, cast(GLint) vb.used);
        glBindVertexArray(0);
        
        r.check();
    }
}
