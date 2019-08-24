amf:	connector.amf divider.amf connector_border.amf divider_border.amf

stl:	connector.stl divider.stl connector_border.stl divider_border.stl

%.amf:	drawer_organizer.scad
	openscad -Dpart=\"$*\" -o $@ $<

%.stl:	drawer_organizer.scad
	openscad -Dpart=\"$*\" -o $@ $<
