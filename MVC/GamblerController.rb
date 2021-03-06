require_relative 'Gambler.rb'
require_relative 'GamblerView.rb'
require_relative '../ObserverPattern/Observer.rb'

class GamblerController < Object
	include Observer
	attr_reader :model
	def initialize
		super()
		@model = Gambler.new
		@view = GamblerView.new
		@bet_list = Hash.new([])
	end

	def createUser
		data = @view.createView
		@model.setUsername(data[0])
		@model.setPassword(data[1])
		@model.setCoins(data[2])
		@bet_list
	end
	def profileInfo
		@view.showProfileInfo(@model.username,@model.password,@model.coins)
	end
	def updateUser
		data = @view.updateView
		@model.setPassword(data[0])
		@model.setCoins(data[1])
	end
	def registBet(event_id,betController)
		if !(@bet_list.key?(event_id))
			@bet_list[event_id]=[]
		end
		@bet_list[event_id].push(betController)
		@model.setCoins(@model.coins - betController.model.value)
	end

	def printBets
		@bet_list.each do |key, value|
      value.each do |bet|
				bet.updateView
			end
    end
	end
	def updateView
		@view.printView(@model.username,@model.coins)
	end

	def addCoins(coins)
		@model.setCoins(@model.coins+coins)
	end

	def createDefaultGambler(name, pass, coins)
		@model.setUsername(name)
		@model.setPassword(pass)
		@model.setCoins(coins)
	end

	def storeNotification(message)
		@model.addNotification(message)
	end

	def readAllNotifications
		if @notifications != nil
			@notifications.each { |msg| @view.showNotification(msg)}
		end
	end

end
