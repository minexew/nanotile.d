module minexewgames.ntile.WorldGeom;

import minexewgames.di;
import minexewgames.engine;

import minexewgames.ntile.Resources;
import minexewgames.ntile.WorldBlocks;

import minexewgames.n3d2;

import std.c.string;
import std.stdio;

enum VERTICES_IN_BLOCK = BLOCK_WIDTH * BLOCK_HEIGHT * 18;

struct WorldVertex {
    @Location(AttrLoc.position)
    ivec3 pos;                          // 12
    
    @Location(AttrLoc.normal) @Normalized
    short[4] n;                         // 20
    
    @Location(AttrLoc.color) @Normalized
    byte4 rgba;                         // 24
    
    @Location(AttrLoc.uv)
    vec2 uv;                            // 32
}

static assert(WorldVertex.sizeof == 32);

alias VertexType = WorldVertex;
VertexType* v0;

// a cluster of 4x4 blocks (64x64 tiles)
// 2.25 MiB of vertex data per cluster
class WorldGeomCluster {
    enum w = 4;
    enum h = 4;
    
    WorldGeom wg;
    
    ivec2 blockXY;      // leftmost topmost in the cluster
    VertexArray vertices;
    
    @Initializer
    void init(WorldGeom wg) {
        this.wg = wg;
        vertices = diNew!VertexArray();
        vertices.initVertexType!VertexType();
    }
    
    void intializeTilesInCluster() {
        VertexType* p_vertices = vertices.allocOffline!VertexType(VERTICES_IN_BLOCK * w * h);
        v0 = p_vertices;
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++) {
                wg.initializeTilesInBlock(blockXY + ivec2(x, y), p_vertices);
                
                // FIXME
                wg.updateAllTiles(blockXY + ivec2(x, y), p_vertices);
                
                p_vertices += VERTICES_IN_BLOCK;
            }
    }
    
    void updateTilesInCluster() {
        
    }
}

class WorldGeom {
    RenderingContext ctx;
    WorldBlocks world;
    
    @Recipe("path=ntile/shaders/basic")
    ShaderProgram prog;
    
    @Recipe("path=ntile/textures/worldtex_%d.png,generateMipmaps=0,loadMipmapLevels=7,mipmapping=false")
    Texture tex;
    
    WorldGeomCluster[][] clusters;
    
    ShaderVariable!float lodBias;
    
    @Initializer
    void init(WorldBlocks world) {
        this.world = world;
        
        ctx = diNew!RenderingContext(prog);
        ctx.setTexture2D(tex);
        
        lodBias.bind(ctx, "lodBias");
        lodBias = -1.5f;
    }
    
    void draw(Camera cam) {
        ctx.setup(cam);

        auto clust = clusters[0][0];
        clust.vertices.install();
        clust.vertices.draw(PrimitiveMode.triangles);
        
        ctx.teardown();
    }
    
    void initializeTilesInBlock(ivec2 blockXY, VertexType* p_vertices) {
        for (int y = 0; y < BLOCK_HEIGHT; y++) {
            int32_t xx1 =       TILE_X / 2 + blockXY.x * BLOCK_WIDTH * TILE_X;
            int32_t xx2 =       xx1 + TILE_X;

            immutable int32_t yy1 = TILE_Y / 2 + (blockXY.y * BLOCK_HEIGHT + y) * TILE_Y;
            immutable int32_t yy2 = yy1 + TILE_Y;

            for (int x = 0; x < BLOCK_WIDTH; x++) {
                static immutable int16_t[4] normal_up =     [0, 0, INT16_MAX, 0];
                static immutable int16_t[4] normal_east =   [INT16_MAX, 0, 0, 0];
                static immutable int16_t[4] normal_south =  [0, INT16_MAX, 0, 0];

                for (int i = 0; i < 18; i++)
                    memset(&p_vertices[i].rgba, 0xFF, 4);

                // this
                p_vertices[0].n[] = normal_up;
                p_vertices[1].n[] = normal_up;
                p_vertices[2].n[] = normal_up;
                p_vertices[3].n[] = normal_up;
                p_vertices[4].n[] = normal_up;
                p_vertices[5].n[] = normal_up;

                p_vertices[0].pos.x = xx1;
                p_vertices[0].pos.y = yy1;
                p_vertices[0].uv.x = 0.0f;
                p_vertices[0].uv.y = 0.0f;

                p_vertices[1].pos.x = xx1;
                p_vertices[1].pos.y = yy2;
                p_vertices[1].uv.x = 0.0f;
                p_vertices[1].uv.y = 1.0f;

                p_vertices[2].pos.x = xx2;
                p_vertices[2].pos.y = yy1;
                p_vertices[2].uv.x = 1.0f;
                p_vertices[2].uv.y = 0.0f;
                
                p_vertices[3].pos.x = xx2;
                p_vertices[3].pos.y = yy1;
                p_vertices[3].uv.x = 1.0f;
                p_vertices[3].uv.y = 0.0f;
                
                p_vertices[4].pos.x = xx1;
                p_vertices[4].pos.y = yy2;
                p_vertices[4].uv.x = 0.0f;
                p_vertices[4].uv.y = 1.0f;
                
                p_vertices[5].pos.x = xx2;
                p_vertices[5].pos.y = yy2;
                p_vertices[5].uv.x = 1.0f;
                p_vertices[5].uv.y = 1.0f;

                // eastern
                p_vertices[6].n[] = normal_east;
                p_vertices[7].n[] = normal_east;
                p_vertices[8].n[] = normal_east;
                p_vertices[9].n[] = normal_east;
                p_vertices[10].n[] = normal_east;
                p_vertices[11].n[] = normal_east;
                
                p_vertices[6].pos.x = xx2;
                p_vertices[6].pos.y = yy2;
                p_vertices[6].uv.x = 0.0f;
                p_vertices[6].uv.y = 0.0f;

                p_vertices[7].pos.x = xx2;
                p_vertices[7].pos.y = yy2;
                p_vertices[7].uv.x = 0.0f;
                p_vertices[7].uv.y = 1.0f;

                p_vertices[8].pos.x = xx2;
                p_vertices[8].pos.y = yy1;
                p_vertices[8].uv.x = 1.0f;
                p_vertices[8].uv.y = 0.0f;
                
                p_vertices[9].pos.x = xx2;
                p_vertices[9].pos.y = yy1;
                p_vertices[9].uv.x = 1.0f;
                p_vertices[9].uv.y = 0.0f;

                p_vertices[10].pos.x = xx2;
                p_vertices[10].pos.y = yy2;
                p_vertices[10].uv.x = 0.0f;
                p_vertices[10].uv.y = 1.0f;

                p_vertices[11].pos.x = xx2;
                p_vertices[11].pos.y = yy1;
                p_vertices[11].uv.x = 1.0f;
                p_vertices[11].uv.y = 1.0f;

                // southern
                p_vertices[12].n[] = normal_south;
                p_vertices[13].n[] = normal_south;
                p_vertices[14].n[] = normal_south;
                p_vertices[15].n[] = normal_south;
                p_vertices[16].n[] = normal_south;
                p_vertices[17].n[] = normal_south;

                p_vertices[12].pos.x = xx1;
                p_vertices[12].pos.y = yy2;
                p_vertices[12].uv.x = 0.0f;
                p_vertices[12].uv.y = 0.0f;

                p_vertices[13].pos.x = xx1;
                p_vertices[13].pos.y = yy2;
                p_vertices[13].uv.x = 0.0f;
                p_vertices[13].uv.y = 1.0f;

                p_vertices[14].pos.x = xx2;
                p_vertices[14].pos.y = yy2;
                p_vertices[14].uv.x = 1.0f;
                p_vertices[14].uv.y = 0.0f;
                
                p_vertices[15].pos.x = xx2;
                p_vertices[15].pos.y = yy2;
                p_vertices[15].uv.x = 1.0f;
                p_vertices[15].uv.y = 0.0f;

                p_vertices[16].pos.x = xx1;
                p_vertices[16].pos.y = yy2;
                p_vertices[16].uv.x = 0.0f;
                p_vertices[16].uv.y = 1.0f;

                p_vertices[17].pos.x = xx2;
                p_vertices[17].pos.y = yy2;
                p_vertices[17].uv.x = 1.0f;
                p_vertices[17].uv.y = 1.0f;

                p_vertices += 18;

                xx1 += 16;
                xx2 += 16;
            }
        }
    }
    
    void updateAllTiles(ivec2 blockXY, WorldVertex* p_vertices) {
        immutable ivec2 worldSize = world.worldSize;
        
        WorldBlock* block = world.blocks[blockXY.y * worldSize.x + blockXY.x];
        WorldBlock* block_east = (blockXY.x + 1 < worldSize.x) ? world.blocks[blockXY.y * worldSize.x + blockXY.x + 1] : null;
        WorldBlock* block_south = (blockXY.y + 1 < worldSize.y) ? world.blocks[(blockXY.y + 1) * worldSize.x + blockXY.x] : null;

        for (int y = 0; y < BLOCK_HEIGHT; y++) {
            WorldTile* p_tile = &block.tiles[y][0];
            WorldTile* tile_east = (block_east != null) ? &block_east.tiles[y][0] : null;

            WorldTile* p_tile_south;

            if (y + 1 < BLOCK_HEIGHT)
                p_tile_south = &block.tiles[y + 1][0];
            else
                p_tile_south = (block_south != null) ? &block_south.tiles[0][0] : null;

            if (p_tile_south != null) {
                for (int x = 0; x < BLOCK_WIDTH - 1; x++) {
                    UpdateTile(p_tile, p_tile + 1, p_tile_south, p_vertices);

                    p_tile++;
                    p_tile_south++;
                }

                UpdateTile(p_tile, tile_east, p_tile_south, p_vertices);
            }
            else {
                for (int x = 0; x < BLOCK_WIDTH - 1; x++) {
                    UpdateTile(p_tile, p_tile + 1, null, p_vertices);

                    p_tile++;
                }

                UpdateTile(p_tile, tile_east, null, p_vertices);
            }
        }
    }

    void UpdateTile(WorldTile* tile, WorldTile* tile_east, WorldTile* tile_south, ref WorldVertex* p_vertices)
    {
        for (int i = 0; i < 6; i++) {
            p_vertices[i].pos.z = tile.elev;

            memcpy(&p_vertices[i].rgba[0], &tile.colour[0], 3);
        }

        p_vertices += 6;

        int16_t normal_x;

        if (tile_east != null) {
            normal_x = (tile.elev > tile_east.elev) ? INT16_MAX : INT16_MIN;

            memcpy(&p_vertices[0].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[1].rgba[0], &tile_east.colour[0], 3);
            memcpy(&p_vertices[2].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[3].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[4].rgba[0], &tile_east.colour[0], 3);
            memcpy(&p_vertices[5].rgba[0], &tile_east.colour[0], 3);

            p_vertices[0].pos.z = tile.elev;
            p_vertices[1].pos.z = tile_east.elev;
            p_vertices[2].pos.z = tile.elev;
            p_vertices[3].pos.z = tile.elev;
            p_vertices[4].pos.z = tile_east.elev;
            p_vertices[5].pos.z = tile_east.elev;
        }
        else {
            normal_x = (tile.elev > 0) ? INT16_MAX : INT16_MIN;

            memcpy(&p_vertices[0].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[1].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[2].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[3].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[4].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[5].rgba[0], &tile.colour[0], 3);

            p_vertices[0].pos.z = tile.elev;
            p_vertices[1].pos.z = 0;
            p_vertices[2].pos.z = tile.elev;
            p_vertices[3].pos.z = tile.elev;
            p_vertices[4].pos.z = 0;
            p_vertices[5].pos.z = 0;
        }

        p_vertices[0].n[0] = normal_x;
        p_vertices[1].n[0] = normal_x;
        p_vertices[2].n[0] = normal_x;
        p_vertices[3].n[0] = normal_x;
        p_vertices[4].n[0] = normal_x;
        p_vertices[5].n[0] = normal_x;

        p_vertices += 6;

        int16_t normal_y;

        if (tile_south != null) {
            normal_y = (tile.elev > tile_south.elev) ? INT16_MAX : INT16_MIN;

            memcpy(&p_vertices[0].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[1].rgba[0], &tile_south.colour[0], 3);
            memcpy(&p_vertices[2].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[3].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[4].rgba[0], &tile_south.colour[0], 3);
            memcpy(&p_vertices[5].rgba[0], &tile_south.colour[0], 3);

            p_vertices[0].pos.z = tile.elev;
            p_vertices[1].pos.z = tile_south.elev;
            p_vertices[2].pos.z = tile.elev;
            p_vertices[3].pos.z = tile.elev;
            p_vertices[4].pos.z = tile_south.elev;
            p_vertices[5].pos.z = tile_south.elev;
        }
        else {
            normal_y = (tile.elev > 0) ? INT16_MAX : INT16_MIN;

            memcpy(&p_vertices[0].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[1].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[2].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[3].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[4].rgba[0], &tile.colour[0], 3);
            memcpy(&p_vertices[5].rgba[0], &tile.colour[0], 3);

            p_vertices[0].pos.z = tile.elev;
            p_vertices[1].pos.z = 0;
            p_vertices[2].pos.z = tile.elev;
            p_vertices[3].pos.z = tile.elev;
            p_vertices[4].pos.z = 0;
            p_vertices[5].pos.z = 0;
        }

        p_vertices[0].n[1] = normal_y;
        p_vertices[1].n[1] = normal_y;
        p_vertices[2].n[1] = normal_y;
        p_vertices[3].n[1] = normal_y;
        p_vertices[4].n[1] = normal_y;
        p_vertices[5].n[1] = normal_y;

        p_vertices += 6;
    }
}
