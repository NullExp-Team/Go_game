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
            cell.classList.add("grid-cell");
            cell.setAttribute("data-index", i);
            board.appendChild(cell);
        }
    }

    initializeBoard();

    // Обработчик изменения выбора размера доски
    function handleBoardSizeChange() {
        initializeBoard();
        resetGame();
    }

    // Добавьте слушатель события для выпадающего списка
    const boardSizeSelect = document.getElementById("board-size");
    boardSizeSelect.addEventListener("change", handleBoardSizeChange);

    function handleCellClick(event) {
        // const cell = event.target;
        // const index = cell.getAttribute("data-index");
        // cell.classList.add("zero");
        // cell.classList.add("cross");

        const cell = event.target;
        const index = cell.getAttribute("data-index");
        
        if (!cell.classList.contains("zero") && !cell.classList.contains("cross")) {
            if (currentPlayer === 1) {
                cell.classList.add("zero");
                player1Score++;
                updatePlayer1Score();
            } else if (currentPlayer === 2) {
                cell.classList.add("cross");
                PCScore++; 
                updatePCScore();
            }

            currentPlayer = currentPlayer === 1 ? 2 : 1;
        }
    }

    board.addEventListener("click", handleCellClick);

    function updatePlayer1Score() {
        const player1ScoreElement = document.getElementById("player1-score");
        player1ScoreElement.textContent = `You: ${player1Score}`;
    }
    
    function updatePCScore() {
        const PCScoreElement = document.getElementById("PC-score");
        PCScoreElement.textContent = `PC: ${PCScore}`;
    }    

    function resetGame() {
        const cells = document.querySelectorAll(".grid-cell");
        cells.forEach(function (cell) {
            cell.classList.remove("zero", "cross");
        });

        player1Score = 0;
        PCScore = 0;
        updatePlayer1Score();
        updatePCScore();
    }

    resetButton.addEventListener("click", resetGame);

});

