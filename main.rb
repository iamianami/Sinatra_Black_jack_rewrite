require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK = 21
MIN_HIT = 17

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
  erb :new_player
end

post '/new_player' do 
  session[:player_name] = params[:player_name] 
  redirect '/game'
end

get '/game' do 
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
    @success = "Congrat! #{session[:player_name]} hit Black Jack"
    @show_hit_or_stay_button = false
    @play_again = true
  elsif player_total > BLACKJACK 
    @error = "Sorry ,#{session[:player_name]} busted"
    @show_hit_or_stay_button = false
    @play_again = true
  end
  
  erb :game
end

post '/player/stay' do
  @error = "#{session[:player_name]} chose STAY."
  @show_hit_or_stay_button = false
  redirect '/game/dealer'
end 

get '/game/dealer' do
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK
    @success = "#{session[:player_name]} lose, Dealer hit BlackJack!"
    @play_again = true
  elsif dealer_total > BLACKJACK
    @success = "#{session[:player_name]} win, Dealer is busted!"
    @play_again = true
  elsif dealer_total >= MIN_HIT
      redirect '/game/compare'   #have to def
  else
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do 
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do 
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    @error = "#{session[:player_name]} LOSE! "
    @play_again = true
  elsif player_total > @dealer_total
    @success = "#{session[:player_name]} WIN! "
    @play_again = true
  else
    @success = "It's a tie"
    @play_again = true
  end

  erb :game     
end

get '/game_over' do 
  erb :game_over
end





