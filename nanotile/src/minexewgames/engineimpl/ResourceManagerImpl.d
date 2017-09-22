module minexewgames.engineimpl.ResourceManagerImpl;

import minexewgames.engine;

class ResourceManagerImpl : ResourceManager {
    Object[string] resources;
    
    Object getInstance(string className, string recipe) {
        string id = className ~ ":" ~ recipe;
        return (id in resources) ? resources[id] : null;
    }
    
    void setInstance(string className, string recipe, Object instance) {
        string id = className ~ ":" ~ recipe;
        
        resources[id] = instance;
    }
}
