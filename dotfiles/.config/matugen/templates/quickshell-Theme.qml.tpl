import QtQml

QtObject {
    property string bgBar: "{{ colors.surface.default.hex }}"
    property string bgBarAlt: "{{ colors.surface_container.default.hex }}"
    property string bgPanel: "{{ colors.surface_variant.default.hex }}"
    property string bgPanelHigh: "{{ colors.surface_container_high.default.hex }}"
    property string bgHover: "{{ colors.surface_variant.default.hex | lighten: 6.0 }}"
    property string bgActive: "{{ colors.primary.default.hex }}"
    property string bgActiveSoft: "{{ colors.primary_container.default.hex }}"
    property string fg: "{{ colors.on_surface.default.hex }}"
    property string fgMuted: "{{ colors.outline.default.hex }}"
    property string fgOnAccent: "{{ colors.on_primary.default.hex }}"
    property string fgOnPanel: "{{ colors.on_surface_variant.default.hex }}"
    property string danger: "{{ colors.error.default.hex }}"
    property string dangerSoft: "{{ colors.error_container.default.hex }}"
    property string secondary: "{{ colors.secondary.default.hex }}"
    property string tertiary: "{{ colors.tertiary.default.hex }}"
    property string border: "{{ colors.outline.default.hex }}"
    property string borderSoft: "{{ colors.outline_variant.default.hex }}"
}
