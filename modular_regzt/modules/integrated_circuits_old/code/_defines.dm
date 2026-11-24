/// Max |x|/|y| for IE chips on the TGUI canvas (must match wire-scale panning).
#define IE_TGUI_COMPONENT_COORD_LIMIT 25000

/// Maximum number of simultaneously highlighted data pulses on the TGUI canvas.
#define IE_TGUI_MAX_LIVE_PULSES 64

/// Horizontal gap between auto-laid-out circuit nodes, px.
#define IE_TGUI_LAYOUT_COL_GAP 500
/// Vertical padding between auto-laid-out circuit nodes, px.
#define IE_TGUI_LAYOUT_NODE_Y_PAD 500

/// Max characters for printer "load program" JSON (layout fields etc. inflate size).
#define MAX_IC_PRINTER_JSON_LEN (512 * 1024)

#define IC_MAX_LIST_NESTING 4

/// Log category for legacy integrated electronics.
#define INVESTIGATE_CIRCUIT "circuit"

/// Dummy human slot used by legacy circuit examining helpers.
#define DUMMY_HUMAN_SLOT_EXAMINER "examiner"

/// UTF-8 header for legacy HTML UIs.
#define UTF8HEADER "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>"
