# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


constants = {"game_1": "GAME 1",
             "description_siciliana": "Si el segundo jugador en jugar en una ronda duda,
                                    el perdedor de la acción pierde dos dados en vez de uno",
             "description_picado": "Si un jugador posee dos ases, puede picar. Cuando un jugador pica, el sentido del juego cambia.
                                    El siguiente jugador solamente puede dudar el picado o seguir jugando.",
             "description_paso": "Si un jugador posee 5 dados y todos estos son iguales, distintos o tiene un trio y un par, puede pasar.
                                  Cuando un jugador pasa, le toca al siguiente jugador y este solamente puede seguir juganddo o dudar el paso",
             "description_cambio_as": "En cualquier momento un jugador puede cambiar la cantidad de dados a la mitad más uno de ases.\n Ej: Si tiene 7 cuadras puede decir 4 ases.\n
                                        Si otro jugador desea volver a otra pinta, debe decir duplicar el numero de dados. \n Ej: Si tiene 3 ases puede decir 7 de algo "
              }

User.create(email: "pgrand@miuandes.cl", password: "password")
User.create(email: "ijfigueroa@miuandes.cl", password: "password")
User.create(email: "vicorrea@miuandes.cl", password: "password")
User.create(email: "mmestevez@miuandes.cl", password: "password")
User.create(email: "mrecabarren@miuandes.cl", password: "password")

Profile.create(nickname: 'Pedrito ElCaja Grand', user_id: 1)
Profile.create(nickname: 'Ignacio ElAngry Figueroa', user_id: 2)
Profile.create(nickname: 'Vicente ElHacker Correa', user_id: 3)
Profile.create(nickname: 'Margarita LaAyudante Estevez', user_id: 4)
Profile.create(nickname: 'Matias SeCayoSaf Recabarren', user_id: 5)

Friend.create(user_sender_id: 1, user_receiver_id: 2, state: 2)
Friend.create(user_sender_id: 1, user_receiver_id: 3, state: 2)
Friend.create(user_sender_id: 1, user_receiver_id: 4, state: 1)
Friend.create(user_sender_id: 1, user_receiver_id: 5, state: 0)

Friend.create(user_sender_id: 2, user_receiver_id: 3, state: 2)
Friend.create(user_sender_id: 2, user_receiver_id: 4, state: 2)
Friend.create(user_sender_id: 2, user_receiver_id: 5, state: 0)

Rule.create(name: "Siciliana", description: constants["description_siciliana"])
Rule.create(name: "Picado", description: constants["description_picado"])
Rule.create(name: "Paso", description: constants["description_paso"])
Rule.create(name: "Cambio a As", description: constants["description_cambio_as"])


Game.create(name: constants["game_1"], finished: true)
GameRule.create(rule_id: 4, game_id:1)

GameUser.create(user_id: 1, game_id: 1, position: 1, final_place: nil, accepted: true)
GameUser.create(user_id: 2, game_id: 1, position: 2, final_place: nil, accepted: true)
GameUser.create(user_id: 3, game_id: 1, position: 3, final_place: nil, accepted: true)

Round.create(game_id: 1, user_action_id: 1, action: false, success: true)
Round.create(game_id: 1, user_action_id: 3, action: nil, success: nil)

Hand.create(user_id: 1, round_id: 1)
Hand.create(user_id: 2, round_id: 1)
Hand.create(user_id: 3, round_id: 1)

Dice.create(hand_id: 1, suit_id: 1)
Dice.create(hand_id: 1, suit_id: 1)
Dice.create(hand_id: 1, suit_id: 3)
Dice.create(hand_id: 1, suit_id: 4)
Dice.create(hand_id: 1, suit_id: 5)

Dice.create(hand_id: 2, suit_id: 1)
Dice.create(hand_id: 2, suit_id: 2)
Dice.create(hand_id: 2, suit_id: 3)
Dice.create(hand_id: 2, suit_id: 4)
Dice.create(hand_id: 2, suit_id: 5)

Dice.create(hand_id: 3, suit_id: 3)
Dice.create(hand_id: 3, suit_id: 3)
Dice.create(hand_id: 3, suit_id: 2)
Dice.create(hand_id: 3, suit_id: 2)
Dice.create(hand_id: 3, suit_id: 2)

Turn.create(round_id: 1, user_id: 1, rule_id: nil, suit_id: 4, quantity: 4)
Turn.create(round_id: 1, user_id: 2, rule_id: nil, suit_id: 6, quantity: 4)
Turn.create(round_id: 1, user_id: 3, rule_id: nil, suit_id: 6, quantity: 5)

Hand.create(user_id: 1, round_id: 2)
Hand.create(user_id: 2, round_id: 2)
Hand.create(user_id: 3, round_id: 2)

Dice.create(hand_id: 4, suit_id: 1)
Dice.create(hand_id: 4, suit_id: 1)
Dice.create(hand_id: 4, suit_id: 3)
Dice.create(hand_id: 4, suit_id: 3)
Dice.create(hand_id: 4, suit_id: 5)

Dice.create(hand_id: 5, suit_id: 3)
Dice.create(hand_id: 5, suit_id: 2)
Dice.create(hand_id: 5, suit_id: 1)
Dice.create(hand_id: 5, suit_id: 1)
Dice.create(hand_id: 5, suit_id: 1)

Dice.create(hand_id: 6, suit_id: 5)
Dice.create(hand_id: 6, suit_id: 5)
Dice.create(hand_id: 6, suit_id: 6)
Dice.create(hand_id: 6, suit_id: 4)

Turn.create(round_id: 1, user_id: 1, rule_id: nil, suit_id: 4, quantity: 4)
Turn.create(round_id: 1, user_id: 2, rule_id: nil, suit_id: 6, quantity: 4)
Turn.create(round_id: 1, user_id: 3, rule_id: nil, suit_id: 6, quantity: 5)
Turn.create(round_id: 1, user_id: 1, rule_id: 4, suit_id: 1, quantity: 3)
Turn.create(round_id: 1, user_id: 2, rule_id: nil, suit_id: 1, quantity: 4)
Turn.create(round_id: 1, user_id: 3, rule_id: 4, suit_id: 6, quantity: 9)














