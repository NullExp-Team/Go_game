const board = document.querySelector('.board');

function createBoard() {
    for (let i = 0; i < 10; i++) {
      for (let j = 0; j < 10; j++) {
        const intersection = document.createElement('div');
        intersection.className = 'intersection';
  
        intersection.addEventListener('click', placeStone);
  
        const cell = document.createElement('div');
        cell.className = 'cell';
        cell.dataset.row = i;
        cell.dataset.col = j;
  
        intersection.appendChild(cell);
        board.appendChild(intersection);
      }
    }
  }

function placeStone(event) {
    const cell = event.target;
    const stone = document.createElement('div');
    stone.className = 'stone';

    if (isEven(parseInt(cell.dataset.row)) && isEven(parseInt(cell.dataset.col))) {
        stone.classList.add('black-stone');
    } else if (!isEven(parseInt(cell.dataset.row)) && !isEven(parseInt(cell.dataset.col))) {
        stone.classList.add('black-stone');
    } else {
        stone.classList.add('white-stone');
    }

    cell.appendChild(stone);
}

function isEven(num) {
    return num % 2 === 0;
}

createBoard();
