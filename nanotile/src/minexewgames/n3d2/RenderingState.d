module minexewgames.n3d2.RenderingState;

import minexewgames.di;

import minexewgames.n3d2.OpenGLConnector;

enum RenderingStateVariable {
    minBool,
    culling,
    depthTest,
    maxBool,
    blendMode,
}

enum BlendMode {
    alpha,
    add,
    subtract
}

struct BlendModeDef {
    GLenum src, op, dst;
}

immutable BlendModeDef[] blendModes = [
    BlendModeDef(GL_SRC_ALPHA, GL_FUNC_ADD, GL_ONE_MINUS_SRC_ALPHA),
    BlendModeDef(GL_SRC_ALPHA, GL_FUNC_ADD, GL_ONE),
    BlendModeDef(GL_SRC_ALPHA, GL_FUNC_REVERSE_SUBTRACT, GL_ONE),
];

class RenderingState {
    @Autowired OpenGLStateTracker stateTracker;
    
    void setVariable(RenderingStateVariable var, int value) {
        if (var > RenderingStateVariable.minBool && var < RenderingStateVariable.maxBool)
            stateTracker.setStateBool(var - RenderingStateVariable.minBool - 1, value > 0);
        else switch (var) {
            case RenderingStateVariable.blendMode:
                glBlendFunc(blendModes[value].src, blendModes[value].dst);
                glBlendEquation(blendModes[value].op);
                break;
                
            default:
        }
    }
}

immutable GLenum glBoolEnums[] = [
    GL_CULL_FACE,
    GL_DEPTH_TEST,
];

class OpenGLStateTracker {
    bool glBoolVars[glBoolEnums.length];
    
    void setStateBool(int index, bool value) {
        if (glBoolVars[index] == value)
            return;

        if (value)
            glEnable(glBoolEnums[index]);
        else
            glDisable(glBoolEnums[index]);

        glBoolVars[index] = value;
    }
}
