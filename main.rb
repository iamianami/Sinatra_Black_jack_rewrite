require 'rubygems'
require 'sinatra'


enable :sessions
set :session_secret, ENV['a_longish_secret_key']

BLACKJACK = 21
MIN_HIT = 17
INITIAL_POT_AMOUNT = 500

helpers do
  def calculate_total(cards)
    arr = cards.map {|element| element[1]} #why map but no select

      total = 0
      arr.each do |val|
        if val == "A"
          total += 11
        else
          total += (val.to_i == 0 ? 10 : val.to_i)
        end
      end

      #correct Ace
      arr.select{|val| val == "A" }.count.times do
        break if total <= BLACKJACK
        total -= 10
      end
      total
  end

  def card_image(card)
    suit = card[0]

    value = card[1]
    if ["J","Q","K","A"].include?(value)
      value = case card[1]
              when "J" then "jack"
              when "Q" then "queen"
              when "K" then "king"
              when "A" then "ace"
              end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='image'/>"
  end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_button = false
    session[:player_pot] = session[:player_pot] + session[:player_bet]    
    @success ="<strong>#{session[:player_name]}</strong> win!!! #{msg}"
  end 

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_button = false
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @error = "<strong>#{session[:player_name]}</strong> lose!!! #{msg}"

    if session[:player_pot] == 0
      @show_recharge_money_button = true
      @play_again = false
    end
  end

  def tie!(msg)
    @show_hit_or_stay_button = false
    @success = "it's a tie!"
    @play_again = true
  end
  
end

before do
  @show_hit_or_stay_button = true
end


get '/' do 
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
  redirect '/new_player'
end

get '/new_player' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do 
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name].capitalize 
  redirect '/bet'
end

get '/bet' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do 
  
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "You must to bet something"
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "You have $#{session[:player_pot]} only,please don't bet more thanplayer you have."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

post '/player/restore_money' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  redirect '/bet'
end

get '/game' do 
  session[:turn] = session[:player_name]  

  suit = ["diamonds","spades","clubs","hearts"]
  value = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
  session[:deck] = suit.product(value).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  erb :game
end

post '/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK
    winner!("#{session[:player_name]} hit Black Jack")
  elsif player_total > BLACKJACK 
    loser!("Sorry ,#{session[:player_name]} just busted at #{player_total}")
  end
  
  erb :game , layout: false
end

post '/player/stay' do
  @error = "#{session[:player_name]} chose STAY."
  @show_hit_or_stay_button = false
  redirect '/game/dealer'
end 

get '/game/dealer' do
  session[:turn] = "dealer"

  @show_hit_or_stay_button = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK
    loser!("Dealer hit BlackJack!")
  elsif dealer_total > BLACKJACK
    winner!("Dealer is #{dealer_total}, is busted!")
  elsif dealer_total >= MIN_HIT || dealer_total > player_total
      redirect '/game/compare'   #have to def     
  else
    @show_dealer_hit_button = true
  end

  erb :game ,layout: false
end

post '/game/dealer/hit' do 
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do 
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("Dealer is win at #{dealer_total} and #{session[:player_name]} is #{player_total}")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} win at #{player_total} , dealer is #{dealer_total}")
  else
    tie!("Both stay at #{player_total}")
  end

  erb :game , layout: false
end

get '/game_over' do 
  erb :game_over
end

get '/get_money' do 
  erb :get_money
end





