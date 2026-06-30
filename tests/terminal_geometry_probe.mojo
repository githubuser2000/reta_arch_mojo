from reta_mojo.terminal_geometry import terminal_columns, automatic_cell_width


def main() raises:
    var columns = terminal_columns()
    print(columns, automatic_cell_width(columns))
