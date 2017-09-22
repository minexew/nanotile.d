module minexewgames.engineimpl.ConfigurationManagerImpl;

import minexewgames.cfx2;

import minexewgames.engine.ConfigurationManager;

import std.file;

class ConfigurationManagerImpl : ConfigurationManager {
    Node conf;

    this () {
        // FIXME: we'll probably need to use VFS for this ?
        auto confFiles = dirEntries("autoconfig", "*.cfx2", SpanMode.depth);
        
        foreach (confFile; confFiles) {
            if (confFile.isFile)
                // LOL
                conf = Reader.loadDocument(confFile.name);
        }
    }

    override string get(string key) {
        string value = Query.queryValue(conf, key);
        
        if (value is null) {
            throw new Exception("Configuration key '" ~ key ~ "' undefined.");
        }

        return value;
    }
}
