require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    #starts a new Twitter client via jumpstart_auth
    #client variable holds connection to Twitter once the pin is entered
  end
  
  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm( parts[1], parts[2..-1].join(" "))
      when 'elt' then everyones_last_tweet
      when 'turl' then tweet( parts[1..-2].join(" ") + " " + shorten(parts[-1]) )
      else
        puts "Sorry, I don't know how to #{command}"
      end
      #prints text, then leaves cursor at end
    end
  end
  
  def tweet(message)
   if message.length <= 140  
      @client.update(message)
      puts "Tweet posted successfully!"
   else
      puts "Message longer than 140 characters. Shorten it."
      new_message = gets.chomp
      tweet(new_message)
    end
  end
  
  def dm(target, message) #target equals the user you want to dm
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include? target
      tweet(message)
    else 
      puts "Sorry, #{target} does not follow you -- You can only DM people who do."
    end
  end
  
  def followers_list
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    screen_names
  end
  
  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end
  
  def everyones_last_tweet
    people_following = @client.following.collect { |follower| @client.user(follower).screen_name.downcase }
    people_following_sorted = people_following.sort
    people_following_sorted.each do |person|
      last_message = @client.user(person).status.text
      puts "#{person} said..."
      puts last_message
      puts ""
    end
  end
  
  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    bitly.shorten(original_url).short_url
  end
  
end

# execution script
MicroBlogger.new.run

