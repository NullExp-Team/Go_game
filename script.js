var values = ['-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-']
var invalids = []
playerScore = 0
computerScore = 0

document.addEventListener("DOMContentLoaded", function () {
    const board = document.getElementById("game-board");
    const status = document.getElementById("status");
    const resetButton = document.getElementById("reset-button");

    const gameContainer = document.getElementById("game-container");
    const cube = document.querySelector(".Cube");
    const transitionOverlay = document.getElementById("transition-overlay");

    let player1Score = 0;
    let PCScore = 0;
    let currentPlayer = 1;

    cube.addEventListener("click", function () {
        let xhr = new XMLHttpRequest();
        xhr.open('GET', 'http://127.0.0.1:5000/new_game');
        xhr.send();

        setTimeout(() => {
            cube.classList.add("hide");
        }, 2000)

        transitionOverlay.classList.add("show");

        setTimeout(() => {
            cube.style.display = "none";
            transitionOverlay.classList.remove("show");
            gameContainer.style.display = "block";
        }, 2500);
    });

    function initializeBoard() {
        const boardSizeSelect = document.getElementById("board-size");
        const selectedSize = parseInt(boardSizeSelect.value, 10);

        board.innerHTML = '';

        const gridSize = Math.sqrt(selectedSize);
        board.style.gridTemplateColumns = `repeat(${gridSize}, 1fr)`;

        for (let i = 0; i < selectedSize; i++) {
            const cell = document.createElement("div");
            cell.id = "cell_" + i;
            cell.classList.add("grid-cell");
            cell.setAttribute("data-index", i);
            board.appendChild(cell);
        }
    }

    initializeBoard();

    function updateBoard() {
        const boardSizeSelect = document.getElementById("board-size");
        const selectedSize = parseInt(boardSizeSelect.value, 10);
        console.log(values)
        for (let i = 0; i < selectedSize; i++) {
            let cell = document.getElementById('cell_' + i)
            console.log(cell.id, i, values[i]);
            
            cell.classList.remove('cross');
            cell.classList.remove('zero');
            cell.classList.remove('block');    
            if (values[i] == 'x') {
                cell.classList.add("cross");
            } else if (values[i] == 'o') {
                cell.classList.add("zero");
            } else {
                if (invalids.includes(i)) {
                    cell.classList.add('block');
                }
                cell.classList.remove('cross');
                cell.classList.remove('zero');    
            }
        }
    }

    // Обработчик изменения выбора размера доски
    function handleBoardSizeChange() {
        initializeBoard();
        resetGame();
    }

    // Добавьте слушатель события для выпадающего списка
    const boardSizeSelect = document.getElementById("board-size");
    boardSizeSelect.addEventListener("change", handleBoardSizeChange);

    function handleCellClick(event) {     
        const cell = event.target;
        const index = cell.getAttribute("data-index");

        let xhr = new XMLHttpRequest();
        xhr.open('GET', 'http://127.0.0.1:5000/step?position=' + index);
        xhr.send();

        // 4. Этот код сработает после того, как мы получим ответ сервера
        xhr.onload = function() {
            if (xhr.status == 200) {
                console.log(xhr.response)
                values = JSON.parse(JSON.stringify(eval('(' + xhr.response + ')')))['X']
                invalids = JSON.parse(JSON.stringify(eval('(' + xhr.response + ')')))['Y']
                playerScore = JSON.parse(JSON.stringify(eval('(' + xhr.response + ')')))['Z']
                computerScore = JSON.parse(JSON.stringify(eval('(' + xhr.response + ')')))['V']
                console.log(values)
                updateBoard()
                updatePlayer1Score()
                updatePCScore()
            }
        };
        
        cell.classList.add("cross");
        PCScore++; 
        updatePCScore();
    }

    board.addEventListener("click", handleCellClick);

    function updatePlayer1Score() {
        const player1ScoreElement = document.getElementById("player1-score");
        player1ScoreElement.textContent = `You: ${playerScore}`;
    }
    
    function updatePCScore() {
        const PCScoreElement = document.getElementById("PC-score");
        PCScoreElement.textContent = `PC: ${computerScore}`;
    }    

    function resetGame() {
        let xhr = new XMLHttpRequest();
        xhr.open('GET', 'http://127.0.0.1:5000/new_game');
        xhr.send();

        const cells = document.querySelectorAll(".grid-cell");
        cells.forEach(function (cell) {
            cell.classList.remove("zero", "cross", "block");
        });

        playerScore = 0;
        computerScore = 0;
        updatePlayer1Score();
        updatePCScore();
    }

    resetButton.addEventListener("click", resetGame);

});