const EMPTY = 0;

// https://stackoverflow.com/a/7616484
function _hash(num_rows, num_cols, board) {

    var s = '';
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            var position = [col, row];
            s += board[position].toString();
        }
    }

    var hash = 0;
    if (s.length === 0) return hash;

    for (var i = 0; i < s.length; i++) {
        var chr = s.charCodeAt(i);
        hash = ((hash << 5) - hash) + chr;
        hash |= 0;
    }

    return hash;
};


// https://stackoverflow.com/a/20339709
// удаляет дубликаты из массива и возвращает массив без повторяющихся элементов
function _unique(array_with_duplicates) {
    var array_uniques = [];
    var items_found = {};
    for (var i = 0, l = array_with_duplicates.length; i < l; i++) {
        var stringified = JSON.stringify(array_with_duplicates[i]);
        if (items_found[stringified]) {
            continue;
        }
        array_uniques.push(array_with_duplicates[i]);
        items_found[stringified] = true;
    }
    return array_uniques;
}

// вычисляет оценку и площади для каждого цвета в игре
// оценка игрока зависит от числа занятых позиций и площадей, принадлежащих ему
function _update_score(num_colors, num_rows, num_cols, board, groups, position_to_group) {

    var score = {};
    var areas = {};

    for (var color = 1; color <= num_colors; color++) {
        score[color] = 0;
        areas[color] = [];
    }

    // сначала мы находим пустые области, которые касаются только одного цвета
    for (var key in groups) {
        var color = groups[key]["color"];
        if (color == EMPTY) {
            var bounding_colors = Object.keys(groups[key]["bounds"]);
            if (bounding_colors.length == 1) {
                areas[bounding_colors[0]].push(Number(key));
            }
        }
    }

    // затем мы добавляем все камни и области, которые принадлежат к одному цвету
    var isFirstMove = true;
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            var position = [col, row];
            if (board[position] == EMPTY) {
                var current_group = position_to_group[position];
                for (var color = 1; color <= num_colors; color++) {
                    if (areas[color].includes(current_group)) {
                        score[color] += 1;
                    }
                }
            } else {
                score[board[position]] += 1;
            }
        }
    }

    return score;
}

// находит и группирует камни на доске в соответствии с их цветом и доступными позициями и определяет грани между группами
function _compute_groups(board, num_rows, num_cols) {
    var groups = {};
    var position_to_group = _reset(num_rows, num_cols, 0);

    var current_group = 1;
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            var position = [col, row];

            // пропустить, если эта позиция уже принадлежит группе
            if (position_to_group[position] > 0) {
                continue;
            }

            if (!(current_group in groups)) {
                groups[current_group] = {};
                groups[current_group]["bounds"] = {};
            }

            var current_color = board[position];
            groups[current_group]["color"] = current_color;

            for (var neighbor of _get_neighbors(position)) {
                var t = _visit_neighbor(board,
                    num_rows,
                    num_cols,
                    neighbor,
                    current_color,
                    current_group,
                    groups,
                    position_to_group);
                groups = t[0];
                position_to_group = t[1];
            }

            position_to_group[position] = current_group;
            current_group++;
        }
    }

    return [groups, position_to_group];
}

// удаляет группу камней с доски. Это происходит, когда группа больше не имеет свободных позиций для хода
function _remove_group(board,
    num_rows,
    num_cols,
    color_current_move,
    group,
    position_to_group) {
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            if (position_to_group[[row, col]] == group) {

                if (board[[row, col]] != color_current_move) {
                    board[[row, col]] = EMPTY;
                }
            }
        }
    }
    return board;
}

//очевидно
function _get_neighbors(position) {
    var x = position[0];
    var y = position[1];

    return [
        [x - 1, y],
        [x + 1, y],
        [x, y - 1],
        [x, y + 1]
    ];
}

//рекурсивно исследует соседние клетки и объединяет их в группу камней, если они имеют одинаковый цвет
function _visit_neighbor(board,
    num_rows,
    num_cols,
    neighbor,
    current_color,
    current_group,
    groups,
    position_to_group) {

    // скип, если сосед находится снаружи
    if (_position_outside_board(neighbor, num_rows, num_cols)) {
        return [groups, position_to_group];
    }

    // если сосед отличается, добавляем к границам этой группы
    var neighbor_color = board[neighbor];
    if (neighbor_color != current_color) {

        if (neighbor_color in groups[current_group]["bounds"]) {
            groups[current_group]["bounds"][neighbor_color].push(neighbor);
        } else {
            groups[current_group]["bounds"][neighbor_color] = [neighbor];
        }

        // удаление дубликатов
        groups[current_group]["bounds"][neighbor_color] = _unique(groups[current_group]["bounds"][neighbor_color]);

        return [groups, position_to_group];
    }

    // пропустить, если эта позиция уже принадлежит группе
    if (position_to_group[neighbor] > 0) {
        return [groups, position_to_group];
    }

    // сосед имеет такой же цвет, добавляем его в эту группу
    // и посещаем его соседей
    position_to_group[neighbor] = current_group;
    for (var _neighbor of _get_neighbors(neighbor)) {
        var t = _visit_neighbor(board,
            num_rows,
            num_cols,
            _neighbor,
            current_color,
            current_group,
            groups,
            position_to_group);
        groups = t[0];
        position_to_group = t[1];
    }

    return [groups, position_to_group];
}

// проверяет находится ли данная позиция за пределами доски
function _position_outside_board(position, num_rows, num_cols) {
    var x = position[0];
    var y = position[1];

    if (x < 1) return true;
    if (x > num_cols) return true;
    if (y < 1) return true;
    if (y > num_rows) return true;

    return false;
}

// находит группы камней, которые не имеют свободных позиций, важно для определения, могут ли они быть удалены с доски
function _find_groups_without_liberties(groups) {
    var r = [];
    for (var key in groups) {
        if (groups[key]["color"] > EMPTY) {
            if (!(EMPTY in groups[key]["bounds"])) {
                r.push(key);
            }
        }
    }
    return r;
}

//создает и возвращает начальное состояние игровой доски с указанным размером и начальным значением
function _reset(num_rows, num_cols, value) {
    var array = {};
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            array[[row, col]] = value;
        }
    }
    return array;
}


function _copy_board(old_board, num_rows, num_cols) {
    var new_board = {};
    for (var row = 1; row <= num_rows; row++) {
        for (var col = 1; col <= num_cols; col++) {
            new_board[[row, col]] = old_board[[row, col]];
        }
    }
    return new_board;
}


function _array_contains_tuple(a, t) {
    for (const element of a) {
        if (t[0] == element[0] && t[1] == element[1]) {
            return true;
        }
    }
    return false;
}

//проверяет, является ли данная позиция на доске "хоши" (особые точки на доске Го)
//это короче крутые точки (выделены жирными точками на доске) которые выжны для стратегии в игре (очевидно не про нас)
//как говорит интернет:
// На доске 19x19 обычно есть следующие хоши:
// Центральный хоши (один в центре доски).
// Угловые хоши (четыре, по одному в каждом углу доски).
// Боковые хоши (четыре, по два на каждой стороне доски).
//Игроки часто стремятся контролировать или использовать эти хоши в ходе игры, так как они представляют собой важные точки для создания территории, захвата и защиты групп, 
//а также для развития стратегии. Хоши также играют важную роль в оценке доски в конце игры, так как они часто считаются пространством, которое приносит очки игрокам.
function _is_hoshi(row, col, num_rows, num_cols) {

    var stars = [];

    stars.push([(num_rows + 1) / 2, (num_cols + 1) / 2]);
    
    if (num_rows == 9 && num_cols == 9) {
        stars.push([3, 3]);
        stars.push([3, 7]);
        stars.push([7, 3]);
        stars.push([7, 7]);
        return _array_contains_tuple(stars, [row, col]);
    }

    if (num_rows == 11 && num_cols == 11) {
        stars.push([3, 3]);
        stars.push([3, 9]);
        stars.push([9, 3]);
        stars.push([9, 9]);
        return _array_contains_tuple(stars, [row, col]);
    }

    if (num_rows == 13 && num_cols == 13) {
        stars.push([4, 4]);
        stars.push([4, 10]);
        stars.push([10, 4]);
        stars.push([10, 10]);
        return _array_contains_tuple(stars, [row, col]);
    }

    stars.push([4, 4]);
    stars.push([4, 10]);
    stars.push([4, 16]);
    stars.push([10, 4]);
    stars.push([10, 16]);
    stars.push([16, 4]);
    stars.push([16, 10]);
    stars.push([16, 16]);
    return _array_contains_tuple(stars, [row, col]);
}

Vue.component('stone-shadow', {
    props: ['cx', 'cy'],
    template: `<g>
                 <circle :cx="cx" :cy="cy" r="12" fill="black" :fill-opacity="0.2"/>
               </g>`
})


Vue.component('stone', {
    props: ['cx', 'cy', 'fill'],
    template: `<g>
                 <circle :cx="cx" :cy="cy" r="12" :fill="fill" />
               </g>`
})


Vue.component('board-corner', {
    props: ['rotate'],
    template: `<g :transform="rotate">
                 <rect x="14.0"
                       y="15.0"
                       width="2.0"
                       height="15.0"
                       fill="#533939" />
                 <rect x="14.0"
                       y="14.0"
                       width="16.0"
                       height="2.0"
                       fill="#533939" />
               </g>`
})


Vue.component('board-edge', {
    props: ['rotate'],
    template: `<g :transform="rotate">
                 <rect x="14.5"
                       y="15.0"
                       width="1.0"
                       height="15.0"
                       fill="#533939" />
                 <rect x="0.0"
                       y="14.0"
                       width="30.0"
                       height="2.0"
                       fill="#533939" />
               </g>`
})


Vue.component('board-any', {
    template: `<g>
                 <rect x="14.5"
                       y="0.0"
                       width="1.0"
                       height="30.0"
                       fill="#533939" />
                 <rect x="0.0"
                       y="14.5"
                       width="30.0"
                       height="1.0"
                       fill="#533939" />
               </g>`
})


Vue.component('board-hoshi', {
    template: `<g>
                 <rect x="14.5"
                       y="0.0"
                       width="1.0"
                       height="30.0"
                       fill="#533939" />
                 <rect x="0.0"
                       y="14.5"
                       width="30.0"
                       height="1.0"
                       fill="#533939" />
                 <circle cx="15.0" cy="15.0" r="2.5" fill="#533939" />
               </g>`
})


Vue.component('board-grid', {
    props: ['col', 'row', 'num_cols', 'num_rows'],
    render(createElement) {

        // верхний левый
        if (this.col == 1 && this.row == 1) {
            return createElement('board-corner', {
                props: {
                    rotate: "rotate(0 15 15)"
                }
            });
        }

        // вверху справа
        if (this.col == this.num_cols && this.row == 1) {
            return createElement('board-corner', {
                props: {
                    rotate: "rotate(90 15 15)"
                }
            });
        }

        // нижний левый
        if (this.col == 1 && this.row == this.num_rows) {
            return createElement('board-corner', {
                props: {
                    rotate: "rotate(270 15 15)"
                }
            });
        }

        // нижний правый
        if (this.col == this.num_cols && this.row == this.num_rows) {
            return createElement('board-corner', {
                props: {
                    rotate: "rotate(180 15 15)"
                }
            });
        }

        // верхний край
        if (this.row == 1) {
            return createElement('board-edge', {
                props: {
                    rotate: "rotate(0 15 15)"
                }
            });
        }

        // нижний край
        if (this.row == this.num_rows) {
            return createElement('board-edge', {
                props: {
                    rotate: "rotate(180 15 15)"
                }
            });
        }

        // левый край
        if (this.col == 1) {
            return createElement('board-edge', {
                props: {
                    rotate: "rotate(270 15 15)"
                }
            });
        }

        // правый край
        if (this.col == this.num_cols) {
            return createElement('board-edge', {
                props: {
                    rotate: "rotate(90 15 15)"
                }
            });
        }

        // где-то посередине
        if (_is_hoshi(this.row, this.col, this.num_rows, this.num_cols)) {
            return createElement('board-hoshi');
        } else {
            return createElement('board-any');
        }
    }
})

var app = new Vue({
    el: '#app',
    data: {
        board_size: 9,
        num_rows: 9,
        num_cols: 9,
        num_players: 2,
        num_colors: 2,
        score: {
            "1": 0,
            "2": 0
        },
        show_score: true,
        color_current_move: null,
        board: null,
        hashes: [],
        shadow_opacity: null, // показывает тени с возможным будущим размещением камней при наведении курсора мыши на доску
        num_consecutive_passes: null,
        num_moves: null,
    },
    created() {
        this.reset();
    },
    methods: {
        mouse_over: function(x, y) {
            this.shadow_opacity[[x, y]] = 0.5;
        },
        mouse_out: function(x, y) {
            this.shadow_opacity[[x, y]] = 0.0;
        },
        _switch_player: function() {
            this.color_current_move += 1;
            if (this.color_current_move > this.num_colors) {
                this.color_current_move = 1;
            }
        },
        pass: function() {
            this.num_consecutive_passes += 1;
            this.num_moves += 1;
            this._switch_player();
        },
        click: function(x, y) {
            if (this.board[[x, y]] != EMPTY) {
                // мы не можем положить камень на другой камень
                return;
            }

            // мы берем копию, поскольку перемещение может быть
            // запрещено - только после того, как мы узнаем, что это законное перемещение
            // мы обновляем this.board
            var temp_board = _copy_board(this.board, this.num_rows, this.num_cols);
            temp_board[[x, y]] = this.color_current_move;

            // правило ко
            //короче придумали миллиард правил, сразу статья из интернета:
            // Суть правила ко заключается в следующем:
            // 1) Если игровая ситуация повторяется точно так же, как и в предыдущем ходе (кроме текущего хода), то игрок не может повторить ход и сделать ход в том же месте.
            // 2) Если игрок все равно хочет сделать ход в точно такой же позиции (то есть создать снова ту же игровую ситуацию), он должен сначала сделать другой ход на доске. 
            // Только после этого он может вернуться и сделать ход в той же позиции, если она осталась доступной
            // очевидно предотвращает бесконечные циклы и чтобы Бушуева в одно место миллиард раз не пыталась поставить
            var hash = _hash(this.num_rows, this.num_cols, temp_board);
            if (this.hashes.includes(hash)) {
                return;
            }

            var t = _compute_groups(temp_board, this.num_rows, this.num_cols);
            var groups = t[0];
            var position_to_group = t[1];

            var groups_without_liberties = _find_groups_without_liberties(groups);

            if (groups_without_liberties.length == 1) {
                var current_group = position_to_group[[x, y]]
                if (groups_without_liberties[0] == current_group) {
                    // само-захват запрещен (это чтобы игрок не ходил туда где установка камня приведет к захвату противником твоих камней)
                    return;
                }
            }

            for (var group of groups_without_liberties) {
                temp_board = _remove_group(temp_board,
                    this.num_rows,
                    this.num_cols,
                    this.color_current_move,
                    group,
                    position_to_group);
            }

            this.num_consecutive_passes = 0;
            this.num_moves += 1;
            this._switch_player();
            this.board = _copy_board(temp_board, this.num_rows, this.num_cols);

            var t = _compute_groups(this.board, this.num_rows, this.num_cols);
            var groups = t[0];
            var position_to_group = t[1];
            this.score = _update_score(this.num_colors, this.num_rows, this.num_cols, this.board, groups, position_to_group);
            this.hashes.push(hash);
        },
        reset: function() {
            this.num_rows = parseInt(this.board_size);
            this.num_cols = parseInt(this.board_size);
            this.num_colors = parseInt(this.num_players);
            this.score = {};
            for (var color = 1; color <= this.num_colors; color++) {
                this.score[color] = 0;
            }
            this.color_current_move = 1;
            this.board = _reset(this.num_rows, this.num_cols, EMPTY);
            this.hashes = [];
            this.shadow_opacity = _reset(this.num_rows, this.num_cols, 0.0);
            this.num_consecutive_passes = 0;
            this.num_moves = 1;
        },
        color: function(n) {
            let colors = ['black', 'white'];
            return colors[n - 1];
        }
    }
})
