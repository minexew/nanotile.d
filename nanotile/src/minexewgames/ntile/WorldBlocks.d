module minexewgames.ntile.WorldBlocks;

import minexewgames.framework.types;

enum BLOCK_WIDTH = 16;
enum BLOCK_HEIGHT = 16;

enum TILE_X = 16;
enum TILE_Y = 16;

enum {
    BLOCK_SHIROI
}

struct WorldTile {
    uint8_t type;
    uint8_t flags;
    int16_t elev;
    uint8_t material;
    uint8_t[3] colour;
}

static assert(WorldTile.sizeof == 8);

struct WorldBlock {
    int type;
    
    WorldTile[BLOCK_WIDTH][BLOCK_HEIGHT] tiles;
}

class WorldBlocks {
    ivec2 worldSize;
    WorldBlock*[] blocks;
}
