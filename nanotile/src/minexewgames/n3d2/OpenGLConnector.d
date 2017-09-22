module minexewgames.n3d2.OpenGLConnector;

public import minexewgames.engineimpl.SDLConnector;

template TypeToGLEnum(T) {
    static assert("No matching GL type");
}

template TypeToGLEnum(T : float) {
    alias TypeToGLEnum = GL_FLOAT;
}

template TypeToGLEnum(T : short) {
    alias TypeToGLEnum = GL_SHORT;
}

template TypeToGLEnum(T : int) {
    alias TypeToGLEnum = GL_INT;
}

template TypeToGLEnum(T : ubyte) {
    alias TypeToGLEnum = GL_UNSIGNED_BYTE;
}
