require 'rubygems'

require 'rest-client'

require 'open-uri' 

require 'nokogiri'

require 'colorize'

#use a local HTML file to get the scraper working before we 
#create a live version

#class shouldn't care how it gets the HTML content.


class Post

  attr_reader :title, :url, :points, :item_id, :comments

  def initialize(title, url, points, item_id)
    @title = title  #title of the hacker news
    @url = url  #the url to find the post
    @points = points  #how many points it already has
    @item_id = item_id
    @comments = []
  end

  def add_comment(comment)
    @comments << comment
  end


end


class Comment
  attr_reader :user, :date_posted, :comment

  def initialize(user, date_posted, comment)
    @user = user
    @date_posted = date_posted
    @comment = comment
  end


end

###Parses the Hacker News HTML
url = "https://news.ycombinator.com/item?id=7663775"
page = Nokogiri::HTML(open("./post.html"))

######## POST #############

title = page.css("td.title a")[0].text
points = page.css("td.subtext").css("span.score")[0].text
ipoints = points.to_i
post_id = page.css("td.votelinks").css("center a")[0]["id"]
len = post_id.length - 1
ipost_id = post_id[3..len].to_i


###Make a post object
post = Post.new(title, url, ipoints, ipost_id)

######## END OF POST ################




######### COMMENTS ##############

## find the usernames
user = page.css("tr.athing").css(".comhead > a:first-child")

## initialize the users hash
users = {}

## Trim off the first match
leng = user.length
user = user[1..leng]

## Add each user as the key in the users hash 
## with an empty array as the value 
user.each_with_index { |item, idx| 
  itemh = item.text + idx.to_s
  itemhi = itemh.to_sym
  users[itemhi] = [] 
}


## Find the dates
dates = user = page.css("tr.athing").css("span.comhead").css("span.age")

## Add the dates to their corresponding index in the users hash
dates.each_with_index { |item, idx|
  ke = users.keys[idx]
  users[ke] << item.text
}



## search for the comments using regex and add them to their corresponding
## users and date posted in the users hash.

com = page.css("tr.athing").css("span.comment").select { |e| e['class'] =~ /c\w\w/}
#com = page.css("tr.athing").css("span.comment").css("span.cae, span.c00, span.cbe, span.c73, span.c5a")
com.each_with_index { |comm, idx| 
 kee = users.keys[idx]
 users[kee] << comm.text
}

## trim off the id numbers of the usernames (key), instantiate
## a new instant of Comment for each key in the hash with it's
## corresponding date and comment.

users.each { |key, value| 
  ikey = key.to_s.gsub(/\d\d?$/, "")
  idate = value[0]
  icomment = value[1]
  comm = Comment.new(ikey, idate, icomment)
  post.add_comment(comm)
}


## call the comments instance variable and print each comments
## username, date_posted, and comment
post.comments.each { |u| 
  puts u.user.red
  puts u.date_posted.green
  puts u.comment.magenta
}

##cyan, magenta, red, green, blue, black

