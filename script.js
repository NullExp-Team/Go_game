document.addEventListener("DOMContentLoaded", function () {
    const board = document.getElementById("game-board");
    const status = document.getElementById("status");
    const resetButton = document.getElementById("reset-button");

    // Функция для инициализации доски
    function initializeBoard() {
        for (let i = 0; i < 25; i++) {
            const cell = document.createElement("div");
            cell.classList.add("grid-cell");
            cell.setAttribute("data-index", i);
            board.appendChild(cell);
        }
    }

    initializeBoard();

    // Функция для обработки щелчка по ячейке
    function handleCellClick(event) {
        const cell = event.target;
        const index = cell.getAttribute("data-index");
        cell.classList.add("black");

    }

    board.addEventListener("click", handleCellClick);

    // Функция обновления отображения статуса игры
    function updateStatus(message) {
        status.textContent = message;
    }

    // Функция перезагрузки игры
    function resetGame() {
        const cells = document.querySelectorAll(".grid-cell");
        cells.forEach(function (cell) {
            cell.classList.remove("black", "white");
        });
    }

    resetButton.addEventListener("click", resetGame);
});

