font=Mojangles 11
anchor=top-right
layer=overlay
width=390
height=130
outer-margin=14
margin=8
padding=12,14
border-size=2
border-radius=16
icons=1
max-icon-size=42
icon-border-radius=10
markup=1
actions=1
history=1
max-visible=5
default-timeout=6500
format=<b>%s</b>\n%b

background-color={{ colors.surface_container.default.hex }}f2
text-color={{ colors.on_surface.default.hex }}
border-color={{ colors.primary.default.hex }}
progress-color=over {{ colors.primary.default.hex }}

[urgency=low]
border-color={{ colors.outline_variant.default.hex }}
default-timeout=3500

[urgency=normal]
border-color={{ colors.primary.default.hex }}

[urgency=high]
background-color={{ colors.error_container.default.hex }}f5
text-color={{ colors.on_error_container.default.hex }}
border-color={{ colors.error.default.hex }}
default-timeout=0

[mode=do-not-disturb]
invisible=1
on-notify=none

[mode=silent]
on-notify=none
