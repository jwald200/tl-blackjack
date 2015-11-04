def init_deck
  suits = ['H', 'D', 'S', 'C']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  deck = suits.product(cards)
  deck.shuffle!
end

def deal_card(participant_cards, deck)
  participant_cards << deck.pop
end

def format_cards(cards)
  cards_string = ''
  cards.each do |card|
    cards_string << "  |#{card.join('-')}|"
  end
  cards_string
end

def total_value(cards)
  cards_values = {
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    '10' => 10,
    'J' => 10,
    'Q' => 10, 
    'K' => 10,
    'A' => 11
  }

  second_part_of_cards = cards.map { |v| v[1] }
  total = cards_values.values_at(*second_part_of_cards).inject(:+)
  
  second_part_of_cards.count('A').times do
    total -= 10 if total > 21
  end
  total
end

def display_table(player_name, dealers_cards, players_cards, state = {})
  system 'clear'
  if state[:players_turn]
    puts "Dealer's cards:  |--|#{format_cards([dealers_cards.last])}"
  else
    puts "Dealer's cards:#{format_cards(dealers_cards)}"
    puts "totaling to: #{total_value(dealers_cards)}"
  end
  puts '-' * 15
  puts "#{player_name}'s cards:#{format_cards(players_cards)}"
  puts "totaling to: #{total_value(players_cards)}"
  if state[:game_over]
    puts '-' * 15
    puts "Results: #{results_msg(player_name, dealers_cards, players_cards)}"
  end
end

def blackjack?(participant)
  (total_value(participant) == 21) ? true : false
end

def busted?(participant)
  (total_value(participant) > 21) ? true : false
end

def results_msg(player_name, dealer, player)
  case 
    when (total_value(dealer) == total_value(player))
      "It's a tie!"
    when busted?(player)
      "oops! You've busted"
    when blackjack?(dealer)
      "#{player_name}, You lost. dealer hit blacjack"
    when blackjack?(player)
      "#{player_name}, You've hit blackjack"
    when (total_value(dealer) > total_value(player))
      "#{player_name}, you lost"
    when busted?(dealer)
      "#{player_name} won! dealer has busted"
    else
      "#{player_name} won!"
  end
end

def game_over_msg(player_name, dealer, player)
  system 'clear'
  puts "Game over. Geting results..."
  sleep 0.5
  display_table(player_name, dealer, player, game_over: true)
end


puts 'Blackjack!'
puts "How would you like to be called?"
player_name = gets.chomp

loop do
system 'clear'
puts "we're preparing the game..."
sleep 0.5
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
while total_value(player) < 21
  begin
    puts "hit (h) or stay (s)"
    input = gets.chomp.downcase
  end until ['s', 'h'].include?(input)
  break if input == 's'
  deal_card(player, deck)
  display_table(player_name, dealer, player, players_turn: true)
end
# dealers turn
if total_value(player) < 21
  puts "You've chosen to stay. Turning to dealer"
  sleep 1
  while total_value(dealer) < 17
    puts "Dealer has #{total_value(dealer)} and will hit..."
    sleep 1
    display_table(player_name, dealer, player)
    deal_card(dealer, deck)
  end
end
game_over_msg(player_name, dealer, player)

puts "Play again? (Y/N)"
break if gets.chomp.downcase == 'n'
end
puts 'Thanks for playing'







