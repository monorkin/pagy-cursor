
# PagyKeyset

Extra for [Pagy](https://github.com/ddnexus/pagy) to work with keyset/cursor
based pagination.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pagy_keyset', git: 'https://github.com/monorkin/pagy-keyset.git'
```

## Usage

Include the backend in a controller:

```ruby
require "pagy_cursor/pagy/extras/keyset"

include Pagy::Backend
```

To paginate any dataset use the `pagy_keyset` method

```ruby
pagy, posts = pagy_cursor(Post.all.order(id: :asc))
```

This returns an array of two objects. The first, `pagy`, contains all pagination
related data, like the current, previous and next cursors.

```ruby
pagy.next
# => "eyJ1c2Vycy5pZCI6MzUwfQ=="
pagy.prev
# => "eyJ1c2Vycy5pZCI6MzMxfQ=="
```

And the second object is the paginated collection.

```ruby
posts.count
# => 20

posts.first.id
# => 1
```

The cursors returned by the `pagy` object can be used to request the next and
previous pages.

```ruby
pagy, posts = pagy_cursor(Post.all.order(id: :asc), after: "eyJ1c2Vycy5pZCI6MzUwfQ==")

posts.count
# => 20

posts.first.id
# => 21

pagy, posts = pagy_cursor(Post.all.order(id: :asc), before: "eyJ1c2Vycy5pZCI6MzUwfQ==")

posts.count
# => 20

posts.first.id
# => 1
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
