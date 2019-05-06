// global design parameters
height = 70;
width_bottom = 13;
width_top = 5;

border_overhang = 17;

gap = 0.15;
gap_top = 1;  // overhang needs bigger tolerances

$fa = 5;
$fs = 0.1;

// derived variables
radius_bottom = width_bottom/2;
radius_top = width_top/2;
height_linear = height-radius_top;
connector_length = 1.5*max(width_top, width_bottom);

showcase();
//printjob();

module showcase(space=40) {
    module line_up(space) {
       for (i = [0 : 1 : $children-1])
         translate([space[0]*i, space[1]*i, 0 ]) children(i);
    }
    line_up([space,0]) {
        divider_bend(distance=-20);
        divider_bend();
        divider_lowered();
        divider();
        connector_zero();
        connector_straight();
        line_up([0,-space]) {
            connector_t(round=true);
            connector_t(round=false);
        }
        line_up([0,-space]) {
            connector_x(round=true);
            connector_x(round=false);
        }
        line_up([0,-space]) {
            connector_corner(round=true);
            connector_corner(round=false);
        }
        group();
        divider(border=true);
        connector_zero(border=true);
        connector_straight(border=true);
        line_up([0,-space]) {
            connector_corner(round=true, border=true);
            connector_corner(round=false, border=true);
        }
        group();
        line_up([0,-space]) {
            connector_t(round=true, border=true);
            connector_t(round=false, border=true);
        }
    }
}

module printjob(space=45) {
    module line_up(space) {
       for (i = [0 : 1 : $children-1])
         translate([space[0]*i, space[1]*i, 0]) children(i);
    }
    line_up([space,0]) {
/*
        divider(length=50);
        divider(length=100+connector_length);
        divider(length=170-connector_length);
        connector_zero();
        connector_straight();
        connector_t();
        connector_x();
        connector_corner(round=true);
        divider(length=50, border=true);
        connector_zero(border=true);
        connector_straight(border=true);
        connector_corner(round=false, border=true);
        group();
        connector_t(border=true);
*/
/*
        divider(length=50);
        divider(length=77);
        divider(length=170-connector_length, border=true);
        divider(length=40, border=true);
        divider(length=100+connector_length, border=true);
        connector_straight(border=true);
        connector_corner(round=false, border=true);
        group();
        connector_t(border=true);
*/
/*
        connector_straight();
        divider(length=170-connector_length);
        divider(length=79);
        divider(length=112);
        connector_t();
        divider(length=79, border=true);
        connector_t(border=true);
*/
        divider(length=79);
        divider(length=50);  // 3x
        divider(length=150+2*connector_length); // 4x
        divider(length=150+2*connector_length, border=true); // 2x
        connector_t();  // 3x
        connector_x();
        group();
        connector_t(border=true); // 2x
    }
}

module profile_shape(border=false) {
    skew = border_overhang;
    multmatrix(m=[
        [1,border?skew/height:0,0,border?-skew:0],
        [0,1,0,0],
        [0,0,1,0],
        [0,0,0,1]]) {
        polygon([
            [-radius_bottom, 0],
            [border ? radius_top : radius_bottom, 0],
            [radius_top, height_linear],
            [-radius_top, height_linear]
        ]);
        translate([0, height_linear])
            circle(r=radius_top);
    }
}

module profile(length=150, border=false) {
    rotate([90,0,0])
        linear_extrude(height=length)
            profile_shape(border=border);
}

module profile_round(radius, angle=90, border=false) {
    border_overhang = border ? border_overhang : 0;
    translate([-radius-border_overhang,0]) {
        rotate_extrude(angle=angle) {
            translate([radius+border_overhang,0])
                profile_shape(border=border);
        }
    }
}

module profile_corner(round=false, border=false) {
    border_overhang = border ? border_overhang : 0;
    translate([0,0.5*connector_length,0])
        scale([-1,-1,1])
            profile_round(radius=0.5*connector_length, border=border);
    if (!round) {
        // add corner
        skew1 = border ? (radius_bottom-radius_top)/2 : 0;
        skew = skew1 + border_overhang;
        difference() {
            translate([0.5*connector_length+border_overhang,0.5*connector_length,0]) {
                scale([-1,-1,1]) {
                    size = 0.5*connector_length-skew1;
                    linear_extrude(height=height, scale=(size+skew)/size) {
                        square(size);
                    }
                }
            }
            radius_bottom2 = border ? (radius_bottom-radius_top)/2 : radius_bottom;
            translate([0.5*connector_length+border_overhang,0.5*connector_length,0]) {
                radius = 0.5*connector_length-skew1;
                linear_extrude(height=height, scale=(radius+skew)/radius) {
                    circle(r=radius);
                }
            }
        }
    }
}

module fitting(male=true, border=false) {
    // shrink male piece a little bit
    gap = male ? gap : 0;
    gap_top = male ? gap_top : 0;
    connector_length = radius_bottom;
    // For crazy people, that choose width_top > width_bottom. Otherwise pieces
    // cannot be sticked together. Such a design actually looks quite nice ;)
    radius_top = radius_top <= radius_bottom ? radius_top : radius_bottom;
    radius_top_gap = radius_top+(radius_bottom-radius_top)*gap_top/height_linear;
    skew = (radius_bottom-radius_top)/2 + border_overhang;
    radius_bottom = border ? (radius_top+radius_bottom)/2 : radius_bottom;
    multmatrix(m=[
        [1,0,border?skew/height:0,border?-skew:0],
        [0,1,0,0],
        [0,0,1,0],
        [0,0,0,1]]) {
        linear_extrude(height=height_linear-gap_top, scale=radius_top_gap/radius_bottom) {
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
}

module divider(length=100, border=false) {
    difference() {
        profile(length=length, border=border);
        scale([1,-1,1])
            fitting(male=false, border=border);
        translate([0,-length])
            fitting(male=false, border=border);
    }
}

module divider_lowered(length=100, lower=0.5, radius1=40, radius2=8) {
    assert(radius1 >= radius_top, "divider_lowered: radius1 must be greater than width_top/2!");
    assert(radius2 >= radius_top, "divider_lowered: radius2 must be greater than width_top/2!");

    height_lower = height_linear*lower;
    angle1 = height_lower > 2*radius1 ? 90 : acos(1-0.5*height_lower/radius1);
    length_round1 = sin(angle1)*radius1;
    height_round1 = (1-cos(angle1))*radius1;
    height_ortho1 = height_lower > 2*radius1 ? height_lower-2*radius1 : 0;
    angle2 = height_lower > 2*radius2 ? 90 : acos(1-0.5*height_lower/radius2);
    length_round2 = sin(angle2)*radius2;
    height_round2 = (1-cos(angle2))*radius2;
    height_ortho2 = height_lower > 2*radius2 ? height_lower-2*radius2 : 0;
    length_ortho = length - 2*(length_round1 + length_round2);
    assert(length_ortho >= 0, "divider_lowered: radius1+radius2 too big or length too small");

    module round_edge(radius, angle, length_round, height_round, height_ortho) {
        translate([0, 0, height_linear-radius])
            rotate([0,-90,180])
                rotate_extrude(angle=angle)
                    translate([radius, 0])
                        circle(r=radius_top);
        if (height_ortho > 0) {
            translate([0, -length_round, height-height_lower+height_round-radius_top])
                linear_extrude(height_ortho)
                    circle(r=radius_top);
        }
        translate([0, -2*length_round, height-height_lower+radius-radius_top])
            rotate([0,90,0])
                rotate_extrude(angle=angle)
                    translate([radius, 0])
                        circle(r=radius_top);
    }

    module spread() {
        angle = asin((radius_bottom - radius_top) / height_linear);
        z_correction = 1/cos(angle);
        translate([0, 0, height_linear])
            scale([1, 1, z_correction])
                rotate([0, angle, 0])
                    translate([0, 0, -height_linear])
                        children();
        translate([0, 0, height_linear])
            scale([1, 1, z_correction])
                rotate([0, -angle, 0])
                    translate([0, 0, -height_linear])
                        children();
    }

    module flat_profile(radius, length_round, height_round, height_ortho) {
        intersection() {
            translate([0, height-height_round-radius_top])
                square([length_round, height_round]);
            translate([0, height-radius-radius_top])
                circle(r=radius);
        }
        difference() {
            translate([length_round, height-height_lower-radius_top])
                square([length_round, height_round]);
            translate([2*length_round, height-height_lower-radius_top+radius]) {
                circle(r=radius);
            }
        }
        translate([0, height-height_lower-radius_top])
            square([length_round, height_round+height_ortho]);
    }

    module flat_cap(top=true) {
        max_radius = max(radius_top, radius_bottom);
        rotate([90,0,270]) {
            translate([0,0,-max_radius]) {
                linear_extrude(height=2*max_radius) {
                    offset(r=top?radius_top:0) {
                        union() {
                            square([length, height-height_lower-radius_top]);
                            flat_profile(radius1, length_round1, height_round1, height_ortho1);
                            translate([length, 0])
                                scale([-1, 1])
                                    flat_profile(radius2, length_round2, height_round2, height_ortho2);
                        }
                    }
                }
            }
        }
    }

    difference() {
        union() {
            // top round edge
            spread() {
                // radius1 round edge
                round_edge(radius1, angle1, length_round1, height_round1, height_ortho1);
                // center round edge
                if (length_ortho > 0) {
                    translate([0, -2*length_round1, height-height_lower-radius_top])
                        rotate([90, 0, 0])
                            linear_extrude(length_ortho)
                                circle(r=radius_top);
                }
                // radius2 round edge
                translate([0, -length, 0])
                    rotate([0,0,180])
                        round_edge(radius2, angle2, length_round2, height_round2, height_ortho2);
            }

            // flat top
            intersection() {
                flat_cap(top=true);
                rotate([90, 0, 0]) {
                    linear_extrude(height=length) {
                        polygon([
                            [-max(0,(radius_bottom-radius_top)), 0],
                            [max(0,(radius_bottom-radius_top)), 0],
                            [0, height]
                        ]);
                    }
                }
            }

            // body
            intersection() {
                profile(length);
                flat_cap(top=false);
            }
        }
        rotate([0,0,180])
            fitting(male=false);
        translate([0,-length])
            fitting(male=false);
    }
}

module divider_bend(length=100, distance=20, radius=50) {
    // more helpful error message for rotate_extrude() error in profile_round()
    assert(radius >= radius_bottom, str("divider_bend: radius (", radius, ") too small, must be >= ", radius_bottom));
    angle = (abs(distance) >= 2*radius ? 90 : acos(1-0.5*abs(distance)/radius))*sign(distance);
    length_ortho = abs(distance) >= 2*radius ? abs(distance)-2*radius : 0;
    length_round = abs(distance) >= 2*radius ? radius : abs(sin(angle))*radius;
    length_start = 0.5*(length-2*length_round);
    assert(length >= 2*length_round, "divider_bend: length too short or radius too big");
    difference() {
        union() {
            if (length_start > 0) {
                profile(length_start);
                translate([distance,length_start-length])
                    profile(length_start);
            }
            translate([0,-length_start])
                rotate([0,0,180])
                    profile_round(radius=radius*sign(angle), angle=angle);
            translate([distance, length_start-length])
                profile_round(radius=radius*sign(angle), angle=angle);
            if (length_ortho > 0) {
                translate([angle>0?radius:-length_ortho-radius,-0.5*length])
                    rotate([0,0,90])
                        profile(length_ortho);
            }
        }
        rotate([0,0,180])
            fitting(male=false);
        translate([distance,-length])
            fitting(male=false);
    }
}

module connector_zero(border=false) {
    union() {
        fitting(male=true, border=border);
        scale([1,-1,1])
            fitting(male=true, border=border);
    }
}

module connector_straight(border=false) {
    translate([0,0.5*connector_length,0]) {
        union() {
            profile(length=connector_length, border=border);
            fitting(male=true, border=border);
            translate([0,-connector_length,0])
                scale([1,-1,1])
                    fitting(male=true, border=border);
        }
    }
}

module connector_x(round=true) {
    union() {
        for (r=[0, 90, 180, 270]) {
            rotate([0,0,r]) {
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
                if (round) {
                    profile_corner();
                } else {
                    translate([0,0.5*connector_length,0])
                        profile(0.5*connector_length);
                }
            }
        }
    }
}

module connector_t_normal(round=true) {
    union() {
        for (r=[0, 90, 180]) {
            rotate([0,0,r])
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
        }
        if (round) {
            for (r=[90, 180]) {
                rotate([0,0,r])
                    profile_corner();
            }
        } else {
            rotate([0,0,270])
                profile(0.5*connector_length);
        }
        translate([0,0.5*connector_length,0])
            profile(connector_length);
    }
}

module connector_t_border(round=true) {
    connector_straight(border=true);
    rotate([0,0,90]) {
        translate([0,0.5*connector_length+border_overhang,0]) {
            fitting(male=true);
            intersection() {
                profile(connector_length+border_overhang);
                skew = border_overhang;
                max_radius = max(radius_top,radius_bottom);
                multmatrix(m=[
                    [1,0,0,-max_radius],
                    [0,1,-skew/height,-0.5*connector_length],
                    [0,0,1,0],
                    [0,0,0,1]]) {
                    cube([2*max_radius,connector_length+skew,height]);
                }
            }
        }
    }
    if (round) {
        skew = border_overhang;
        multmatrix(m=[
            [1,0,skew/height,-border_overhang],
            [0,1,0,0],
            [0,0,1,0],
            [0,0,0,1]]) {
            difference() {
                for (r=[90, 180]) {
                    rotate([0,0,r]) {
                        profile_corner(round=false, border=false);
                    }
                }
                translate([radius_top,-0.5*connector_length,0])
                    cube([radius_bottom,connector_length,height]);
            }
        }
    }
}

module connector_t(round=true, border=false) {
    if (border)
        connector_t_border(round=round);
    else
        connector_t_normal(round=round);
}

module connector_corner_normal(round=true) {
    border=false;
    union() {
        profile_corner(round=round, border=border);

        scale([-1,1,1]) {
            translate([0,0.5*connector_length,0]) {
                fitting(male=true, border=border);
                if (!round)
                    profile(length=0.5*connector_length, border=border);
            }
        }
        translate([0.5*connector_length,0,0]) {
            rotate([0,0,270]) {
                fitting(male=true, border=border);
                if (!round)
                    profile(length=0.5*connector_length, border=border);
            }
        }

        if (!round) {
            rotate([0,0,180]) {
                rotate_extrude(angle=90) {
                    intersection() {
                        profile_shape(border=border);
                        square([max(radius_bottom, radius_top), height]);
                    }
                }
            }
        }
    }
}

module connector_corner_border(round=true) {
    border = true;

    module side_wall() {
        intersection() {
            profile(length=0.5*connector_length+border_overhang, border=border);
            skew = border_overhang;
            translate([-(0.5*connector_length+border_overhang)+radius_bottom,0,0]) {
                scale([1,-1,1]) {
                    size = 0.5*connector_length;
                    linear_extrude(height=height, scale=(size+skew)/size) {
                        square(size);
                    }
                }
            }
        }
    }

    union() {
        profile_corner(round=round, border=border);

        scale([-1,1,1]) {
            translate([0,0.5*connector_length,0]) {
                fitting(male=true, border=border);
                if (!round) {
                    side_wall();
                }
            }
        }
        translate([0.5*connector_length+border_overhang,-border_overhang,0]) {
            rotate([0,0,270]) {
                fitting(male=true, border=border);
                if (!round) {
                    side_wall();
                }
            }
        }

        if (!round) {
            skew = border_overhang;
            multmatrix(m=[
                [1,0,-skew/height,skew],
                [0,1,-skew/height,0],
                [0,0,1,0],
                [0,0,0,1]]) {
                rotate([0,0,180]) {
                    rotate_extrude(angle=90) {
                        union() {
                            square([radius_top, height_linear]);
                            translate([0,height_linear]) {
                                intersection() {
                                    circle(r=radius_top);
                                    square(radius_top);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module connector_corner(round=true, border=false) {
    if (border)
        connector_corner_border(round=round);
    else
        connector_corner_normal(round=round);
}
