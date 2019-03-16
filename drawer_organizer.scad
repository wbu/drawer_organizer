height = 60;
width_bottom = 13;
width_top = 5;

gap = 0.15;
gap_top = 1;  // overhang needs bigger tolerances

$fa = 5;
$fs = 0.1;

// derived variables
radius_bottom = width_bottom/2;
radius_top = width_top/2;
height_linear = height-radius_top;
connector_length = 2*width_bottom;

divider();
translate([40,0,0])
    connector_straight();
translate([80,0,0])
    connector_t();
translate([120,0,0])
    connector_x();
translate([160,0,0])
    connector_corner();

module profile(length=150) {
    rotate([90,0,0]) {
        linear_extrude(height=length) {
            polygon([
                [-radius_bottom, 0],
                [radius_bottom, 0],
                [radius_top, height_linear],
                [-radius_top, height_linear]
            ]);
            translate([0, height_linear])
                circle(r=radius_top);
        }
    }
}

module profile_corner(round=false) {
    // bottom part
    difference() {
        if (round) {
            intersection() {
                translate([-0.5*connector_length, -0.5*connector_length])
                    cube([connector_length, connector_length, height_linear]);
                translate([0.5*connector_length, 0.5*connector_length]) {
                    rotate_extrude() {
                        polygon([
                            [0, 0],
                            [0.5*connector_length+radius_bottom, 0],
                            [0.5*connector_length+radius_top, height_linear],
                            [0, height_linear]
                        ]);
                    }
                }
            }
        } else {
            cube([0.5*connector_length, 0.5*connector_length, height_linear]);
        }
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                polygon([
                    [0, 0],
                    [0.5*connector_length-radius_bottom, 0],
                    [0.5*connector_length-radius_top, height_linear],
                    [0, height_linear]
                ]);
            }
        }
    }
    // top round part
    intersection() {
        translate([0, 0, height_linear]) {
            if (round) {
                translate([-0.5*connector_length, -0.5*connector_length])
                    cube([connector_length, connector_length, radius_top]);
            } else {
                cube([0.5*connector_length, 0.5*connector_length, radius_top]);
            }
        }
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                translate([0.5*connector_length, height_linear])
                    circle(r=radius_top);
            }
        }
    }
    // top flat part
    if (!round) {
        difference() {
            translate([0, 0, height_linear])
                cube([0.5*connector_length, 0.5*connector_length, radius_top]);
            translate([0.5*connector_length, 0.5*connector_length, height_linear])
                cylinder(h=radius_top, r=0.5*connector_length);
        }
    }
}


module fitting(male=true) {
    // shrink male piece a little bit
    gap = male ? gap : 0;
    gap_top = male ? gap_top : 0;
    connector_length = radius_bottom;
    radius_top_corrected = radius_top+(radius_bottom-radius_top)*gap_top/height_linear;
    linear_extrude(height=height_linear-gap_top, scale=radius_top_corrected/radius_bottom) {
        polygon([
            [-0.3*radius_bottom+gap, 0],
            [0.3*radius_bottom-gap, 0],
            [0.5*radius_bottom-gap, connector_length],
            [-0.5*radius_bottom+gap, connector_length]
        ]);
        translate([0,connector_length]) {
            circle(r=0.6*radius_bottom-gap);
            // add "air channel" for female piece
            if (!male)
                translate([-0.1*radius_bottom,0])
                    square([0.2*radius_bottom, radius_bottom]);
        }
    }
}

module divider(length=100) {
    difference() {
        profile(length);
        rotate([0,0,180])
            fitting(male=false);
        translate([0,-length,0])
            fitting(male=false);
    }
}

module connector_straight() {
    translate([0,0.5*connector_length,0]) {
        union() {
            profile(connector_length);
            fitting(male=true);
            translate([0,-connector_length,0])
                rotate([0,0,180])
                    fitting(male=true);
        }
    }
}

module connector_x() {
    union() {
        for (r=[0, 90, 180, 270]) {
            rotate([0,0,r]) {
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
                profile_corner();
            }
        }
    }
}

module connector_t() {
    union() {
        for (r=[0, 90, 180]) {
            rotate([0,0,r])
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
        }
        for (r=[90, 180]) {
            rotate([0,0,r])
                profile_corner();
        }
        translate([0,0.5*connector_length,0])
            profile(connector_length);
    }
}

module connector_corner() {
    union() {
        profile_corner(round=true);
        for (r=[0,270]) {
            rotate([0,0,r])
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
        }
    }
}
