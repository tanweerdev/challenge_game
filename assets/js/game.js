let game = {
    init(socket) {
        let name = document.querySelector("#name").innerHTML;
        let currentPosition = {
            player: {
                name: name
            }
        }
        let channel = socket.channel("game:lobby", currentPosition)
        channel.join()
        this.listenForMoves(channel)
    },

    listenForMoves(channel) {
        let name = document.querySelector("#name").innerHTML;
        window.addEventListener("keydown", (event) => {
            let moveKey = event.key.split("Arrow")[1]
            if (moveKey) {
                this['move'](channel, `${moveKey.toLowerCase()}`)
            }
        })
        document.querySelectorAll(".movement").forEach((element, _) => {
            element.addEventListener("click", (event) => this['move'](channel, event.target.getAttribute("direction")))
        });
        document.querySelector(".attack-btn").addEventListener("click", () => this.attack(channel));
        channel.on('movement', payload => {
            this.updatePosition(payload)
        })
        channel.on("user:" + name + ":attacked", payload => {
            setTimeout(() => {
                let player = {
                    player: {
                        name: name
                    }
                }
                channel.push("rejoin", player)
            }, 5000)
        })
    },
    updatePosition(payload) {
        let name = document.querySelector("#name").innerHTML;
        if (document.querySelector(".bot")) {
            document.querySelector(".bot").classList.remove("bot");
        }
        document.querySelectorAll(".enemy").forEach((enemy, _) => {
            enemy.classList.remove("enemy");
        })
        if (document.querySelector(`.bot-${name}`)) {
            document.querySelector(`.bot-${name}`).classList.remove(`bot-${name}`);
        }
        this.setPosition(payload)
    },
    setPosition(payload) {
        let name = document.querySelector("#name").innerHTML;
        for (var player in payload.players) {
            let postition = document.querySelector(`.row-${payload.players[player]["x"]} > .col-${payload.players[player]["y"]}`);
            if (player == name) {
                postition.classList.add("bot");
                postition.classList.add(`bot-${name}`);
            } else {
                postition.classList.add("enemy");
            }
        }
    },
    move(channel, movement) {
        let currentPosition = this.getCurrentPosition()
        if (this.isNewPositionWalkable(currentPosition) == true) {
            channel.push("movement", movement)
        }
    },
    getCurrentPosition() {
        let name = document.querySelector("#name").innerHTML;
        let id = document.querySelector(`.bot-${name}`).id.split("_");
        let row = parseInt(id[0].split("-")[1]);
        let column = parseInt(id[1].split("-")[1]);
        let obj = {
            name: name,
            x: row,
            y: column
        }
        return obj;
    },
    isNewPositionWalkable(position) {
        let row = position.x
        let col = position.y
        if ((row == 5 && col == 5) || (row == 5 && col == 4) || (row == 5 && col == 3) || (row == 5 && col == 2) || (row == 5 && col == 6) || (row == 6 && col == 4)) {
            return false
        } else {
            return true
        }
    },
    attack(channel) {
        channel.push("attack", {});
    }
}



export default game;