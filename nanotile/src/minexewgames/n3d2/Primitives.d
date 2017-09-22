module minexewgames.n3d2.Primitives;

import minexewgames.di;
import minexewgames.n3d2.Renderer;

class Primitives {
    @Autowired Renderer r;
    
    void fillRect(vec2 pos, vec2 size, const ref vec2[2] uv, const ref byte4[4] rgba) {
        auto vertices = r.vertices(6);
        
        vertices.pos = vec3(pos.x, pos.y, 0.0f);
        vertices.rgba = rgba[0];
        vertices.uv = vec2(uv[0].x, uv[0].y);
        vertices++;
        
        vertices.pos = vec3(pos.x, pos.y + size.y, 0.0f);
        vertices.rgba = rgba[1];
        vertices.uv = vec2(uv[0].x, uv[1].y);
        vertices++;
        
        vertices.pos = vec3(pos.x + size.x, pos.y, 0.0f);
        vertices.rgba = rgba[3];
        vertices.uv = vec2(uv[1].x, uv[0].y);
        vertices++;
        
        vertices.pos = vec3(pos.x + size.x, pos.y, 0.0f);
        vertices.rgba = rgba[3];
        vertices.uv = vec2(uv[1].x, uv[0].y);
        vertices++;
        
        vertices.pos = vec3(pos.x, pos.y + size.y, 0.0f);
        vertices.rgba = rgba[1];
        vertices.uv = vec2(uv[0].x, uv[1].y);
        vertices++;

        vertices.pos = vec3(pos.x + size.x, pos.y + size.y, 0.0f);
        vertices.rgba = rgba[2];
        vertices.uv = vec2(uv[1].x, uv[1].y);
    }
    
    void fillRect(vec2 pos, vec2 size, const ref vec2[2] uv, byte4 rgba) {
        immutable byte4[4] rgba_4 = [rgba, rgba, rgba, rgba];
        
        fillRect(pos, size, uv, rgba_4);
    }
    
    void fillRect(vec2 pos, vec2 size, byte4 rgba) {
        immutable static vec2[2] uv = [vec2(0.0f, 0.0f), vec2(1.0f, 1.0f)];
        immutable byte4[4] rgba_4 = [rgba, rgba, rgba, rgba];
        
        fillRect(pos, size, uv, rgba_4);
    }
}
