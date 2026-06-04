/**
 * @name midnight-matugen
 * @description Midnight Discord theme + wallpaper colors from matugen
 * @author you
 * @version 1.0.0
 */

@import url('https://refact0r.github.io/midnight-discord/build/midnight.css');

body {
    --font: 'figtree';
    --gap: 12px;
    --divider-thickness: 4px;
    --animations: on;
    --custom-window-controls: on;
    --window-control-size: 14px;
    --small-user-panel: off;
}

:root {
    --colors: on;

    --text-0: {{ colors.surface.default.hex }};
    --text-1: {{ colors.on_surface.default.hex }};
    --text-2: {{ colors.on_surface_variant.default.hex }};
    --text-3: {{ colors.outline.default.hex }};
    --text-4: {{ colors.outline_variant.default.hex }};
    --text-5: {{ colors.outline.default.hex }};

    --bg-1: {{ colors.surface_variant.default.hex }};
    --bg-2: {{ colors.surface_variant.default.hex | lighten: -4.0 }};
    --bg-3: {{ colors.surface.default.hex }};
    --bg-4: {{ colors.background.default.hex }};

    --hover: color-mix(in srgb, {{ colors.primary.default.hex }} 12%, transparent);
    --active: color-mix(in srgb, {{ colors.primary.default.hex }} 20%, transparent);
    --active-2: color-mix(in srgb, {{ colors.primary.default.hex }} 30%, transparent);

    --accent-1: {{ colors.primary.default.hex }};
    --accent-2: {{ colors.secondary.default.hex }};
    --accent-3: {{ colors.tertiary.default.hex }};
    --accent-4: {{ colors.secondary.default.hex }};
    --accent-5: {{ colors.primary.default.hex }};
    --accent-new: {{ colors.error.default.hex }};

    --online: #43a25a;
    --dnd: {{ colors.error.default.hex }};
    --idle: #ca9654;
    --streaming: #7a5bd6;
    --offline: {{ colors.outline_variant.default.hex }};

    --border-light: color-mix(in srgb, {{ colors.outline.default.hex }} 25%, transparent);
    --border: color-mix(in srgb, {{ colors.outline.default.hex }} 45%, transparent);
    --button-border: color-mix(in srgb, {{ colors.on_surface.default.hex }} 12%, transparent);

    --red-1: {{ colors.error.default.hex | lighten: 10.0 }};
    --red-2: {{ colors.error.default.hex }};
    --red-3: {{ colors.error.default.hex | lighten: -8.0 }};
    --red-4: {{ colors.error.default.hex | lighten: -14.0 }};
    --red-5: {{ colors.error.default.hex | lighten: -20.0 }};

    --green-1: #5fc978;
    --green-2: #43a25a;
    --green-3: #3b8f4f;
    --green-4: #327a43;
    --green-5: #296638;

    --blue-1: {{ colors.primary.default.hex | lighten: 10.0 }};
    --blue-2: {{ colors.primary.default.hex }};
    --blue-3: {{ colors.primary.default.hex | lighten: -8.0 }};
    --blue-4: {{ colors.primary.default.hex | lighten: -14.0 }};
    --blue-5: {{ colors.primary.default.hex | lighten: -20.0 }};

    --yellow-1: #e6b86a;
    --yellow-2: #ca9654;
    --yellow-3: #b68447;
    --yellow-4: #9f733d;
    --yellow-5: #896333;

    --purple-1: {{ colors.tertiary.default.hex | lighten: 10.0 }};
    --purple-2: {{ colors.tertiary.default.hex }};
    --purple-3: {{ colors.tertiary.default.hex | lighten: -8.0 }};
    --purple-4: {{ colors.tertiary.default.hex | lighten: -14.0 }};
    --purple-5: {{ colors.tertiary.default.hex | lighten: -20.0 }};
}
