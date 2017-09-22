module minexewgames.n3d2.ShaderProgram;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;

import std.conv;

class ShaderProgram {
    struct RecipeParams {
        @Required string path;
    }
    
    @Autowired Renderer r;
    
    string path;
    Shader frag, vert;
    
    GLuint program = 0;
    
    ~this() {
        if (program != 0)
            glDeleteProgram(program);
    }
    
    @Initializer
    void init(const ref RecipeParams recipe) {
        this.path = recipe.path;
    
        vert = diNew!Shader(r, ShaderType.vertex, path ~ ".vert");
        frag = diNew!Shader(r, ShaderType.fragment, path ~ ".frag");

        program = glCreateProgram();
        glAttachShader(program, vert.shader);
        glAttachShader(program, frag.shader);

        glBindAttribLocation(program, AttrLoc.position, "in_Position");
        glBindAttribLocation(program, AttrLoc.normal, "in_Normal");
        glBindAttribLocation(program, AttrLoc.color, "in_Color");
        glBindAttribLocation(program, AttrLoc.uv, "in_UV");

        glLinkProgram(program);
 
        GLint isLinked = 0;
        glGetProgramiv(program, GL_LINK_STATUS, &isLinked);

        if (isLinked == GL_FALSE) {
            GLint maxLength = 0;
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &maxLength);

            GLchar errorLog[] = new GLchar [maxLength];
            glGetProgramInfoLog(program, maxLength, &maxLength, &errorLog[0]);

            throw new Exception("Failed to compile shader program '"
                    ~ path ~ "': " ~ to!string(errorLog));
        }

        glDetachShader(program, vert.shader);
        glDetachShader(program, frag.shader);
        
        vert = null;
        frag = null;
        
        r.check();
    }
}
