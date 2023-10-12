document.addEventListener("DOMContentLoaded", function () {
    const board = document.getElementById("game-board");
    const status = document.getElementById("status");
    const resetButton = document.getElementById("reset-button");

    const gameContainer = document.getElementById("game-container");
    const cube = document.querySelector(".Cube");
    const transitionOverlay = document.getElementById("transition-overlay");

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
    }

    // Добавьте слушатель события для выпадающего списка
    const boardSizeSelect = document.getElementById("board-size");
    boardSizeSelect.addEventListener("change", handleBoardSizeChange);

    // Инициализируем доску при загрузке страницы
    initializeBoard();

    function handleCellClick(event) {
        const cell = event.target;
        const index = cell.getAttribute("data-index");
        cell.classList.add("zero");
        // cell.classList.add("cross");
    }

    board.addEventListener("click", handleCellClick);

    // Функция обновления отображения статуса игры
    function updateStatus(message) {
        status.textContent = message;
    }

    function resetGame() {
        const cells = document.querySelectorAll(".grid-cell");
        cells.forEach(function (cell) {
            cell.classList.remove("zero", "cross");
        });
    }

    resetButton.addEventListener("click", resetGame);

});

