module minexewgames.engineimpl.LoggerImpl;

import minexewgames.engine.Logger;

import std.datetime;
import std.stdio;

class LoggerImpl : Logger {
    public void log(LogLevel level, string origin, string msg) {
        TickDuration td = Clock.currAppTick();

        writef("[%5u.%04u] ", cast(int)(td.usecs / 1000000), cast(int)(td.usecs % 1000000) / 100);
        writefln("%14s: %s", origin, msg);
    }
}
