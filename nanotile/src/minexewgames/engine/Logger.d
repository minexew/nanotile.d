module minexewgames.engine.Logger;

enum LogLevel {
    always,
    error,
    warning,
    info,
    debugInfo
}

interface Logger {
    public void log(LogLevel level, string origin, string msg);
}
