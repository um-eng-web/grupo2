require_relative './MVC/GamblerController.rb'
require_relative './MVC/BookieController.rb'
require_relative './MVC/SportEventController.rb'
require_relative './MVC/BetController.rb'
require_relative 'Populate.rb'
require_relative 'String.rb'

class Facade < Object


  def initialize
    @event_counter = 0
    @gamblers = Hash.new("user doesnt exist!\n") #GamblersController
    @bookies = Hash.new("user doesnt exist!\n") #BookieController
    @events = Hash.new("event doesnt exist!\n") #SportEventController
    # Populate -------------------------------
    pop = Populate.new
    @event_counter = pop.populate(@gamblers, @bookies, @events, @event_counter)
  end


  # Gambler --------------------------------
  def registerGambler
    controller = GamblerController.new
    controller.createUser
    if @gamblers.has_key?(controller.model.username)
      return nil
    else
      @gamblers[controller.model.username] = controller
      return controller
    end
  end

  def gamblerLogin(username, password)
    if @gamblers.key?(username)
      if password == @gamblers[username].model.password
        controller = @gamblers[username]
      else
        return nil
      end
    end
  end

  def placeBet(event_id, gambler_id)
    if (@events.key?(event_id) && @events[event_id].model.state==true)
      bet_controller = BetController.new
      odd = @events[event_id].model.odd
      bet_controller.create(gambler_id,odd,@gamblers[gambler_id].model.coins)
      @events[event_id].addBet(bet_controller)
      @gamblers[gambler_id].registBet(event_id,bet_controller)
    end
  end

  def bettingHistory(gambler_id)
    if @gamblers.key?(gambler_id)
      @gamblers[gambler_id].printBets
    end
  end
  def gamblerNotifications(gambler_id)
    @gamblers[gambler_id].readAllNotifications
  end

  # Bookie ---------------------------------
  def registerBookie
    controller = BookieController.new
    controller.create
    if  @bookies.has_key?(controller.model.username)
      controller = nil
    else
       @bookies[controller.model.username] = controller
      return controller
    end
  end

  def bookieLogin(username, password)
    if @bookies.key?(username)
      if password ==  @bookies[username].model.password
        controller =  @bookies[username]
      else
        return nil
      end
    end
  end

  def updateEventState(event_id)
    if @events.key?(event_id)
      @events[event_id].updateState
    end
  end

  def changeOdd(event_id)
    if @events.key?(event_id)
      @events[event_id].updateOdd
    end
  end

  def payGamblers(event_id)
    total = 0.0
    @events[event_id].bet_list.each do |key,gamblerBets|
      gamblerBets.each do |bet|
        if @events[event_id].model.result == bet.model.result
          o = bet.model.result == "win" ? bet.model.odd[0] : (bet.model.result == "draw" ? bet.model.odd[1] : bet.model.odd[2])
          @gamblers[bet.model.gambler_id].addCoins(o*bet.model.value)
          @gamblers[bet.model.gambler_id].updateObserver("#{"you won a bet! ".green} #{o*bet.model.value} coins, event_id:#{event_id}, for result:#{bet.model.result}" )
          total+=(o*bet.model.value)
        else
          @gamblers[bet.model.gambler_id].updateObserver("#{"you lost a bet! ".red} #{bet.model.value} coins, event_id:#{event_id}, for result:#{bet.model.result}")
        end
      end
    end
    return total
  end

  def endEvent(event_id)
    if @events.key?(event_id)
      @events[event_id].setResult
      @events[event_id].notifyObserver(@bookies[@events[event_id].model.owner_id],"total win for event #{event_id} is #{payGamblers(event_id)} coins")
      @events[event_id].deleteObservers
    end
  end

  def showInterestBookie(bookie_id,event_id)
    unless !(@events.has_key?(event_id))
      if @bookies.has_key?(bookie_id)
        @events[event_id].addObserver(@bookies[bookie_id])
      end
    end
  end
  def showInterestGambler(gambler_id,event_id)
    unless !(@events.has_key?(event_id))
      if @gamblers.has_key?(gambler_id)
        @events[event_id].addObserver(@gamblers[gambler_id])
      end
    end
  end

  def listEvents(owner_id)
    @events.each do |key,value|
      if value.model.owner_id == owner_id
        value.updateView
      end
    end
  end

  def bookieNotifications(bookie_id)
    @bookies[bookie_id].readAllNotifications
  end


  # Event ----------------------------------
  def newEvent(owner)
    controller = SportEventController.new(owner, @event_counter+=1)
    controller.createSportEvent
    controller.addObserver(@bookies[owner]) #adiciona o bookie como observador do proprio evento
    @events[controller.model.event_id] = controller
  end

  def openEvent(event_id)
    if @events.key?(event_id)
      @events[event_id].model.setState(true)
    end
  end

  def listGamblerAvailableEvents
    @events.each do |key,value|
      if value.model.state == true
        value.updateView
      end
    end
  end


  private :payGamblers
end
