
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

pagy.more?
# => true
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
pagy, posts = pagy_cursor(
  Post.all.order(id: :asc),
  after: "eyJ1c2Vycy5pZCI6MzUwfQ=="
)

posts.count
# => 20

posts.first.id
# => 21

pagy, posts = pagy_cursor(
  Post.all.order(id: :asc),
  before: "eyJ1c2Vycy5pZCI6MzUwfQ=="
)

posts.count
# => 20

posts.first.id
# => 1
```

### Security considerations

The cursor contains information about the table columns used in the collection's
sort. **This might expose your application's internals to the world, which
might be exploited by malicious actors**.

To combat this, the cursor can be encrypted by passing a `secret` variable.

```ruby
pagy, posts = pagy_cursor(Post.all.order(id: :asc))

pagy.next
# => "eyJ1c2Vycy5pZCI6MTMxfQ=="

pagy, posts = pagy_cursor(Post.all.order(id: :asc), secret: 'super secret secret')

pagy.next
# => "QRcTAEMXRgBQE1FFFkBTWkNSTRZMFFMWFERUBkoHJElAFhZURUZLWgUWCwQDSw=="
```

The cursor is encrypted by XOR-ing it with a randomly generated nounce value,
and the nounce is XOR-ed with the secret and concatenated to the cyphertext.
The resulting cyphertext should be about twice as long as the JSON encoded
cursor.

This is by no means a strong encryption method and is intended to be used only
as a deterrent. Values passed in the cursor are used in queryes but always pass
through the adapter's sanitizer
(e.g. for ActiveRecord `where('posts.id > ?', cursor[:id])`). The cursor's keys
are never used in the generation of a query.

### Configuration

The following configuration variables are read from Pagy:

| Name              | Default   | Description                                                     |
|:------------------|:----------|:----------------------------------------------------------------|
| keyset_secret     | `nil`     | Passed as `secret` to `pagy_keyset`. Used to encrypt the cursor |
| before_page_param | `:before` | Determines which parameter holds the before cursor              |
| after_page_param  | `:after`  | Determines which parameter holds the after cursor               |

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
