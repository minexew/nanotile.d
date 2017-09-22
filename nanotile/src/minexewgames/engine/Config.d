module minexewgames.engine.Config;

import minexewgames.engine.ConfigurationManager;
import minexewgames.engine.Logger;

import std.conv;
import std.traits;

class Config {
    static void annotatedMemberInjection(InstanceManager, Class, T)
        (Class instance, string memberName, T* field) {
            static assert(__traits(compiles, instance.configNode));

            ConfigurationManager conf = InstanceManager.get!ConfigurationManager;

            string value = conf.get(instance.configNode ~ "/" ~ memberName);

            *field = to!T(value);
            
            //Logger logger = DefaultInstanceManager.get!Logger();
            //logger.print("Config", "@Config field " ~ fullyQualifiedName!T ~ " "
            //             ~ fullyQualifiedName!Class ~ "." ~ memberName ~ " = " ~ value);
        }
}
