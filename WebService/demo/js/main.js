var grid = function() {
    var history_tables = document.querySelectorAll(".history table");

    function push_new_grid(matrix) {
        // push history down
        for (var i = history_tables.length - 1; i > 0; i--) {
            var from = history_tables[i - 1];
            var from_cells = from.querySelectorAll("td");
            var to = history_tables[i];
            var to_cells = to.querySelectorAll("td");

            to.className = from.className ? from.className : "";

            for (var j = 0; j < to_cells.length; j++) {
                to_cells[j].className = from_cells[j].className;
            }
        }

        // update topmost history entry
        from.className = "";

        for (i = 0; i < matrix.length; i++) {
            from_cells[i].className = matrix.charAt(i) === "1" ? "dark" : "";
        }
    }

    function copy_to_grid(from) {
        var to = document.querySelectorAll(".grid td");

        for (var i = 0; i < from.length; i++) {
            // history grids only bother with .dark
            to[i].className = from[i].className ? "dark" : "light";
        }
    }

    var init = function() {
        for (var i = 0; i < history_tables.length; i++) {
            var table = history_tables[i];

            table.addEventListener("mouseover", function() {
                for (var j = 0; j < history_tables.length; j++) {
                    history_tables[j].className = "";
                }
                this.className = "selected";
                copy_to_grid(this.querySelectorAll("td"));
            });
        }

        document.querySelector(".grid").addEventListener("click", function() {
            push_new_grid("10101011010101101010110101011010101");
        });
    }

    return {
        init: init
    }
}();

grid.init();
