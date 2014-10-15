require './board'

class ConnectFourGame

  PLAYERS = [:red,:yellow]

  attr_accessor :gameboard, :cur_player, :winner

  def initialize
    @gameboard = Board.new
    initialize_game
  end

  def initialize_game
    @gameboard.clear_board
    @cur_player = PLAYERS.first
    @winner = nil
  end

  def play
    display_welcome_message
    loop do
      initialize_game
      play_game
      break unless play_again?
    end
    display_goodbye_message
  end

  def play_game
    loop do
      @gameboard.display_board
      col = get_valid_input
      @gameboard.place_piece_in_column(@cur_player,col)
      break if game_over?
      switch_player
    end
    @gameboard.display_board
    display_endgame_message
  end

  def display_welcome_message
		puts "\n\t*************************************"
		puts "\t*****  Welcome to Connect Four  *****"
		puts "\t*************************************\n\n"
  end

	def display_goodbye_message
		puts "\nThanks for playing Connect Four. Come back soon :-)"
	end

  # Format and display message declaring winner (or a draw)
	def display_endgame_message
		puts @gameboard.color(@winner == :draw ? "\n\tGame ended in a draw." :
		                        "\n\t#{@winner.to_s.capitalize} player WON!", :flip)
	end

  #switch to other player
  def switch_player
    current_index = PLAYERS.index(@cur_player)
    @cur_player = PLAYERS[1-current_index]
  end

  def get_input_for_prompt prompt
    loop do
      print prompt + ": "
      input = gets.chomp
      return input unless input.empty?
    end
  end

  def valid_input? input
		  input_int = input.to_i
		  return false unless input_int.between?(1, Board::COLS)
		  unless @gameboard.board[input_int - 1][Board::ROWS - 1] == :blank
			  puts "Column #{input.strip} is full; please choose another column."
			  return false
		  end
		  true
  end

  def get_valid_input
    loop do
      prompt = "#{@cur_player.to_s.capitalize} player, Enter column to play in (1-#{Board::COLS})"
      input = get_input_for_prompt(prompt)
      return input.to_i - 1 if valid_input?(input)
    end
  end

  def play_again?
    print "Do you want to play again? (y/n?)"
    input = ""
    until input == 'y' || input == 'n'
      input = gets.chomp
      if input == 'y'
        return true
      elsif input == 'n'
        return false
      end
    end
  end

  def game_over?
    return true if horizontal_win?
    return true if vertical_win?
    return true if diagonal_win?
    return draw?
  end

  def draw?
    top_cell = @gameboard.board.map {|col| col[Board::ROWS - 1]}
    if top_cell.none? {|cell| cell == :blank}
      @winner = :draw
      true
    else
      false
    end
  end

  def horizontal_win?
    check_board_section(0,Board::COLS - 4, 0, Board::ROWS - 1, [1,0])
  end

  def vertical_win?
    check_board_section(0,Board::COLS - 1, 0, Board::ROWS - 4, [0,1])
  end

  def diagonal_win?
    return true if ne_diagonal_win?
    return true if nw_diagonal_win?
    false
  end

  def ne_diagonal_win?
    check_board_section(0,Board::COLS - 4, 0,Board::ROWS - 4, [1,1])
  end

  def nw_diagonal_win?
    check_board_section(3,Board::COLS - 1,0,Board::ROWS - 4, [-1,1])
  end

  def check_board_section(start_col,end_col,start_row,end_row,position_change)
    (start_col..end_col).each do |col|
      (start_row..end_row).each do |row|
        if same_piece_at_positions(consecutive_position([col,row],position_change))
          @winner = @gameboard.board[col][row]
          return true
        end
      end
    end
    false
  end

  def consecutive_position(start_position,position_change)
    positions = [start_position]
    3.times {positions << add_position(positions.last,position_change)}
    positions
  end

  def add_position(position1,position2)
    [position1[0] + position2[0],position1[1] + position2[1]]
  end

  def same_piece_at_positions(positions)
    pieces = positions.map {|pos| @gameboard.board[pos.first][pos.last] }
    return if pieces.first == :blank
    pieces.uniq.length == 1
  end
end

cfg = ConnectFourGame.new
cfg.play
