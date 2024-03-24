# Rails

Examples here will be based on rails `v7`, although they may be backwards
compatible until rails `v6`.

On a personal level: I have a 70-30 hate-despise relationship with rails.
Everything looks "pretty" from afar, but this framework allows you to shoot
yourself in so many creative ways...

It barely enforces any structure or give you hints how to do things other than
the dumb mantra _"convention over configuration"_.

With that said...

## `request.format` is only for Content-Negotiation of the Response

[`request.format`][request-format] will give you a `Mime::Type` computed out of `params[:format]`
OR the [`Accept`][MDN-Accept] header OR Path ends in `.<format>`.

See the issue there? [`Accept`][MDN-Accept] is meant for the client to indicate what type can
it read.

```ruby
# actionpack/lib/action_dispatch/http/mime_negotiation.rb
# [...]
def format(_view_path = nil)
  formats.first || Mime::NullType.instance
end

def formats
  fetch_header("action_dispatch.request.formats") do |k|
    v = if params_readable?
      Array(Mime[parameters[:format]]) # Writer's Note: this means query-string or request body has: format=json
    elsif use_accept_header && valid_accept_header # Writer's Note: this means: 'Has "Accept: application/json" header?'
      accepts.dup
    elsif extension_format = format_from_path_extension
      [extension_format] # Writer's Note: this means 'request uri ends_with ".json"?'
    elsif xhr?
      [Mime[:js]]
    else
      [Mime[:html]]
    end

    v.select! do |format|
      format.symbol || format.ref == "*/*"
    end

    set_header k, v
  end
end
# [...]
```

## `request.content_mime_type` is *actually* for Content-Negotiation of the Request

[`request.content_mime_type`][request-content-mime] will give you a `Mime::Type` computed from the
[`Content-Type`][MDN-Content-Type] header.

```ruby
def content_mime_type
  fetch_header("action_dispatch.request.content_type") do |k|
    v = if get_header("CONTENT_TYPE") =~ /^([^,;]*)/
      Mime::Type.lookup($1.strip.downcase)
    else
      nil
    end
    set_header k, v
  rescue ::Mime::Type::InvalidMimeType => e
    raise InvalidType, e.message
  end
end
```


[request-format]: https://github.com/rails/rails/blob/v7.1.3.2/actionpack/lib/action_dispatch/http/mime_negotiation.rb#L75-L85
[request-content-mime]: https://github.com/rails/rails/blob/v7.1.3.2/actionpack/lib/action_dispatch/http/mime_negotiation.rb#L36-L47
[MDN-Accept]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
[MDN-Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
