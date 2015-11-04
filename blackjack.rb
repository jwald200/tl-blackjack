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

def display_table(player_name, dealers_hand, players_hand, state = {})
  system 'clear'
  dealers_score = check_value(dealers_hand)
  players_score = check_value(players_hand)
  if state[:players_turn]
    puts "Dealer's hand:  |--|#{format_cards([dealers_hand.last])}"
  else
    puts "Dealer's hand:#{format_cards(dealers_hand)}"
    puts "totaling to: #{dealers_score}"
  end
  puts '-' * 15
  puts "#{player_name}'s hand:#{format_cards(players_hand)}"
  puts "totaling to: #{players_score}"
  return unless state[:game_over]
  puts '-' * 15
  puts "Results: #{results_msg(player_name, dealers_score, players_score)}"
end

def blackjack?(score)
  score == 21
end

def busted?(score)
  score > 21
end

def results_msg(player_name, dealers_score, players_score)
  case
  when (dealers_score == players_score)
    "It's a tie!"
  when busted?(dealers_score)
    "#{player_name} won! dealer has busted"
  when busted?(players_score)
    "oops! You've busted"
  when blackjack?(dealers_score)
    "#{player_name}, You lost. dealer hit blacjack"
  when blackjack?(players_score)
    "#{player_name}, You've hit blackjack"
  when (dealers_score > players_score)
    "#{player_name}, you lost"
  else
    "#{player_name} won!"
  end
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
  system 'clear'
  puts 'Game over...'
  sleep 1
  display_table(player_name, dealer, player, game_over: true)

  puts 'Play again? (Y/N)'
  break if gets.chomp.downcase == 'n'
end
puts 'Thanks for playing'
