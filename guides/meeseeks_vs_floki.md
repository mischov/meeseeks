# Meeseeks vs. Floki

### Why was Meeseeks created in the same space as the earlier existing library Floki?

Meeseeks was created to provide a correct-by-default solution for parsing HTML since Floki's default, `:mochiweb_html`-based parser is not HTML5 compliant and can produce unexpected results.

### When should I use Meeseeks instead of Floki?

- When needing to parse HTML which may not be wellformed (anything scraped), Meeseeks should be preferred to Floki with its default, `:mochiweb_html`-based parser (Meeseeks has no advantage in correctness over Floki with a `html5ever` or other HTML5 compliant parser)
- When needing to parse XML, Meeseeks should be preferred to Floki which doesn't include an XML parser
- When needing to select with XPath selectors, Meeseeks should be preferred to Floki which doesn't provide XPath selectors
- When needing to select with a custom selector, Meeseeks should be preffered to Floki which doesn't allow custom selectors

### When should I used Floki instead of Meeseeks?

- When needing to parse wellformed HTML without including Rust in your build process, Floki with the default `:mochiweb_html`-based parser should be preferred to Meeseeks which requires Rust in the build process (use of the `:mochiweb_html`-based parser with HTMl that may not be wellformed is not recommended)
- When needing to make updates to an HTML document, Floki should be preferred to Meeseeks which does not provide the ability to do so.

### How does Meeseeks performance compare to Floki performance?

For benchmarks see [Meeseeks vs. Floki Performance](https://github.com/mischov/meeseeks_floki_bench).
