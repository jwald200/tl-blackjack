def init_deck
  suits = %w(H D S C)
  ranks = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  deck = suits.product(ranks)
  deck.shuffle!
end

def deal_card(hand, deck)
  hand << deck.pop
end

def format_cards(hand)
  string = ''
  hand.each do |card|
    string << "  |#{card.join('-')}|"
  end
  string
end

def check_value(hand)
  cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  values = [*(2..10), 10, 10, 10, 11]
  card_values = Hash[cards.zip values]

  rank = hand.map { |v| v[1] }
  sum = card_values.values_at(*rank).inject(:+)

  rank.count('A').times do
    sum -= 10 if sum > 21
  end
  sum
end

def display_table(player_name, dealers_cards, players_cards, state = {})
  system 'clear'
  if state[:players_turn]
    puts "Dealer's cards:  |--|#{format_cards([dealers_cards.last])}"
  else
    puts "Dealer's cards:#{format_cards(dealers_cards)}"
    puts "totaling to: #{check_value(dealers_cards)}"
  end
  puts '-' * 15
  puts "#{player_name}'s cards:#{format_cards(players_cards)}"
  puts "totaling to: #{check_value(players_cards)}"
  return unless state[:game_over]
  puts '-' * 15
  puts "Results: #{results_msg(player_name, dealers_cards, players_cards)}"
end

def blackjack?(hand)
  check_value(hand) == 21
end

def busted?(hand)
  check_value(hand) > 21
end

def results_msg(player_name, dealer, player)
  case
  when (check_value(dealer) == check_value(player))
    "It's a tie!"
  when busted?(dealer)
    "#{player_name} won! dealer has busted"
  when busted?(player)
    "oops! You've busted"
  when blackjack?(dealer)
    "#{player_name}, You lost. dealer hit blacjack"
  when blackjack?(player)
    "#{player_name}, You've hit blackjack"
  when (check_value(dealer) > check_value(player))
    "#{player_name}, you lost"
  else
    "#{player_name} won!"
  end
end

def game_over_msg(player_name, dealer, player)
  system 'clear'
  puts 'Game over...'
  sleep 1
  display_table(player_name, dealer, player, game_over: true)
end

puts 'Blackjack!'
puts 'How would you like to be called?'
player_name = gets.chomp

loop do
  system 'clear'
  puts 'Preparing the game...'
  sleep 1
  # game setup
  dealer = []
  player = []
  deck = init_deck
  2.times do
    deal_card(dealer, deck)
    deal_card(player, deck)
  end
  display_table(player_name, dealer, player, players_turn: true)
  # player's turn
  while check_value(player) < 21
    puts "hit (h) or stay (s)"
    input = gets.chomp.downcase
    unless ['s', 'h'].include?(input)
      puts "We didn't get that..."
      next
    end
    break if input == 's'
    deal_card(player, deck)
    display_table(player_name, dealer, player, players_turn: true)
  end
  # dealers turn
  if check_value(player) < 21
    puts "You've chosen to stay. Turning to dealer"
    sleep 1
    while check_value(dealer) < 17
      puts "Dealer has #{check_value(dealer)} and will hit..."
      sleep 1
      display_table(player_name, dealer, player)
      deal_card(dealer, deck)
    end
  end
  game_over_msg(player_name, dealer, player)

  puts 'Play again? (Y/N)'
  break if gets.chomp.downcase == 'n'
end
puts 'Thanks for playing'
