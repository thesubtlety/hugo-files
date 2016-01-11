---
author: noah
comments: false
date: 2014-04-11 01:57:03+00:00
layout: post
slug: building-a-web-app-in-rails
title: Building a Web App in Rails
wordpress_id: 156
categories:
- Development
- Projects
- Ruby on Rails
tags:
- develop
- projects
- rails
- ruby
---

A brilliant [software engineering friend](http://blaedj.github.io/) and I were recently discussing with another mutual friend the inefficiencies of employees filling out paper forms after completion of a construction job and the inefficiencies of transferring said forms to excel and so on. Said friend and I figured we could probably fix this with a web app for a nominal fee, but which would greatly increase our mutual friends' productivity. A win win situation if there ever was one.

So we set about the process of building a web application in Ruby on Rails. And several weeks later, we had one completed. It's nothing too fancy, but one that is being used in production and is adding business value. And it was an awesome learning experience. I just wanted to highlight some of what we encountered, how we went about the task, and a few lessons learned along the way.

Said friend and I had tinkered with Ruby on Rails before, but never to any great extent, nor had we worked with a business customer in this fashion by building a product to solve a problem, so I'm quite pleased with the way our stabbings in the dark went.

We had gotten okay requirements with the first discussions, and putting our collective heads together to make a small pile of rocks, we discussed how long this would take, what tools, libraries, and third party applications to use, where we would be hosting, understanding how we would actually solve the problem, and what to charge. Mutual friend agreed, and off we went.

**Working remotely**

We worked together remotely on this project. Skype and Google hangouts worked well when our schedules coincided. Starting out, we worked in tandem to get the foundation
down and a workflow established, and as we became more proficient, our productivity increased as we worked in parallel on different issues. Git, Github, and Heroku make for incredibly painless collaboration. I learned that git is a stupid content tracker, and a great tool. And for small deployments like this one, Heroku's robustness and free-ness were awesome.

**On Building**

As we hadn't used RoR too much beyond tutorials, we bootstrapped using [Michael Hartl's tutorial](http://ruby.railstutorial.org/) to get us started. Unlike many online tutorials, this one has great explanations and security hygiene and explained in great detail the user authentication and authorization pieces (among many others). And gems like bcrypt's has_secure_token for example, makes the implementation of secure passwords brain-dead simple. Rails make things very easy implement. Almost too easy. That opinion is likely due to not having worked too in depth with PHP, Apache, and MySQL. And now that I begin to recall the school projects of years past, RoR is quite nice indeed.

Our requirements didn't have us do anything too difficult, although we certainly had our share of hurdles; both in learning how the framework works and actually solving design problems. Working our way through various database relationships was a challenge, and pretty rewarding once we came up with solutions. Proper inheritance, indexing, and scoping all gave cause for some extra reading. Heroku makes things incredibly easy as far as using APIs, so incorporating email was no problem either.

UI and UX is always interesting. I hate poorly thought out UIs with a passion, so building a sensible interface was important. Yet css, javascript, html, and various cross-platform and browser (in)compatibilities can easily drive one nuts. And since I have no desire to wander about in insanity, we ended up using Bootstrap and HTML5 to keep things simple. And simple is beautiful.

**On Changing requirements**

And just like any other project, we had multiple feature requests as the weeks went by. All honored because we are kind and generous souls. These things had impacts on our initial estimates, but understandably so from our wonderful customer's perspective.

**A Few Lessons Learned**



	
  * Requirements are very important. More time spent at the beginning better understanding how users interact with and use an application is essential.

	
  * Understanding the various differences between mobile and desktop and between various browser rendering is pretty important. For example, we initially used Chrome for testing purposes with things working great. When we got reports back saying dates don't work we were initially baffled. Apparently Firefox doesn't render the date drop down and requires a very specific format.

	
  * Helpful error messages and graceful error handling is paramount to ease user experience.

	
  * Logging and alerting is essential. Multiple times we have been immediately alerted when things break or user experience is poor, allowing us to investigate and resolve.

	
  * Tests are essential. Refactoring a feature should never break existing functionality.



**On Securing**

Fortunately Rails 4 comes with many secure defaults such as protect_from_forgery for example, which adds csrf tokens to forms automatically. There are many great resources out there to help secure web apps. [Brakeman](http://brakemanscanner.org/) and [Dawn by Codesake](https://github.com/codesake/codesake-dawn) both caught a number of issues that were remediated. And while [this](https://www.owasp.org/images/8/89/Rails_Security_2.pdf) resource is aging, and many of the issues outlined in it are remediated in later versions of Ruby, it is a great guide explaining what to look for, why various practices are poor, their consequences, and how to remediate them.

No mention of app sec should be without reference to OWASP. The [OWASP Top Ten](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project) and [Secure SDLC](https://www.owasp.org/index.php/Secure_SDLC_Cheat_Sheet) have a plethora of good resources for Builders, Breakers, and Defenders. While this project was fairly ad-hoc, there are enough resources on OWASP for another post and give rise to more than a few questions and places for improvement going forward. The [OWASP RoR Cheatsheet](https://www.owasp.org/index.php/Ruby_on_Rails_Cheatsheet) is a good resource as well. And another: The [RoR Security Guide](http://guides.rubyonrails.org/security.html). There is no end to good resources out there.

Yet another well written and mildly humourous post by Honeybadger is [here](http://www.honeybadger.io/blog/guides/2013/03/09/ruby-security-tutorial-and-rails-security-guide) which contains wise advice such as the following. 
`match "/launch_all_the_missiles", to: "missiles#launch_all"
Conclusion: PANIC!`

And Kalzumeus's awesome blog and excellent [post](http://www.kalzumeus.com/2013/01/31/what-the-rails-security-issue-means-for-your-startup/) on Rails security and startups has a ton of all around great advice. 

**In Conclusion**

While this post is fairly short, I learned an incredible amount from completing this project. From both the technical aspects of working with Ruby on Rails, git, various APIs, and Heroku to the business and customer aspects, this was challenging, fun, and rewarding. And getting to delve into the web app sec world in more detail and have a postive impact on a business application is a reward in its own. Of course maintaining a production web application means the work is never done, so there is that as well. A little lesson all in it's own, I suppose.

Thanks for reading.
