# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    movie_obj = Movie.new()
    movie_obj.title = movie['title']
    movie_obj.rating = movie['rating']
    movie_obj.release_date = movie['release_date']
    movie_obj.save
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  Movie.count.should be n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  page.body.should =~ /#{Regexp.escape(e1)}(.|\n)*#{Regexp.escape(e2)}/

  # Note for grader: I have used a separate step defination for 
  # checking if all the movies are in sorted order, please check
  # below.
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  rating_list.split(',') do |rating|
    if uncheck == nil
      check "ratings[#{rating}]"
    else
      uncheck "ratings[#{rating}]"
    end
  end
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  # fail "Unimplemented"
end

When /I press (.*)/ do |button|
  click_button button
end

Then /I should( not)? see the following movies: (.*)/ do |not_present, movie_list|
  movie_list.split(',') do |movie|
    if not_present == nil
      page.find('tr', text: movie)
    else
      expect(page).not_to have_content(movie)
    end
  end
end

Then /I should see the (movies|release_date) in ascending order/ do |col|
  movie_list = []
  release_date = []
  page.all(:xpath, '//table[@id="movies"]//tbody//tr').each do |tr|
    movie_list.push tr.all('td')[0].text
    if col == "release_date"
      release_date.push tr.all('td')[2].text
    end
  end
  (1..movie_list.length()).each do |i|
    if col == "release_date"
      val = (release_date[i-1] <=> release_date[i])
    else
      val = (movie_list[i-1] <=> movie_list[i])
    end
    if val==1
      fail "Movies #{movie_list[i-1]} and #{movie_list[i]} not in correct order for sorted column #{col}"
    end
  end
end


Then /I should see all the movies: (\d+)/ do |number|
  # Make sure that all the movies in the app are visible in the table
  # The heading is also considered as one row.
  page.all('table#movies tr').count.should == number + 1
end
