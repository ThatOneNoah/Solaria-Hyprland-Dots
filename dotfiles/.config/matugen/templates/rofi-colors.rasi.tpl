* {
bg: {{ colors.surface.default.hex }};
bg-alt: {{ colors.surface_variant.default.hex }};
bg-hover: {{ colors.surface_variant.default.hex | lighten: 6.0 }};
surface: {{ colors.surface_container.default.hex }};
surface2: {{ colors.surface_container_high.default.hex }};
fg: {{ colors.on_surface.default.hex }};
fg-muted: {{ colors.outline.default.hex }};
muted: {{ colors.outline.default.hex }};
accent: {{ colors.primary.default.hex }};
accent-fg: {{ colors.on_primary.default.hex }};
border: {{ colors.outline.default.hex }};
}
