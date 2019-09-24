# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


User.create(email:"pgrand@miuandes.cl",password:"password")
User.create(email:"ijfigueroa@miuandes.cl",password:"password")
User.create(email:"vicorrea@miuandes.cl",password:"password")
User.create(email:"mmestevez@miuandes.cl",password:"password")
User.create(email:"mrecabarren@miuandes.cl",password:"password")
Profile.create(nickname: 'Pedrito ElCaja Grand', user_id: 1)
Profile.create(nickname: 'Ignacio ElAngry Figueroa', user_id: 2)
Profile.create(nickname: 'Vicente ElHacker Correa', user_id: 3)
Profile.create(nickname: 'Margarita LaAyudante Estevez', user_id: 4)
Profile.create(nickname: 'Matias SeCayoSaf Recabarren', user_id: 4)
Friends.create(user_sender_id: 1, user_receiver_id: 2, state: 2)
Friends.create(user_sender_id: 1, user_receiver_id: 3, state: 2)
Friends.create(user_sender_id: 1, user_receiver_id: 4, state: 1)
Friends.create(user_sender_id: 1, user_receiver_id: 5, state: 0)

Friends.create(user_sender_id: 2, user_receiver_id: 3, state: 2)
Friends.create(user_sender_id: 2, user_receiver_id: 4, state: 2)
Friends.create(user_sender_id: 2, user_receiver_id: 5, state: 0)









