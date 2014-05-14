/*
  Generates a pixel-grid stamp.

    Based on knowledge gleaned from:
        - https://api.tinkercad.com/libraries/1vxKXGNaLtr/0/docs/topic/
          Shape+Generator+Overview.html
        - https://api.tinkercad.com/libraries/1vxKXGNaLtr/0/docs/symbol/
          Mesh3D.html
        - https://api.tinkercad.com/libraries/1vxKXGNaLtr/0/docs/symbol/
          Solid.html
        - my old OpenGL programs
*/

// dependencies ////////////////////////////////////////////////////////////////
var Mesh3D = Core.Mesh3D;
var Solid = Core.Solid;


// geometry constants //////////////////////////////////////////////////////////
var GEOM = function() {
    // coordinate abbreviations
    var LO = 0;
    var HI = 1;

    // vertices
    var TOP_NW = [LO, HI, HI];
    var TOP_NE = [HI, HI, HI];
    var TOP_SW = [LO, LO, HI];
    var TOP_SE = [HI, LO, HI];
    var BOTTOM_NW = [LO, HI, LO];
    var BOTTOM_NE = [HI, HI, LO];
    var BOTTOM_SW = [LO, LO, LO];
    var BOTTOM_SE = [HI, LO, LO];

    // sides
    var flatten = function(array) {
        return Array.prototype.concat.apply([], array);
    };

    var SIDES = ["FRONT", "RIGHT", "BACK", "LEFT", "TOP", "BOTTOM"];
    var FRONT = flatten([TOP_SW, BOTTOM_SW, BOTTOM_SE, TOP_SE]);
    var RIGHT = flatten([TOP_SE, BOTTOM_SE, BOTTOM_NE, TOP_NE]);
    var BACK = flatten([TOP_NE, BOTTOM_NE, BOTTOM_NW, TOP_NW]);
    var LEFT = flatten([TOP_NW, BOTTOM_NW, BOTTOM_SW, TOP_SW]);
    var TOP = flatten([TOP_NW, TOP_SW, TOP_SE, TOP_NE]);
    var BOTTOM = flatten([BOTTOM_NW, BOTTOM_NE, BOTTOM_SE, BOTTOM_SW]);

    return {
        SIDES: SIDES,
        FRONT: FRONT,
        RIGHT: RIGHT,
        BACK: BACK,
        LEFT: LEFT,
        TOP: TOP,
        BOTTOM: BOTTOM
    };
}();


// config //////////////////////////////////////////////////////////////////////
var ON = "1";
var OFF = "0";

var NUM_COLS = 7;
var COL_WIDTH = 7;
var ROW_HEIGHT = COL_WIDTH * 3;
var HEIGHT_RAISED = 15;
var HEIGHT_LOWERED = 7;

var DEFAULT_GRID = "0100110";
DEFAULT_GRID += "1001000";
DEFAULT_GRID += "0101011";
DEFAULT_GRID += "0011001";
DEFAULT_GRID += "1011110";


// params //////////////////////////////////////////////////////////////////////
var params = [
    {
        id: "matrix",
        displayName: "matrix ('binary' string)",
        type: "string",
        "default": DEFAULT_GRID
    }
];


// main ////////////////////////////////////////////////////////////////////////
function shapeGeneratorEvaluate(params, callback) {
    var cells = render_matrix(params.matrix);
    var first = cells.shift();

    // TODO: optimize (render flat base, add raised squares)
    return first.unite(cells, function(mesh) {
        callback(Solid.make(mesh));
    });
}


// renderers ///////////////////////////////////////////////////////////////////
function render_matrix(matrix) {
    var cells = [];

    for (var i = 0; i < matrix.length; i++) {
        var row = Math.floor(i / NUM_COLS);
        var col = i % NUM_COLS;
        var x = col_to_x(col);
        var y = row_to_y(row);

        cells.push(render_cell(x, y, 0, matrix.charAt(i)));
    }
    return cells;
}

function render_cell(x, y, z, state) {
    return transform_mesh(render_unit_cube(),
        x, y, z,
        COL_WIDTH, ROW_HEIGHT, state === ON ? HEIGHT_RAISED : HEIGHT_LOWERED);
}

function render_unit_cube() {
    var mesh = new Mesh3D();

    for (var i = 0; i < GEOM.SIDES.length; i++) {
        mesh.quad(GEOM[GEOM.SIDES[i]]);
    }
    return mesh;
}


// (row, col) --> (x, y) converters ////////////////////////////////////////////
function row_to_y(row) {
    // allow unlimited row growth
    return -1 * (row - 1) * ROW_HEIGHT;
}

function col_to_x(col) {
    if (col_to_x.offsets === undefined) {
        col_to_x.offsets = [];

        for (var i = 0, offset = 0; i < NUM_COLS; i++, offset += COL_WIDTH) {
            col_to_x.offsets[i] = offset;
        }
    }
    return col_to_x.offsets[col];
}


// mesh utilities //////////////////////////////////////////////////////////////
function transform_mesh(mesh,
        translate_x, translate_y, translate_z,
        scale_x, scale_y, scale_z) {
    return mesh.transform([
        scale_x,        0,              0,              0,
        0,              scale_y,        0,              0,
        0,              0,              scale_z,        0,
        translate_x,    translate_y,    translate_z,    0
        ]);
}
