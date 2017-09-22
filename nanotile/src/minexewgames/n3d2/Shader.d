module minexewgames.n3d2.Shader;

import minexewgames.di;
import minexewgames.engine.FileSystem;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;

import std.conv;

enum ShaderType {
    fragment,
    vertex
} 

GLenum getGLShaderType(ShaderType type) {
    return [ShaderType.fragment: GL_FRAGMENT_SHADER,
            ShaderType.vertex: GL_VERTEX_SHADER][type];
}

class Shader {
    ShaderType type;
    string fileName;
    
    GLuint shader = 0;
    
    ~this() {
        if (shader != 0)
            glDeleteShader(shader);
    }
    
    @Initializer
    void init(Renderer r, ShaderType type, string fileName) {
        this.type = type;
        this.fileName = fileName;
        
        string source = (diGet!FileSystem).readFileContents(fileName);
        
        shader = glCreateShader(getGLShaderType(type));

        GLint len = cast(GLint) source.length;
        const char* text = cast(const char*) source.ptr;

        glShaderSource(shader, 1, &text, &len);

        glCompileShader(shader);
        
        GLint isCompiled = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &isCompiled);
        
        if (isCompiled == GL_FALSE) {
            GLsizei maxLength = 0;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength);

            GLchar errorLog[] = new GLchar [maxLength];
            glGetShaderInfoLog(shader, maxLength, &maxLength, &errorLog[0]);

            throw new Exception("Failed to compile shader '"
                    ~ fileName ~ "': " ~ to!string(errorLog));
        }
        
        r.check();
    }
}
