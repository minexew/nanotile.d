module minexewgames.n3d2.Texture;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.framework.stream;
import minexewgames.framework.types;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.VertexArray;

import dlib.image.image;
import dlib.image.io.png;

import std.array;
import std.format;
import std.stdint;
import std.stdio;
import std.string;

class Texture {
    struct RecipeParams {
        @Required string path;
        int loadMipmapLevels = 1;//fixme: rename to maxmipmaplevel
        bool filtered = true;
        bool mipmapped = true;
        bool generateMipmaps = true;
    }
    
    @Autowired Renderer r;
    @Autowired FileSystem fs;
    
    GLuint tex = 0;
    
    GLenum type = GL_TEXTURE_2D;
    
    ivec2 size; 
    
    int alignment = 1;  // TODO: what's this for anyway?
    float lodBias = 0.0f;
    
    bool filtered = true;
    bool mipmapped = true;
    bool generateMipmaps = true;

    void preInit() {
    	if (tex != 0)
    	    return;
    	
        glGenTextures(1, &tex);

        bind();

        if (filtered) {
            glTexParameteri(type, GL_TEXTURE_MIN_FILTER, mipmapped ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);
            glTexParameteri(type, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        }
        else {
            glTexParameteri(type, GL_TEXTURE_MIN_FILTER, mipmapped ? GL_NEAREST_MIPMAP_LINEAR : GL_LINEAR);
            glTexParameteri(type, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        }

        glTexParameteri(type, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(type, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        //if (generateMipmaps)
        //    glGenerateMipmap(type);
    }

    void initLevel(int level, GLenum format, ivec2 size, const void* data) {
        glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
        glTexImage2D(type, level, GL_RGBA8, size.x, size.y, 0, format, GL_UNSIGNED_BYTE, data);

        this.size = size;
    }

    @Initializer
    void init() {
    }
    
    @Initializer
    void init(const ref RecipeParams recipe) {
        this.filtered = recipe.filtered;
        this.mipmapped = recipe.mipmapped;
        this.generateMipmaps = recipe.generateMipmaps;
        
        preInit();
        
        for (int i = 0; i < recipe.loadMipmapLevels; i++) {
            auto writer = appender!string();
            formattedWrite(writer, recipe.path, i);
            loadLevel(i, writer.data);
        }
    } 
    
    void create(ivec2 size) {
        preInit();

        glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
        glTexImage2D(type, 0, GL_RGBA8, size.x, size.y, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);

        this.size = size;
    }
    
    void bind() {
        r.setActiveTexture(-1, tex);
        
        //glBindTexture(type, tex);
        //glTexEnvf(GL_TEXTURE_FILTER_CONTROL, GL_TEXTURE_LOD_BIAS, lodBias);
    }

    void loadLevel(int level, string fileName) {
        SuperImage img;
        
        try {
            img = loadPNG(fs.openInput(fileName));
        } catch (PNGLoadException ex) {
            throw new Exception("'" ~ fileName ~ "' :" ~ ex.msg, ex.file, ex.line, ex.next);
        }

        immutable int bpp = img.channels * 8;
    
        if (bpp == 24) {
            initLevel(level, GL_RGB, ivec2(img.width, img.height), img.data.ptr);
        }
        else if (bpp == 32) {
            initLevel(level, GL_RGBA, ivec2(img.width, img.height), img.data.ptr);
        }
        else
            throw new Exception(fileName ~ ": Expected 24/32-bit PNG");
    }
}
