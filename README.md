# dna.hx

Generic plugin APIs for [Helix](https://helix-editor.com)'s
[Steel](https://github.com/mattwparas/steel) plugin system, as patches to the
Steel branch (`mattwparas/helix`, `steel-event-system`). What the plugins
in the forest are grown from.

Each patch adds a capability plugins can use, never a feature: features live
in plugins. They apply to `424add1` of the Steel branch on their own and
together, in any order. The virtual-text, overlay and theme patches come
with unit tests; the picker patch is exercised through sap.hx.

| Patch | Steel API (in `helix/misc.scm`) | Used by |
| --- | --- | --- |
| `helix-virtual-text.patch` | `add-virtual-lines`, `add-line-highlight`, `remove-virtual-text`, `clear-virtual-text`: styled rows below a line (reserved in the layout, so the cursor and scrolling skip them; long rows wrap), whole-line highlights | [mokh.hx](https://github.com/vitaliikindrat/mokh.hx) (inline diff review), [sap.hx](https://github.com/vitaliikindrat/sap.hx) (git hunks) |
| `helix-overlays.patch` | `set-overlays!`, `set-inline-annotations!`, `clear-overlays!`: draw styled text over the grapheme at chosen positions (what jump labels use), or insert styled inline text (what inlay hints use); one layer per theme scope | [rings.hx](https://github.com/vitaliikindrat/rings.hx) (rainbow indentation) |
| `helix-picker.patch` | `custom-picker` (a global): Helix's own picker with rows a plugin chooses -- a label to show and filter on, a file to preview (highlighted by its extension), and a callback with the chosen row's index instead of opening a file | [sap.hx](https://github.com/vitaliikindrat/sap.hx) (changed files with their diffs) |
| `helix-theme.patch` | `theme-changed` (a hook), `theme-style-exact`, `set-current-theme-style!`, `color-mix`, `color->rgb` (in `helix/themes.scm`): see when the theme changes, tell what the theme itself defines from what it falls back to, fill in scopes on the theme in use, mix its colours | rings.hx, sap.hx, mokh.hx (their scopes inherit the theme's colours) |

Everything is anchored by char index and follows edits; layout, soft wrap
and scrolling stay correct because the core does the positioning.

## Inheriting the theme's colours

Plugin scopes like `ui.virtual.diff.minus` are in no theme, and `:theme`
should not leave a plugin colourless. With the theme patch a plugin fills
them in from colours the theme does have, and again on every change:

```scheme
(require (prefix-in th. "helix/themes.scm"))
(require (prefix-in hc. "helix/components.scm"))

(define (inherit-colors!)
  (let* ([theme (th.current-theme)]
         [base (hc.style->bg (th.theme-style theme "ui.background"))]
         [red (hc.style->fg (th.theme-style theme "diff.minus"))])
    ;; a theme that sets the scope itself keeps it
    (unless (th.theme-style-exact theme "ui.virtual.diff.minus")
      (th.set-current-theme-style! "ui.virtual.diff.minus"
                                   (hc.style-bg (hc.style) (th.color-mix red base 0.2))))))

(register-hook 'theme-changed inherit-colors!)
(inherit-colors!)
```

`set-current-theme-style!` changes the theme in use only, in place: the next
`:theme` (or a preview while typing it) starts from the file again and fires
`theme-changed`. Named and indexed colours mix through the xterm palette.

## Use

With Nix:

```nix
inputs.dna = { url = "github:vitaliikindrat/dna.hx"; flake = true; };

helix-steel.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ inputs.dna.patchList;
})
```

`inputs.dna.patches.virtual-text`, `.overlays`, `.picker` and `.theme` are
there for picking.

Without Nix: `git apply patches/*.patch` in a checkout of the Steel branch,
then build it as usual (`cargo xtask steel`).

## Upstream

These are meant to go upstream into the Steel branch; until then they are
carried here so the plugins that need them have one place to point at.

## License

MIT.
