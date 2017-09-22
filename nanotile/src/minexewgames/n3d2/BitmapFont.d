module minexewgames.n3d2.BitmapFont;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.framework.stream;
import minexewgames.framework.types;

import minexewgames.n3d2;
import minexewgames.n3d2.OpenGLConnector;
import minexewgames.n3d2.VertexArray;

import std.algorithm;
import std.array;
import std.stdint;
import std.stdio;

struct Glyph {
    vec2 uv[2];
    uint width = 0;
}

class BitmapFont {
    struct RecipeParams {
        @Required string path;
        int scale = 1;
    }
    
    @Autowired FileSystem fs;
    @Autowired Renderer r;
    @Autowired Primitives p;

    uint height, spacing, space_width;
    int scale;

    Texture texture;
    Glyph[] glyphs;
	
    @Initializer
    void init(const ref RecipeParams recipe) {
        auto mf = fs.openMediaFile(recipe.path, true, false);
        InputStream input = mf.openSection("minexewgames.n3d2.BitmapFontData");

        uint32_t kind;
        uint8_t numChars, h, spacing, space_width;

        assert(input.readLE!uint32_t(&kind) && kind == 0x01);
        assert(input.readLE!uint8_t(&numChars));
        assert(input.readLE!uint8_t(&h));
        assert(input.readLE!uint8_t(&spacing));
        assert(input.readLE!uint8_t(&space_width));

        writefln("%s numChars=%u h=%u spacing=%u space_width=%u scale=%d",
                mf.getMetadata("media.original_name"), numChars, h, spacing, space_width, recipe.scale);

        uint8_t[] charData;
        charData.length = numChars * (2 + h * 2);
        assert(input.readBytes(charData.ptr, charData.length) == charData.length);

        uint texWidth = 0;
        uint8_t* p_charData = charData.ptr;

        for (uint i = 0; i < numChars; i++) {
            p_charData++;
            texWidth += 1 + (*p_charData++) + 1;
            p_charData += h * 2;
        }

        texWidth =              alignValue!32(texWidth);
        uint texHeight =    	alignValue!16(h);

        ubyte[] pixels = new ubyte[texWidth * texHeight * 4];
        uint stride = texWidth * 4;

        uint x = 0;
        p_charData = charData.ptr;

        for (uint i = 0; i < numChars; i++) {
            uint index = *p_charData++;
            uint width = *p_charData++;
            
            x++;

            if (index >= glyphs.length)
            	glyphs.length = toNearestPowerOf2(max(index, 128));
            
            Glyph* glyph = &glyphs[index];
            glyph.width = width;
            glyph.uv[0] = vec2(cast(float) (x) / texWidth, 0.0f);
            glyph.uv[1] = vec2(cast(float) (x + width) / texWidth, cast(float) h / texHeight);

            for (uint y = 0; y < h; y++) {
                uint line = *p_charData++;
                line = line | (*p_charData++ << 8);

                uint8_t* pixelData = pixels.ptr + y * stride + x * 4;

                for (uint xx = 0; xx < width; xx++) {
                    pixelData[0] = 0xFF;
                    pixelData[1] = 0xFF;
                    pixelData[2] = 0xFF;
                    pixelData[3] = (line & 1) * 0xFF;

                    pixelData += 4;
                    line >>= 1;
                }
            }

            x += width + 1;
        }

        texture = diNew!Texture();
        texture.filtered = false;
        texture.mipmapped = false;
        texture.generateMipmaps = false;
        texture.create(ivec2(texWidth, texHeight));
        
        texture.initLevel(0, GL_RGBA, ivec2(texWidth, texHeight), pixels.ptr);

        this.height = h;
        this.spacing = spacing * recipe.scale;
        this.space_width = space_width * recipe.scale;
        this.scale = recipe.scale;
    }

    void drawText(int x1, int y1, int flags, string text, byte4 color) {
        ivec2 size;
        int x1_0;

        if (text.empty)
            return;

        auto ctx = r.getImmedContext();

        if (ctx.getTexture2D() !is texture) {
            r.flush();
            ctx.setTexture2D(texture);
        }

        size = measureText(text, flags);

        if (flags & Align.hcenter)
            x1 -= size.x / 2;
        else if (flags & Align.right)
            x1 -= size.x;

        if (flags & Align.vcenter)
            y1 -= size.y / 2;
        else if (flags & Align.bottom)
            y1 -= size.y;

        x1_0 = x1;

        foreach (c; text) {
        	if (c == '\n') {
                x1 = x1_0;
                y1 += height;
            }
            else if (c == ' ')
                x1 += space_width;
            else if (c < glyphs.length) {
                Glyph* glyph = &glyphs[c];

                // TODO: Should we allocate once or every time?
                /*FontVertex* vertices = static_cast<FontVertex*>(
                        vertexCache->Alloc(this, 4 * sizeof(FontVertex)));
                
                vertices[0].x = x1;
                vertices[0].y = y1;
                vertices[0].z = 0;
                memcpy(&vertices[0].rgba[0], &colour[0], 4);
                vertices[0].u = glyph.uv[0].x;
                vertices[0].v = glyph.uv[0].y;
                
                vertices[1].x = x1;
                vertices[1].y = y1 + height * scale;
                vertices[1].z = 0;
                memcpy(&vertices[1].rgba[0], &colour[0], 4);
                vertices[1].u = glyph.uv[0].x;
                vertices[1].v = glyph.uv[1].y;
                
                vertices[2].x = x1 + glyph.width * scale;
                vertices[2].y = y1 + height * scale;
                vertices[2].z = 0;
                memcpy(&vertices[2].rgba[0], &colour[0], 4);
                vertices[2].u = glyph.uv[1].x;
                vertices[2].v = glyph.uv[1].y;
                
                vertices[3].x = x1 + glyph.width * scale;
                vertices[3].y = y1;
                vertices[3].z = 0;
                memcpy(&vertices[3].rgba[0], &colour[0], 4);
                vertices[3].u = glyph.uv[1].x;
                vertices[3].v = glyph.uv[0].y;*/
                
                //glr->DrawTexture(texture, Int2(x1, y1), Int2(glyph.width, height) * scale, glyph.pos, glyph.size);
                
                p.fillRect(vec2(x1, y1), vec2(glyph.width * scale, height * scale), glyph.uv, color);

                x1 += glyph.width * scale + spacing;
            }
        }
        
        //vertexCache->Flush();

        //glr->SetColour(RGBA_WHITE);
    }

    ivec2 measureText(string text, int flags) {
        int width, height, maxw;

        if (text.empty)
            return ivec2();

        width = 0;
        height = this.height;
        maxw = 0;

        // whoops unicode
        foreach (c; text) {
            if (c == '\n') {
                if (width > maxw)
                    maxw = width;

                width = 0;
                height += this.height;
            }
            else if (c == ' ')
                width += space_width + spacing;
            else if (c < glyphs.length)
                width += glyphs[c].width * scale + spacing;
        }

        if (width > maxw)
            maxw = width;

        return ivec2(maxw, height * scale);
    }

    /*void GLFont::OnVertexCacheFlush(GLVertexBuffer* vb, size_t bytesUsed)
    {
        gl.SetState(ST_GL_TEXTURE_2D, true);
        glr->SetTextureUnit(0, texture);
        glr->DrawPrimitives(vb, PRIMITIVE_QUADS, glr->GetFontVertexFormat(), 0,
                (uint32_t)(bytesUsed / sizeof(FontVertex)));
    }*/
}
