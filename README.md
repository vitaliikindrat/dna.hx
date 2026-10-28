# canopy.hx

Generic plugin APIs for [Helix](https://helix-editor.com)'s
[Steel](https://github.com/mattwparas/steel) plugin system, as patches to the
Steel branch (`mattwparas/helix`, `steel-event-system`). The layer the
forest of plugins grows under.

Each patch adds a capability plugins can use, never a feature: features live
in plugins. They apply to `424add1` of the Steel branch on their own and
together, in any order. The virtual-text and overlay patches come with unit
tests; the picker patch is exercised through sap.hx.

| Patch | Steel API (in `helix/misc.scm`) | Used by |
| --- | --- | --- |
| `helix-virtual-text.patch` | `add-virtual-lines`, `add-line-highlight`, `remove-virtual-text`, `clear-virtual-text`: styled rows below a line (reserved in the layout, so the cursor and scrolling skip them; long rows wrap), whole-line highlights | [mokh.hx](https://github.com/vitaliikindrat/mokh.hx) (inline diff review), [sap.hx](https://github.com/vitaliikindrat/sap.hx) (git hunks) |
| `helix-overlays.patch` | `set-overlays!`, `set-inline-annotations!`, `clear-overlays!`: draw styled text over the grapheme at chosen positions (what jump labels use), or insert styled inline text (what inlay hints use); one layer per theme scope | [rings.hx](https://github.com/vitaliikindrat/rings.hx) (rainbow indentation) |
| `helix-picker.patch` | `custom-picker` (a global): Helix's own picker with rows a plugin chooses -- a label to show and filter on, a file to preview (highlighted by its extension), and a callback with the chosen row's index instead of opening a file | [sap.hx](https://github.com/vitaliikindrat/sap.hx) (changed files with their diffs) |

Everything is anchored by char index and follows edits; layout, soft wrap
and scrolling stay correct because the core does the positioning.

## Use

With Nix:

```nix
inputs.canopy = { url = "github:vitaliikindrat/canopy.hx"; flake = true; };

helix-steel.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ inputs.canopy.patchList;
})
```

`inputs.canopy.patches.virtual-text`, `.overlays` and `.picker` are there for
picking.

Without Nix: `git apply patches/*.patch` in a checkout of the Steel branch,
then build it as usual (`cargo xtask steel`).

## Upstream

These are meant to go upstream into the Steel branch; until then they are
carried here so the plugins that need them have one place to point at.

## License

MIT.
