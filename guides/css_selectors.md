# CSS Selectors

`Meeseeks.CSS` supports a subset of CSS3 selectors.

### Supported Syntax

| Pattern | Example | Notes |
| --- | --- | --- |
| **Basic Selectors** | --- | --- |
| `*` | `*` | Matches any for `ns` or `tag` |
| `tag` | `div` | |
| `ns\\|tag` | `foo\\|div` | |
| `#id` | `div#bar`, `#bar` | |
| `.class` | `div.baz`, `.baz` | |
| `[attr]` | `a[href]`, `[lang]` | |
| `[^attrPrefix]` | `div[^data-]` | |
| `[attr=val]` | `a[rel="nofollow"]` | |
| `[attr~=valIncludes]` | `div[things~=thing1]` | |
| `[attr\\|=valDash]` | `p[lang\\|=en]` | |
| `[attr^=valPrefix]` | `a[href^=https:]` | |
| `[attr$=valSuffix]` | `img[src$=".png"]` | |
| `[attr*=valContaining]` | `a[href*=admin]` | |
| &#8203; | | |
| **Pseudo Classes** | --- | --- |
| `:first-child` | `li:first-child` | |
| `:first-of-type` | `li:first-of-type` | |
| `:last-child` | `tr:last-child` | |
| `:last-of-type` | `tr:last-of-type` | |
| `:not` | `not(p:nth-child(even))` | Selectors cannot contain combinators or the `not` pseudo class |
| `:nth-child(n)` | `p:nth-child(even)` | Supports even, odd, 1.., or *a*n+*b* formulas |
| `:nth-last-child(n)` | `p:nth-last-child(2)` | Supports even, odd, 1.., or *a*n+*b* formulas |
| `:nth-last-of-type(n)` | `p:nth-last-of-type(2n+1)` | Supports even, odd, 1.., or *a*n+*b* formulas |
| `:nth-of-type(n)` | `p:nth-of-type(1)` | Supports even, odd, 1.., or *a*n+*b* formulas |
| &#8203; | | |
| **Combinators** | --- | --- |
| `X Y` | `div.header .logo` | `Y` descendant of `X` |
| `X > Y` | `ol > li` | `Y` child of `X` |
| `X + Y` | `div + p` | `Y` is sibling directly after `X` |
| `X ~ Y` | `div ~ p` | `Y` is any sibling after `X` |
| `X, Y, Z` | `button.standard, button.alert` | Matches `X`, `Y`, or `Z` |
