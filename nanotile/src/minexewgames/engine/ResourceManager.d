module minexewgames.engine.ResourceManager;

import minexewgames.di;
import minexewgames.framework.annotationUtil;
import minexewgames.framework.ParamList;

import std.stdio;

interface ResourceManager {
    Object getInstance(string className, string recipe);
    void setInstance(string className, string recipe, Object instance);
}

struct Recipe {
    string recipe;
    
    void annotatedMemberInjection(InstanceManager, Class, T)
        (Class instance, string memberName, T* field) {
        *field = (diGet!ResourceManager).getResourceFromRecipe!T(recipe);
    }
}

Class createResourceFromRecipe(Class)(ResourceManager resMgr, string recipe) {
    Class.RecipeParams params;

    ParamList.parseIntoStructure(params, recipe, function void(string fieldName) {
        throw new Exception("Failed to parse Recipe for class '" ~ Class.stringof
            ~ "' - missing required param '" ~ fieldName ~ "'");
        });

    return diNew!Class(params);
}

Class getResourceFromRecipe(Class)(ResourceManager resMgr, string recipe) {
    Class instance = cast(Class) resMgr.getInstance(Class.stringof, recipe);
    
    if (instance is null) {
        instance = createResourceFromRecipe!Class(resMgr, recipe);

        resMgr.setInstance(Class.stringof, recipe, instance);
    }
    
    return instance;
}
