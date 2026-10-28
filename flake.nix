{
  description = "canopy.hx: generic Steel plugin APIs for Helix, as patches to the Steel branch";

  outputs =
    { self }:
    {
      # Each is against mattwparas/helix `steel-event-system` at 424add1 and
      # adds a plugin API, never a feature. They apply on their own and
      # together, in either order.
      patches = {
        # add-virtual-lines / add-line-highlight / remove-virtual-text /
        # clear-virtual-text: styled rows below a line, whole-line highlights.
        virtual-text = ./patches/helix-virtual-text.patch;
        # set-overlays! / set-inline-annotations! / clear-overlays!: styled
        # graphemes over text positions, styled inline virtual text.
        overlays = ./patches/helix-overlays.patch;
        # custom-picker: Helix's picker with plugin-chosen rows, a preview file
        # per row and a callback on choice.
        picker = ./patches/helix-picker.patch;
      };

      # All of them, for a Steel helix derivation:
      #   helix.overrideAttrs (old: { patches = (old.patches or [ ]) ++ canopy.patchList; })
      patchList = [
        self.patches.virtual-text
        self.patches.overlays
        self.patches.picker
      ];
    };
}
