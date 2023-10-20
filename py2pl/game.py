from swiplserver import PrologMQI, PrologThread, create_posix_path, prologmqi
import flask

from flask import Flask
from flask import request
from flask_cors import CORS, cross_origin

class Game:
    mqi = PrologMQI(password="aboba")
    prolog = mqi.create_thread()

    def startGame(self):
        self.mqi.stop()
        self.mqi = PrologMQI(password="aboba")
        self.mqi.start()
        self.prolog = self.mqi.create_thread()
        print(self.mqi.pending_connections)
        path = create_posix_path("/Users/delta-null/Documents/GitHub/Go_game/Computer vs Human (Single player).pl")
        self.prolog.query(f'consult("{path}").')
        self.prolog.query(f'new_game.')

    def step(self, position):
        print(f'bbb')
        try:
            self.prolog.query(f'play({position}).',3)
        except prologmqi.PrologQueryTimeoutError:
            pass
        print(f'aaa')

        self.mqi = PrologMQI(password="aboba")
        self.prolog = self.mqi.create_thread()
        path = create_posix_path("/Users/delta-null/Documents/GitHub/Go_game/Computer vs Human (Single player).pl")
        self.prolog.query(f'consult("{path}").')
        self.prolog.query(f'read_file.')
        self.prolog.query_async('state(X).', find_all=True)
        answer = self.prolog.query_async_result(5)
        print(f'ans: {answer}')
        return answer


game = Game()
game.startGame()

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route("/step")
@cross_origin()
def hello_world():
    pos = int(request.args.get('position'))
    return game.step(pos)[0]['X']

@app.route("/new_game")
@cross_origin()
def hello_world2():
    game.startGame()
    return ""

if __name__ == "__main__":
    app.run(host="localhost", port=5000, debug=True)


# s = socket.socket(-1, -1)
# s.bind(('localhost', 22841)) # Привязываем серверный сокет к localhost и 3030 порту.
# s.listen() # Начинаем прослушивать входящие соединения
# conn, addr = s.accept() # Метод который принимает входящее соединение.
# print('fin')

# conn.sendall(b'aaaaa')
# data = conn.recv(1024) # Получаем данные из сокета.
# # conn.sendall(data) # Отправляем данные в сокет.
# print(data.decode('utf-8')) # Выводим информацию на печать.

# data = conn.recv(1024) # Получаем данные из сокета.
# print(data.decode('utf-8')) # Выводим информацию на печать.

# data = conn.recv(1024) # Получаем данные из сокета.
# print(data.decode('utf-8')) # Выводим информацию на печать.

# while True: # Создаем вечный цикл.
	# data = conn.recv(1024) # Получаем данные из сокета.
	# if not data:
	# 	break
	# conn.sendall(data) # Отправляем данные в сокет.
	# print(data) # Выводим информацию на печать.
# conn.close()
# print('end')