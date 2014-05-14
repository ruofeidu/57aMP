var grid = function() {

    var lock = false; 
    var localhost = false; 
    var word = "11111111111111100001100000101100110";
    var viz = "10101011010101101010110101011010101";
    var baseURL = "http://duruofei.com/57aMP/";
    var localURL = "http://localhost:8888/57aMP/";

    var lastURL = "?last="; 
    var setURL = "?set="; 
    var n = 5, m = 7; 

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

        // if nothing's selected (anymore), show the latest entry
        if (!document.querySelector(".selected")) {
            copy_to_grid(history_tables[0].querySelectorAll("td"));
        }
    }

    function copy_to_grid(from) {
        var to = document.querySelectorAll(".grid td");

        for (var i = 0; i < from.length; i++) {
            // history grids only bother with .dark
            to[i].className = from[i].className ? "dark" : "light";
        }
    }

    function updateViz() {
        if (viz != word) {
            viz = word;
            push_new_grid(viz);
        }
    }

    function updateData() {
        if (!lock) {
            $.ajax({url:(baseURL + lastURL + 1) , success:function(result){
                    word = result;
                    lock = false; 
                }, error: function(XMLHttpRequest, textStatus, errorThrown) { 
                    lock = false; 
                }   
            });
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

            table.addEventListener("click", function() {
                this.className = "";
                copy_to_grid(history_tables[0].querySelectorAll("td"));
            });
        }

        if (localhost) {
            baseURL = localURL; 
        }
        updateViz(); 

        setInterval(function() {
            updateData();
            updateViz(); 
        }, 500); 

        document.querySelector(".grid").addEventListener("click", function() {
            push_new_grid("10101011010101101010110101011010101");
        });
    }

    return {
        init: init
    }

}();


$(document).ready(function() {
    grid.init();
});

