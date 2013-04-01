#Spandex is a simple content engine for Ruby. And gymnasts#

Spandex manages a bucket of text files written in your favorite markup (Markdown, Textile, or even Haml). You mark those files up with metadata (like date and tags), and Spandex gives you access to them. This is perfect for building a simple git-based blog or content site.

Spandex is largely extracted from [Nesta](http://nestacms.com/), a Ruby CMS. The markup is rendered using [Tilt](http://github.com/rtomayko/tilt).

##It's super freaking easy##

Make a directory called "content".

In that directory, create a file called `things.md`:

```
Title: I have an affinity for goats
Date: 2011/9/25
Tags: gerrymandering, hyperbolic geometry

No, really goats are *awesome*.
```

Then use Spandex to do the work:

```ruby
spandex = Spandex.new(File.expand_path('content', File.dirname(__FILE__))

page = spandex.get('things') 
page.title                   #=> "I have an affinity for goats"
page.tags                    #=> ["gerrymandering", "hyperbolic geometry"]
page.body                    #=> <p>No, really goats are <em>awesome</em>.</p>\n

spandex.all_pages            #=> all pages under content
spandex.all_articles         #=> all pages with dates (e.g. blog posts)
spandex.tags                 #=> ["gerrymandering", "hyperbolic geometry"]
spandex.atom_feed            #=> a bunch of XML, only finds posts with dates

spandex.find_articles(:tag => "gerrymandering")
```

The spandex object caches the pages and does all of the right last-mod-time checking. Your application should just keep the object around.

##Build things!##

Blog engines are great, and there are, like, three thousand of them. Sometimes, though, you just want to build a website with the tools you know. Spandex lets you do that while taking care of all the grody work of keeping track of posts. A barebones example of a Spandex-based blog is the [tinyblogofdoom](http://github.com/icambron/tinyblogofdoom).

But wait! There's more! Spandex can also implement the core functionality for a blog engine or CMS. Spandex brings the post rendering and you bring the themes, UI chrome, and plugins.

##Some more cool stuff##

Paths can be deep:

```ruby
page = spandex.get('subfolder/deeper/things') 
```

You can pass options through to Tilt at initialization:

```ruby
spandex = Spandex.new(path, :fenced_code_blocks => true) #special option for Redcarpet
```

##The content is just Tilt##

The markup is processed using [Tilt](https://github.com/rtomayko/tilt). That means it can read a lot of different markup formats, and gives you access to all of Tilt's configuration options. You can change what extensions get bound to what template engines, and that sort of thing

You can also customize rendering by customizing Tilt. Here's how you might customize Spandex to hightlight code with Pygments:

```ruby
require 'redcarpet'
require 'pygments'

class Syntactical < Redcarpet::Render::HTML
  include Pygments
  def block_code(code, language)
    highlight code, :lexer => lexer_name_for(:lexer => language)
  end
end

class SyntacticalTemplate < Tilt::RedcarpetTemplate::Redcarpet2
  def generate_renderer
    Syntactical
  end
end

Tilt::register SyntacticalTemplate, 'some_file_extension'
```
