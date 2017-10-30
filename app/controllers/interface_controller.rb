require 'open-uri'

class InterfaceController < ApplicationController
  def game
   # a new random grid of words
   @start_time = Time.now
   @grid = generate_grid(9).join(" ")
  end
  # http://localhost:3000/score?start_time=2017-10-30+12%3A10%3A49+-0400&attempt=fab&end_time=2017-10-30+12%3A10%3A49+-0400
  def score
    # compute and display your score
    end_time = Time.now
    @attempt = params[:attempt]
    grid = params[:grid].split(' ')
    time = (end_time - Time.parse(params[:start_time])).round
    @results = run_game(@attempt, grid, time)
    if session.key?(:user_scores)
      session[:user_scores] << @results[:score]
    else
      session[:user_scores] = [@results[:score]]
    end
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    # ("A".."Z").to_a.sample(grid_size).join(" ")
    (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, time)
    # TODO: runs the game and return detailed hash of result
    score = (attempt.size * (1 - (time / 60))).round
    if dictionary_check(attempt) && grid_check(attempt, grid)
      { time: time, score: score, message: "Well done!" }
    elsif dictionary_check(attempt)
      { time: time, score: 0, message: "Sorry your attempt is not in the grid!" }
    elsif grid_check(attempt, grid)
      { time: time, score: 0, message: "Sorry your attempt is not an english word!" }
    else { time: time, score: 0, message: "Sorry your word is not a word and in the grid!" }
    end
  end

  def dictionary_check(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    check = open(url).read
    result = JSON.parse(check) # {"found"=>true, "word"=>"apple", "length"=>5}
    return result["found"]
  end

  def grid_check(attempt, grid, att_hash = {}, grid_hash = {})
    attempt.upcase.split('').each { |letter| att_hash.key?(letter) ? att_hash[letter] += 1 : att_hash[letter] = 1 }
    grid.each { |letter| grid_hash.key?(letter) ? grid_hash[letter] += 1 : grid_hash[letter] = 1 }
    check = true
    att_hash.each do |letter, count|
      if grid_hash.key? letter
        check = false unless grid_hash[letter] >= count
      else check = false
      end
    end
    return check
  end
end
