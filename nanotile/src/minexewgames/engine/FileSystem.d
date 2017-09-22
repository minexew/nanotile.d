module minexewgames.engine.FileSystem;

import minexewgames.framework.stream;
import minexewgames.framework.MediaFile;

import std.file;
import std.stream : File;

class FileSystem {
	InputStream openInput(string fileName) {
		return new StdStreamWrapper(new File(fileName));
	}
	
	MediaFile openMediaFile(string fileName, bool readOnly, bool canCreate) {
		auto mediaFile = new MediaFile;
		mediaFile.open(fileName, readOnly, canCreate);
		return mediaFile;
	}
	
    string readFileContents(string fileName) {
        return readText(fileName);
    }
}
